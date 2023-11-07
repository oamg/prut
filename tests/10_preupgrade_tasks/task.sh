#!/bin/sh -xe

echo "Applying workaround for firewalld inhibitor."
case "${TARGET}" in
    9.*)
        sed -i s/^AllowZoneDrifting=.*/AllowZoneDrifting=no/ /etc/firewalld/firewalld.conf
        ;;
esac

echo "Applying workaround for ssh inhibitor."
case "${TARGET}" in
    8.*)
        printf "\n%s\n" "PermitRootLogin yes" >> f
        ;;
    9.*)
        echo '#comment added by upgrade plan to workaround leapp inhibitor' >> /etc/ssh/sshd_config
        ;;
esac

echo "Applying workaround for kernel modules inhibitors."
case "${TARGET}" in
    8.*)
        modprobe -r floppy pata_acpi || true
        ;;
esac

echo "Answering common answers to workaround leapp inhibitors."
case "${TARGET}" in
    8.*)
        leapp answer --add \
            --section remove_pam_pkcs11_module_check.confirm=True \
            --section remove_pam_krb5_module_check.confirm=True \
            --section authselect_check.confirm=True
        ;;
    9.*)
        leapp answer --add --section check_vdo.confirm=True
        ;;
esac

ls -l /etc/yum.repos.d
