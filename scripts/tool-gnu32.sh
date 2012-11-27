#! /bin/bash

export JOBS=3

export BZ=tar.bz2
export GZ=tar.gz
export XZ=tar.xz

export AUTOCONF_VERSION=2.69
export AUTOCONF_SUFFIX=${XZ}
export AUTOMAKE_VERSION=1.12.3
export AUTOMAKE_SUFFIX=${XZ}
export LLVM_VERSION=3.1
export LLVM_SUFFIX=${GZ}
export LINUX_VERSION=3.3.7
export LINUX_SUFFIX=${XZ}
export GMP_VERSION=5.0.5
export GMP_SUFFIX=${XZ}
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
export EGLIBC_VERSION=2.15
export EGLIBC_SUFFIX=${XZ}
export EGLIBCPORTS_VERSION=2.15
export EGLIBCPORTS_SUFFIX=${XZ}
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

export METADATA32=${SCRIPT}/../metadata/gnu32

export SRC32=${SCRIPT}/../src/mips-linux-tool

export BUILD32=${SCRIPT}/../build/mips-linux-tool

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

[ -d "${SRC32}" ] || mkdir -p "${SRC32}"

[ -d "${BUILD32}" ] || mkdir -p "${BUILD32}"

[ -d "${METADATA32}" ] || mkdir -p "${METADATA32}"

#################################################################
### 32bit gnu extract
#################################################################
pushd ${SRC32}
[ -f ${METADATA32}/linux_extract ] || \
tar xf ${TARBALL}/linux-${LINUX_VERSION}.${LINUX_SUFFIX} || \
  die "extract linux error" && \
    touch ${METADATA32}/linux_extract

[ -f ${METADATA32}/gmp_extract ] || \
tar xf ${TARBALL}/gmp-${GMP_VERSION}.${GMP_SUFFIX} || \
  die "extract gmp error" && \
    touch ${METADATA32}/gmp_extract

[ -f ${METADATA32}/mpfr_extract ] || \
tar xf ${TARBALL}/mpfr-${MPFR_VERSION}.${MPFR_SUFFIX} || \
  die "extract mpfr error" && \
    touch ${METADATA32}/mpfr_extract

[ -f ${METADATA32}/mpc_extract ] || \
tar xf ${TARBALL}/mpc-${MPC_VERSION}.${MPC_SUFFIX} || \
  die "extract mpc error" && \
    touch ${METADATA32}/mpc_extract

[ -f ${METADATA32}/ppl_extract ] || \
tar xf ${TARBALL}/ppl-${PPL_VERSION}.${PPL_SUFFIX} || \
  die "extract ppl error" && \
    touch ${METADATA32}/ppl_extract

[ -f ${METADATA32}/cloog_extract ] || \
tar xf ${TARBALL}/cloog-${CLOOG_VERSION}.${CLOOG_SUFFIX} || \
  die "extract cloog error" && \
    touch ${METADATA32}/cloog_extract

[ -f ${METADATA32}/binutils_extract ] || \
tar xf ${TARBALL}/binutils-${BINUTILS_VERSION}.${BINUTILS_SUFFIX} || \
  die "extract binutils error" && \
    touch ${METADATA32}/binutils_extract

[ -f ${METADATA32}/gcc_extract ] || \
tar xf ${TARBALL}/gcc-${GCC_VERSION}.${GCC_SUFFIX} || \
  die "extract gcc error" && \
    touch ${METADATA32}/gcc_extract

[ -f ${METADATA32}/eglibc_extract ] || \
tar xf ${TARBALL}/eglibc-${EGLIBC_VERSION}-r21467.${EGLIBC_SUFFIX} || \
  die "extract eglibc error" && \
    touch ${METADATA32}/eglibc_extract

pushd ${SRC32}/eglibc-${EGLIBC_VERSION}
[ -f ${METADATA32}/eglibc_ports_extract ] || \
tar xf ${TARBALL}/eglibc-ports-${EGLIBCPORTS_VERSION}-r21467.${EGLIBCPORTS_SUFFIX} || \
  die "extract eglibc ports error" && \
    touch ${METADATA32}/eglibc_ports_extract
popd

