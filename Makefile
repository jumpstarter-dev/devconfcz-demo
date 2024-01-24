DEVICE=rpi4-00

###############################################################################
# Targets that interact with the DUT via Jumpstarter
###############################################################################

test-in-hardware: umount images/latest.raw images/.prepared
	jumpstarter run-script test-tpm-on-latest-raw.yaml

write-image: umount images/latest.raw images/.prepared
	jumpstarter run-script setup-latest-raw.yaml

power-on:
	jumpstarter power on -a $(DEVICE)

console:
	jumpstarter console $(DEVICE)

power-off:
	jumpstarter detach-storage $(DEVICE)
	jumpstarter power off $(DEVICE)

###############################################################################
# Image preparation targets
###############################################################################

download-image:
	scripts/download-latest-fedora

prepare-image: images/latest.raw mount
	scripts/prepare-latest-raw
	touch images/.prepared
	umount mnt

images/.prepared:
	make prepare-image

images/latest.raw.xz:
	make download-image
	
images/latest.raw: images/latest.raw.xz
	xz -d -v -T0 -k $^
	touch images/latest.raw
	rm -f images/.prepared

clean-image:
	rm -f images/.prepared
	rm -f images/latest.raw

clean-images: clean-image
	rm -rf images/dl.fedoraproject.org
	rm -rf images/latest.raw.xz

###############################################################################
# Image manipulation targets
###############################################################################

mnt:
	mkdir -p $@

umount:
	umount mnt || true

mount: umount images/latest.raw mnt
	guestmount -a images/latest.raw -m /dev/fedora/root -m /dev/sda2:/boot -m /dev/sda1:/boot/efi -o allow_other --rw mnt  


###############################################################################
# phony targets are targets which don't produce files, just for utility
###############################################################################


.PHONY: download-image prepare-image
.PHONY: test-in-hardware
.PHONY: write-image
.PHONY: power-on power-off
.PHONY: console
.PHONY: mount umount
