#!/bin/bash

input_file="${HOME}/.bashrc"
backup_file="${HOME}/.bashrc.bak"
temp_file=$(mktemp)

# Create backup file
cp $input_file $backup_file

# Custom lines to add
custom_lines=(
  ""
  "function tc() {"
  "  source $(pwd)/scripts/tc.sh -n /usr/bin/c89-gcc,/usr/bin/c99-gcc,/usr/bin/gcc,snap,crosstool-ng/.build,tmp/work"
  "}"
  ""
  "function tc_refresh() {"
  "  source $(pwd)/scripts/tc_refresh.sh"
  "}"
  ""
  "function tc_printenv() {"
  "  source $(pwd)/scripts/tc_printenv.sh"
  "}"
  ""
  "function emb_listlibs() {"
  "  $(pwd)/scripts/emb_listlibs.sh \$@"
  "}"
  ""
  "function git_tree() {"
  "  git log --oneline --graph --decorate"
  "}"
  ""
)

START="# == embtools begin == #"
END="# == embtools end == #"

# Flag to track if START was found
found_start=false

# Start processing the input file
{
  while IFS= read -r line; do
    # Check for the START line
    if [[ "$line" == $START ]]; then
      echo "$line"    # Print the START line
      # Print the custom lines
      for custom_line in "${custom_lines[@]}"; do
        echo "$custom_line"
      done
      found_start=true
      # Skip over lines until we reach END
      while IFS= read -r line && [[ "$line" != $END ]]; do
        : # Do nothing, just skip lines
      done
      echo "$line"    # Print the END line
    else
      echo "$line"    # Print other lines as is
    fi
  done < "$input_file"
} > "$temp_file"

# If START was not found, append the custom lines at the end of the file
if [ "$found_start" = false ]; then
  echo "" >> "$temp_file"
  echo $START >> "$temp_file"
  for custom_line in "${custom_lines[@]}"; do
    echo "$custom_line" >> "$temp_file"
  done
  echo $END >> "$temp_file"
fi

# Replace the original file with the modified content
mv "$temp_file" "$input_file"

echo "~/.bashrc has been updated with aliases to scripts in embtools."
echo "You can find a backup of the original in ~/.bashrc.bak."