[ -f ${METADATA32}/gdb_extract ] || \
tar xf ${TARBALL}/gdb-${GDB_VERSION}.${GDB_SUFFIX} || \
  die "extract gdb error" && \
    touch ${METADATA32}/gdb_extract
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
### 32bit gnu build
#################################################################
pushd ${SRC32}
cd linux-${LINUX_VERSION}
make distclean
[ -f ${METADATA32}/linux_headers_install ] || make mrproper
[ -f ${METADATA32}/linux_headers_install ] || \
  make ARCH=mips headers_check || die "***check headers error 32bit"
[ -f ${METADATA32}/linux_headers_install ] || \
  make ARCH=mips INSTALL_HDR_PATH=${SYSROOT32}/usr headers_install || \
    die "***install headers error 32bit" && \
      touch ${METADATA32}/linux_headers_install
make distclean
popd

pushd ${SRC32}
unset CFLAGS
[ -d "gmp-${GMP_VERSION}" ] \
  || tar xf ${TARBALL}/gmp-${GMP_VERSION}.${GMP_SUFFIX}
cd gmp-${GMP_VERSION}
[ -f ${METADATA32}/gmp_configure ] || \
CPPFLAGS=-fexceptions ./configure \
  --prefix=${PREFIX32} --enable-cxx || die "***config gmp error 32bit" && \
    touch ${METADATA32}/gmp_configure
[ -f ${METADATA32}/gmp_build ] || \
make -j${JOBS} || die "***build gmp error 32bit" && \
  touch ${METADATA32}/gmp_build
[ -f ${METADATA32}/gmp_install ] || \
make install || die "***install gmp error 32bit" && \
touch ${METADATA32}/gmp_install
export CFLAGS="-w"
popd

pushd ${SRC32}
[ -d "mpfr-${MPFR_VERSION}" ] \
  || tar xf ${TARBALL}/mpfr-${MPFR_VERSION}.${MPFR_SUFFIX}
cd mpfr-${MPFR_VERSION}
[ -f ${METADATA32}/mpfr_configure ] || \
LDFLAGS="-Wl,-rpath,${PREFIX32}/lib" \
./configure --prefix=${PREFIX32} \
    --enable-shared --with-gmp=${PREFIX32} || \
      die "***config mpfr error 32bit" && \
        touch ${METADATA32}/mpfr_configure
[ -f ${METADATA32}/mpfr_build ] || \
make -j${JOBS} || die "***build mpfr error 32bit" && \
  touch ${METADATA32}/mpfr_build
[ -f ${METADATA32}/mpfr_install ] || \
make install || die "***install mpfr error 32bit" && \
  touch ${METADATA32}/mpfr_install
popd

pushd ${SRC32}
[ -d "mpc-${MPC_VERSION}" ] \
  || tar xf ${TARBALL}/mpc-${MPC_VERSION}.${MPC_SUFFIX}
cd mpc-${MPC_VERSION}
[ -f ${METADATA32}/mpc_configure ] || \
LDFLAGS="-Wl,-rpath,${PREFIX32}/lib" \
./configure --prefix=${PREFIX32} \
  --with-gmp=${PREFIX32} \
  --with-mpfr=${PREFIX32} || die "***config mpc error 32bit" && \
     touch ${METADATA32}/mpc_configure
[ -f ${METADATA32}/mpc_build ] || \
make -j${JOBS} || die "***config mpc error 32bit" && \
  touch ${METADATA32}/mpc_build
[ -f ${METADATA32}/mpc_install ] || \
make install || die "***install mpc error 32bit" && \
  touch ${METADATA32}/mpc_install
popd

pushd ${SRC32}
[ -d "ppl-${PPL_VERSION}" ] \
  || tar xf ${TARBALL}/ppl-${PPL_VERSION}.${PPL_SUFFIX}
cd ppl-${PPL_VERSION}
[ -f ${METADATA32}/ppl_configure ] || \
CPPFLAGS="-I${PREFIX32}/include" \
  LDFLAGS="-Wl,-rpath,${PREFIX32}/lib" \
  ./configure --prefix=${PREFIX32} --enable-shared \
  --enable-interfaces="c,cxx" --disable-optimization \
  --with-libgmp-prefix=${PREFIX32} \
  --with-libgmpxx-prefix=${PREFIX32} || die "***config ppl error 32bit" && \
    touch ${METADATA32}/ppl_configure
[ -f ${METADATA32}/ppl_build ] || \
make -j${JOBS} || die "***build ppl error 32bit" && \
  touch ${METADATA32}/ppl_build
[ -f ${METADATA32}/ppl_install ] || \
make install || die "***install ppl error 32bit" && \
  touch ${METADATA32}/ppl_install
