# copied from https://github.com/concourse/concourse/blob/master/jobs/baggageclaim/templates/baggageclaim_ctl.erb#L54
# break out of bosh-lite device limitations
function filesystem_permit_device_control() {
  local devices_mount_info
  devices_mount_info="$( cat /proc/self/cgroup | grep devices )"

  if [ -z "$devices_mount_info" ]; then
    # cgroups not set up; must not be in a container
    return
  fi

  local devices_subsytems
  devices_subsytems="$( echo "$devices_mount_info" | cut -d: -f2 )"

  local devices_subdir
  devices_subdir="$( echo "$devices_mount_info" | cut -d: -f3 )"

  if [ "$devices_subdir" = "/" ]; then
    # we're in the root devices cgroup; must not be in a container
    return
  fi

  cgroup_dir=/devices-cgroup

  if [ ! -e "${cgroup_dir}" ]; then
    # mount our container's devices subsystem somewhere
    mkdir "$cgroup_dir"
  fi

  if ! mountpoint -q "$cgroup_dir"; then
    mount -t cgroup -o "$devices_subsytems" none "$cgroup_dir"
  fi

  # permit our cgroup to do everything with all devices
  echo a > "${cgroup_dir}${devices_subdir}/devices.allow"

  umount "$cgroup_dir"
}

function filesystem_create_loop_devices() {
  set +e
  LOOP_CONTROL=/dev/loop-control
  if [ ! -c $LOOP_CONTROL ]; then
    mknod $LOOP_CONTROL c 10 237
    chown root:disk $LOOP_CONTROL
    chmod 660 $LOOP_CONTROL
  fi

  amt=${1:-256}
  for i in $( seq 0 "$amt" ); do
    mknod -m 0660 "/dev/loop${i}" b 7 "$i" > /dev/null 2>&1
  done
  set -e
}

# workaround until Concourse's garden sets this up for us
function filesystem_mount_sysfs() {
  if ! grep -qs '/sys' /proc/mounts; then
    mount -t sysfs sysfs /sys
  fi
}
