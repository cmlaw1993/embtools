#!/bin/sh
readelf -a $1 | grep "program interpreter"
readelf -a $1 | grep "Shared library"