popd

pushd ${SRC32}
[ -d "cloog-${CLOOG_VERSION}" ] \
  || tar xf ${TARBALL}/cloog-${CLOOG_VERSION}.${CLOOG_SUFFIX}
cd cloog-${CLOOG_VERSION}
cp -v configure{,.orig}
sed -e "/LD_LIBRARY_PATH=/d" \
  configure.orig > configure
[ -f ${METADATA32}/cloog_configure ] || \
LDFLAGS="-Wl,-rpath,${PREFIX32}/lib" \
  ./configure --prefix=${PREFIX32} --enable-shared \
  --with-gmp-prefix=${PREFIX32} || die "***config cloog error 32bit" && \
    touch ${METADATA32}/cloog_configure
[ -f ${METADATA32}/cloog_build ] || \
make -j${JOBS} || die "***build cloog error 32bit" && \
    touch ${METADATA32}/cloog_build
[ -f ${METADATA32}/cloog_install ] || \
  make install || die "***install cloog error 32bit" && \
    touch ${METADATA32}/cloog_install
popd

pushd ${BUILD32}
[ -d "binutils-build" ] || mkdir binutils-build
cd binutils-build
[ -f "${METADATA32}/binutils_configure" ] || AS="as" AR="ar" \
  ${SRC32}/binutils-${BINUTILS_VERSION}/configure \
  --prefix=${PREFIX32} --host=${CROSS_HOST} --target=${CROSS_TARGET32} \
  --with-sysroot=${SYSROOT32} --with-lib-path=${SYSROOT32}/usr/lib \
  --disable-nls --enable-shared \
  --enable-cloog-backend=isl --enable-poison-system-directories \
  --with-gmp=${PREFIX32} --with-mpfr=${PREFIX32} \
  --with-ppl=${PREFIX32} --with-cloog=${PREFIX32} \
  --with-build-sysroot=${SYSROOT32} || \
    die "***config 32bit binutils error" && \
      touch ${METADATA32}/binutils_configure
[ -f ${METADATA32}/binutils_build ] || \
  make configure-host || die "config 32bit binutils host error"
[ -f ${METADATA32}/binutils_build ] || \
  make -j${JOBS} || die "***build 32bit binutils error" && \
    touch ${METADATA32}/binutils_build
[ -f ${METADATA32}/binutils_install ] || \
  make install || die "***install 32bit binutils error" && \
    touch ${METADATA32}/binutils_install
popd

pushd ${BUILD32}
[ -d "gcc-build-stage1" ] || mkdir gcc-build-stage1
cd gcc-build-stage1
[ -f "${METADATA32}/gcc_stage1_configure" ] || \
  AR=ar LDFLAGS="-Wl,-rpath,${PREFIX32}/lib" \
  ${SRC32}/gcc-${GCC_VERSION}/configure \
  --prefix=${PREFIX32} --build=${CROSS_HOST} --host=${CROSS_HOST} \
  --target=${CROSS_TARGET32} --with-sysroot=${SYSROOT32} \
  --with-local-prefix=${SYSROOT32}/usr --disable-nls \
  --disable-shared \
  --without-headers --with-newlib --disable-decimal-float \
  --disable-libgomp --disable-libmudflap --disable-libssp \
  --disable-threads --enable-languages=c \
  --enable-cloog-backend=isl \
  --with-gmp=${PREFIX32} --with-mpfr=${PREFIX32} \
  --with-ppl=${PREFIX32} --with-cloog=${PREFIX32} \
  --enable-poison-system-directories --with-build-sysroot=${SYSROOT32} || \
    die "***config 32bit gcc stage1 error" && \
      touch ${METADATA32}/gcc_stage1_configure
[ -f "${METADATA32}/gcc_stage1_build" ] || \
  make -j${JOBS} all-gcc all-target-libgcc || \
    die "***build 32bit gcc stage1 error" && \
      touch ${METADATA32}/gcc_stage1_build
[ -f "${METADATA32}/gcc_stage1_install" ] || \
  make install-gcc install-target-libgcc || \
    die "***install 32bit gcc stage1 error" && \
      touch ${METADATA32}/gcc_stage1_install
popd

pushd ${SRC32}
cd eglibc-${EGLIBC_VERSION}
cp -v Makeconfig{,.orig}
sed -e 's/-lgcc_eh//g' Makeconfig.orig > Makeconfig
popd

