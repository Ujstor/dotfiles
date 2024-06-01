## Docker

sudo chmod 666 /var/run/docker.sock

sudo nano /etc/systemd/system/docker-sock-permissions.service
sudo systemctl daemon-reload
sudo systemctl enable docker-sock-permissions.service



