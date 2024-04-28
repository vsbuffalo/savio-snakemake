#!/bin/bash

# Set the directory path
config_dir="$HOME/.config/snakemake"
savio_dir="$config_dir/savio"

# Check if ~/.config/snakemake/ exists, create it if not
if [ ! -d "$config_dir" ]; then
  echo "Creating directory: $config_dir"
  mkdir -p "$config_dir"
fi

# Check if ~/.config/snakemake/savio exists, clone the repository if not
if [ ! -d "$savio_dir" ]; then
  echo "Cloning repository into: $savio_dir"
  git clone https://github.com/vsbuffalo/savio-snakemake "$savio_dir"
else
  echo "Directory $savio_dir already exists. Skipping cloning."
fi

echo "Installation completed."
