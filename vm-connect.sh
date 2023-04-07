#!/bin/bash


# ask the user what the virtual machine is

echo "Which VM would you like to start & connect to (If the VM is already running, it will connect instead.)"

echo "You currently have these options:"

sudo virsh list --all

read vm

echo "Connecting to $vm"

# Gives permissions to libvirt-qemu:libvirt-qemu to /dev/shm/looking-glass (Required when starting the VM)

sudo chown libvirt-qemu:libvirt-qemu /dev/shm/looking-glass

# Starts virtual machine, If virtual machine is already running it will 'error' and run the rest of the script.

sudo virsh start $vm

# Waits 3 seconds for VM to initialize. 

sleep 3

# Gives permissions back to your current user (Using $USER)

sudo chown $USER:libvirt-qemu /dev/shm/looking-glass

# Opens looking glass. (Currently using stored in /usr/bin/looking-glass-client)

looking-glass-client -F
