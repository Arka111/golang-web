#! /bin/bash


# Exit immediately if a command exits with a non-zero status.
# Print commands and arguments as they are being executed.
set -xe


if ! command -v helm  &> /dev/null
then
    echo "Helm could not be found."
    echo "Please install it."
    exit 1
fi


if ! command -v kubectl  &> /dev/null
then
    echo "kubectl could not be found."
    echo "Please install it."
    exit 1
fi