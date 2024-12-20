#!/bin/bash
#

<<comment
This script is to perform rotational backup
Usage : bash <path of the script> <path to source> <path to store backup> <number of rotations>
comment

if [ $# -lt 3 ]; then
    echo "Usage : bash <path of the script> <path to source> <path to store backup> <number of rotations>"
    exit 1
fi

function create_backup {
    source_dir=$1
    backup_dir=$2
    time_stamp=$(date '+%Y-%m-%d-%H-%M-%S')

    # Check if source directory exists
    if [ ! -d "$source_dir" ]; then
        echo "Error: Source directory '$source_dir' does not exist."
        exit 1
    fi

    # Create the backup directory if it doesn't exist
    mkdir -p "$backup_dir"

    # Create the backup
    zip -r "${backup_dir}/backup_${time_stamp}.zip" "${source_dir}" >/dev/null
    if [ $? -eq 0 ]; then
        echo "Backup is generated for ${time_stamp}"
    fi
}

function rotationary_backup1 {
    backup_dir=$1
    mx_rotation=$2

    # Validate the backup directory
    if [ ! -d "$backup_dir" ]; then
        echo "Error: Backup directory '$backup_dir' does not exist."
        exit 1
    fi

    # Validate mx_rotation is a positive integer
    if ! [[ "$mx_rotation" =~ ^[0-9]+$ ]]; then
        echo "Error: Number of rotations must be a valid positive integer."
        exit 1
    fi

    # Find all backups sorted by time (newest first)
    backups=($(ls -t "${backup_dir}/backup_"*.zip 2>/dev/null))

    # Debugging output
    echo "Backup directory: $backup_dir"
    echo "Number of backups: ${#backups[@]}"

    # If no backups exist, skip rotation
    if [ "${#backups[@]}" -eq 0 ]; then
        echo "No backups found in the backup directory. Skipping rotation."
        return
    fi

    # Check if backups exceed the limit
    if [ "${#backups[@]}" -gt "$mx_rotation" ]; then
        echo "Performing rotation: Keeping the latest $mx_rotation backups."

        # Slice the backups array to find old ones to delete
        backups_to_remove=("${backups[@]:$mx_rotation}")

        # Delete old backups
        for backup in "${backups_to_remove[@]}"; do
            echo "Deleting old backup: $backup"
            rm -f "$backup"
        done
    else
        echo "No rotation required: Total backups (${#backups[@]}) within the limit."
    fi
}

# Call the functions with script arguments
create_backup "$1" "$2"
rotationary_backup1 "$2" "$3"

