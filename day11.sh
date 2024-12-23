#!/bin/bash

<<comment
 Day 11 Task: Error Handling in Shell Scripting

# Learning Objectives
Understanding how to handle errors in shell scripts is crucial for creating robust and reliable scripts. Today, you'll learn how to use various techniques to handle errors effectively in your bash scripts.
comment

# Get the directory name from the first argument
New_Dir="$1"

# Solution of Task 1 and 2: Checking Exit Status
# This function checks if the specified directory exists. If it doesn't, it prints an error message.
checking_exit_check() {
    if [[ ! -d "$New_Dir" ]]; then
        echo "Error: The directory '$New_Dir' does not exist."
    fi
}

# Solution of Task 3: Using `trap` for Cleanup
# Create a temporary file and set a trap to delete it when the script exits.
tempfile="abcd.txt"
trap "rm -f $tempfile" EXIT

# Write a message to the temporary file and display its contents.
echo "This is a temporary file." > $tempfile
cat $tempfile

# Solution of Task 4: Redirecting Errors
# Attempt to read a non-existent file and redirect any error messages to /dev/null (silencing them).
cat non_existent_file.txt 2>/dev/null

# Solution of Task 5: Creating Custom Error Messages
# Attempt to create a directory and check if the operation was successful. If not, print a custom error message.
mkdir /tmp/mydir 2>/dev/null
if [[ $? -ne 0 ]]; then
    echo "Error: Directory /tmp/mydir could not be created. Check if you have the necessary permissions."
fi

# Call the function to check the exit status of the directory check
checking_exit_check "$1"

# Exit the script with a status of 1 to indicate an error occurred.
exit 1