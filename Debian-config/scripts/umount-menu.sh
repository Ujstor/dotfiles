!/bin/bash

# NAME: umount-menu.sh
# PATH: /usr/local/bin
# DESC: Select mounted partition for unmounting
# DATE: May 10, 2018. Modified May 11, 2018.
# sudo chmod a+x /usr/local/bin/umount-menu.sh

# $TERM variable may be missing when called via desktop shortcut
CurrentTERM=$(env | grep TERM)
if [[ $CurrentTERM == "" ]] ; then
    notify-send --urgency=critical \ 
                "$0 cannot be run from GUI without TERM environment variable."
    exit 1
fi

# Must run as root
if [[ $(id -u) -ne 0 ]] ; then echo "Usage: sudo $0" ; exit 1 ; fi

#
# Create unqique temporary file names
#

tmpMenu=$(mktemp /mnt/mount-menu.XXXXX)   # Menu list

#
# Function Cleanup () Removes temporary files
#

CleanUp () {
    [[ -f "$tmpMenu" ]] && rm -f "$tmpMenu" #  at various program stages
}


#
# Mainline
#

lsblk -o NAME,FSTYPE,LABEL,SIZE,MOUNTPOINT > "$tmpMenu"

i=0
SPACES='                                                                     '
DoHeading=true
AllPartsArr=()      # All partitions.

# Build whiptail menu tags ($i) and text ($Line) into array

while read -r Line; do
    if [[ $DoHeading == true ]] ; then
        DoHeading=false                     # First line is the heading.
        MenuText="$Line"                    # Heading for whiptail.
        MOUNTPOINT_col="${Line%%MOUNTPOINT*}"
        MOUNTPOINT_col="${#MOUNTPOINT_col}" # Required to ensure mounted.
        continue
    fi

    Line="$Line$SPACES"                     # Pad extra white space.
    Line=${Line:0:74}                       # Truncate to 74 chars for menu.

    AllPartsArr+=($i "$Line")               # Menu array entry = Tag# + Text.
    (( i++ ))

done < "$tmpMenu"                           # Read next "lsblk" line.

#
# Display whiptail menu in while loop until no errors, or escape,
# or valid partion selection .
#

DefaultItem=0

while true ; do

    # Call whiptail in loop to paint menu and get user selection
    Choice=$(whiptail \
        --title "Use arrow, page, home & end keys. Tab toggle option" \
        --backtitle "Mount Partition" \
        --ok-button "Select unmounted partition" \
        --cancel-button "Exit" \
        --notags \
        --default-item "$DefaultItem" \
        --menu "$MenuText" 24 80 16 \
        "${AllPartsArr[@]}" \
        2>&1 >/dev/tty)

    clear                                   # Clear screen.

    if [[ $Choice == "" ]]; then            # Escape or dialog "Exit".
        CleanUp
        exit 1;
     fi

    DefaultItem=$Choice                     # whiptail start option.
    ArrNdx=$(( $Choice * 2 + 1))            # Calculate array offset.
    Line="${AllPartsArr[$ArrNdx]}"          # Array entry into $Line.

    if [[ "${Line:MOUNTPOINT_col:15}" != "/mnt/mount-menu" ]] ; then
        echo "Only Partitions mounted by mount-menu.sh can be unounted."
        read -p "Press <Enter> to continue"
        continue
    fi

    # Build "/dev/Xxxxx" FS name from "├─Xxxxx" menu line
    MountDev="${Line%% *}"
    MountDev=/dev/"${MountDev:2:999}"

    # Build Mount Name
    MountName="${Line:MOUNTPOINT_col:999}"
    MountName="${MountName%% *}"

    break                                   # Validated: Break menu loop.

done                                        # Loop while errors.

#
# Unmount partition
#

echo ""
echo "====================================================================="
umount "$MountName" -l                      # Unmount the clone
rm  -d "$MountName"                         # Remove clone directory

echo $(tput bold)                           # Set to bold text
echo $MountDev mounted on $MountName unmounted.
echo $(tput sgr0)                           # Reset to normal text

CleanUp                                     # Remove temporary files

exit 0
