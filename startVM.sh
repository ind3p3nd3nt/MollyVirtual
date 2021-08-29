#!/usr/bin/bash
VARIANT=kde
MEMORY=1024M
DISKSIZE=100G
CPUS=$(getconf _NPROCESSORS_ONLN)
ACCELSUPPORT=$(lscpu | grep Virt)
echo "You are installing MollyEskamLinux $VARIANT variant with $MEMORY memory in a QEMU Virtual Machine";
if [ -z "$ACCELSUPPORT" ]; then echo "KVM Acceleration is not supported by your processor"; 
else echo "$ACCELSUPPORT"
fi
if [ -s "/bin/qemu-img" ]; then echo "All QEMU tools are already installed.";
else sudo apt update && sudo apt install vinagre qemu-system-x86 qemu-utils -y;
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
if [ -z "$ACCELSUPPORT" ]; then qemu-system-x86_64 -boot c -cdrom "MollyEskamLinux-$VARIANT.iso" -hda disk.qcow2 -m $MEMORY -M pc -cpu qemu64 -smp $CPUS,cores=1 -vnc :99 -usb -net nic -net user -soundhw hda -spice port=5900,addr=127.0.0.1,disable-ticketing -usb -usbdevice tablet&
else qemu-system-x86_64 -boot c -cdrom "MollyEskamLinux-$VARIANT.iso" -hda disk.qcow2 -m $MEMORY -M pc -machine accel=kvm -enable-kvm -cpu max,hv_relaxed,hv_vapic,hv_spinlocks=0x1fff -smp $CPUS,cores=1 -vnc :99 -usb -net nic -net user -k en-us -device qxl-vga,id=video0,ram_size=67108864,vram_size=67108864,vram64_size_mb=0,vgamem_mb=1531,max_outputs=1 -soundhw hda -spice port=5900,addr=127.0.0.1,disable-ticketing -usb -usbdevice tablet&
fi
sleep 3;
vinagre "spice://127.0.0.1:5900";
