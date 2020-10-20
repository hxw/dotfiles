# Basic VNET Jail setup

In the following document these terms are used

* `$pool` refers to ZFS pool hosting the jail datasets. e.g., `zroot`
* `$j` refers to the absolute path to the jail root. e.g., `/jails`
* `$name` refers to the jail name both as a directory and a configuration in jail.conf

## Create the jail datasets

Root dataset: (only needed for initial setup)

~~~~~
zfs create -o mountpoint $j ${pool}${j}
~~~~~

Per jail chroot dataset: (and install a release)

~~~~~
zfs create ${pool}${j}/$name
tar -xpf /path/to/downloaded/12.1-RELEASE/base.txz -C $j/$name
~~~~~

Set root password within jail chroot, without starting the jail

~~~~~
chroot $j/$name
passwd
adduser
...etc.
~~~~~

## ZFS dataset delegation

Creating delegated dataset:  (e.g., for poudriere)
Create as unmounted and jailed, so mountpoint will be local to the running jail's chroot

~~~~~
zfs create -u -o mountpoint=/usr/local/poudriere -o jailed=on ${pool}${j}/$name/poudriere
~~~~~

In the jail's `/usr/local/etc/poudriere.conf` use these settings:
Must substitute the `$…` values to the values from `/etc/jail.conf`:
i.e., ${ZPOOL}${ZROOTFS} matches the delegated dataset created above

~~~~~
ZPOOL=$pool
ZROOTFS=$j/$name/poudriere
~~~~~


# Other configuration files

## Sample jail /etc/rc.conf

Substitute @NAME@ appropriately to the name of the jail from `/etc/jail.conf`
(Other uses of '$' are real shell variables, so do not substitute)

~~~~~
# rc.conf

# offset cron for root jobs
cron_flags="${cron_flags} -J 15"

# Disable Sendmail by default
sendmail_enable="NO"
sendmail_submit_enable="NO"
sendmail_outbound_enable="NO"
sendmail_msp_queue_enable="NO"

# Run secure syslog
syslogd_flags="-c -ss"

# Enable IPv6
ipv6_activate_all_interfaces="YES"

#hostname="@NAME@"

# DHCP
ifconfig_e0b_@NAME@="SYNCDHCP"
#dhclient_program="/usr/local/sbin/dual-dhclient"

#dhclient_program="/usr/local/sbin/dhclient"
#dhclient_flags="-q"

# Static IPs
#ifconfig_e0b_@NAME@="inet 192.168.10.100/24"
#ifconfig_e0b_@NAME@_ipv6="inet6 fd00::192:168:10:100/64"

# Static Routes
#defaultrouter="192.168.10.1"
#ipv6_defaultrouter="fd00::192:168:10:1"

# Enable Services
clear_tmp_enable="YES"
sshd_enable="YES"
~~~~~

Note: when using static IPs copy the host's /etc/resolv.conf into the jail
and modify if necessary.

## Optional sample fstab for inside the jail

If not used the jail's `/etc/fstab` can be empty or absent.

If used, this is placed in: `$j/$name/etc/fstab`.

Example for Linux emulation in a jail: (maybe also need enable mount.procfs)

~~~~~
# Device	Mountpoint		FStype		Options		Dump	Pass#
# linux support
linprocfs	/compat/linux/proc	linprocfs	rw		0	0
tmpfs		/compat/linux/dev/shm	tmpfs		rw,mode=1777	0	0
linsysfs	/compat/linux/sys	linsysfs	rw		0	0
~~~~~

## Sample pre-jail fstab in: $j/${name}.fstab

Allows null mounts to host file systems
(be sure to update $j and $name in real file)

~~~~~
# Device	Mountpoint		FStype		Options		Dump	Pass#
/usr/home/toor	$j/$name/home/toor	nullfs		rw,noatime	0	0
/usr/home/other	$j/$name/home/other	nullfs		ro,noatime	0	0
~~~~~

## Append the following to hosts /etc/devfs.rules (access to bpf for dhclient)

also allows jail access to /dev/bpf in order to use DHCP

~~~~~
[devfsrules_jail=11]
add include $devfsrules_hide_all
add include $devfsrules_unhide_basic
add include $devfsrules_unhide_login
add path 'bpf*' unhide
~~~~~

## For the update-jail script

Create `/etc/jail-update.conf`

~~~~~
egrep -v '^(#.*)?$' /etc/freebsd-update.conf > /etc/jail-update.conf
~~~~~

Check the `Components` line and remove kernel, possibly remove everything but world:
~~~~~
Components world
~~~~~
