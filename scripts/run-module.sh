#!/bin/bash

# Run individual modules for testing/debugging
set -e

source scripts/common.sh

show_usage() {
    echo "Usage: $0 <module-number>"
    echo "Available modules:"
    echo "  1 - System check"
    echo "  2 - Dependencies"
    echo "  3 - Backup"
    echo "  4 - Install files"
    echo "  5 - Environment setup"
    echo "  6 - Waybar config"
    echo "  7 - CSS styling"
    echo "  8 - Test"
    echo "  9 - Restart Waybar"
}

if [ $# -eq 0 ]; then
    show_usage
    exit 1
fi

case $1 in
    1) bash scripts/01-system-check.sh ;;
    2) bash scripts/02-dependencies.sh ;;
    3) bash scripts/03-backup.sh ;;
    4) bash scripts/04-install-files.sh ;;
    5) bash scripts/05-environment.sh ;;
    6) bash scripts/06-waybar-config.sh ;;
    7) bash scripts/07-css-styling.sh ;;
    8) bash scripts/08-test.sh ;;
    9) bash scripts/09-restart.sh ;;
    *) 
        print_error "Invalid module number: $1"
        show_usage
        exit 1
        ;;
esac
