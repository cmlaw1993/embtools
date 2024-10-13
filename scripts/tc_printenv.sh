#!/bin/bash

# Prints environment variable and aliases set by tc.sh

echo "PATH=$PATH"
echo "HOST=$HOST"
echo "ARCH=$ARCH"
echo "CC=$CC"
echo "CXX=$CXX"
echo "SYSROOT=$SYSROOT"
echo "PKG_CONFIG_LIBDIR=$PKG_CONFIG_LIBDIR"
echo "CROSS_COMPILE=$CROSS_COMPILE"

commands=("ar" "g++" "gcc" "gdb" "ldd" "nm" "objdump" "readelf" "strip")

for cmd in "${commands[@]}"; do
  alias $cmd
done