pushd ${BUILD32}
[ -d "eglibc-build-o32" ] || mkdir eglibc-build-o32
cd eglibc-build-o32
cat > config.cache << "EOF"
libc_cv_forced_unwind=yes
libc_cv_c_cleanup=yes
libc_cv_gnu89_inline=yes
libc_cv_ssp=no
EOF
cat > configparms << EOF
install_root=${SYSROOT32}
EOF
[ -f "${METADATA32}/eglibc_configure_32" ] || \
  BUILD_CC="gcc" CC="${CROSS_TARGET32}-gcc" \
  AR="${CROSS_TARGET32}-ar" RANLIB="${CROSS_TARGET32}-ranlib" \
  CFLAGS_FOR_TARGET="-O2" CFLAGS="-O2" \
  ${SRC32}/eglibc-${EGLIBC_VERSION}/configure \
  --prefix=/usr --host=${CROSS_TARGET32} --build=${CROSS_HOST} \
  --disable-profile --enable-add-ons \
  --with-tls --enable-kernel=2.6.0 --with-__thread \
  --with-binutils=${PREFIX32}/bin --with-headers=${SYSROOT32}/usr/include \
  --cache-file=config.cache || \
    die "***config 32bit eglibc error" && \
      touch ${METADATA32}/eglibc_configure_32
[ -f "${METADATA32}/eglibc_build_32" ] || \
  make -j${JOBS} || die "***build 32bit eglibc error" && \
    touch ${METADATA32}/eglibc_build_32
[ -f "${METADATA32}/eglibc_install_32" ] || \
  make install inst_vardbdir=${SYSROOT32}/var/db || \
    die "***install 32bit eglibc error" && \
      touch ${METADATA32}/eglibc_install_32
popd

pushd ${BUILD32}
[ -d "gcc-build-stage2" ] || mkdir gcc-build-stage2
cd gcc-build-stage2
[ -f "${METADATA32}/gcc_stage2_configure" ] || \
  AR=ar LDFLAGS="-Wl,-rpath,${PREFIX32}/lib" \
  ${SRC32}/gcc-${GCC_VERSION}/configure \
  --prefix=${PREFIX32} --build=${CROSS_HOST} --target=${CROSS_TARGET32} \
  --host=${CROSS_HOST} --with-sysroot=${SYSROOT32} \
  --with-local-prefix=/${SYSROOT32}/usr \
  --disable-nls \
  --enable-shared --enable-languages=c,c++ --enable-__cxa_atexit \
  --enable-c99 \
  --enable-long-long --enable-threads=posix \
  --enable-cloog-backend=isl \
  --with-gmp=${PREFIX32} --with-mpfr=${PREFIX32} \
  --with-ppl=${PREFIX32} --with-cloog=${PREFIX32} \
  --enable-poison-system-directories --with-build-sysroot=${SYSROOT32} || \
    die "***config 32bit gcc stage2 error" && \
      touch ${METADATA32}/gcc_stage2_configure
[ -f "${METADATA32}/gcc_stage2_build" ] || \
  make -j${JOBS} \
    AS_FOR_TARGET="${CROSS_TARGET32}-as" \
    LD_FOR_TARGET="${CROSS_TARGET32}-ld" \
      || die "***build 32bit gcc stage2 error" && \
        touch ${METADATA32}/gcc_stage2_build
[ -f "${METADATA32}/gcc_stage2_install" ] || \
  make install || die "***install 32bit gcc stage2 error" && \
    touch ${METADATA32}/gcc_stage2_install
popd

pushd ${BUILD32}
[ -d "gdb-build" ] || mkdir gdb-build
cd gdb-build
[ -f "${METADATA32}/gdb_configure" ] || \
  ${SRC32}/gdb-${GDB_VERSION}/configure \
  --prefix=${PREFIX32} --target=${CROSS_TARGET32} \
  --with-sysroot=${SYSROOT32} --with-lib-path=${SYSROOT32}/usr/lib \
  --enable-poison-system-directories --with-build-sysroot=${SYSROOT32} || \
    die "***config 32bit gdb error" && \
      touch ${METADATA32}/gdb_configure
[ -f "${METADATA32}/gdb_build" ] || \
  make -j${JOBS} || die "***build 32bit gdb error" && \
    touch ${METADATA32}/gdb_build
[ -f "${METADATA32}/gdb_install" ] || \
  make install || die "***install 32bit gdb error" && \
    touch ${METADATA32}/gdb_install
popd