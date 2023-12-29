#!/bin/bash

VERSION="v0.1.0"


display_version() {
    echo "internsctl $VERSION"
}

display_help() {
    echo "Usage: internsctl [options] <command>"
    echo "Options:"
    echo "  --help       Display help"
    echo "  --version    Display version"
    echo "Commands:"
    echo "  cpu getinfo        Get CPU information"
    echo "  memory getinfo     Get memory information"
    echo "  user create <username>     Create a new user"
    echo "  user list                  List regular users"
    echo "  user list --sudo-only      List users with sudo permissions"
    echo "  file getinfo <file-name>   Get file information"
    echo "  file getinfo <file-name> [options: --size, --permissions, --owner, --last-modified]   Get specific file information"

}






get_file_info() {
    local file_name=$1

    if [[ "$2" == "--size" || "$2" == "-s" ]]; then
        du -b "$file_name" | awk '{print $1}'
    elif [[ "$2" == "--permissions" || "$2" == "-p" ]]; then
        stat --printf="%A\n" "$file_name" 2>/dev/null
    elif [[ "$2" == "--owner" || "$2" == "-o" ]]; then
        stat --printf="%U\n" "$file_name" 2>/dev/null
    elif [[ "$2" == "--last-modified" || "$2" == "-m" ]]; then
        stat --printf="%y\n" "$file_name" 2>/dev/null
    else
        file_info=$(stat --printf="File: %n\nAccess: %A\nSize(B): %s\nOwner: %U\nModify: %y\n" "$file_name" 2>/dev/null)
        echo "$file_info"
    fi
}

if [[ "$1" == "file" && "$2" == "getinfo" && -n "$3" && -n "$4" ]]; then
    get_file_info "$4" "$3"
fi


if [[ "$1" == "--help" ]]; then
    display_help
    exit 0
elif [[ "$1" == "--version" ]]; then
    display_version
    exit 0
elif [[ "$1" == "cpu" && "$2" == "getinfo" ]]; then
    lscpu
    exit 0
elif [[ "$1" == "memory" && "$2" == "getinfo" ]]; then
    free
    exit 0
elif [[ "$1" == "user" && "$2" == "create" && -n "$3" ]]; then
    sudo useradd -m "$3" 
    echo "User $3 created successfully."
    exit 0
elif [[ "$1" == "user" && "$2" == "list" && "$3" != "--sudo-only" ]]; then
    getent passwd | cut -d: -f1
    exit 0
elif [[ "$1" == "user" && "$2" == "list" && "$3" == "--sudo-only" ]]; then
    grep -Po '^sudo.+:\K.*$' /etc/group | tr ',' '\n'
    exit 0
elif [[ "$1" == "file" && "$2" == "getinfo" && -n "$3" ]]; then
    get_file_info "$3" "$4"
    exit 0
else
    echo "Error: Unrecognized command or incorrect usage."
    echo "Run 'internsctl --help' for usage instructions."
    exit 1
fi

