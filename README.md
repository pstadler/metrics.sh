# metrics.sh

metrics.sh is a lightweight metrics collection and fowarding utility implemented in portable POSIX compliant shell scripts. An elegant interface based on hooks enables writing custom metric collectors and forwarders in a transparent way.

Besides having a low impact on system resources, which makes metric.sh a suitable solution for running in virtual environments and servers with limited capacities, simplicty is the main goal of this project, hence its documentation shall fit in a single README.

## Usage

```
$ ./metrics.sh --help

  Usage: ./metrics.sh [-d] [-h] [-v] [-m metrics] [-r reporter] [-i interval]

  Options:

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

TODO: /etc/init.d

### Requirements

metrics.sh has been tested on Ubuntu and Mac OS X but is supposed to run on most *NIX-line operating systems. Some of the provided metrics require [procfs](http://en.wikipedia.org/wiki/Procfs) to be available.

## Metrics

Metric        | Description
------------- | -------------
cpu           | CPU usage in %
memory        | Memory usage in %
swap          | Swap usage in %
network_io    | Network I/O in kB/s
disk_io       | Disk I/O in MB/s
disk_usage    | Disk usage in %
heartbeat     | System heartbeat
ping          | Check whether a remote host is reachable

TODO: how to write custom metrics

## Reporters

TODO: how to write custom reporters

## TODO

- README
- config file support
- config file auto-generation
- load custom/contrib metrics and reporters
- same metric multiple times? (e.g. disk_usage for multiple devices)
- allow multiple reporters?