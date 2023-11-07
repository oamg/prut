#!/bin/sh -xe

print_system_info(){
    echo "Printing pre-upgrade system info:"

    cat /etc/redhat-release
    uname -a
    locale
    free
    cat /etc/fstab
    parted -l
    fdisk -l
    lsblk -f
    df -h
    yum repolist
    ls -l /etc/yum.repos.d/
    subscription-manager list
}

distro_source_check() {
    echo "Checking source distro version."

    VERSION_ID=$(grep VERSION_ID= /etc/os-release)

    if [ "${VERSION_ID}" = "VERSION_ID=\"${SOURCE}\"" ]; then
        echo "The provisioned system matches the requirementes of current plan."
    else
        echo "The provisioned system does not match the requirementes of current plan."
        echo "Plan expects source os version: ${SOURCE}"
        echo "Provisioned version is: $(grep VERSION_ID= /etc/os-release)"
        echo "The test might pass or it might fail based on many factors."
    fi
}

check_source_target(){
    if test -v SOURCE; then
        case "${SOURCE}" in
            7.*|8.*)
                echo "SOURCE: ${SOURCE} is supported."
                ;;
            *)
                echo "SOURCE: ${SOURCE} is not supported!"
                return 1
                ;;
        esac
    else
        echo "SOURCE is not set!"
        return 1
    fi
    if test -v TARGET; then
        case "${TARGET}" in
            8.*|9.*)
                echo "TARGET: ${TARGET} is supported."
                ;;
            *)
                echo "TARGET: ${TARGET} is not supported!"
                return 1
                ;;
        esac
    else
        echo "TARGET is not set!"
        return 1
    fi
}

check_source_target
print_system_info
distro_source_check
