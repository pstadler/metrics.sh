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

TODO: /etc/init.d

### Requirements

metrics.sh has been tested on Ubuntu and Mac OS X but is supposed to run on most *NIX-like operating systems. Some of the provided metrics require [procfs](http://en.wikipedia.org/wiki/Procfs) to be available.

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
- config file docs
- load custom/contrib metrics and reporters
- enable -m <alias> / -r <alias>
- allow multiple reporters?