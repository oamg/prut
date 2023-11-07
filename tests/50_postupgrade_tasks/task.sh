#!/bin/sh -xe

PREVIOUS_MAJOR="${SOURCE%.*}"
CURRENT_MAJOR="${TARGET%.*}"

remove_old_kernel_parts(){
    # TODO: do not fail when no old kernels are found
    OLD_KERNELS=$(cd /lib/modules && ls -d -- *.el"$1"* || true)
    echo "Old kernels found: ${OLD_KERNELS}"
    for KERNEL_VERSION in ${OLD_KERNELS}; do
        echo "Cleaning for old kernel ${KERNEL_VERSION}"

        echo "Removing weak modules from the old kernel"
        test -x /usr/sbin/weak-modules && /usr/sbin/weak-modules --remove-kernel "${KERNEL_VERSION}"

        echo "Removing the old kernel from the boot loader entry"
        /bin/kernel-install remove "${KERNEL_VERSION}" /lib/modules/"${KERNEL_VERSION}"/vmlinuz
    done
}

remove_old_packages(){
    echo "Removing remnants after the upgrade"

    echo "Removing packages from the exclude list"
    dnf config-manager --save --setopt exclude=''

    remove_old_kernel_parts "${PREVIOUS_MAJOR}"

    echo "Checking remaining el${PREVIOUS_MAJOR} packages"
    rpm -qa | grep -e "\.el${PREVIOUS_MAJOR}" | grep -vE '^(gpg-pubkey|libmodulemd|katello-ca-consumer)' | sort

    echo "Removing remaining el${PREVIOUS_MAJOR} packages"
    rpm -qa | grep -e "\.el${PREVIOUS_MAJOR}" | grep -vE '^(gpg-pubkey|libmodulemd|katello-ca-consumer)' | sort | xargs rpm -ev || true

    echo "Re-checking remaining el${PREVIOUS_MAJOR} packages"
    rpm -qa | grep -e "\.el${PREVIOUS_MAJOR}" | grep -vE '^(gpg-pubkey|libmodulemd|katello-ca-consumer)' | sort

    echo "Removing leftover leapp-*-el${CURRENT_MAJOR} packages"
    dnf remove -y leapp-deps-el"${CURRENT_MAJOR}" leapp-repository-deps-el"${CURRENT_MAJOR}"

    echo "Removing any remaining empty directories"
    rm -vr "/lib/modules/*el${PREVIOUS_MAJOR}*" || true

    echo "Checking for sanity after rpm removal"
    dnf check --all
}

echo "Cleaning up dnf data."
dnf clean all

remove_old_packages

echo "Remove the old rescue kernel and initramdisk"
rm -v /boot/vmlinuz-*rescue* /boot/initramfs-*rescue*

echo "Reinstall the current kernel to recover the rescue kernel and initramdisk"
dnf reinstall -y kernel-core-"$(uname -r)"

echo "Verifying that old kernels are not present in the bootloader."
grubby --info=ALL | grep "\.el${PREVIOUS_MAJOR}" || echo "Old kernels are not present in the bootloader."

echo "Verifying that rescue kernel have been created for the current kernel."
ls /boot/vmlinuz-*rescue* /boot/initramfs-*rescue*

echo "Verifying that rescue initramdisk files have been created for the current kernel"
lsinitrd /boot/initramfs-*rescue*.img | grep -qm1 "$(uname -r)/kernel/"

echo "Verify the rescue boot entry refers to the existing rescue files"
grubby --info "$(ls /boot/vmlinuz-*rescue*)"
