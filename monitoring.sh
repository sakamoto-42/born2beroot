#!bin/bash

architecture=$(uname -a)

cpu_physical=$(grep "physical id" /proc/cpuinfo | sort -u | wc -l)

v_cpu=$(grep "processor" /proc/cpuinfo | wc -l)

used_memory_mb=$(free -m | grep "Mem:" | awk '{print $3}')
total_memory_mb=$(free -m | grep "Mem:" | awk '{print $2}')
used_memory_kb=$(free -k | grep "Mem:" | awk '{print $3}')
total_memory_kb=$(free -k | grep "Mem:" | awk '{print $2}')

memory_usage_rate=$(awk "BEGIN {printf \"%.2f\", ($used_memory_kb / $total_memory_kb) * 100}")
used_disk_memory=$(df -h --total | grep "total" | awk '{print $3}')
total_disk_memory=$(df -h --total | grep "total" | awk '{print $2}')
disk_memory_usage_rate=$(df -h --total | grep "total" | awk '{print $5}')

us_load=$(top -bn1 | grep "%Cpu(s)" | awk '{print $2}')
sy_load=$(top -bn1 | grep "CPu(s)" | awk '{print $4}')
ni_load=$(top -bn1 | grep "Cpu(s)" | awk '{print $6}')
cpu_load=$(awk "BEGIN {printf \"%.1f\", $us_load + $sy_load + $ni_load}")

last_boot_date=$(who -b | awk '{print $3}')
last_boot_time=$(who -b | awk '{print $4}')

lvm_active_logical_volumes=$(lvs | wc -l)
lvm_active_volume_groups=$(vgs | wc -l)
lvm_active_mounted_partitions=$(df | grep "^/dev/mapper" | wc -l)
lvm_active_total=$((lvm_active_logical_volumes + lvm_active_volume_groups + lvm_active_mounted_partitions))
if [ $lvm_active_total -eq 0 ]; then
        lvm_active="no"
else
        lvm_active="yes"
fi

tcp_connections=$(ss -s | grep "TCP:" | awk '{print $4}' | sed 's/,//')

user_log=$(who -q | awk -F '=' '/# users=/ {print $2}')

network_ip=$(hostname -I | awk '{print $1}')
main_network_interface=$(ip route show default | grep -o "dev [^ ]*" | awk '{print $2}')
network_mac_address=$(ip link show $main_network_interface | grep 'link/ether' | awk '{print $2}')

sudo_command_count=$(grep -a -o "COMMAND=[^ ]*" /var/log/sudo/sudo.log | wc -l)
echo "#Architecture: $architecture
#CPU physical : $cpu_physical
#vCPU : $v_cpu
#Memory Usage : ${used_memory_mb}/${total_memory_mb}MB (${memory_usage_rate}%)
#Disk Usage: ${used_disk_memory}/${total_disk_memory} (${disk_memory_usage_rate})
#CPU load: ${cpu_load}%
#Last boot: $last_boot_date $last_boot_time
#LVM use: $lvm_active
#Connexions TCP : ${tcp_connexions:-0} ESTABLISHED
#User log: $user_log
#Network IP $network_ip (${network_mac_address})
#Sudo : ${sudo_command_count:-0} cmd"

