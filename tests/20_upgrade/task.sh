#!/bin/sh -xe

echo "Running 'leapp upgrade'"
# TODO: Should we allow upgrade when $SOURCE or $TARGET is not on supported upgrade path?
leapp upgrade --target "${TARGET}"

echo "Collecting leapp report."
cp /var/log/leapp/leapp-report.txt "${TMT_TEST_DATA}"

# echo "Collecting leapp logs."
# tar -cJf "${TMT_TEST_DATA}/var-log-leapp-pre-reboot.tar.xz" /var/log/leapp/*
