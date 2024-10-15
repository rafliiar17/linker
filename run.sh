#!/bin/bash
script_dir="$(dirname "$(realpath "$0")")"

echo "Running main.sh"
"$script_dir/main.sh"
echo "main.sh completed"

echo ""
echo "Running sqlmap.sh"
"$script_dir/sqlmap.sh"
echo "sqlmap.sh completed"
