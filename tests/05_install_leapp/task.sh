#!/bin/sh -xe

echo "Installing leapp:"
case "${TARGET}" in
    8.*)
        yum install -y leapp-upgrade
        ;;
    9.*)
        dnf install -y leapp-upgrade
        ;;
esac

echo "Checking if leapp is present and 'working'"
rpm -qa | grep leapp
leapp upgrade --help
ls -l /etc/leapp/files
find /etc/leapp/files -type f -exec sha256sum {} \;

echo "Showing leapp env variables"
env | grep LEAPP_ || true
