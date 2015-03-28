# Running metrics.sh as a service on Linux

Run the following commands as root:

```sh
# Install at /opt/metrics.sh
$ mkdir /opt && cd /opt
$ git clone https://github.com/pstadler/metrics.sh.git
$ cd metrics.sh
# Install service
$ ln -s $PWD/init.d/metrics.sh /etc/init.d/metrics.sh
# Create config file
$ mkdir /etc/metrics.sh && chmod 600 /etc/metrics.sh
$ ./metrics.sh -C > /etc/metrics.sh/metrics.ini
# At this point you should edit your config file
# at /etc/metrics.sh/metrics.ini

# Start service
$ service metrics.sh start
# Stop service
$ service metrics.sh stop
# Check servie status
$ service metrics.sh status

# Check log file
$ tail /var/log/metrics.sh.log

# Automatically start/stop service when (re-)booting
$ update-rc.d metrics.sh defaults

# Uninstall automatic start/stop
$ update-rc.d -f metrics.sh remove
```
