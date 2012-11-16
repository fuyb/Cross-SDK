#! /bin/bash

export JOBS=3

export BZ=tar.bz2
export GZ=tar.gz
export XZ=tar.xz

export AUTOCONF_VERSION=2.69
export AUTOCONF_SUFFIX=${XZ}
export AUTOMAKE_VERSION=1.12.1
export AUTOMAKE_SUFFIX=${XZ}
export LLVM_VERSION=3.1
export LLVM_SUFFIX=${BZ}
export LINUX_VERSION=3.3.7
export LINUX_SUFFIX=${BZ}
export GMP_VERSION=5.0.5
export GMP_SUFFIX=${BZ}
export MPFR_VERSION=3.1.0
export MPFR_SUFFIX=${BZ}
export MPC_VERSION=0.9
export MPC_SUFFIX=${GZ}
export PPL_VERSION=0.11.2
export PPL_SUFFIX=${BZ}
export CLOOG_VERSION=0.16.3
export CLOOG_SUFFIX=${GZ}
export BINUTILS_VERSION=2.22
export BINUTILS_SUFFIX=${BZ}
export GCC_VERSION=4.6.3
export GCC_SUFFIX=${BZ}
export GLIBC_VERSION=2.15
export GLIBC_SUFFIX=${BZ}
export NEWLIB_VERSION=1.20.0
export NEWLIB_SUFFIX=${GZ}
export GDB_VERSION=7.4
export GDB_SUFFIX=${BZ}
export QEMU_VERSION=1.1.1
export QTC_VERSION=2.5.2-src
export TERMCAP_VERSION=1.3.1
export TERMCAP_SUFFIX=${GZ}

function die() {
  echo "$1"
  exit 1
}

export SCRIPT="$(pwd)"
export TARBALL=${SCRIPT}/../tarballs
export PATCH=${SCRIPT}/../patches

export METADATABARE32=${SCRIPT}/../metadata/elf32

export SRCBARE32=${SCRIPT}/../src/mips-elf-tool

export BUILDBARE32=${SCRIPT}/../build/mips-elf-tool

