#! /bin/bash

export JOBS=16


export BZ=tar.bz2
export GZ=tar.gz
export XZ=tar.xz

export BUSYBOX_VERSION=1.20.1
export BUSYBOX_SUFFIX=${BZ}

export IMAGE=busybox-mul64.img
export MOUNT_POINT=busybox_mount

function die() {
  echo "$1"
  exit 1
}

export SCRIPT="$(pwd)"
export TARBALL=${SCRIPT}/../tarballs
export PATCH=${SCRIPT}/../patches
export CONFIG=${SCRIPT}/../configs
export SRCS=${SCRIPT}/../srcs
export SRC=${SCRIPT}/../src/busybox-mul64
export BUILD=${SCRIPT}/../build/busybox-mul64
export METADATAMUL64=${SCRIPT}/../metadata/busybox-mul64

[ -d "${SRC}" ] || mkdir -p "${SRC}"
[ -d "${BUILD}" ] || mkdir -p "${BUILD}"
[ -d "${METADATAMUL64}" ] || mkdir -p "${METADATAMUL64}"

unset CFLAGS
unset CXXFLAGS
export CROSS_HOST=${MACHTYPE}
export CROSS_TARGET="mips64el-unknown-linux-gnu"

[[ $# -eq 1 ]] || die "usage: $0 PREFIX"
export PREFIX="$1"
export PREFIX64=${PREFIX}/gnu64
export PREFIXGNULINUX=${PREFIX}/gnu-linux
export PATH=${PATH}:${PREFIX64}/bin
export SYSROOT=${PREFIX64}/${CROSS_TARGET}/sys-root/

# Change ABI, Change libdir (LIB).
export ABI=64
export BUILDFLAG="-mabi=${ABI}"
export LIB=lib64

export CC=${CROSS_TARGET}-gcc
export CFLAGS="-isystem ${SYSROOT}/usr/include ${BUILDFLAG}"
export CXX=${CROSS_TARGET}-g++
export CXXFLAGS="-isystem ${SYSROOT}/usr/include ${BUILDFLAG}"
export LDFLAGS="-Wl,-rpath-link,${SYSROOT}/usr/${LIB}:${SYSROOT}/${LIB} ${BUILDFLAG}"

[ -f ${PREFIX64}/bin/${CC} ] || die "No toolchain found, process error"

#export BUSYBOX_OPTIONS="static dynamic"
export BUSYBOX_OPTIONS="dynamic"

# Begin for loop, build static/dynamic busybox.
for option in ${BUSYBOX_OPTIONS}; do

[ -f ${METADATAMUL64}/busybox-${option}-create ] || \
  mkdir ${SRC}/busybox-$option || \
    die "busybox-${option}-create dir create failed" && \
      touch ${METADATAMUL64}/busybox-${option}-create

pushd ${SRC}/busybox-$option
[ -f ${METADATAMUL64}/busybox-${option}-extract ] || \
  tar xf ${TARBALL}/busybox-${BUSYBOX_VERSION}.${BUSYBOX_SUFFIX} || \
    die "busybox-${option}-extract error" && \
      touch ${METADATAMUL64}/busybox-${option}-extract

cd busybox-${BUSYBOX_VERSION}
[ -f ${METADATAMUL64}/busybox-${option}-patch-busybox-${BUSYBOX_VERSION} ] || \
  patch -Np1 -i ${PATCH}/busybox-${BUSYBOX_VERSION}.patch || \
    die "Patch failed" && \
      touch ${METADATAMUL64}/busybox-${option}-patch-busybox-${BUSYBOX_VERSION}
[ -f ${METADATAMUL64}/busybox-${option}-patch-busybox-mips64el-${option}_defconfig ] || \
  patch -Np1 -i ${PATCH}/busybox-mips64el-${option}_defconfig.patch \
    || die "Patch failed" && \
      touch ${METADATAMUL64}/busybox-${option}-patch-busybox-mips64el-${option}_defconfig
[ -f ${METADATAMUL64}/busybox-${option}-config ] || \
  make mips64el-${option}_defconfig || \
    die "busybox-${option}-config error" && \
      touch ${METADATAMUL64}/busybox-${option}-config
[ -f ${METADATAMUL64}/busybox-${option}-build ] || \
  make -j${JOBS} ARCH=mips CROSS_COMPILE=${CROSS_TARGET}- || \
    die "busybox-${option}-build error" && \
      touch ${METADATAMUL64}/busybox-${option}-build
[ -f ${METADATAMUL64}/busybox-${option}-install ] || \
  make ARCH=mips CROSS_COMPILE=${CROSS_TARGET}- install || \
    die "busybox-${option}-install error" && \
      touch ${METADATAMUL64}/busybox-${option}-install
popd

# Make BusyBox Image
pushd ${SRC}/busybox-$option
dd if=/dev/zero of=${IMAGE} bs=4k count=512k
echo y | mkfs.ext3 ${IMAGE}
[ -d "${MOUNT_POINT}" ] || mkdir ${MOUNT_POINT}
sudo mount -o loop ${IMAGE} ${MOUNT_POINT}

# Build BusyBox File System
cp -ar ${SRC}/busybox-$option/busybox-${BUSYBOX_VERSION}/_install/* ${MOUNT_POINT}
sudo cp -ar ${SRC}/busybox-$option/busybox-${BUSYBOX_VERSION}/examples/bootfloppy/etc \
  ${MOUNT_POINT}/
mkdir ${MOUNT_POINT}/dev
mkdir ${MOUNT_POINT}/proc

sudo cp -a /dev/zero ${MOUNT_POINT}/dev/
sudo cp -a /dev/console ${MOUNT_POINT}/dev/
sudo cp -a /dev/null ${MOUNT_POINT}/dev/
sudo cp -a /dev/tty ${MOUNT_POINT}/dev/
sudo cp -a /dev/tty2 ${MOUNT_POINT}/dev/
sudo cp -a /dev/ttyS0 ${MOUNT_POINT}/dev/

# Copy Library to File System
if [ -d ${SYSROOT}/lib ]; then
    cp -ar ${SYSROOT}/lib ${MOUNT_POINT}/
fi

if [ -d ${SYSROOT}/lib32 ]; then
    cp -ar ${SYSROOT}/lib32 ${MOUNT_POINT}/
fi

if [ -d ${SYSROOT}/lib64 ]; then
    cp -ar ${SYSROOT}/lib64 ${MOUNT_POINT}/
fi

sudo echo "/bin/mount -o remount,rw /" >> ${MOUNT_POINT}/etc/init.d/rcS
sudo umount ${MOUNT_POINT}

popd

[ -d ${PREFIXGNULINUX} ] || mkdir -p ${PREFIXGNULINUX}
mv ${SRC}/busybox-$option/${IMAGE} ${PREFIXGNULINUX}
# End for loop, build static/dynamic busybox.
done