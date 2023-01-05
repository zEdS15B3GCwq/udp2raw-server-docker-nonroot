#!/bin/sh

# Adds iptables rule and launches udp2raw as a non-root user.
# Requires NET_ADMIN capability for iptables access.
#

_is_udp2raw_command() {
  case "$@" in
    *udp2raw*)
      return 0
      ;;
  esac
  return 1
}

if _is_udp2raw_command "$@"; then
  # Resolve host's IP (added to /etc/hosts as host.docker.internal)
  host_ip=$(cat /etc/hosts | grep -m 1 'host.docker.internal$' | awk '{print $1}')
  echo "Host IP is $host_ip"

  # Replace host.docker.internal with IP address in command line
  command=$(echo "$@" | sed s/host.docker.internal/$host_ip/)

  # Get udp2raw to generate firewall rule and execute that
  iptables_rule=$($command -g | grep -A 1 'generated iptables rule:' | tail -n 1)
  echo "Adding iptables rule: '$iptables_rule'"
  $iptables_rule

  # Launch command line as another (preferably non-root) user
  user="${UPD2RAW_USER:-2000:2000}"
  echo "Executing udp2raw command line as user $user"

  exec su-exec $user $command
else
  echo "Doesn't appear to be an udp2raw command line, executing as is"
  "$@"
fi
