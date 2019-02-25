![metrics.sh](https://raw.githubusercontent.com/pstadler/metrics.sh/assets/logo.png)

metrics.sh is a lightweight metrics collection and forwarding daemon implemented in portable POSIX compliant shell scripts. A transparent interface based on hooks enables writing custom collectors and reporters in an elegant way.

**Project philosophy**

  - Flat learning curve
  - Easily extensible
  - Low impact on system resources
  - No compilation, custom interpreters and runtimes required
  - Freedom to choose any service for storage, charting and alerting
  - Open source, no proprietary parts
  - Community-driven development, growing number of included metrics over time

## Usage

```
$ ./metrics.sh --help

  Usage: ./metrics.sh [-d] [-h] [-v] [-c] [-m] [-r] [-i] [-C] [-u]

  Options:

    -c, --config   <file>      path to config file
    -m, --metrics  <metrics>   comma-separated list of metrics to collect
    -r, --reporter <reporter>  use specified reporter (default: stdout)
    -i, --interval <seconds>   collect metrics every n seconds (default: 2)
    -v, --verbose              enable verbose mode
    -C, --print-config         print output to be used in a config file
    -u, --update               pull the latest version (requires git)
    -d, --docs                 show documentation
    -h, --help                 show this text
```

## Installation

```sh
$ git clone https://github.com/pstadler/metrics.sh.git
```

See this [guide](init.d/README.md) how to run metrics.sh as a service on Linux.
Or [here](systemd/README.md) for instructions to set metrics.sh up for systemd.

### Requirements

metrics.sh has been tested on Ubuntu 14.04 and Mac OS X but is supposed to run on most Unix-like operating systems. Some of the provided metrics require [procfs](http://en.wikipedia.org/wiki/Procfs) to be available when running on *nix. POSIX compliancy means that metrics.sh works with minimalistic command interpreters such as [dash](http://manpages.ubuntu.com/manpages/en/man1/dash.1.html). Built-in metrics do __not__ require root privileges.

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

Reporter         | Description
---------------- | -------------
`stdout`         | Write to standard out (default)
`file`           | Write to a file or named pipe
`udp`            | Send data to any service via UDP
`statsd`         | Send data to [StatsD](https://github.com/etsy/statsd)
`influxdb`       | Send data to [InfluxDB](http://influxdb.com/)
`prometheus`     | Provide HTTP endpoint for [Prometheus](http://prometheus.io/)
`keen_io`        | Send data to [Keen IO](https://keen.io)
`stathat`        | Send data to [StatHat](https://www.stathat.com)
`logentries_com` | Send data to [Logentries](https://logentries.com/)

## Configuration

metrics.sh can be configured on the fly by passing along options when calling it:

```sh
$ ./metrics.sh --help              # print help
$ ./metrics.sh -m cpu,memory -i 1  # report cpu and memory usage every second
```

Some of the metrics and reporters are configurable or require some variables to be defined in order to work. Documentation is available with the `--docs` option.

```sh
$ ./metrics.sh --docs | less
```

As an example, the `disk_usage` metric has a configuration variable `DISK_USAGE_MOUNTPOINT` which is set to a default value depending on the operating system metrics.sh is running on. Setting the variable before starting will overwrite it.

```sh
$ DISK_USAGE_MOUNTPOINT=/dev/vdb ./metrics.sh -m disk_usage
# reports disk usage of /dev/vdb
```

### Configuration files

Maintaining all these options can become a cumbersome job, but metrics.sh provides functionality for creating and reading configuration files.

```sh
$ ./metrics.sh -C > metrics.ini  # write configuration to metrics.ini
$ ./metrics.sh -c metrics.ini    # load configuration from metrics.ini
```

By default most lines in the configuration are commented out:

```ini
;[metric network_io]
;Network traffic in kB/s.
;NETWORK_IO_INTERFACE=eth0
```

To enable a metric, simply remove comments and modify values where needed:

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

`network_eth0` and `network_eth1` are aliases of the `network_io` metric with specific configurations for each of them. Data of both network interfaces will now be collected and reported independently:

```
network_eth0.in: 0.26
network_eth0.out: 0.14
network_eth1.in: 0.08
network_eth1.out: 0.03
...
```

## Writing custom metrics and reporters

metrics.sh provides a simple interface based on hooks for writing custom metrics and reporters. Each hook is optional and only needs to be implemented if necessary. In order for metrics.sh to find and load custom metrics, they have to be placed in `./metrics/custom` or wherever `CUSTOM_METRICS_PATH` is pointing to. The same applies to custom reporters, whose default location is `./reporters/custom` or any folder specified by `CUSTOM_REPORTERS_PATH`.

### Custom metrics

```sh
# Hooks for metrics in order of execution
defaults () {}  # setting default variables
start () {}     # called at the beginning
collect () {}   # collect the actual metric
stop () {}      # called before exiting
docs () {}      # used for printing docs and creating output for configuration
```

Metrics run within an isolated scope. It's generally safe to create variables and helper functions within metrics.

Below is an example script for monitoring the size of a specified folder. Assuming this script is located at `./metrics/custom/dir_size.sh`, it can be invoked by calling `./metrics.sh -m dir_size`.

```sh
#!/bin/sh

# Set default values. This function should never fail.
defaults () {
  if [ -z $DIR_SIZE_PATH ]; then
    DIR_SIZE_PATH="."
  fi
  if [ -z $DIR_SIZE_IN_MB ]; then
    DIR_SIZE_IN_MB=false
  fi
}

# Prepare the collector. Create helper functions to be used during collection
# if needed. Returning 1 will disable this metric and report a warning.
start () {
  if [ $DIR_SIZE_IN_MB = false ]; then
    DU_ARGS="-s -k $DIR_SIZE_PATH"
  else
    DU_ARGS="-s -m $DIR_SIZE_PATH"
  fi
}

# Collect actual metric. This function is called every N seconds.
collect () {
  # Calling `report $val` will check if the value is a number (int or float)
  # and then send it over to the reporter's report() function, together with
  # the name of the metric, in this case "dir_size" if no alias is used.
  report $(du $DU_ARGS | awk '{ print $1 }')
  # If report is called with two arguments, the first one will be appended
  # to the metric name, for example `report "foo" $val` would be reported as
  # "dir_size.foo: $val". This is helpful when a metric is collecting multiple
  # values like `network_io`, which reports "network_io.in" / "network_io.out".
}

# Stop is not needed for this metric, there's nothing to clean up.
# stop () {}

# The output of this function is shown when calling `metrics.sh`
# with `--docs` and is even more helpful when creating configuration
# files with `--print-config`.
docs () {
  echo "Monitor size of a specific folder in Kb or Mb."
  echo "DIR_SIZE_PATH=$DIR_SIZE_PATH"
  echo "DIR_SIZE_REPORT_MB=$DIR_SIZE_IN_MB"
}
```

### Custom reporters

```sh
# Hooks for reporters in order of execution
defaults () {}  # setting default variables
start () {}     # called at the beginning
report () {}    # report the actual metric
stop () {}      # called before exiting
docs () {}      # used for printing docs and creating output for configuration
```

Below is an example script for sending metrics as JSON data to an API endpoint. Assuming this script is located at `./reporters/custom/json_api.sh`, it can be invoked by calling `./metrics.sh -r json_api`.

```sh
#!/bin/sh

# Set default values. This function should never fail.
defaults () {
  if [ -z $JSON_API_METHOD ]; then
    JSON_API_METHOD="POST"
  fi
}

# Prepare the reporter. Create helper functions to be used during collection
# if needed. Returning 1 will result in an error and execution will be stopped.
start () {
  if [ -z $JSON_API_ENDPOINT ]; then
    echo "Error: json_api requires \$JSON_API_ENDPOINT to be specified"
    return 1
  fi
}

# Report metric. This function is called whenever there's a new value
# to report. It's important to know that metrics don't call this function
# directly, as there's some more work to be done before. You can safely assume
# that arguments passed to this function are sanitized and valid.
report () {
  local metric=$1 # the name of the metric, e.g. "cpu", "cpu_alias", "cpu.foo"
  local value=$2  # int or float
  curl -s -H "Content-Type: application/json" $JSON_API_ENDPOINT \
       -X $JSON_API_METHOD -d "{\"metric\":\"$metric\",\"value\":$value}"
}

# Stop is not needed here, there's nothing to clean up.
# stop () {}

# The output of this function is shown when calling `metrics.sh`
# with `--docs` and is even more helpful when creating configuration
# files with `--print-config`.
docs () {
  echo "Send data as JSON to an API endpoint."
  echo "JSON_API_ENDPOINT=$JSON_API_ENDPOINT"
  echo "JSON_API_METHOD=$JSON_API_METHOD"
}
```
