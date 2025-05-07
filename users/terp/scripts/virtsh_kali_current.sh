#!/usr/bin/env bash

# Usage: ./virtsh_kali_current.sh <vm-name>
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <vm-name> <iso-path>"
    echo "Example: $0 kali-current"
    exit 1
fi

# Variables
VM_NAME="$1" # Name of the VM positional argument
ISO_PATH="$2"  # Adjust if your ISO is elsewhere
RAM_GB=4 # Ram in Gigabytes
VCPUS=4 # Number of virtual CPUs
DISK_SIZE=200  # Gigabytes
OS_VARIANT="debian11" # Closest match for Kali Linux
DISK_PATH="$HOME/Documents/VMs/${VM_NAME}.qcow2" # Where to write the disk image
RAM_MB=$((RAM_GB * 1024)) # Convert GB to MB

# Create disk if it doesn't exist
if [ ! -f "$DISK_PATH" ]; then
    qemu-img create -f qcow2 "$DISK_PATH" ${DISK_SIZE}G
fi

# Check if the VM already exists
if virsh list --all | grep -q "$VM_NAME"; then
    echo "VM $VM_NAME already exists. Please choose a different name."
    exit 1
fi

# Check if the ISO file exists
if [ ! -f "$ISO_PATH" ]; then
    echo "ISO file $ISO_PATH not found. Please check the path."
    exit 1
fi

# Create the VM using virt-install
virt-install \
    --name "$VM_NAME" \
    --ram "$RAM_MB" \
    --vcpus "$VCPUS" \
    --os-variant "$OS_VARIANT" \
    --disk path="$DISK_PATH",format=qcow2 \
    --cdrom "$ISO_PATH" \
    --network bridge=virbr0,model=virtio \
    --graphics spice \
    --video qxl \
    --sound ich9 \
    --channel unix,target_type=virtio,name=org.qemu.guest_agent.0 \
    --channel spicevmc,target_type=virtio,name=com.redhat.spice.0 \
    --noautoconsole

# Check if the VM was created successfully
if [ $? -ne 0 ]; then
    echo "Failed to create VM $VM_NAME."
    exit 1
fi

# Connect to the VM using virt-viewer or remote-viewer
echo "VM $VM_NAME created. Connect with virt-viewer or remote-viewer using SPICE."