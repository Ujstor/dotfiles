#!/bin/bash
# sudo apt install xdotool
# Get screen dimensions

# Delay to ensure the environment is ready

# Full paths to commands
XDOTOOL="/usr/bin/xdotool"
XRANDR="/usr/bin/xrandr"

# Get screen dimensions
screen_info=$($XRANDR | grep 'Screen 0')
screen_width=$(echo $screen_info | awk '{print $8}')
screen_height=$(echo $screen_info | awk '{print $10}' | sed 's/,//')

# Get the width of each monitor
monitor_info=$($XRANDR | grep ' connected' | awk '{print $3}')
monitor_widths=($(echo "$monitor_info" | cut -d '+' -f 1 | cut -d 'x' -f 1))

# Calculate cumulative widths
cumulative_widths=()
sum=0
for width in "${monitor_widths[@]}"; do
  sum=$((sum + width))
  cumulative_widths+=($sum)
done

# Function to get the cumulative width of the previous monitors
get_cumulative_width() {
  local idx=$1
  if [ $idx -eq 0 ]; then
    echo 0
  else
    echo ${cumulative_widths[$((idx-1))]}
  fi
}

# Infinite mouse loop
while true; do
  eval $($XDOTOOL getmouselocation --shell)
  
  # Wrap horizontally
  if [ -n "$X" ] && [ -n "$Y" ]; then
    if [ $X -le 0 ]; then
      $XDOTOOL mousemove $((screen_width - 1)) $Y
    elif [ $X -ge $((screen_width - 1)) ]; then
      $XDOTOOL mousemove 1 $Y
    else
      # Check monitor boundaries
      for i in "${!cumulative_widths[@]}"; do
        prev_cum_width=$(get_cumulative_width $i)
        if [ $X -le ${cumulative_widths[$i]} ] && [ $X -gt $prev_cum_width ]; then
          if [ $X -le $prev_cum_width ]; then
            $XDOTOOL mousemove ${cumulative_widths[$i]} $Y
          elif [ $X -ge ${cumulative_widths[$i]} ]; then
            $XDOTOOL mousemove $prev_cum_width $Y
          fi
        fi
      done
    fi
  fi

  # Optional: Wrap vertically
  # if [ $Y -le 0 ]; then
  #   $XDOTOOL mousemove $X $((screen_height - 1))
  # elif [ $Y -ge $((screen_height - 1)) ]; then
  #   $XDOTOOL mousemove $X 1
  # fi

  # Sleep for a short duration to prevent high CPU usage
  sleep 0.01
done
