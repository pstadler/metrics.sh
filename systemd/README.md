# Running metrics.sh as a systemd service on Linux

Run the following commands as root:

```sh
# Install metrics.sh at /opt/metrics.sh
$ mkdir /opt; cd /opt
$ git clone https://github.com/pstadler/metrics.sh.git
$ cd metrics.sh
# Install the service
$ cp -p $PWD/systemd/metrics.sh.service /etc/systemd/system/metrics.sh.service
$ chmod 664 /etc/systemd/system/metrics.sh.service
# Create a config file
$ mkdir /etc/metrics.sh && chmod 600 /etc/metrics.sh
$ ./metrics.sh -C > /etc/metrics.sh/metrics.ini
# At this point you should edit your config file at
# /etc/metrics.sh/metrics.ini

# Reload systemd daemon
$ systemctl daemon-reload

# Start service
$ systemctl start metrics.sh.service

# If run with the default configuration where reporter is 'stdout', metrics
# will be written to /var/log/metrics.sh.log. Be aware that this file will
# grow fast.
$ tail -f /var/log/metrics.sh.log

# Stop service
$ systemctl stop metrics.sh.service

# Check service status
$ systemctl status metrics.sh.service

# Automatically start service when booting and stop when shutting down
$ systemctl enable metrics.sh.service

# Disable automatic starting/stopping
$ systemctl disable metrics.sh.service
```
