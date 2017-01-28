#!/bin/bash
## Description: increase the cpu numbers of list of VMs from one pool
## It dosen't check if the CPU configuration is supported. 
## Tested on xenserver 6.5
## Synopsis ./script.sh [cores] [sockets] [input file]
if [ $# -eq 3 ]
        then
        vms=$( sed "s/,/ /g" $3 ) # note that the VMs from the input file should be devided with comma, otherwise you should modify this line
        cores=$1
        cores_per_socket=$(( $cores / $2 ))
        if [ $cores_per_socket -eq 0 ]
                then
                cores_per_socket=1
        fi
        for i in $vms
                do
                vm_uuid=$(xe vm-list name-label=$i | grep uuid | awk '{print $5}')
                if [ $vm_uuid ]
                        then
                        xe vm-param-set VCPUs-max=$cores uuid=$vm_uuid
                        xe vm-param-set VCPUs-at-startup=$cores uuid=$vm_uuid
                        xe vm-param-set platform:cores-per-socket=$cores_per_socket uuid=$vm_uuid
                        echo "VCPU on VM $i are reconfugured to $( xe vm-param-get uuid=$vm_uuid param-name=VCPUs-max )"
                else
                        echo "VM $i is not found"
                fi
                done
        else
        echo "Use the following format ./script.sh [cores] [sockets] [input file]"
fi
