# Running metrics.sh as a service on Linux

Run the following commands as root:

```sh
# Install metrics.sh at /opt/metrics.sh
$ mkdir /opt; cd /opt
$ git clone https://github.com/pstadler/metrics.sh.git
$ cd metrics.sh
# Install the service
$ ln -s $PWD/init.d/metrics.sh /etc/init.d/metrics.sh
# Create a config file
$ mkdir /etc/metrics.sh && chmod 600 /etc/metrics.sh
$ ./metrics.sh -C > /etc/metrics.sh/metrics.ini
# At this point you should edit your config file at
# /etc/metrics.sh/metrics.ini

# Start service
$ service metrics.sh start

# If run with the default configuration where reporter is 'stdout', metrics
# will be written to /var/log/metrics.sh.log. Be aware that this file will
# grow fast.
$ tail -f /var/log/metrics.sh.log

# Stop service
$ service metrics.sh stop

# Check service status
$ service metrics.sh status

# Automatically start service when booting and stop when shutting down
$ update-rc.d metrics.sh defaults

# Disable automatic starting/stopping
$ update-rc.d -f metrics.sh remove
```
