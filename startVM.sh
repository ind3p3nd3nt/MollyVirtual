#!/usr/bin/bash
VARIANT=kde
MEMORY=1024M
DISKSIZE=100G
CPUS=$(getconf _NPROCESSORS_ONLN)
ACCELSUPPORT=$(lscpu | grep VT-x)
echo "You are installing MollyEskamLinux $VARIANT variant with $MEMORY memory in a QEMU Virtual Machine";
if [ -z "$ACCELSUPPORT" ]; then echo "KVM Acceleration is not supported by your processor"; 
else echo "$ACCELSUPPORT"
fi
if [ -s "/usr/bin/qemu-img" ]; then echo "All QEMU tools are already installed.";
else if [ -f "/ust/bin/apt" ]; then sudo apt update && sudo apt install qemu-system-x86 qemu-utils -y; else yum install qemu-system-x86 qemu-img -y; fi;
fi
if [ -s "disk.qcow2" ]; then echo "$(du disk.qcow2) Found";
else qemu-img create -f qcow2 disk.qcow2 $DISKSIZE;
fi
if [ -s "MollyEskamLinux-$VARIANT.iso" ]; then echo "$(du MollyEskamLinux-$VARIANT.iso) Found";
else if [ $VARIANT = kde ]; then wget -O "MollyEskamLinux-$VARIANT.iso" https://archive.org/download/molly-eskam-linux/linux-MollyEskamv1.0-live-amd64.iso;
else wget -O "MollyEskamLinux-$VARIANT.iso" "https://archive.org/download/molly-eskam-linux/linux-MollyEskamv1.0-live-$VARIANT-amd64.iso";
fi
fi
sudo pkill qemu;
if [ -z "$ACCELSUPPORT" ]; then qemu-system-x86_64 -boot c -cdrom "MollyEskamLinux-$VARIANT.iso" -hda disk.qcow2 -m $MEMORY -M pc -cpu qemu64 -smp $CPUS,cores=1 -vnc :99 -usb -net nic -net user -usb -usbdevice tablet&
else qemu-system-x86_64 -boot c -cdrom "MollyEskamLinux-$VARIANT.iso" -hda disk.qcow2 -m $MEMORY -M pc -machine accel=kvm -enable-kvm -cpu max -smp $CPUS,cores=1 -vnc :99 -usb -net nic -net user -k en-us -device qxl-vga -soundhw hda -spice port=5900,addr=127.0.0.1,disable-ticketing -usb -usbdevice tablet&
fi
