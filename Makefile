DEVICE=rpi4-00

write-image: umount images/latest.raw images/.prepared
	jumpstarter run-script setup-latest-raw.yaml

console:
	jumpstarter power on -a -c $(DEVICE)

power-off:
	jumpstarter power off $(DEVICE)

download-image:
	scripts/download-latest-fedora

prepare-image: mount
	scripts/prepare-latest-raw
	touch images/.prepared
	umount mnt

images/.prepared:
	make prepare-image

images/latest.raw.xz:
	make download-image
	
images/latest.raw: images/latest.raw.xz
	xz -d -v -T0 -k $^
	rm images/.prepared

mnt:
	mkdir -p $@

umount:
	umount mnt || true

mount: umount images/latest.raw mnt
	guestmount -a images/latest.raw -m /dev/fedora/root -m /dev/sda2:/boot -m /dev/sda1:/boot/efi -o allow_other --rw mnt  


.PHONY: download-image
.PHONY: mount umount