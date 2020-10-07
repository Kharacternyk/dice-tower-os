![](screenshot.png?raw=true)

Dice Tower OS is a bootable image written in [Flat Assembly](https://flatassembler.net/)
that emulates a [dice tower](https://en.wikipedia.org/wiki/Dice_tower) and fits into a
boot sector of 512 bytes. It implements the 16-bit variant of the
[xorshift algorithm](https://en.wikipedia.org/wiki/Xorshift). Dice Tower OS uses BIOS
interrupts, hence it requires a PC with BIOS or BIOS-compatible UEFI.

###### Get it running

Grab a binary disk image from the releases page. Then either specify the disk image
while creating a virtual machine (there should be an option like
_import existing disk image_) or create a bootable USB flash drive to boot into it on
some real hardware (**the filesystem on the flash drive will be destroyed; make sure you
don't need the data anymore**):

1. `dd if=/path/to/image of=/dev/your_flash_drive` or use a GUI bootable USB creator.
2. **Unplug the internal HDD or SSD of the PC to make sure that Dice Tower can not damage
their file systems.** Dice Tower doesn't contain any code to read or write to drives, but
this step is recommended anyway.
3. Choose the flash drive in the BIOS/UEFI boot menu.

###### Keys to press

- Press _1-9_ to change the dice count.
- Press _Space_ to roll the dice.
