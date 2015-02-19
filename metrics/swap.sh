#!/bin/sh
echo $(free | awk '/Swap/{print $3/$2 * 100.0;}')