[[ $# -eq 1 ]] || die "usage: $0 PREFIX"
export PREFIX="$1"
export PREFIX64=${PREFIX}/gnu64
export PREFIX32=${PREFIX}/gnu32
export RTEMSPREFIX64=${PREFIX}/rtems64
export RTEMSPREFIX32=${PREFIX}/rtems32
export BAREPREFIX64=${PREFIX}/elf64
export BAREPREFIX32=${PREFIX}/elf32
export QEMUPREFIX=${PREFIX}/qemu
export LLVMPREFIX=${PREFIX}/llvm
export QTCPREFIX=${PREFIX}/qt-creator
export PATH=${PATH}:${PREFIX64}/bin:${PREFIX32}/bin:${RTEMSPREFIX64}/bin:${RTEMSPREFIX32}/bin:${BAREPREFIX64}/bin:${BAREPREFIX32}/bin

[ -d "${SRCBARE32}" ] || mkdir -p "${SRCBARE32}"

[ -d "${BUILDBARE32}" ] || mkdir -p "${BUILDBARE32}"

[ -d "${METADATABARE32}" ] || mkdir -p "${METADATABARE32}"

#################################################################
### 32bit bare extract
#################################################################
pushd ${SRCBARE32}
[ -f ${METADATABARE32}/gmp_extract ] || \
(tar xf ${TARBALL}/gmp-${GMP_VERSION}.${GMP_SUFFIX} || \
  die "extract gmp error" ) && \
    touch ${METADATABARE32}/gmp_extract

[ -f ${METADATABARE32}/mpfr_extract ] || \
(tar xf ${TARBALL}/mpfr-${MPFR_VERSION}.${MPFR_SUFFIX} || \
  die "extract mpfr error" ) && \
    touch ${METADATABARE32}/mpfr_extract

[ -f ${METADATABARE32}/mpc_extract ] || \
(tar xf ${TARBALL}/mpc-${MPC_VERSION}.${MPC_SUFFIX} || \
  die "extract mpc error" ) && \
    touch ${METADATABARE32}/mpc_extract

[ -f ${METADATABARE32}/binutils_extract ] || \
(tar xf ${TARBALL}/binutils-${BINUTILS_VERSION}.${BINUTILS_SUFFIX} || \
  die "extract binutils error" ) && \
    touch ${METADATABARE32}/binutils_extract

[ -f ${METADATABARE32}/gcc_extract ] || \
(tar xf ${TARBALL}/gcc-${GCC_VERSION}.${GCC_SUFFIX} || \
  die "extract gcc error" ) && \
    touch ${METADATABARE32}/gcc_extract

[ -f ${METADATABARE32}/newlib_extract ] || \
(tar xf ${TARBALL}/newlib-${NEWLIB_VERSION}.${NEWLIB_SUFFIX} || \
  die "extract newlib error" ) && \
    touch ${METADATABARE32}/newlib_extract

[ -f ${METADATABARE32}/gdb_extract ] || \
(tar xf ${TARBALL}/gdb-${GDB_VERSION}.${GDB_SUFFIX} || \
  die "extract gdb error" ) && \
    touch ${METADATABARE32}/gdb_extract
popd

unset CFLAGS
unset CXXFLAGS
export CFLAGS="-w"
export CROSS_HOST=${MACHTYPE}
export CROSS_TARGET64="mips64el-unknown-linux-gnu"
export CROSS_TARGET32="$(echo ${CROSS_TARGET64}| sed -e 's/64//g')"
export CROSS_RTEMSTARGET64="mips64el-rtems4.11"
export CROSS_RTEMSTARGET32="mipsel-rtems4.11"
export CROSS_BARETARGET64="mips64el-unknown-elf"
export CROSS_BARETARGET32="mipsel-unknown-elf"
export SYSROOT64=${PREFIX64}/${CROSS_TARGET64}/sys-root
export SYSROOT32=${PREFIX32}/${CROSS_TARGET32}/sys-root
export O32="-mabi=32"
export N32="-mabi=n32"
export N64="-mabi=64"
export QEMU_TARGET="mips64el-softmmu,mipsel-softmmu,mipsel-linux-user"

#################################################################
### 32bit bare build
#################################################################
pushd ${SRCBARE32}
cd gmp-${GMP_VERSION}
unset CFLAGS
[ -f "${METADATABARE32}/gmp_configure" ] || \
  ./configure --prefix=${BUILDBARE32}/gmp --disable-shared --enable-static || \
    die "***config 32bit bare gmp error" && \
      touch ${METADATABARE32}/gmp_configure
[ -f ${METADATABARE32}/gmp_build ] || \
  make -j${JOBS} || die "***build 32bit bare gmp error" && \
    touch ${METADATABARE32}/gmp_build
[ -f ${METADATABARE32}/gmp_install ] || \
  make install || die "***install 32bit bare gmp error" && \
    touch ${METADATABARE32}/gmp_install
export CFLAGS="-w"
popd

pushd ${SRCBARE32}
cd mpfr-${MPFR_VERSION}
[ -f "${METADATABARE32}/mpfr_configure" ] || \
  ./configure --prefix=${BUILDBARE32}/mpfr --with-gmp=${BUILDBARE32}/gmp \
  --disable-shared --enable-static || \
    die "***config 32bit bare mpfr error" && \
      touch ${METADATABARE32}/mpfr_configure
[ -f "${METADATABARE32}/mpfr_build" ] || \
  make -j${JOBS} || die "***build 32bit bare mpfr error" && \
    touch ${METADATABARE32}/mpfr_build
[ -f "${METADATABARE32}/mpfr_install" ] || \
  make install || die "***install 32bit bare mpfr error" && \
    touch ${METADATABARE32}/mpfr_install
popd

pushd ${SRCBARE32}
cd mpc-${MPC_VERSION}
[ -f "${METADATABARE32}/mpc_configure" ] || \
  ./configure --prefix=${BUILDBARE32}/mpc \
  --with-gmp=${BUILDBARE32}/gmp --with-mpfr=${BUILDBARE32}/mpfr \
  --disable-shared --enable-static || \
    die "***config 32bit bare mpc error" && \
      touch ${METADATABARE32}/mpc_configure
[ -f ${METADATABARE32}/mpc_build ] || \
  make -j${JOBS} || die "***build 32bit bare mpc error" && \
    touch ${METADATABARE32}/mpc_build
[ -f ${METADATABARE32}/mpc_install ] || \
  make install || die "***install 32bit bare mpc error" && \
    touch ${METADATABARE32}/mpc_install
popd

pushd ${BUILDBARE32}
[ -d "binutils-build" ] || mkdir binutils-build
cd binutils-build
[ -f "${METADATABARE32}/binutils_configure" ] || AS="as" AR="ar" \
  ${SRCBARE32}/binutils-${BINUTILS_VERSION}/configure \
  --prefix=${BAREPREFIX32} --target=${CROSS_BARETARGET32} \
  --disable-nls --enable-interwork --disable-shared \
  --enable-threads --with-gcc --with-gnu-as --with-gnu-ld \
  --with-gmp=${BUILDBARE32}/gmp --with-mpfr=${BUILDBARE32}/mpfr \
  --with-mpc=${BUILDBARE32}/mpc || \
    die "***config 32bit bare binutils error" && \
      touch ${METADATABARE32}/binutils_configure
[ -f ${METADATABARE32}/binutils_build ] || \
  make -j${JOBS} all || die "***build 32bit bare binutils error" && \
    touch ${METADATABARE32}/binutils_build
[ -f ${METADATABARE32}/binutils_install ] || \
  make install || die "***install 32bit bare binutils error" && \
    touch ${METADATABARE32}/binutils_install
popd

pushd ${BUILDBARE32}
[ -d "gcc-build-stage" ] || mkdir gcc-build-stage1
cd gcc-build-stage1
[ -f "${METADATABARE32}/gcc_configure_stage1" ] || \
  AR="ar" AS="as" \
  ${SRCBARE32}/gcc-${GCC_VERSION}/configure \
  --prefix=${BAREPREFIX32} --target=${CROSS_BARETARGET32} \
  --enable-interwork --enable-languages=c \
  --with-newlib --disable-nls --disable-shared --enable-threads \
  --with-gnu-as --with-gnu-ld \
  --without-headers --disable-libquadmath --disable-libssp \
  --with-gmp=${BUILDBARE32}/gmp --with-mpfr=${BUILDBARE32}/mpfr \
  --with-mpc=${BUILDBARE32}/mpc || \
    die "***config 32bit bare gcc stage1 error" && \
      touch ${METADATABARE32}/gcc_configure_stage1
[ -f "${METADATABARE32}/gcc_build_stage1" ] || \
  make -j${JOBS} all || die "***build 32bit bare gcc stage1 error" && \
      touch ${METADATABARE32}/gcc_build_stage1
[ -f "${METADATABARE32}/gcc_install_stage1" ] || \
  make install || die "***install 32bit bare gcc stage1 error" && \
      touch ${METADATABARE32}/gcc_install_stage1
popd

pushd ${BUILDBARE32}
[ -d "newlib-build" ] || mkdir newlib-build
cd newlib-build
[ -f "${METADATABARE32}/newlib_configure" ] || \
  ${SRCBARE32}/newlib-${NEWLIB_VERSION}/configure \
  --prefix=${BAREPREFIX32} --target=${CROSS_BARETARGET32} \
  --enable-interwork --with-gnu-as --with-gnu-ld \
  --disable-nls || \
    die "***config 32bit newlib error" && \
      touch ${METADATABARE32}/newlib_configure
[ -f "${METADATABARE32}/newlib_build" ] || \
  make -j${JOBS} || die "***build 32bit newlib error" && \
    touch ${METADATABARE32}/newlib_build
[ -f "${METADATABARE32}/newlib_install" ] || \
  make install || die "***install 32bit newlib error"
    touch ${METADATABARE32}/newlib_install
popd

pushd ${BUILDBARE32}
[ -d "gcc-build-stage2" ] || mkdir gcc-build-stage2
cd gcc-build-stage2
[ -f "${METADATABARE32}/gcc_configure_stage2" ] || \
  AR="ar" AS="as" \
  ${SRCBARE32}/gcc-${GCC_VERSION}/configure \
  --prefix=${BAREPREFIX32} --target=${CROSS_BARETARGET32} \
  --enable-interwork --enable-languages=c,c++ \
  --with-newlib --disable-nls --disable-shared --enable-threads \
  --with-gnu-as --with-gnu-ld \
  --with-gmp=${BUILDBARE32}/gmp --with-mpfr=${BUILDBARE32}/mpfr \
  --with-mpc=${BUILDBARE32}/mpc || \
    die "***config 32bit bare gcc stage2 error" && \
      touch ${METADATABARE32}/gcc_configure_stage2
[ -f "${METADATABARE32}/gcc_build_stage2" ] || \
  make -j${JOBS} all || die "***build 32bit bare gcc stage2 error" && \
      touch ${METADATABARE32}/gcc_build_stage2
[ -f "${METADATABARE32}/gcc_install_stage2" ] || \
  make install || die "***install 32bit bare gcc stage2 error" && \
      touch ${METADATABARE32}/gcc_install_stage2
popd

pushd ${BUILDBARE32}
[ -d "gdb-build" ] || mkdir gdb-build
cd gdb-build
[ -f "${METADATABARE32}/gdb_configure" ] || \
  ${SRCBARE32}/gdb-${GDB_VERSION}/configure \
  --prefix=${BAREPREFIX32} --target=${CROSS_BARETARGET32} \
  --with-gmp=${BUILDBARE32}/gmp --with-mpfr=${BUILDBARE32}/mpfr \
  --with-mpc=${BUILDBARE32}/mpc || \
    die "***config 32bit bare gdb error" && \
      touch ${METADATABARE32}/gdb_configure
[ -f "${METADATABARE32}/gdb_build" ] || \
  make -j${JOBS} || die "***build 32bit bare gdb error" && \
    touch ${METADATABARE32}/gdb_build
[ -f "${METADATABARE32}/gdb_install" ] || \
  make install || die "***install 32bit bare gdb error" && \
    touch ${METADATABARE32}/gdb_install
popd
