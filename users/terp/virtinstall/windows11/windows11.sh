#!/usr/bin/env bash

# Usage: sudo ./windows11.sh <vm-name> <win11-iso-path> <autounattend-xml-path>
if [[ $# -ne 3 ]]; then
    echo "[+] Usage: sudo $0 <vm-name> <win11-iso-path> <autounattend-xml-path>"
    echo "[+] Example: sudo $0 win11 ~/Downloads/Win11.iso ~/autounattend.xml"
    exit 1
fi

# Check if running as root or sudo
if [[ $EUID -ne 0 ]]; then
    echo "[!] This script must be run as root or with sudo."
    exit 1
fi

# Check if /tmp/AUTOUNATTEND.iso exists and remove it
if [ -f "/tmp/AUTOUNATTEND.iso" ]; then
    echo "[!] Removing existing /tmp/AUTOUNATTEND.iso"
    rm -f "/tmp/AUTOUNATTEND.iso"
fi

# Variables
VM_NAME="$1"
WIN11_ISO="$2"
UNATTEND_XML="$3"
RAM_GB=8
VCPUS=4
DISK_SIZE=128
OS_VARIANT="win11"
DISK_PATH="/var/lib/libvirt/images/${VM_NAME}.qcow2"
UNATTEND_ISO="/tmp/AUTOUNATTEND.iso"
RAM_MB=$((RAM_GB * 1024))

# Check for required files
if [ ! -f "$WIN11_ISO" ]; then
    echo "[!] Windows 11 ISO not found: $WIN11_ISO"
    exit 1
fi
if [ ! -f "$UNATTEND_XML" ]; then
    echo "[!] autounattend.xml not found: $UNATTEND_XML"
    exit 1
fi

# Create disk if it doesn't exist
if [ ! -f "$DISK_PATH" ]; then
    sudo qemu-img create -f qcow2 "$DISK_PATH" ${DISK_SIZE}G
fi

# Create autounattend ISO
mkisofs -o "$UNATTEND_ISO" -V "AUTOUNATTEND" -iso-level 4 -udf "$UNATTEND_XML"

# Check if the VM already exists
if sudo virsh --connect qemu:///system list --all | grep -q "$VM_NAME"; then
    echo "[!] VM $VM_NAME already exists in system session. Please choose a different name."
    rm -f "$UNATTEND_ISO"
    exit 1
fi

# Install the VM
sudo virt-install \
    --connect qemu:///system \
    --name "$VM_NAME" \
    --ram "$RAM_MB" \
    --vcpus "$VCPUS" \
    --os-variant "$OS_VARIANT" \
    --disk path="$DISK_PATH",format=qcow2 \
    --cdrom "$WIN11_ISO" \
    --disk path="$UNATTEND_ISO",device=cdrom \
    --network bridge=virbr0,model=virtio \
    --graphics spice \
    --video qxl \
    --boot uefi \
    --noautoconsole

# Optionally remove the autounattend ISO after VM creation
echo "[!] Waiting for VM to finish initial setup before removing autounattend ISO..."
sleep 60 # Adjust this if needed
echo "[+] You may remove $UNATTEND_ISO manually after installation is complete, or uncomment the next line to remove it now."
# rm -f "$UNATTEND_ISO"

echo "[+] Windows 11 VM $VM_NAME created. Connect with virt-viewer or remote-viewer using SPICE."