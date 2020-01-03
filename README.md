![](screenshot.png?raw=true)

# What is it?

Dice Tower is a programm written in [Flat Assembly](https://flatassembler.net/) that emulates a dice tower and fits into a boot sector of 512 bytes. Internally it uses a variant of [xorshift algorithm](https://en.wikipedia.org/wiki/Xorshift). Dice Tower uses BIOS interrupts, and one should be able to boot into it on any PC with BIOS or BIOS-compatible UEFI (in other words, if a motherboard isn't one of the newest, Dice Tower will boot fine).

# Get it running.

Grab a binary disk image from the releases page. Then either specify the disk image while creating a virtual machine (there should be an option like _import existing disk image_) or create a bootable USB flash drive to boot into it on real hardware:

1. `dd if=/path/to/image of=/dev/your_flash_drive`. **This command will make the filesystem on the flash drive unusable. Make sure you don't need data that is stored on the flash drive anymore.**
2. **Unplug the internal HDD or SSD of the PC to make sure that Dice Tower can not damage their file systems.** Dice Tower doesn't contain any code to read or write to drives, but this step is recommended anyway.
3. Choose the flash drive in the BIOS/UEFI boot menu.
