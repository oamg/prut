#!/bin/sh -xe

print_system_info(){
    echo "Printing post-upgrade system info:"

    cat /etc/redhat-release
    uname -a
    locale
    free
    cat /etc/fstab
    lsblk -f
    df -h
    dnf repolist
    ls -l /etc/yum.repos.d/
    subscription-manager list
    if test -v SOURCE; then
        echo "SOURCE: ${SOURCE}"
    else
        echo "SOURCE not set"
    fi
    if test -v TARGET; then
        echo "TARGET: ${TARGET}"
    else
        echo "TARGET not set"
    fi
}

check_kernel_version(){
    echo "Checking running kernel."
    uname -r

    KERNEL_MAJOR_VERSION=$(uname -r | cut -d. -f1)
    if [ "${KERNEL_MAJOR_VERSION}" = "$1" ]; then
        echo "Kernel major version (${KERNEL_MAJOR_VERSION}) as expected."
    else
        echo "Expected kernel major version: $1"
        echo "Detected kernel major version: ${KERNEL_MAJOR_VERSION}"
        echo "Incorrect kernel major version!"
        return 1
    fi
}

echo "Waiting for leapp post-upgrade service to finish."
# it would be easier if inotifywait could be used...
TIMEOUT=600
DELAY=5
FILE=/etc/systemd/system/leapp_resume.service
while [ -e "${FILE}" ]; do
  if [ "${TIMEOUT}" -le 0 ]; then
    echo "Timeout while waiting leapp post-upgrade service to finish."
    exit 1
  fi

  sleep "${DELAY}"
  TIMEOUT=$((TIMEOUT-5))
done
echo "leapp post-upgrade service finished."

echo "Checking distro version"
uname -a

VERSION_ID=$(sed -nE 's/VERSION_ID="([[:digit:]\.]+)"/\1/p' /etc/os-release)
if [ "${VERSION_ID}" != "${TARGET}" ]; then
    echo "Expected VERSION_ID: ${TARGET}"
    echo "Detected VERSION_ID: ${VERSION_ID}"
    echo "System upgrade has failed, skipping checks!"
    exit 1
fi

case "${TARGET}" in
    8.*)
        check_kernel_version 4
        ;;
    9.*)
        check_kernel_version 5
        ;;
esac

echo "Checking dnf."
dnf check

echo "Checking active swap."
if grep -qE "^[^#].*swap[[:space:]]+defaults" /etc/fstab; then
    echo "Checking swap devices are active."
    sed 1d /proc/swaps | grep -q .
else
    echo "No swap defined on the machine's fstab."
fi

print_system_info

echo "Collecting leapp logs."
tar -cJf "${TMT_TEST_DATA}/var-log-leapp.tar.xz" /var/log/leapp/*

echo "Collecting leapp datafiles."
tar -cJf "${TMT_TEST_DATA}/leappdata.tar.xz" /etc/leapp/files/*
