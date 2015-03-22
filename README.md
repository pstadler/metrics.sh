# metrics.sh

metrics.sh is a lightweight metrics collection and fowarding utility implemented in portable POSIX compliant shell scripts. A transparent interface based on hooks enables writing custom metric collectors and reporters in an elegant way.

## Usage

```
$ ./metrics.sh --help

  Usage: ./metrics.sh [-d] [-h] [-v] [-c] [-m] [-r] [-i]

  Options:

    -c, --config   <file>      path to config file
    -m, --metrics  <metrics>   comma-separated list of metrics to collect
    -r, --reporter <reporter>  use specified reporter (default: stdout)
    -i, --interval <seconds>   collect metrics every n seconds (default: 2)
    -v, --verbose              enable verbose mode
    -d, --docs                 show documentation
    -h, --help                 show this text
```

## Installation

```bash
$ git clone git@github.com:pstadler/metrics.sh.git
```

### Requirements

metrics.sh has been tested on Ubuntu 14.04 and Mac OS X but is supposed to run on most *NIX-like operating systems. Some of the provided metrics require [procfs](http://en.wikipedia.org/wiki/Procfs) to be available.

## Metrics

Metric          | Description
--------------- | -------------
`cpu`           | CPU usage in %
`memory`        | Memory usage in %
`swap`          | Swap usage in %
`network_io`    | Network I/O in kB/s, collecting two metrics: `network_io.in` and `network_io.out`
`disk_io`       | Disk I/O in MB/s
`disk_usage`    | Disk usage in %
`heartbeat`     | System heartbeat
`ping`          | Check whether a remote host is reachable

## Reporters

Reporter        | Description
--------------- | -------------
`stdout`        | Write to standard out (default)
`file`          | Write to a file or named pipe
`influxdb`      | Send data to [InfluxDB](http://influxdb.com/)
`keen_io`       | Send data to [Keen IO](https://keen.io)
`stathat`       | Send data to [StatHat](https://www.stathat.com)

## Configuration

A first step of configuration can be done by passing options to metrics.sh:

```
$ ./metrics.sh --help
...
$ ./metrics.sh -m cpu,memory -i 1
# reports cpu and memory every second
```

Some of the metrics and reporters are configurable. Documentation is available from within metrics.sh and can be printed with `--docs`:

```
$ ./metrics.sh --docs | less
```

For example, the `disk_usage` metric has a configuration variable `DISK_USAGE_MOUNTPOINT` which set to a default depending on the operating system metrics.sh is running on. Setting the variable before starting will overwrite it:

```
$ DISK_USAGE_MOUNTPOINT=/dev/vdb ./metrics.sh -m disk_usage
# reports disk usage of /dev/vdb
```

### Configuration file

As maintaing all these options can become a cumbersome job, metrics.sh has support for configuration files.

```
$ ./metrics.sh -C > metrics.ini  # write configuration to metrics.ini
$ ./metrics.sh -c metrics.ini    # load configuration from metrics.ini
```

By default most lines in the configuration are commented out:

```ini
;[metric network_io]
;Network traffic in kB/s.
;NETWORK_IO_INTERFACE=eth0
```

To enable a metric, simply remove the comments and modify values where needed:

```ini
[metric network_io]
;Network traffic in kB/s.
NETWORK_IO_INTERFACE=eth1
```

### Multiple metrics of the same type

Configuring and reporting multiple metrics of the same type is possible through the use of aliases:

```ini
[metric network_io:network_eth0]
NETWORK_IO_INTERFACE=eth0

[metric network_io:network_eth1]
NETWORK_IO_INTERFACE=eth1
```

`network_eth0` and `network_eth1` are aliases of the `network_io` metric with specific configurations. Data of both network interfaces will now be collected and reported independently:

```
network_eth0.in: 0.26
network_eth0.out: 0.14
network_eth1.in: 0.08
network_eth1.out: 0.03
...
```

### Daemonize / init.d/ upstart

TODO

## Writing custom metrics / reporters

TODO