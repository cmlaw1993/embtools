#!/bin/bash

# Tool for locating, selecting, and configuring system environment variables
# using the selected toolchain.

# Check if script is being sourced
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  echo "ERROR: Please rerun the script with source"
  exit 1
fi

# Read arguments
OPTIND=1
n_values=()
while getopts ":n:" opt; do
  case $opt in
    n)
      # Split the comma-separated values into an array
      IFS=',' read -ra n_values <<< "$OPTARG"
      ;;
    \?)
      echo "Invalid option -$OPTARG" >&2
      return 1
      ;;
  esac
done

# Build exclusion arguments
exclude_args=()
for value in "${n_values[@]}"; do
  exclude_args+=("-e" "$value")
done

# Search for candidates
if [ "${#exclude_args[@]}" -eq 0 ]; then
    candidates=$(locate gcc | grep "gcc$" | grep "bin")
else
    candidates=$(locate gcc | grep "gcc$" | grep "bin" | grep -v "${exclude_args[@]}")
fi

if [ -z "$candidates" ]; then
  echo "No candidates found"
  return
fi

# Convert candidates to an array
IFS=$'\n' read -r -d '' -a candidates_array <<< "$candidates"

# Display the candidates and allow the user to select one
echo "Select a candidate:"
selection=""
select candidate in "${candidates_array[@]}"; do
  if [ -n "$candidate" ]; then
    selection="$candidate"
    echo "Selection=$selection"
    break
  else
    echo "Invalid selection"
  fi
done

# Derive parameters
gcc_name=$(basename "$selection")
bin_path=$(dirname "$selection")
host="${gcc_name%-gcc}"
arch=$(echo "$gcc_name" | cut -d'-' -f1)
if [ "$arch" = "aarch64" ]; then
  arch="arm64"
fi

orig_path=$(bash -c "echo $PATH")

# Set environment variables

export PATH="$bin_path:$PATH"
echo "PATH=$PATH"

export HOST="$host"
echo "HOST=$HOST"

export ARCH="$arch"
echo "ARCH=$ARCH"

export CC="$bin_path/$host-gcc"
echo "CC=$CC"

export CXX="$bin_path/$host-g++"
echo "CXX=$CXX"

export SYSROOT="$($CC -print-sysroot)"
echo "SYSROOT=$SYSROOT"

export PKG_CONFIG_LIBDIR="$SYSROOT/usr/lib/pkgconfig"
echo "PKG_CONFIG_LIBDIR=$PKG_CONFIG_LIBDIR"

export CROSS_COMPILE="$host-"
echo "CROSS_COMPILE=$CROSS_COMPILE"

# Set alias

commands=("ar" "g++" "gcc" "gdb" "ldd" "nm" "objdump" "readelf" "strip")

for cmd in "${commands[@]}"; do
  alias_string="$bin_path/$host-$cmd"
  alias "$cmd"="$alias_string" && echo "alias $cmd=$alias_string"
done
