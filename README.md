Cross-SDK
=========


This is a OpenSource Cross Platform SDK.

The development project for Cross-SDK is https://github.com/elta/Cross-SDK.
The development repository is https://github.com/elta/Cross-SDK.git

Our aim is build a user friendly Cross SDK for a Real Time GNU/Linux system
which using LLVM/Clang as default compiler, you are welcome to use and hack
this project, we can make it better together.

I'll try my best to fix all the toolchain bugs, and keep the other members
maintain their part of the SDK.

===============================================================================
Version History:
0.9:
- Build QT-Creator Plugin instead of the whole QT-Creator.

0.8:
- Add OpenOCD.
- KUbuntu 13.04 well tested all of the scripts.
- KUbuntu 12.10 AMD64 no longger tested.

0.7:
- Remove busybox support, minimal-system and command-line-tools.
- Add SSH support.
- New IDE plugin support(still in develop).

0.6:
- OS X Mountain Lion well tested minimal-system now!

0.5:
- Combine ${SRC} as possible as we can, saving a huge disk space.

0.4:
- Slipt scripts.
- OS X Mountain Lion well tested command-line-tools and development-kit,
  KUbuntu 12.10 AMD64 well tested all of the scripts.

0.3:
- OS X Mountain Lion partly support, toolchain and linux kernel can be compiled,
  rootfs and busybox can not.
- Remove RTEMS, baremetal support.
- KUbuntu 12.04 AMD64 no longger tested.

0.2:
- KUbuntu 12.10 AMD64 well tested.
- Compile GNU rootfs using sysroot way.

0.1:
- KUbuntu 12.04 AMD64 well tested.

===============================================================================
TODO:
- Switch to LLVMLinux
- Make Clang to be the default compiler
- IDE Debugger, Static Analyzer, U-Boot & Linux config support

===============================================================================
Prerequisites:
OS X Mountain Lion is partly suppoted, we are using Homebrew, and we need a
Case-sensitive, Journaled FS or working DMG.
You need run this in your terminal:
brew install autoconf autoconf213 automake bash-completion cmake coreutils \
             ext2fuse fuse4x fuse4x-kext gawk gettext glib gnu-getopt gnu-sed \
             libelf libffi libpng libtool p7zip pixman pkg-config qt texinfo \
             unrar wget xz zlib

(K)Ubuntu 12.10 AMD64 and (K)Ubuntu 12.04 AMD64 are well tested.
You need run this in your terminal:
sudo apt-get install libncurses5-dev libgtk2.0-dev libqt4-dev g++ flex bison \
                     cmake automake gawk libtool gettext gperf dejagnu \
                     guile-2.0 autogen texinfo patch xz-utils

You are welcome to test it on other platforms.

===============================================================================
Usage:
${SCRIPT}.sh

Example:
run
./mipsel-development-kit.sh
to get a SDK.

run
./mipsel-system.sh
to get gnu root fs.

If you were to use qemu with network:
sudo tunctl -t qemutap
sudo ifconfig qemutap 10.0.0.1
sudo qemu-system-mipsel -kernel vmlinux-32 -hda mipsel-rootfs.img -append "root=/dev/hda" -nographic  -net nic -net tap,ifname=qemutap,script=no,downscript=no -M malta

Notice:
It will take a lot of space in your disk, make sure you run them in a big
partation:)
Make sure you have run ./get-sources.sh first, if you got failed,
just run it again.
Run ./cleanup.sh to free your disk space.

===============================================================================
GNU root FS is partly come from CLFS, IDE-plugin is writen by Yu Tang at
https://github.com/tangbongbong/qt-crossprojectmanager.

===============================================================================
The last thing, Happy Hacking:)