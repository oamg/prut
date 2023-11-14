# Upgradability test for 3rd party applications
Purpose of this [tmt] [test plan][tmt-plan] is to simplify upgradability testing of 3rd party application on RHEL.

All steps of the test plan are implemented as POSIX compliant shell scripts, therefore there are almost no dependencies
(except `tmt`, see [Prerequisites](#prerequisites) section) to run the plan.

## Prerequisites
1. Fully updated VM with RHEL content (e.g. from [Developer Subscription][dev-sub]).
   * For RHEL 7 system, `extras` repo is needed to get leapp, e.g.
     ```sh
     subscription-manager repos --enable rhel-7-server-extras-rpms
     ```
2. SSH public keys for root user are present on the VM, e.g.
   ```sh
   ssh-copy-id root@${VM_IP}
   ```
3. Installed `tmt` on the host machine (available in Fedora 37 and newer and EPEL 9 and newer, see
   [installation instructions][tmt-installation])

## Running the test
Run the whole test plan
```sh
SOURCE=8.8
TARGET=9.2
VM_IP=192.168.122.118

tmt run \
  --environment SOURCE=${SOURCE} \
  --environment TARGET=${TARGET} \
  --all \
  provision --how connect --guest ${VM_IP} \
  plans --name paths/prut
```

The environment variables `SOURCE` and `TARGET` refers to version of RHEL installed on the machine before and after
performing the upgrade and are used to perform sanity checks before and after the upgrade. Please note that not all
combinations are valid, for supported upgrade paths see the [official documentation][upgrade-paths] for in-place
upgrades.

Run only tests from the test plan with `pre-upgrade` tag
```sh
tmt run \
  --environment SOURCE=${SOURCE} --environment TARGET=${TARGET} \
  --all \
  provision --how connect --guest ${VM_IP} \
  plans --name paths/prut \
  tests --filter 'tag: pre-upgrade'
```

Run just one test of the test plan
```sh
tmt run \
  --environment SOURCE=${SOURCE} --environment TARGET=${TARGET} \
  --all \
  provision --how connect --guest ${VM_IP} \
  tests --name /tasks/00_initial_checks
```

## Viewing results
To view results of the last test in web browser, use
```sh
tmt run --last report --how html --open
```

# tmt primer
One repo can contain multiple [test plans][tmt-plan] (usually in `plans` directory) which consists of multiple steps
(the most prominent is `execute` step, which executes the tests). A test plan groups multiple [tests][tmt-test] (usually
in `tests` directory).

To show details for all plans (only one plan is currently present in this repo)
```sh
tmt plans show
```

To show details for all tests (regardless if they belong to any test plan)
```sh
tmt tests show
```

List tests with specified tag
```sh
tmt tests ls --filter 'tag: pre-upgrade'
```

<!-- links -->
[tmt]: https://tmt.readthedocs.io/
[tmt-plan]: https://tmt.readthedocs.io/en/stable/guide.html#plans
[tmt-test]: https://tmt.readthedocs.io/en/stable/guide.html#tests
[tmt-installation]: https://tmt.readthedocs.io/en/stable/overview.html#install
[upgrade-paths]: https://access.redhat.com/articles/4263361
[dev-sub]: https://developers.redhat.com/articles/getting-red-hat-developer-subscription-what-rhel-users-need-know
