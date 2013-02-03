#! /bin/bash

source source.sh

[ -d "${SRCMIPSELROOTFS}" ] || mkdir -p "${SRCMIPSELROOTFS}"
[ -d "${BUILDMIPSELROOTFS}" ] || mkdir -p "${BUILDMIPSELROOTFS}"
[ -d "${METADATAMIPSELROOTFS}" ] || mkdir -p "${METADATAMIPSELROOTFS}"

mkdir -p ${PREFIXMIPSELROOTFS}
mkdir -p ${PREFIXMIPSELROOTFS}/cross-tools
export PATH=${PREFIXHOSTTOOLS}/bin:${PREFIXMIPSELROOTFS}/cross-tools/bin:$PATH

#################### Creating Directories ###############
mkdir -pv ${PREFIXMIPSELROOTFS}/{bin,boot,dev,{etc/,}opt,home,lib,mnt,run}
mkdir -pv ${PREFIXMIPSELROOTFS}/{proc,media/{floppy,cdrom},sbin,srv,sys}
mkdir -pv ${PREFIXMIPSELROOTFS}/var/{lock,log,mail,run,spool}
mkdir -pv ${PREFIXMIPSELROOTFS}/var/{opt,cache,lib/{misc,locate},local}
install -dv -m 0750 ${PREFIXMIPSELROOTFS}/root
install -dv -m 1777 ${PREFIXMIPSELROOTFS}{/var,}/tmp
mkdir -pv ${PREFIXMIPSELROOTFS}/usr/{,local/}{bin,include,lib,sbin,src}
mkdir -pv ${PREFIXMIPSELROOTFS}/usr/{,local/}share/{doc,info,locale,man}
mkdir -pv ${PREFIXMIPSELROOTFS}/usr/{,local/}share/{misc,terminfo,zoneinfo}
mkdir -pv ${PREFIXMIPSELROOTFS}/usr/{,local/}share/man/man{1,2,3,4,5,6,7,8}
for dir in ${PREFIXMIPSELROOTFS}/usr{,/local}; do
  ln -sfnv share/{man,doc,info} ${dir}
done
mkdir -pv ${PREFIXMIPSELROOTFS}/etc/sysconfig

cat > ${PREFIXMIPSELROOTFS}/etc/passwd << "EOF"
root::0:0:root:/root:/bin/bash
EOF

cat > ${PREFIXMIPSELROOTFS}/etc/group << "EOF"
root:x:0:
bin:x:1:
sys:x:2:
kmem:x:3:
tty:x:4:
tape:x:5:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
usb:x:14:
cdrom:x:15:
EOF

touch ${PREFIXMIPSELROOTFS}/var/run/utmp ${PREFIXMIPSELROOTFS}/var/log/{btmp,lastlog,wtmp}
touch ${PREFIXMIPSELROOTFS}/run/utmp
chmod -v 664 ${PREFIXMIPSELROOTFS}/run/utmp
chmod -v 664 ${PREFIXMIPSELROOTFS}/var/run/utmp ${PREFIXMIPSELROOTFS}/var/log/lastlog
chmod -v 600 ${PREFIXMIPSELROOTFS}/var/log/btmp

################## End Creating Directories ###############

###############################################################
# mipsel sysroot extract
###############################################################

pushd ${BUILDMIPSELROOTFS}
[ -f ${METADATAMIPSELROOTFS}/linux_extract ] || \
  tar xf ${TARBALL}/linux-${LINUX_VERSION}.${LINUX_SUFFIX} || \
    die "***extract linux error" && \
      touch ${METADATAMIPSELROOTFS}/linux_extract

[ -f ${METADATAMIPSELROOTFS}/iana_extract ] || \
  tar xf ${TARBALL}/iana-etc-${IANA_VERSION}.${IANA_SUFFIX} || \
    die "***extract iana error" && \
      touch ${METADATAMIPSELROOTFS}/iana_extract

[ -f ${METADATAMIPSELROOTFS}/iproute2_extract ] || \
  tar xf ${TARBALL}/iproute2-${IPROUTE2_VERSION}.${IPROUTE2_SUFFIX} || \
    die "***extract iproute2 error" && \
      touch ${METADATAMIPSELROOTFS}/iproute2_extract

[ -f ${METADATAMIPSELROOTFS}/bzip2_extract ] || \
  tar xf ${TARBALL}/bzip2-${BZIP2_VERSION}.${BZIP2_SUFFIX} || \
    die "***extract bzip2 error" && \
      touch ${METADATAMIPSELROOTFS}/bzip2_extract

[ -f ${METADATAMIPSELROOTFS}/man_extract ] || \
  tar xf ${TARBALL}/man-${MAN_VERSION}.${MAN_SUFFIX} || \
    die "***extract man error" && \
      touch ${METADATAMIPSELROOTFS}/man_extract

[ -f ${METADATAMIPSELROOTFS}/bootscript_extract ] || \
  tar xf ${TARBALL}/bootscripts-cross-lfs-${BOOTSCRIPTS_VERSION}.${BOOTSCRIPTS_SUFFIX} || \
    die "***extract bootscript error" && \
      touch ${METADATAMIPSELROOTFS}/bootscript_extract

[ -f ${METADATAMIPSELROOTFS}/vim_extract ] || \
  tar xf ${TARBALL}/vim-${VIM_VERSION}.${VIM_SUFFIX} || \
    die "***extract vim error" && \
      touch ${METADATAMIPSELROOTFS}/vim_extract

[ -f ${METADATAMIPSELROOTFS}/dhcpcd_extract ] || \
  tar xf  ${TARBALL}/dhcpcd-${DHCPCD_VERSION}.${DHCPCD_SUFFIX} || \
    die "***extract dhcpcd error" && \
      touch ${METADATAMIPSELROOTFS}/dhcpcd_extract

[ -f ${METADATAMIPSELROOTFS}/groff_extract_cross ] || \
  tar xf ${TARBALL}/groff-${GROFF_VERSION}.${GROFF_SUFFIX} || \
    die "***extract groff cross error" && \
      touch ${METADATAMIPSELROOTFS}/groff_extract_cross

[ -f ${METADATAMIPSELROOTFS}/perl_extract ] || \
  tar xf ${TARBALL}/perl-${PERL_VERSION}.${PERL_SUFFIX} || \
    die "***extract perl error" && \
      touch ${METADATAMIPSELROOTFS}/perl_extract

[ -f ${METADATAMIPSELROOTFS}/iputils_extract ] || \
  tar xf ${TARBALL}/iputils-${IPUTILS_VERSION}.${IPUTILS_SUFFIX} || \
    die "***extract iputils error" && \
      touch ${METADATAMIPSELROOTFS}/iputils_extract

popd

pushd ${SRCMIPSELROOTFS}
[ -f ${METADATAMIPSELROOTFS}/perl_cross_extract ] || \
  tar xf ${TARBALL}/perl-${PERLCROSS_VERSION}.tar.gz || \
    die "***extract cross perl error" && \
      touch ${METADATAMIPSELROOTFS}/perl_cross_extract

pushd ${BUILDMIPSELROOTFS}
cd perl-${PERL_VERSION}
[ -f "${METADATAMIPSELROOTFS}/perl_cross_merge" ] || \
  cp -a ${SRCMIPSELROOTFS}/perl-${PERL_VERSION}/* ./ || \
    die "merge cross perl error" && \
      touch ${METADATAMIPSELROOTFS}/perl_cross_merge
popd

[ -f ${METADATAMIPSELROOTFS}/gmp_extract ] || \
  tar xf ${TARBALL}/gmp-${GMP_VERSION}.${GMP_SUFFIX} || \
    die "***extract gmp error" && \
      touch ${METADATAMIPSELROOTFS}/gmp_extract

[ -f ${METADATAMIPSELROOTFS}/mpfr_extract ] || \
  tar xf ${TARBALL}/mpfr-${MPFR_VERSION}.${MPFR_SUFFIX} || \
    die "***extract mpfr error" && \
      touch ${METADATAMIPSELROOTFS}/mpfr_extract

[ -f ${METADATAMIPSELROOTFS}/mpc_extract ] || \
  tar xf ${TARBALL}/mpc-${MPC_VERSION}.${MPC_SUFFIX} || \
    die "***extract mpc error" && \
      touch ${METADATAMIPSELROOTFS}/mpc_extract

[ -f ${METADATAMIPSELROOTFS}/ppl_extract ] || \
  tar xf ${TARBALL}/ppl-${PPL_VERSION}.${PPL_SUFFIX} || \
    die "***extract ppl error" && \
      touch ${METADATAMIPSELROOTFS}/ppl_extract

[ -f ${METADATAMIPSELROOTFS}/cloog_extract ] || \
  tar xf ${TARBALL}/cloog-${CLOOG_VERSION}.${CLOOG_SUFFIX} || \
    die "***extract cloog error" && \
      touch ${METADATAMIPSELROOTFS}/cloog_extract

[ -f ${METADATAMIPSELROOTFS}/binutils_extract ] || \
  tar xf ${TARBALL}/binutils-${BINUTILS_VERSION}.${BINUTILS_SUFFIX} || \
    die "***extract binutils error" && \
      touch ${METADATAMIPSELROOTFS}/binutils_extract

[ -f ${METADATAMIPSELROOTFS}/gcc_extract ] || \
  tar xf ${TARBALL}/gcc-${GCC_VERSION}.${GCC_SUFFIX} || \
    die "***extract gcc error" && \
      touch ${METADATAMIPSELROOTFS}/gcc_extract

[ -f ${METADATAMIPSELROOTFS}/glibc_extract ] || \
  tar xf ${TARBALL}/glibc-${GLIBC_VERSION}.${GLIBC_SUFFIX} || \
    die "***extract glibc error" && \
      touch ${METADATAMIPSELROOTFS}/glibc_extract

[ -f ${METADATAMIPSELROOTFS}/file_extract ] || \
  tar xf ${TARBALL}/file-${FILE_VERSION}.${FILE_SUFFIX} || \
    die "***extract file error" && \
      touch ${METADATAMIPSELROOTFS}/file_extract

[ -f ${METADATAMIPSELROOTFS}/groff_extract ] || \
  tar xf ${TARBALL}/groff-${GROFF_VERSION}.${GROFF_SUFFIX} || \
    die "***extract groff error" && \
      touch ${METADATAMIPSELROOTFS}/groff_extract

[ -f ${METADATAMIPSELROOTFS}/shadow_extract ] || \
  tar xf ${TARBALL}/shadow-${SHADOW_VERSION}.${SHADOW_SUFFIX} || \
    die "***extract shadow error" && \
      touch ${METADATAMIPSELROOTFS}/shadow_extract

[ -f ${METADATAMIPSELROOTFS}/ncurses_extract ] || \
  tar xf ${TARBALL}/ncurses-${NCURSES_VERSION}.${NCURSES_SUFFIX} || \
    die "***extract ncurses error" && \
      touch ${METADATAMIPSELROOTFS}/ncurses_extract

[ -f ${METADATAMIPSELROOTFS}/man-pages_extract ] || \
  tar xf ${TARBALL}/man-pages-${MANPAGES_VERSION}.${MANPAGES_SUFFIX} || \
    die "***extract man pages error" && \
      touch ${METADATAMIPSELROOTFS}/man-pages_extract

[ -f ${METADATAMIPSELROOTFS}/zlib_extract ] || \
  tar xf ${TARBALL}/zlib-${ZLIB_VERSION}.${ZLIB_SUFFIX} || \
    die "***extract zlib error" && \
      touch ${METADATAMIPSELROOTFS}/zlib_extract

[ -f ${METADATAMIPSELROOTFS}/sed_extract ] || \
  tar xf ${TARBALL}/sed-${SED_VERSION}.${SED_SUFFIX} || \
    die "***extract sed error" && \
      touch ${METADATAMIPSELROOTFS}/sed_extract

[ -f ${METADATAMIPSELROOTFS}/util_linux_extract ] || \
  tar xf ${TARBALL}/util-${UTIL_VERSION}.${UTIL_SUFFIX} || \
    die "***extract util-linux error" && \
      touch ${METADATAMIPSELROOTFS}/util_linux_extract

[ -f ${METADATAMIPSELROOTFS}/e2fsprogs_extract ] || \
  tar xf ${TARBALL}/e2fsprogs-${E2FSPROGS_VERSION}.${E2FSPROGS_SUFFIX} || \
    die "***extract e2fsprogs error" && \
      touch ${METADATAMIPSELROOTFS}/e2fsprogs_extract

[ -f ${METADATAMIPSELROOTFS}/coreutils_extract ] || \
  tar xf ${TARBALL}/coreutils-${COREUTILS_VERSION}.${COREUTILS_SUFFIX} || \
    die "***extract coreutils error" && \
      touch ${METADATAMIPSELROOTFS}/coreutils_extract

[ -f ${METADATAMIPSELROOTFS}/m4_extract ] || \
  tar xf ${TARBALL}/m4-${M4_VERSION}.${M4_SUFFIX} || \
    die "***extract m4 error" && \
      touch ${METADATAMIPSELROOTFS}/m4_extract

[ -f ${METADATAMIPSELROOTFS}/bison_extract ] || \
  tar xf ${TARBALL}/bison-${BISON_VERSION}.${BISON_SUFFIX} || \
    die "***extract bison error" && \
      touch ${METADATAMIPSELROOTFS}/bison_extract

[ -f ${METADATAMIPSELROOTFS}/procps_extract ] || \
  tar xf ${TARBALL}/procps-${PROCPS_VERSION}.${PROCPS_SUFFIX} || \
    die "***extract procps error" && \
      touch ${METADATAMIPSELROOTFS}/procps_extract

[ -f ${METADATAMIPSELROOTFS}/libtool_extract ] || \
  tar xf ${TARBALL}/libtool-${LIBTOOL_VERSION}.${LIBTOOL_SUFFIX} || \
    die "***extract libtool error" && \
      touch ${METADATAMIPSELROOTFS}/libtool_extract

[ -f ${METADATAMIPSELROOTFS}/flex_extract ] || \
  tar xf ${TARBALL}/flex-${FLEX_VERSION}.${FLEX_SUFFIX} || \
    die "***extract flex error" && \
      touch ${METADATAMIPSELROOTFS}/flex_extract

[ -f ${METADATAMIPSELROOTFS}/readline_extract ] || \
  tar xf ${TARBALL}/readline-${READLINE_VERSION}.${READLINE_SUFFIX} || \
    die "***extract readline error" && \
      touch ${METADATAMIPSELROOTFS}/readline_extract

[ -f ${METADATAMIPSELROOTFS}/python_extract ] || \
  tar xf ${TARBALL}/python-${PYTHON_VERSION}.${PYTHON_SUFFIX} || \
    die "***extract python error" && \
      touch ${METADATAMIPSELROOTFS}/python_extract

[ -f ${METADATAMIPSELROOTFS}/autoconf_extract ] || \
  tar xf ${TARBALL}/autoconf-${AUTOCONF_VERSION}.${AUTOCONF_SUFFIX} || \
    die "***extract autoconf error" && \
      touch ${METADATAMIPSELROOTFS}/autoconf_extract

[ -f ${METADATAMIPSELROOTFS}/automake_extract ] || \
  tar xf ${TARBALL}/automake-${AUTOMAKE_VERSION}.${AUTOMAKE_SUFFIX} || \
    die "***extract automake error" && \
      touch ${METADATAMIPSELROOTFS}/automake_extract

[ -f ${METADATAMIPSELROOTFS}/bash_extract ] || \
  tar xf ${TARBALL}/bash-${BASH_VERSION}.${BASH_SUFFIX} || \
    die "***extract bash error" && \
      touch ${METADATAMIPSELROOTFS}/bash_extract

[ -f ${METADATAMIPSELROOTFS}/diffutils_extract ] || \
  tar xf ${TARBALL}/diffutils-${DIFFUTILS_VERSION}.${DIFFUTILS_SUFFIX} || \
    die "***extract diffutils error" && \
      touch ${METADATAMIPSELROOTFS}/diffutils_extract

[ -f ${METADATAMIPSELROOTFS}/findutils_extract ] || \
  tar xf ${TARBALL}/findutils-${FINDUTILS_VERSION}.${FINDUTILS_SUFFIX} || \
    die "***extract findutils error" && \
      touch ${METADATAMIPSELROOTFS}/findutils_extract

[ -f ${METADATAMIPSELROOTFS}/gawk_extract ] || \
  tar xf ${TARBALL}/gawk-${GAWK_VERSION}.${GAWK_SUFFIX} || \
    die "***extract gawk error" && \
      touch ${METADATAMIPSELROOTFS}/gawk_extract

[ -f ${METADATAMIPSELROOTFS}/gettext_extract ] || \
  tar xf ${TARBALL}/gettext-${GETTEXT_VERSION}.${GETTEXT_SUFFIX} || \
    die "***extract gettext error" && \
      touch ${METADATAMIPSELROOTFS}/gettext_extract

[ -f ${METADATAMIPSELROOTFS}/grep_extract ] || \
  tar xf ${TARBALL}/grep-${GREP_VERSION}.${GREP_SUFFIX} || \
    die "***extract grep error" && \
      touch ${METADATAMIPSELROOTFS}/grep_extract

[ -f ${METADATAMIPSELROOTFS}/gzip_extract ] || \
  tar xf ${TARBALL}/gzip-${GZIP_VERSION}.${GZIP_SUFFIX} || \
    die "***extract gzip error" && \
      touch ${METADATAMIPSELROOTFS}/gzip_extract

[ -f ${METADATAMIPSELROOTFS}/kbd_extract ] || \
  tar xf ${TARBALL}/kbd-${KBD_VERSION}.${KBD_SUFFIX} || \
    die "***extract kbd error" && \
      touch ${METADATAMIPSELROOTFS}/kbd_extract

[ -f ${METADATAMIPSELROOTFS}/less_extract ] || \
  tar xf ${TARBALL}/less-${LESS_VERSION}.${LESS_SUFFIX} || \
    die "***extract less error" && \
      touch ${METADATAMIPSELROOTFS}/less_extract

[ -f ${METADATAMIPSELROOTFS}/make_extract ] || \
  tar xf ${TARBALL}/make-${MAKE_VERSION}.${MAKE_SUFFIX} || \
    die "***extract make error" && \
      touch ${METADATAMIPSELROOTFS}/make_extract

[ -f ${METADATAMIPSELROOTFS}/module_init_extract ] || \
  tar xf ${TARBALL}/module-init-tools-${MODULE_VERSION}.${MODULE_SUFFIX} || \
    die "***extract module init error" && \
      touch ${METADATAMIPSELROOTFS}/module_init_extract

[ -f ${METADATAMIPSELROOTFS}/patch_extract ] || \
  tar xf ${TARBALL}/patch-${PATCH_VERSION}.${PATCH_SUFFIX} || \
    die "***extract patch error" && \
      touch ${METADATAMIPSELROOTFS}/patch_extract

[ -f ${METADATAMIPSELROOTFS}/psmisc_extract ] || \
  tar xf ${TARBALL}/psmisc-${PSMISC_VERSION}.${PSMISC_SUFFIX} || \
    die "***extract psmisc error" && \
      touch ${METADATAMIPSELROOTFS}/psmisc_extract

[ -f ${METADATAMIPSELROOTFS}/libestr_extract ] || \
  tar xf ${TARBALL}/libestr-${LIBESTR_VERSION}.${LIBESTR_SUFFIX} || \
    die "***extract libestr error" && \
      touch ${METADATAMIPSELROOTFS}/libestr_extract

[ -f ${METADATAMIPSELROOTFS}/libee_extract ] || \
  tar xf ${TARBALL}/libee-${LIBEE_VERSION}.${LIBEE_SUFFIX} || \
    die "***extract libee error" && \
      touch ${METADATAMIPSELROOTFS}/libee_extract

[ -f ${METADATAMIPSELROOTFS}/jsonc_extract ] || \
  tar xf ${TARBALL}/json-c-${JSONC_VERSION}.${JSONC_SUFFIX} || \
    die "***extract jsonc error" && \
      touch ${METADATAMIPSELROOTFS}/jsonc_extract

[ -f ${METADATAMIPSELROOTFS}/rsyslog_extract ] || \
  tar xf ${TARBALL}/rsyslog-${RSYSLOG_VERSION}.${RSYSLOG_SUFFIX} || \
    die "***extract rsyslog error" && \
      touch ${METADATAMIPSELROOTFS}/rsyslog_extract

[ -f ${METADATAMIPSELROOTFS}/sysvinit_extract ] || \
  tar xf ${TARBALL}/sysvinit-${SYSVINIT_VERSION}.${SYSVINIT_SUFFIX} || \
    die "***extract rsyvinit error" && \
      touch ${METADATAMIPSELROOTFS}/sysvinit_extract

[ -f ${METADATAMIPSELROOTFS}/tar_extract ] || \
  tar xf ${TARBALL}/tar-${TAR_VERSION}.${TAR_SUFFIX} || \
    die "***extract tar error" && \
      touch ${METADATAMIPSELROOTFS}/tar_extract

[ -f ${METADATAMIPSELROOTFS}/texinfo_extract ] || \
  tar xf ${TARBALL}/texinfo-${TEXINFO_VERSION}a.${TEXINFO_SUFFIX} || \
    die "***extract texinfo error" && \
      touch ${METADATAMIPSELROOTFS}/texinfo_extract

[ -f ${METADATAMIPSELROOTFS}/kmod_extract ] || \
  tar xf ${TARBALL}/kmod-${KMOD_VERSION}.${KMOD_SUFFIX} || \
    die "***extract kmod error" && \
      touch ${METADATAMIPSELROOTFS}/kmod_extract

[ -f ${METADATAMIPSELROOTFS}/udev_extract ] || \
  tar xf ${TARBALL}/udev-${UDEV_VERSION}.${UDEV_SUFFIX} || \
    die "***extract udev error" && \
      touch ${METADATAMIPSELROOTFS}/udev_extract

[ -f ${METADATAMIPSELROOTFS}/xz_extract ] || \
  tar xf ${TARBALL}/xz-${XZ_VERSION}.${XZ_SUFFIX} || \
    die "***extract xz error" && \
      touch ${METADATAMIPSELROOTFS}/xz_extract

[ -f ${METADATAMIPSELROOTFS}/gdb_extract ] || \
  tar xf ${TARBALL}/gdb-${GDB_VERSION}.${GDB_SUFFIX} || \
    die "***extractjgdb error" && \
      touch ${METADATAMIPSELROOTFS}/gdb_extract

popd

pushd ${BUILDMIPSELROOTFS}
cd linux-${LINUX_VERSION}
[ -f ${METADATAMIPSELROOTFS}/linux_mrproper ] || \
  make mrproper || \
    die "***make mrproper error" && \
      touch ${METADATAMIPSELROOTFS}/linux_mrproper
[ -f ${METADATAMIPSELROOTFS}/linux_headers_check ] || \
  make ARCH=mips headers_check || \
    die "***check headers error" && \
      touch ${METADATAMIPSELROOTFS}/linux_headers_check
[ -f ${METADATAMIPSELROOTFS}/linux_headers_install ] || \
  make ARCH=mips INSTALL_HDR_PATH=dest headers_install || \
    die "***install headers error" && \
      touch ${METADATAMIPSELROOTFS}/linux_headers_install
[ -f ${METADATAMIPSELROOTFS}/linux_headers_copy ] || \
  cp -r dest/include/* ${PREFIXMIPSELROOTFS}/usr/include || \
    die "***copy headers error" && \
      touch ${METADATAMIPSELROOTFS}/linux_headers_copy
[ -f ${METADATAMIPSELROOTFS}/linux_headers_find ] || \
  find ${PREFIXMIPSELROOTFS}/usr/include -name .install \
  -or -name ..install.cmd | xargs rm -fv || \
    die "***install headers error" && \
      touch ${METADATAMIPSELROOTFS}/linux_headers_find
popd

pushd ${BUILDMIPSELROOTFS}
[ -d "gmp_build" ] || mkdir gmp_build
cd gmp_build
[ -f ${METADATAMIPSELROOTFS}/gmp_configure ] || \
  CPPFLAGS=-fexceptions \
    ${SRCMIPSELROOTFS}/gmp-${GMP_VERSION}/configure \
    --prefix=${PREFIXMIPSELROOTFS}/cross-tools --enable-cxx || \
      die "***config gmp error" && \
        touch ${METADATAMIPSELROOTFS}/gmp_configure
[ -f ${METADATAMIPSELROOTFS}/gmp_build ] || \
  make -j${JOBS} || die "***build gmp error" && \
    touch ${METADATAMIPSELROOTFS}/gmp_build
[ -f ${METADATAMIPSELROOTFS}/gmp_install ] || \
  make install || die "***install gmp error" && \
    touch ${METADATAMIPSELROOTFS}/gmp_install
popd

pushd ${BUILDMIPSELROOTFS}
[ -d "mpfr_build" ] || mkdir mpfr_build
cd mpfr_build
[ -f ${METADATAMIPSELROOTFS}/mpfr_configure ] || \
  LDFLAGS="-Wl,-rpath,${PREFIXMIPSELROOTFS}/cross-tools/lib" \
  ${SRCMIPSELROOTFS}/mpfr-${MPFR_VERSION}/configure \
  --prefix=${PREFIXMIPSELROOTFS}/cross-tools \
  --with-gmp=${PREFIXMIPSELROOTFS}/cross-tools --enable-shared || \
    die "***config mpfr error" && \
      touch ${METADATAMIPSELROOTFS}/mpfr_configure
[ -f ${METADATAMIPSELROOTFS}/mpfr_build ] || \
  make -j${JOBS} || \
    die "***build mpfr error" && \
      touch ${METADATAMIPSELROOTFS}/mpfr_build
[ -f ${METADATAMIPSELROOTFS}/mpfr_install ] || \
  make install || \
    die "***install mpfr error" && \
      touch ${METADATAMIPSELROOTFS}/mpfr_install
popd

pushd ${BUILDMIPSELROOTFS}
[ -d "mpc_build" ] || mkdir mpc_build
cd mpc_build
[ -f ${METADATAMIPSELROOTFS}/mpc_configure ] || \
  LDFLAGS="-Wl,-rpath,/cross-tools/lib" \
  ${SRCMIPSELROOTFS}/mpc-${MPC_VERSION}/configure \
  --prefix=${PREFIXMIPSELROOTFS}/cross-tools \
  --with-gmp=${PREFIXMIPSELROOTFS}/cross-tools \
  --with-mpfr=${PREFIXMIPSELROOTFS}/cross-tools || \
    die "***config mpc error" && \
      touch ${METADATAMIPSELROOTFS}/mpc_configure
[ -f ${METADATAMIPSELROOTFS}/mpc_build ] || \
  make -j${JOBS} || die "***build mpc error" && \
    touch ${METADATAMIPSELROOTFS}/mpc_build
[ -f ${METADATAMIPSELROOTFS}/mpc_install ] || \
  make install || die "***install mpc error" && \
    touch ${METADATAMIPSELROOTFS}/mpc_install
popd

pushd ${BUILDMIPSELROOTFS}
[ -d "ppl_build" ] || mkdir ppl_build
cd ppl_build
[ -f ${METADATAMIPSELROOTFS}/ppl_configure ] || \
  LDFLAGS="-Wl,-rpath,${PREFIXMIPSELROOTFS}/cross-tools/lib" \
  ${SRCMIPSELROOTFS}/ppl-${PPL_VERSION}/configure \
  --prefix=${PREFIXMIPSELROOTFS}/cross-tools --enable-shared \
  --enable-interfaces="c,cxx" --disable-optimization \
  --with-gmp=${PREFIXMIPSELROOTFS}/cross-tools || \
    die "***config ppl error" && \
      touch ${METADATAMIPSELROOTFS}/ppl_configure
[ -f ${METADATAMIPSELROOTFS}/ppl_build ] || \
  make -j${JOBS} || die "***build ppl error" && \
    touch ${METADATAMIPSELROOTFS}/ppl_build
[ -f ${METADATAMIPSELROOTFS}/ppl_install ] || \
  make install || die "***install ppl error" && \
    touch ${METADATAMIPSELROOTFS}/ppl_install
popd

pushd ${BUILDMIPSELROOTFS}
[ -d "cloog_build" ] || mkdir cloog_build
cd cloog_build
[ -f ${METADATAMIPSELROOTFS}/cloog_configure ] || \
  LDFLAGS="-Wl,-rpath,${PREFIXMIPSELROOTFS}/cross-tools/lib" \
  ${SRCMIPSELROOTFS}/cloog-${CLOOG_VERSION}/configure \
  --prefix=${PREFIXMIPSELROOTFS}/cross-tools --enable-shared \
  --with-gmp-prefix=${PREFIXMIPSELROOTFS}/cross-tools || \
    die "***config cloog error" && \
      touch ${METADATAMIPSELROOTFS}/cloog_configure
[ -f ${METADATAMIPSELROOTFS}/cloog_build ] || \
  make -j${JOBS} || die "***build cloog error" && \
    touch ${METADATAMIPSELROOTFS}/cloog_build
[ -f ${METADATAMIPSELROOTFS}/cloog_install ] || \
  make install || die "***install cloog error" && \
    touch ${METADATAMIPSELROOTFS}/cloog_install
popd

pushd ${BUILDMIPSELROOTFS}
[ -d "binutils-build" ] || mkdir binutils-build
cd binutils-build
[ -f ${METADATAMIPSELROOTFS}/binutils_configure ] || \
  AS="as" AR="ar" \
  ${SRCMIPSELROOTFS}/binutils-${BINUTILS_VERSION}/configure \
  --prefix=${PREFIXMIPSELROOTFS}/cross-tools \
  --host=${CROSS_HOST} --target=${CROSS_TARGET32} \
  --with-sysroot=${PREFIXMIPSELROOTFS} --disable-nls \
  --enable-shared \
  --disable-multilib || \
    die "***config binutils error" && \
      touch ${METADATAMIPSELROOTFS}/binutils_configure
[ -f ${METADATAMIPSELROOTFS}/binutils_build_host ] || \
  make configure-host || \
    die "config binutils host error" && \
      touch ${METADATAMIPSELROOTFS}/binutils_build_host
[ -f ${METADATAMIPSELROOTFS}/binutils_build ] || \
  make -j${JOBS} || \
    die "***build binutils error" && \
      touch ${METADATAMIPSELROOTFS}/binutils_build
[ -f ${METADATAMIPSELROOTFS}/binutils_install ] || \
  make install || \
    die "***install binutils error" && \
      touch ${METADATAMIPSELROOTFS}/binutils_install
[ -f ${METADATAMIPSELROOTFS}/binutils_headers_copy ] || \
  cp ${SRCMIPSELROOTFS}/binutils-${BINUTILS_VERSION}/include/libiberty.h ${PREFIXMIPSELROOTFS}/usr/include || \
    die "***copy binutils header error" && \
      touch ${METADATAMIPSELROOTFS}/binutils_headers_copy
popd

pushd ${BUILDMIPSELROOTFS}
[ -d "gcc-static-build" ] || mkdir gcc-static-build
cd gcc-static-build
[ -f ${METADATAMIPSELROOTFS}/gcc_static_configure ] || \
  AR=ar LDFLAGS="-Wl,-rpath,${PREFIXMIPSELROOTFS}/cross-tools/lib" \
  ${SRCMIPSELROOTFS}/gcc-${GCC_VERSION}/configure \
  --prefix=${PREFIXMIPSELROOTFS}/cross-tools \
  --build=${CROSS_HOST} --host=${CROSS_HOST} \
  --target=${CROSS_TARGET32} --with-sysroot=${PREFIXMIPSELROOTFS} \
  --disable-multilib --disable-nls \
  --without-headers --with-newlib --disable-decimal-float \
  --disable-libgomp --disable-libmudflap --disable-libssp \
  --with-mpfr=${PREFIXMIPSELROOTFS}/cross-tools \
  --with-gmp=${PREFIXMIPSELROOTFS}/cross-tools \
  --with-ppl=${PREFIXMIPSELROOTFS}/cross-tools \
  --with-cloog=${PREFIXMIPSELROOTFS}/cross-tools \
  --with-mpc=${PREFIXMIPSELROOTFS}/cross-tools \
  --disable-shared --disable-threads --enable-languages=c \
  --enable-cloog-backend=isl || \
    die "***config gcc static stage1 error" && \
      touch ${METADATAMIPSELROOTFS}/gcc_static_configure
[ -f ${METADATAMIPSELROOTFS}/gcc_static_build ] || \
  make -j${JOBS} all-gcc all-target-libgcc || \
    die "***build gcc static stage1 error" && \
      touch ${METADATAMIPSELROOTFS}/gcc_static_build
[ -f ${METADATAMIPSELROOTFS}/gcc_static_install ] || \
  make install-gcc install-target-libgcc || \
    die "***install gcc static stage1 error" && \
      touch ${METADATAMIPSELROOTFS}/gcc_static_install
popd

pushd ${SRCMIPSELROOTFS}
if [ ${HOSTOS} = "Darwin" ]; then
cd glibc-${GLIBC_VERSION}
[ -f "${METADATAMIPSELROOTFS}/glibc_macos_patch" ] || \
  patch -p1 < ${PATCH}/glibc-2.17-os-x-build.patch || \
    die "***patch glibc for macosx error" && \
      touch ${METADATAMIPSELROOTFS}/glibc_macos_patch
fi
popd

pushd ${BUILDMIPSELROOTFS}
[ -d "glibc-build" ] || mkdir glibc-build
cd glibc-build
[ -f ${METADATAMIPSELROOTFS}/glibc_config ] || \
cat > config.cache << "EOF"
lic_cv_forced_unwind=yes
libc_cv_c_cleanup=yes
libc_cv_gnu89_inline=yes
EOF
#cat > configparms << EOF
#install_root=${PREFIXMIPSELROOTFS}
#EOF
[ -f ${METADATAMIPSELROOTFS}/glibc_configure ] || \
  BUILD_CC="gcc" CC="${CROSS_TARGET32}-gcc" \
  AR="${CROSS_TARGET32}-ar" \
  RANLIB="${CROSS_TARGET32}-ranlib" \
  CFLAGS_FOR_TARGET="-O2" CFLAGS+="-O2" \
  ${SRCMIPSELROOTFS}/glibc-${GLIBC_VERSION}/configure \
  --prefix=/usr \
  --libexecdir=/usr/lib/glibc --host=${CROSS_TARGET32} \
  --build=${CROSS_HOST} \
  --disable-profile --enable-add-ons --with-tls --enable-kernel=2.6.0 \
  --with-__thread --with-binutils=${PREFIXMIPSELROOTFS}/cross-tools/bin \
  --with-headers=${PREFIXMIPSELROOTFS}/usr/include \
  --cache-file=config.cache ||\
    die "***config glibc error" && \
      touch ${METADATAMIPSELROOTFS}/glibc_configure
[ -f ${METADATAMIPSELROOTFS}/glibc_build ] || \
  make || die "***build glibc error" && \
    touch ${METADATAMIPSELROOTFS}/glibc_build
[ -f ${METADATAMIPSELROOTFS}/glibc_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} install || \
    die "***install glibc error" && \
      touch ${METADATAMIPSELROOTFS}/glibc_install
popd

pushd ${BUILDMIPSELROOTFS}
[ -d "gcc-build" ] || mkdir gcc-build
cd gcc-build
[ -f ${METADATAMIPSELROOTFS}/gcc_configure ] || \
  AR=ar LDFLAGS="-Wl,-rpath,${PREFIXMIPSELROOTFS}/cross-tools/lib" \
  ${SRCMIPSELROOTFS}/gcc-${GCC_VERSION}/configure \
  --prefix=${PREFIXMIPSELROOTFS}/cross-tools \
  --build=${CROSS_HOST} --host=${CROSS_HOST} \
  --target=${CROSS_TARGET32} \
  --disable-multilib --with-sysroot=${PREFIXMIPSELROOTFS} --disable-nls \
  --enable-shared --enable-languages=c,c++ --enable-__cxa_atexit \
  --with-mpfr=${PREFIXMIPSELROOTFS}/cross-tools \
  --with-gmp=${PREFIXMIPSELROOTFS}/cross-tools \
  --with-ppl=${PREFIXMIPSELROOTFS}/cross-tools \
  --with-cloog=${PREFIXMIPSELROOTFS}/cross-tools \
  --with-mpc=${PREFIXMIPSELROOTFS}/cross-tools \
  --enable-c99 --enable-long-long --enable-threads=posix \
  --enable-cloog-backend=isl || \
    die "***config gcc stage2 error" && \
      touch ${METADATAMIPSELROOTFS}/gcc_configure
[ -f ${METADATAMIPSELROOTFS}/gcc_build ] || \
  make -j${JOBS} \
  AS_FOR_TARGET="${CROSS_TARGET32}-as" \
  LD_FOR_TARGET="${CROSS_TARGET32}-ld" || \
    die "***build gcc stage2 error" && \
      touch ${METADATAMIPSELROOTFS}/gcc_build
[ -f ${METADATAMIPSELROOTFS}/gcc_install ] || \
  make install || \
    die "***install gcc stage2 error" && \
      touch ${METADATAMIPSELROOTFS}/gcc_install
popd

pushd ${BUILDMIPSELROOTFS}
[ -d "file_build" ] || mkdir file_build
cd file_build
[ -f ${METADATAMIPSELROOTFS}/file_configure ] || \
  ${SRCMIPSELROOTFS}/file-${FILE_VERSION}/configure \
  --prefix=${PREFIXMIPSELROOTFS}/cross-tools || \
    die "***config file error" && \
      touch ${METADATAMIPSELROOTFS}/file_configure
[ -f ${METADATAMIPSELROOTFS}/file_build ] || \
  make -j${JOBS} || \
    die "***build file error" && \
      touch ${METADATAMIPSELROOTFS}/file_build
[ -f ${METADATAMIPSELROOTFS}/file_install ] || \
  make install || \
    die "***install file error" && \
      touch ${METADATAMIPSELROOTFS}/file_install
popd

pushd ${BUILDMIPSELROOTFS}
[ -d "groff_build" ] || mkdir groff_build
cd groff_build
[ -f ${METADATAMIPSELROOTFS}/groff_configure ] || \
  PAGE=A4 ${SRCMIPSELROOTFS}/groff-${GROFF_VERSION}/configure \
  --prefix=${PREFIXMIPSELROOTFS}/cross-tools --without-x || \
    die "***config groff error" && \
      touch ${METADATAMIPSELROOTFS}/groff_configure
[ -f ${METADATAMIPSELROOTFS}/groff_build ] || \
  make -j${JOBS} || \
    die "***build groff error" && \
      touch ${METADATAMIPSELROOTFS}/groff_build
[ -f ${METADATAMIPSELROOTFS}/groff_install ] || \
  make install || \
    die "***install groff error" && \
      touch ${METADATAMIPSELROOTFS}/groff_install
popd


pushd ${BUILDMIPSELROOTFS}
cd perl-${PERL_VERSION}
[ -f ${METADATAMIPSELROOTFS}/perl_cross_copy ] || \
  cp -ar ${SRCMIPSELROOTFS}/perl-${PERL_VERSION}/* . || \
    die "***copy cross perl error" && \
      touch ${METADATAMIPSELROOTFS}/perl_cross_copy

[ -f ${METADATAMIPSELROOTFS}/perl_configure ] || \
  ./configure --prefix=${PREFIXMIPSELROOTFS}/cross-tools || \
    die "***config perl error" && \
      touch ${METADATAMIPSELROOTFS}/perl_configure

[ -f ${METADATAMIPSELROOTFS}/perl_build ] || \
  make || \
    die "***make perl error" && \
      touch ${METADATAMIPSELROOTFS}/perl_build

[ -f ${METADATAMIPSELROOTFS}/perl_install ] || \
  make install || \
    die "***install perl error" && \
      touch ${METADATAMIPSELROOTFS}/perl_install
popd

pushd ${BUILDMIPSELROOTFS}
[ -d "python_build" ] || mkdir python_build
cd python_build
[ -f ${METADATAMIPSELROOTFS}/python_configure ] || \
  ${SRCMIPSELROOTFS}/Python-${PYTHON_VERSION}/configure \
  --prefix=${PREFIXMIPSELROOTFS}/cross-tools || \
    die "***config python error" && \
      touch ${METADATAMIPSELROOTFS}/python_configure

[ -f ${METADATAMIPSELROOTFS}/python_build ] || \
  make -j${JOBS} || \
    die "***build python error" && \
      touch ${METADATAMIPSELROOTFS}/python_build

[ -f ${METADATAMIPSELROOTFS}/python_install ] || \
  make install || \
    die "***install python error" && \
      touch ${METADATAMIPSELROOTFS}/python_install
popd

pushd ${SRCMIPSELROOTFS}
cd shadow-${SHADOW_VERSION}
[ -f ${METADATAMIPSELROOTFS}/shadow_patch ] || \
  patch -p1 < ${PATCH}/shadow-${SHADOW_VERSION}-sysroot_hacks-1.patch || \
    die "Patch shadow error" && \
      touch ${METADATAMIPSELROOTFS}/shadow_patch
popd

pushd ${BUILDMIPSELROOTFS}
[ -d "shadow_build" ] || mkdir shadow_build
cd shadow_build
cat > config.cache << EOF
shadow_cv_passwd_dir="${PREFIXMIPSELROOTFS}/bin"
EOF
cat >> config.cache << EOF
ac_cv_func_lckpwdf=no
EOF
[ -f ${METADATAMIPSELROOTFS}/shadow_configure ] || \
  ${SRCMIPSELROOTFS}/shadow-${SHADOW_VERSION}/configure \
  --prefix=${PREFIXMIPSELROOTFS}/cross-tools \
  --sbindir=${PREFIXMIPSELROOTFS}/cross-tools/bin \
  --sysconfdir=$PREFIXMIPSELROOTFS/etc \
  --disable-shared --without-libpam \
  --without-audit --without-selinux \
  --program-prefix=${CROSS_TARGET32}- \
  --without-nscd --cache-file=config.cache || \
    die "***config shadow error" && \
      touch ${METADATAMIPSELROOTFS}/shadow_configure
[ -f ${METADATAMIPSELROOTFS}/cp_config ] || \
  cp config.h{,.orig} || \
    die "***copy config error" && \
      touch ${METADATAMIPSELROOTFS}/cp_config
[ -f ${METADATAMIPSELROOTFS}/cp_config_sed ] || \
  sed "/PASSWD_PROGRAM/s/passwd/${CROSS_TARGET32}-&/" config.h.orig > config.h || \
    die "***sed config.h error" && \
      touch ${METADATAMIPSELROOTFS}/cp_config_sed
[ -f ${METADATAMIPSELROOTFS}/shadow_build ] || \
  make -j${JOBS} || \
    die "***build shadow error" && \
      touch ${METADATAMIPSELROOTFS}/shadow_build
[ -f ${METADATAMIPSELROOTFS}/shadow_install ] || \
  make install || \
    die "***install shadow error" && \
      touch ${METADATAMIPSELROOTFS}/shadow_install
popd

pushd ${SRCMIPSELROOTFS}
cd ncurses-${NCURSES_VERSION}
[ -f ${METADATAMIPSELROOTFS}/ncurses_patch ] || \
  patch -Np1 -i ${PATCH}/ncurses-5.9-bash_fix-1.patch || \
    die "***patch ncurses error" && \
      touch ${METADATAMIPSELROOTFS}/ncurses_patch
popd

pushd ${BUILDMIPSELROOTFS}
[ -d "ncurses_build" ] || mkdir ncurses_build
cd ncurses_build
[ -f ${METADATAMIPSELROOTFS}/ncurses_configure ] || \
  ${SRCMIPSELROOTFS}/ncurses-${NCURSES_VERSION}/configure \
  --prefix=${PREFIXMIPSELROOTFS}/cross-tools \
  --without-debug --without-shared || \
    die "***config ncurses error" && \
      touch ${METADATAMIPSELROOTFS}/ncurses_configure
[ -f ${METADATAMIPSELROOTFS}/ncurses_include_build ] || \
  make -C include || \
    die "***build ncurses include error" && \
      touch ${METADATAMIPSELROOTFS}/ncurses_include_build
[ -f ${METADATAMIPSELROOTFS}/ncurses_tic_build ] || \
  make -C progs tic || \
    die "***build ncurses tic error" && \
      touch ${METADATAMIPSELROOTFS}/ncurses_tic_build
[ -f ${METADATAMIPSELROOTFS}/ncurses_install ] || \
  install -m755 progs/tic ${PREFIXMIPSELROOTFS}/cross-tools/bin || \
    die "***install ncurses error" && \
      touch ${METADATAMIPSELROOTFS}/ncurses_install
popd


export CC="${CROSS_TARGET32}-gcc"
export CXX="${CROSS_TARGET32}-g++"
export AR="${CROSS_TARGET32}-ar"
export AS="${CROSS_TARGET32}-as"
export RANLIB="${CROSS_TARGET32}-ranlib"
export LD="${CROSS_TARGET32}-ld"
export STRIP="${CROSS_TARGET32}-strip"

pushd ${SRCMIPSELROOTFS}
cd man-pages-${MANPAGES_VERSION}
[ -f ${METADATAMIPSELROOTFS}/manpages_install ] || \
  make prefix=${PREFIXMIPSELROOTFS}/usr install || \
    die "***install man pages error" && \
      touch ${METADATAMIPSELROOTFS}/manpages_install
popd

pushd ${BUILDMIPSELROOTFS}
[ -d "gmp_cross_build" ] || mkdir gmp_cross_build
cd gmp_cross_build
[ -f ${METADATAMIPSELROOTFS}/gmp_cross_configure ] || \
  CPPFLAGS=-fexceptions \
  ${SRCMIPSELROOTFS}/gmp-${GMP_VERSION}/configure --prefix=/usr \
  --build=${CROSS_HOST} --host=${CROSS_TARGET32} \
  --enable-cxx --enable-mpbsd || \
    die "***config cross gmp error" && \
      touch ${METADATAMIPSELROOTFS}/gmp_cross_configure
[ -f ${METADATAMIPSELROOTFS}/gmp_cross_build ] || \
  make -j${JOBS} || \
    die "***make cross gmp error" && \
      touch ${METADATAMIPSELROOTFS}/gmp_cross_build
[ -f ${METADATAMIPSELROOTFS}/gmp_cross_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} install || \
    die "***install cross gmp error" && \
      touch ${METADATAMIPSELROOTFS}/gmp_cross_install
[ -f ${METADATAMIPSELROOTFS}/gmp_cross_rmla ] || \
  rm -v ${PREFIXMIPSELROOTFS}/usr/lib/lib{gmp,gmpxx,mp}.la || \
    die "***remove cross gmp *.la error" && \
      touch ${METADATAMIPSELROOTFS}/gmp_cross_rmla
popd

pushd ${BUILDMIPSELROOTFS}
[ -d "mpfr_cross_build" ] || mkdir mpfr_cross_build
cd mpfr_cross_build
[ -f ${METADATAMIPSELROOTFS}/mpfr_cross_configure ] || \
  ${SRCMIPSELROOTFS}/mpfr-${MPFR_VERSION}/configure \
  --prefix=/usr --enable-shared \
  --build=${CROSS_HOST} --host=${CROSS_TARGET32} \
  --with-gmp-lib=${PREFIXMIPSELROOTFS}/usr/lib || \
    die "***config cross mpfr error" && \
      touch ${METADATAMIPSELROOTFS}/mpfr_cross_configure
[ -f ${METADATAMIPSELROOTFS}/mpfr_cross_build ] || \
  make -j${JOBS} || \
    die "***build cross mpfr error" && \
      touch ${METADATAMIPSELROOTFS}/mpfr_cross_build
[ -f ${METADATAMIPSELROOTFS}/mpfr_cross_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} install || \
    die "***install cross mpfr error" && \
      touch ${METADATAMIPSELROOTFS}/mpfr_cross_install
[ -f ${METADATAMIPSELROOTFS}/mpfr_cross_rmla ] || \
  rm -v ${PREFIXMIPSELROOTFS}/usr/lib/libmpfr.la || \
    die "***remove cross mpfr *.la error" && \
      touch ${METADATAMIPSELROOTFS}/mpfr_cross_rmla
popd

pushd ${BUILDMIPSELROOTFS}
[ -d "mpc_cross_build" ] || mkdir mpc_cross_build
cd mpc_cross_build
[ -f ${METADATAMIPSELROOTFS}/mpc_cross_configure ] || \
  ${SRCMIPSELROOTFS}/mpc-${MPC_VERSION}/configure \
  --prefix=/usr --enable-shared \
  --build=${CROSS_HOST} \
  --host=${CROSS_TARGET32} \
  --with-gmp-lib=${PREFIXMIPSELROOTFS}/usr/lib \
  --with-mpfr-lib=${PREFIXMIPSELROOTFS}/usr/lib || \
    die "***config cross mpc error"
      touch ${METADATAMIPSELROOTFS}/mpc_cross_configure
[ -f ${METADATAMIPSELROOTFS}/mpc_cross_build ] || \
  make -j${JOBS} || \
    die "***build cross mpc error" && \
      touch ${METADATAMIPSELROOTFS}/mpc_cross_build
[ -f ${METADATAMIPSELROOTFS}/mpc_cross_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} install || \
    die "***install cross mpc error" && \
      touch ${METADATAMIPSELROOTFS}/mpc_cross_install
[ -f ${METADATAMIPSELROOTFS}/mpc_cross_rmla ] || \
  rm -v ${PREFIXMIPSELROOTFS}/usr/lib/libmpc.la || \
    die "***remove cross mpc *la error" && \
      touch ${METADATAMIPSELROOTFS}/mpc_cross_rmla
popd

pushd ${BUILDMIPSELROOTFS}
[ -d "ppl_cross_build" ] || mkdir ppl_cross_build
cd ppl_cross_build
[ -f ${METADATAMIPSELROOTFS}/ppl_cross_configure ] || \
  CPPFLAGS=-fexceptions \
  ${SRCMIPSELROOTFS}/ppl-${PPL_VERSION}/configure --prefix=/usr \
  --build=${CROSS_HOST} --host=${CROSS_TARGET32} \
  --with-gmp=${PREFIXMIPSELROOTFS}/usr \
  --enable-shared --disable-optimization \
  --enable-check=quick || \
    die "***config cross ppl error" && \
      touch ${METADATAMIPSELROOTFS}/ppl_cross_configure
[ -f ${METADATAMIPSELROOTFS}/ppl_cross_build ] || \
  make -j${JOBS} || \
    die "***build cross ppl error" && \
      touch ${METADATAMIPSELROOTFS}/ppl_cross_build
[ -f ${METADATAMIPSELROOTFS}/ppl_cross_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} install || \
    die "***install cross ppl error" && \
      touch ${METADATAMIPSELROOTFS}/ppl_cross_install

[ -f ${METADATAMIPSELROOTFS}/ppl_cross_rmla ] || \
  rm -v ${PREFIXMIPSELROOTFS}/usr/lib/lib{ppl,ppl_c}.la || \
    die "***remove cross ppl *.la error" && \
      touch ${METADATAMIPSELROOTFS}/ppl_cross_rmla
popd

pushd ${SRCMIPSELROOTFS}
cd cloog-${CLOOG_VERSION}
cp -v configure{,.orig}
sed -e "/LD_LIBRARY_PATH=/d" configure.orig > configure
popd

pushd ${BUILDMIPSELROOTFS}
[ -d "cloog_cross_build" ] || mkdir cloog_cross_build
cd cloog_cross_build
[ -f ${METADATAMIPSELROOTFS}/cloog_cross_configure ] || \
  LDFLAGS="-Wl,-rpath-link,${PREFIXMIPSELROOTFS}/cross-tools/${CROSS_TARGET32}/lib" \
  ${SRCMIPSELROOTFS}/cloog-${CLOOG_VERSION}/configure \
  --build=${CROSS_HOST} --host=${CROSS_TARGET32} \
  --prefix=/usr --enable-shared --with-gmp --with-ppl || \
    die "config cross cloog error" && \
      touch ${METADATAMIPSELROOTFS}/cloog_cross_configure
[ -f ${METADATAMIPSELROOTFS}/cloog_cross_build ] || \
  make -j${JOBS} || \
    die "***build cross cloog error" && \
      touch ${METADATAMIPSELROOTFS}/cloog_cross_build
[ -f ${METADATAMIPSELROOTFS}/cloog_cross_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} install || \
    die "***install cross cloog error" && \
      touch ${METADATAMIPSELROOTFS}/cloog_cross_install
[ -f ${METADATAMIPSELROOTFS}/cloog_cross_rmla ] || \
  rm -v ${PREFIXMIPSELROOTFS}/usr/lib/libcloog-isl.la || \
    die "***remove cross cloog *.la error" && \
      touch ${METADATAMIPSELROOTFS}/cloog_cross_rmla
popd

pushd ${SRCMIPSELROOTFS}
cd zlib-${ZLIB_VERSION}
[ -f ${METADATAMIPSELROOTFS}/zlib_cross_configure ] || \
  ./configure \
  --prefix=/usr --shared || \
    die "***config zlib error" && \
      touch ${METADATAMIPSELROOTFS}/zlib_cross_configure
[ -f ${METADATAMIPSELROOTFS}/zlib_cross_build ] || \
  make -j${JOBS}|| \
    die "***build zlib error" && \
      touch ${METADATAMIPSELROOTFS}/zlib_cross_build
[ -f ${METADATAMIPSELROOTFS}/zlib_cross_install ] || \
  make prefix=${PREFIXMIPSELROOTFS}/usr install || \
    die "***install zlib error" && \
      touch ${METADATAMIPSELROOTFS}/zlib_cross_install
[ -f ${METADATAMIPSELROOTFS}/zlib_cross_mvso ] || \
  mv -v ${PREFIXMIPSELROOTFS}/usr/lib/libz.so.* ${PREFIXMIPSELROOTFS}/lib || \
    die "***move libz.so.* zlib error" && \
      touch ${METADATAMIPSELROOTFS}/zlib_cross_mvso
[ -f ${METADATAMIPSELROOTFS}/zlib_cross_ln ] || \
  ln -sfv ../../lib/libz.so.1 ${PREFIXMIPSELROOTFS}/usr/lib/libz.so || \
    die "***link libz.so.1 zlib error" && \
      touch ${METADATAMIPSELROOTFS}/zlib_cross_ln
chmod -v 644 ${PREFIXMIPSELROOTFS}/usr/lib/libz.a
popd

#pushd ${BUILDMIPSELROOTFS}
#[ -d "expat_cross_build" ] || mkdir expat_cross_build
#cd expat_cross_build
#[ -f ${METADATAMIPSELROOTFS}/expat_cross_configure ] || \
#  ${SRCMIPSELROOTFS}/expat-${EXPAT_VERSION}/configure \
#  --prefix=/usr \
#  --build=${CROSS_HOST} --host=${CROSS_TARGET32} \
#  --target=${CROSS_TARGET32} || \
#    die "***config expat error" && \
#      touch ${METADATAMIPSELROOTFS}/expat_cross_configure
#[ -f ${METADATAMIPSELROOTFS}/expat_cross_build ] || \
#  make -j${JOBS} || \
#    die "***build expat error" && \
#      touch ${METADATAMIPSELROOTFS}/expat_cross_build
#[ -f ${METADATAMIPSELROOTFS}/expat_cross_install ] || \
#  make prefix=${PREFIXMIPSELROOTFS}/usr install || \
#    die "***install expat error" && \
#      touch ${METADATAMIPSELROOTFS}/expat_cross_install
#popd
#
#pushd ${BUILDMIPSELROOTFS}
#[ -d "dbus_cross_build" ] || mkdir dbus_cross_build
#cd dbus_cross_build
#[ -f ${METADATAMIPSELROOTFS}/dbus_cross_configure ] || \
#  ${SRCMIPSELROOTFS}/dbus-${DBUS_VERSION}/configure \
#  --prefix=/usr \
#  --build=${CROSS_HOST} --host=${CROSS_TARGET32} \
#  --target=${CROSS_TARGET32} || \
#    die "***config dbus error" && \
#      touch ${METADATAMIPSELROOTFS}/dbus_cross_configure
#[ -f ${METADATAMIPSELROOTFS}/dbus_cross_build ] || \
#  make -j${JOBS} || \
#    die "***build dbus error" && \
#      touch ${METADATAMIPSELROOTFS}/dbus_cross_build
#[ -f ${METADATAMIPSELROOTFS}/dbus_cross_install ] || \
#  make DESTDIR=${PREFIXMIPSELROOTFS} install || \
#    die "***install dbus error" && \
#      touch ${METADATAMIPSELROOTFS}/dbus_cross_install
#popd
#
#pushd ${BUILDMIPSELROOTFS}
#[ -d "glib_cross_build" ] || mkdir glib_cross_build
#cd glib_cross_build
#cat > config.cache << EOF
#glib_cv_stack_grows=false
#glib_cv_uscore=false
#ac_cv_func_posix_getpwuid_r=false
#ac_cv_func_posix_getgrgid_r=false
#EOF
#[ -f ${METADATAMIPSELROOTFS}/glib_cross_configure ] || \
#  ${SRCMIPSELROOTFS}/glib-${GLIB_VERSION}/configure \
#  --prefix=/usr \
#  --build=${CROSS_HOST} --host=${CROSS_TARGET32} \
#  --target=${CROSS_TARGET32} --sysconfdir=/etc \
#  --cache-file=config.cache --enable-debug=no || \
#    die "***config glib error" && \
#      touch ${METADATAMIPSELROOTFS}/glib_cross_configure
#[ -f ${METADATAMIPSELROOTFS}/glib_cross_build ] || \
#  make -j${JOBS} || \
#    die "***build glib error" && \
#      touch ${METADATAMIPSELROOTFS}/glib_cross_build
#[ -f ${METADATAMIPSELROOTFS}/glib_cross_install ] || \
#  make DESTDIR=${PREFIXMIPSELROOTFS} install || \
#    die "***install glib error" && \
#      touch ${METADATAMIPSELROOTFS}/glib_cross_install
#popd

pushd ${BUILDMIPSELROOTFS}
[ -d "binutils_cross_build" ] || mkdir binutils_cross_build
cd binutils_cross_build
[ -f ${METADATAMIPSELROOTFS}/binutils_cross_configure ] || \
  ${SRCMIPSELROOTFS}/binutils-${BINUTILS_VERSION}/configure \
  --prefix=/usr \
  --build=${CROSS_HOST} --host=${CROSS_TARGET32} \
  --target=${CROSS_TARGET32} --enable-shared || \
    die "***config file error" && \
      touch ${METADATAMIPSELROOTFS}/binutils_cross_configure
[ -f ${METADATAMIPSELROOTFS}/binutils_cross_buildhost ] || \
  make configure-host || \
    die "config cross binutils host error" && \
      touch ${METADATAMIPSELROOTFS}/binutils_cross_buildhost
[ -f ${METADATAMIPSELROOTFS}/binutils_cross_buildtooldir ] || \
  make tooldir=/usr || \
    die "***build cross binutils tooldir error" && \
      touch ${METADATAMIPSELROOTFS}/binutils_cross_buildtooldir
[ -f ${METADATAMIPSELROOTFS}/binutils_cross_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} tooldir=/usr install || \
    die "***install binutils error" && \
      touch ${METADATAMIPSELROOTFS}/binutils_cross_install
popd

pushd ${SRCMIPSELROOTFS}
cd gcc-${GCC_VERSION}
cp libiberty/Makefile.in{,.orig}
sed 's/install_to_$(INSTALL_DEST) //' libiberty/Makefile.in.orig > \
libiberty/Makefile.in
cp gcc/gccbug.in{,.orig}
sed 's/@have_mktemp_command@/yes/' gcc/gccbug.in.orig > gcc/gccbug.in
cp gcc/Makefile.in{,.orig}
sed 's@\./fixinc\.sh@-c true@' gcc/Makefile.in.orig > gcc/Makefile.in
popd

pushd ${BUILDMIPSELROOTFS}
[ -d "gcc_cross_build" ] || mkdir gcc_cross_build
cd gcc_cross_build
[ -f ${METADATAMIPSELROOTFS}/gcc_cross_configure ] || \
  LDFLAGS="-Wl,-rpath-link,${PREFIXMIPSELROOTFS}/cross-tools/${CROSS_TARGET32}/lib" \
  ${SRCMIPSELROOTFS}/gcc-${GCC_VERSION}/configure \
  --prefix=/usr --libexecdir=/usr/lib \
  --build=${CROSS_HOST} --host=${CROSS_TARGET32} --target=${CROSS_TARGET32} \
  --enable-shared --enable-threads=posix --enable-__cxa_atexit \
  --enable-c99 --enable-long-long --enable-clocale=gnu \
  --enable-languages=c,c++ --disable-libstdcxx-pch || \
    die "***configure cross gcc error" && \
      touch ${METADATAMIPSELROOTFS}/gcc_cross_configure
cp Makefile{,.orig}
sed "/^HOST_\(GMP\|PPL\|CLOOG\)\(LIBS\|INC\)/s:-[IL]/\(lib\|include\)::" \
    Makefile.orig > Makefile
[ -f ${METADATAMIPSELROOTFS}/gcc_cross_build ] || \
  make -j${JOBS} || \
    die "***build cross gcc error" && \
      touch ${METADATAMIPSELROOTFS}/gcc_cross_build
[ -f ${METADATAMIPSELROOTFS}/gcc_cross_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} install || \
    die "***install cross gcc error" && \
      touch ${METADATAMIPSELROOTFS}/gcc_cross_install
[ -f ${METADATAMIPSELROOTFS}/gcc_cross_lncpp ] || \
  ln -sfv ../usr/bin/cpp ${PREFIXMIPSELROOTFS}/lib || \
    die "***link cross gcc lncpp error" && \
      touch ${METADATAMIPSELROOTFS}/gcc_cross_lncpp
[ -f ${METADATAMIPSELROOTFS}/gcc_cross_lncc ] || \
  ln -sfv gcc ${PREFIXMIPSELROOTFS}/usr/bin/cc || \
    die "***link cross gcc lncpp error" && \
      touch ${METADATAMIPSELROOTFS}/gcc_cross_lncc
popd


pushd ${BUILDMIPSELROOTFS}
[ -d "sed_build" ] || mkdir sed_build
cd sed_build
[ -f ${METADATAMIPSELROOTFS}/sed_cross_configure ] || \
  ${SRCMIPSELROOTFS}/sed-${SED_VERSION}/configure \
  --build=${CROSS_HOST} \
  --host=${CROSS_TARGET32} \
  --prefix=/usr --bindir=/bin || \
    die "***config sed error" && \
      touch ${METADATAMIPSELROOTFS}/sed_cross_configure
[ -f ${METADATAMIPSELROOTFS}/sed_cross_build ] || \
  make -j${JOBS} || \
    die "***build sed error" && \
      touch ${METADATAMIPSELROOTFS}/sed_cross_build
[ -f ${METADATAMIPSELROOTFS}/sed_cross_buildhtml ] || \
  make html || \
    die "***build sed html error" && \
      touch ${METADATAMIPSELROOTFS}/sed_cross_buildhtml
[ -f ${METADATAMIPSELROOTFS}/sed_cross_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} install || \
    die "***install sed error" && \
      touch ${METADATAMIPSELROOTFS}/sed_cross_install
[ -f ${METADATAMIPSELROOTFS}/sed_cross_installhtml ] || \
  make -C doc DESTDIR=${PREFIXMIPSELROOTFS} install-html || \
    die "***install sed html error" && \
      touch ${METADATAMIPSELROOTFS}/sed_cross_installhtml
popd

pushd ${BUILDMIPSELROOTFS}
[ -d "ncurses_cross_build" ] || mkdir ncurses_cross_build
cd ncurses_cross_build
[ -f ${METADATAMIPSELROOTFS}/ncurses_cross_configure ] || \
  ${SRCMIPSELROOTFS}/ncurses-${NCURSES_VERSION}/configure \
  --build=${CROSS_HOST} \
  --host=${CROSS_TARGET32} \
  --prefix=/usr --libdir=/lib --with-shared \
  --enable-widec --without-debug --without-ada \
  --with-manpage-format=normal \
  --with-build-cc="gcc -D_GNU_SOURCE" || \
    die "***config cross ncurses error" && \
      touch ${METADATAMIPSELROOTFS}/ncurses_cross_configure
[ -f ${METADATAMIPSELROOTFS}/ncurses_cross_build ] || \
  make -j${JOBS} || \
    die "***build cross ncurses error" && \
      touch ${METADATAMIPSELROOTFS}/ncurses_cross_build
[ -f ${METADATAMIPSELROOTFS}/ncurses_cross_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} install || \
    die "***install cross ncurses error" && \
      touch ${METADATAMIPSELROOTFS}/ncurses_cross_install
[ -f ${METADATAMIPSELROOTFS}/ncurses_cross_mva ] || \
  mv -v ${PREFIXMIPSELROOTFS}/lib/lib{panelw,menuw,formw,ncursesw,ncurses++w}.a \
  ${PREFIXMIPSELROOTFS}/usr/lib || \
    die "***move *.a cross ncurses error" && \
      touch ${METADATAMIPSELROOTFS}/ncurses_cross_mva
[ -f ${METADATAMIPSELROOTFS}/ncurses_cross_rmso ] || \
  rm -v ${PREFIXMIPSELROOTFS}/lib/lib{ncursesw,menuw,panelw,formw}.so || \
    die "***remove *.so cross ncurses error" && \
      touch ${METADATAMIPSELROOTFS}/ncurses_cross_rmso
ln -sfv ../../lib/libncursesw.so.5 ${PREFIXMIPSELROOTFS}/usr/lib/libncursesw.so
ln -sfv ../../lib/libmenuw.so.5 ${PREFIXMIPSELROOTFS}/usr/lib/libmenuw.so
ln -sfv ../../lib/libpanelw.so.5 ${PREFIXMIPSELROOTFS}/usr/lib/libpanelw.so
ln -sfv ../../lib/libformw.so.5 ${PREFIXMIPSELROOTFS}/usr/lib/libformw.so
for lib in curses ncurses form panel menu ; do
    echo "INPUT(-l${lib}w)" > ${PREFIXMIPSELROOTFS}/usr/lib/lib${lib}.so
    ln -sfv lib${lib}w.a ${PREFIXMIPSELROOTFS}/usr/lib/lib${lib}.a
done
ln -sfv libncursesw.so ${PREFIXMIPSELROOTFS}/usr/lib/libcursesw.so
ln -sfv libncursesw.a ${PREFIXMIPSELROOTFS}/usr/lib/libcursesw.a
ln -sfv libncurses++w.a ${PREFIXMIPSELROOTFS}/usr/lib/libncurses++.a
ln -sfv ncursesw5-config ${PREFIXMIPSELROOTFS}/usr/bin/ncurses5-config
ln -sfv ../share/terminfo ${PREFIXMIPSELROOTFS}/usr/lib/terminfo
popd

pushd ${SRCMIPSELROOTFS}
cd util-${UTIL_VERSION}
cp hwclock/hwclock.c{,.orig}
sed -e 's@etc/adjtime@var/lib/hwclock/adjtime@g' \
    hwclock/hwclock.c.orig > hwclock/hwclock.c
popd

pushd ${BUILDMIPSELROOTFS}
[ -d "util_linux_build" ] || mkdir util_linux_build
cd util_linux_build
cat > config.cache << EOF
scanf_cv_type_modifier=ms
EOF
mkdir -pv ${PREFIXMIPSELROOTFS}/var/lib/hwclock
[ -f ${METADATAMIPSELROOTFS}/util_linux_configure ] || \
  ${SRCMIPSELROOTFS}/util-${UTIL_VERSION}/configure \
  --build=${CROSS_HOST} \
  --host=${CROSS_TARGET32} \
  --enable-arch --enable-partx --disable-wall \
  --enable-write --disable-makeinstall-chown \
  --cache-file=config.cache || \
    die "***config util-linux error" && \
      touch ${METADATAMIPSELROOTFS}/util_linux_configure
[ -f ${METADATAMIPSELROOTFS}/util_linux_build ] || \
  make -j${JOBS} || \
    die "***build util-linux error" && \
      touch ${METADATAMIPSELROOTFS}/util_linux_build
[ -f ${METADATAMIPSELROOTFS}/util_linux_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} install || \
    die "***install util-linux error" && \
      touch ${METADATAMIPSELROOTFS}/util_linux_install
[ -f ${METADATAMIPSELROOTFS}/util_linux_mv ] || \
  mv -v ${PREFIXMIPSELROOTFS}/usr/bin/logger ${PREFIXMIPSELROOTFS}/bin || \
    die "***move looger util-linux error" && \
      touch ${METADATAMIPSELROOTFS}/util_linux_mv

[ -f ${METADATAMIPSELROOTFS}/util_linux_la ] || \
  rm ${PREFIXMIPSELROOTFS}/usr/lib/libuuid.la ${PREFIXMIPSELROOTFS}/usr/lib/libblkid.la || \
    die "rm util linux uuid blkid la files" && \
      touch ${METADATAMIPSELROOTFS}/util_linux_la
popd

pushd ${BUILDMIPSELROOTFS}
[ -d e2fs_build ] || mkdir e2fs_build
cd e2fs_build
[ -f ${METADATAMIPSELROOTFS}/e2fs_configure ] || \
  PKG_CONFIG=true LDFLAGS="-lblkid -luuid" \
  ${SRCMIPSELROOTFS}/e2fsprogs-${E2FSPROGS_VERSION}/configure \
  --build=${CROSS_HOST} \
  --host=${CROSS_TARGET32} \
  --prefix=/usr --with-root-prefix="" \
  --enable-elf-shlibs --disable-libblkid \
  --disable-libuuid --disable-fsck --disable-uuidd \
  --cache-file=config.cache || \
    die "***config e2fsprogs error" && \
      touch ${METADATAMIPSELROOTFS}/e2fs_configure
[ -f ${METADATAMIPSELROOTFS}/e2fs_build ] || \
  make -j${JOBS} || \
    die "***build e2fsprogs error" && \
      touch ${METADATAMIPSELROOTFS}/e2fs_build
[ -f ${METADATAMIPSELROOTFS}/e2fs_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} install || \
    die "***install e2fsprogs error" && \
      touch ${METADATAMIPSELROOTFS}/e2fs_install
[ -f ${METADATAMIPSELROOTFS}/e2fs_install_libs ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} install-libs || \
    die "***install e2fsprogs libs error" && \
      touch ${METADATAMIPSELROOTFS}/e2fs_install_libs
[ -f ${METADATAMIPSELROOTFS}/e2fs_install_rmso ] || \
  rm -v ${PREFIXMIPSELROOTFS}/usr/lib/lib{com_err,e2p,ext2fs,ss}.so || \
    die "***remove *.so e2fsprogs libs error" && \
      touch ${METADATAMIPSELROOTFS}/e2fs_install_rmso
ln -sv ../../lib/libcom_err.so.2 ${PREFIXMIPSELROOTFS}/usr/lib/libcom_err.so
ln -sv ../../lib/libe2p.so.2 ${PREFIXMIPSELROOTFS}/usr/lib/libe2p.so
ln -sv ../../lib/libext2fs.so.2 ${PREFIXMIPSELROOTFS}/usr/lib/libext2fs.so
ln -sv ../../lib/libss.so.2 ${PREFIXMIPSELROOTFS}/usr/lib/libss.so
popd

pushd ${BUILDMIPSELROOTFS}
[ -d coreutils_build ] || mkdir coreutils_build
cd coreutils_build
touch man/uname.1 man/hostname.1
cat > config.cache << EOF
fu_cv_sys_stat_statfs2_bsize=yes
gl_cv_func_rename_trailing_slash_bug=no
gl_cv_func_mbrtowc_incomplete_state=yes
gl_cv_func_mbrtowc_nul_retval=yes
gl_cv_func_mbrtowc_null_arg=yes
gl_cv_func_mbrtowc_retval=yes
gl_cv_func_btowc_eof=yes
gl_cv_func_wcrtomb_retval=yes
gl_cv_func_wctob_works=yes
EOF
[ -f ${METADATAMIPSELROOTFS}/coreutils_configure ] || \
  ${SRCMIPSELROOTFS}/coreutils-${COREUTILS_VERSION}/configure \
  EXTRA_MANS='' \
  --build=${CROSS_HOST} \
  --host=${CROSS_TARGET32} \
  --prefix=/usr --cache-file=config.cache \
  --enable-no-install-program=kill,uptime \
  --enable-install-program=hostname || \
    die "***config coreutils error" && \
      touch ${METADATAMIPSELROOTFS}/coreutils_configure
[ -f ${METADATAMIPSELROOTFS}/coreutils_make ] || \
  make CC=gcc src/make-prime-list || \
    die "***make coreutils error" && \
      touch ${METADATAMIPSELROOTFS}/coreutils_make
[ -f ${METADATAMIPSELROOTFS}/coreutils_build ] || \
  make EXTRA_MANS='' -j${JOBS} || \
    die "***build coreutils error" && \
      touch ${METADATAMIPSELROOTFS}/coreutils_build
[ -f ${METADATAMIPSELROOTFS}/coreutils_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} EXTRA_MANS='' install || \
    die "***install coreutils error" && \
      touch ${METADATAMIPSELROOTFS}/coreutils_install
[ -f ${METADATAMIPSELROOTFS}/coreutils_move1 ] || \
  mv -v ${PREFIXMIPSELROOTFS}/usr/bin/{cat,chgrp,chmod,chown,cp,date} ${PREFIXMIPSELROOTFS}/bin || \
    die "***move usr/bin/* coreutils first error" && \
      touch ${METADATAMIPSELROOTFS}/coreutils_move1
[ -f ${METADATAMIPSELROOTFS}/coreutils_move2 ] || \
  mv -v ${PREFIXMIPSELROOTFS}/usr/bin/{dd,df,echo,false,hostname,ln,ls,mkdir} ${PREFIXMIPSELROOTFS}/bin || \
    die "***move usr/bin/* coreutils second error" && \
      touch ${METADATAMIPSELROOTFS}/coreutils_move2
[ -f ${METADATAMIPSELROOTFS}/coreutils_move3 ] || \
  mv -v ${PREFIXMIPSELROOTFS}/usr/bin/{mv,pwd,rm,rmdir,stty,true,uname} ${PREFIXMIPSELROOTFS}/bin || \
    die "***move usr/bin/* coreutils third error" && \
      touch ${METADATAMIPSELROOTFS}/coreutils_move3
[ -f ${METADATAMIPSELROOTFS}/coreutils_move4 ] || \
  mv -v ${PREFIXMIPSELROOTFS}/usr/bin/chroot ${PREFIXMIPSELROOTFS}/usr/sbin || \
    die "***move usr/bin/* coreutils fourth error" && \
      touch ${METADATAMIPSELROOTFS}/coreutils_move4
[ -f ${METADATAMIPSELROOTFS}/coreutils_move5 ] || \
  mv -v ${PREFIXMIPSELROOTFS}/usr/bin/{[,basename,head,install,nice} ${PREFIXMIPSELROOTFS}/bin || \
    die "***move usr/bin/* coreutils fifth error" && \
      touch ${METADATAMIPSELROOTFS}/coreutils_move5
[ -f ${METADATAMIPSELROOTFS}/coreutils_move6 ] || \
  mv -v ${PREFIXMIPSELROOTFS}/usr/bin/{readlink,sleep,sync,test,touch} ${PREFIXMIPSELROOTFS}/bin || \
    die "***move usr/bin/* coreutils sixth error" && \
      touch ${METADATAMIPSELROOTFS}/coreutils_move6
[ -f ${METADATAMIPSELROOTFS}/coreutils_link ] || \
  ln -sfv ../../bin/install ${PREFIXMIPSELROOTFS}/usr/bin || \
    die "***link usr/bin/install coreutils error" && \
      touch ${METADATAMIPSELROOTFS}/coreutils_link
popd

pushd ${BUILDMIPSELROOTFS}
cd iana-etc-${IANA_VERSION}
[ -f ${METADATAMIPSELROOTFS}/iana_build ] || \
  make -j${JOBS} || \
    die "***build iana-etc error" && \
      touch ${METADATAMIPSELROOTFS}/iana_build
[ -f ${METADATAMIPSELROOTFS}/iana_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} install || \
    die "***install iana-etc error" && \
      touch ${METADATAMIPSELROOTFS}/iana_install
popd

pushd ${SRCMIPSELROOTFS}
cd m4-${M4_VERSION}
[ -f ${METADATAMIPSELROOTFS}/m4_patch ] || \
  sed -i '/gets is a security hole/d' lib/stdio.in.h || \
    die "patch m4 stdio.h error" && \
      touch ${METADATAMIPS64ELROOTFS}/m4_patch_stdio.h
popd

pushd ${BUILDMIPSELROOTFS}
[ -d m4_build ] || mkdir m4_build
cd m4_build
cat > config.cache << EOF
gl_cv_func_btowc_eof=yes
gl_cv_func_mbrtowc_incomplete_state=yes
gl_cv_func_mbrtowc_sanitycheck=yes
gl_cv_func_mbrtowc_null_arg=yes
gl_cv_func_mbrtowc_retval=yes
gl_cv_func_mbrtowc_nul_retval=yes
gl_cv_func_wcrtomb_retval=yes
gl_cv_func_wctob_works=yes
EOF
[ -f ${METADATAMIPSELROOTFS}/m4_configure ] || \
  ${SRCMIPSELROOTFS}/m4-${M4_VERSION}/configure --build=${CROSS_HOST} \
  --host=${CROSS_TARGET32} \
  --prefix=/usr --cache-file=config.cache || \
    die "***config m4 error" && \
      touch ${METADATAMIPSELROOTFS}/m4_configure
[ -f ${METADATAMIPSELROOTFS}/m4_build ] || \
  make -j${JOBS} || \
    die "***build m4 error" && \
      touch ${METADATAMIPSELROOTFS}/m4_build
[ -f ${METADATAMIPSELROOTFS}/m4_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} install || \
    die "***install m4 error" && \
      touch ${METADATAMIPSELROOTFS}/m4_install
popd

pushd ${BUILDMIPSELROOTFS}
[ -d bison_build ] || mkdir bison_build
cd bison_build
[ -f ${METADATAMIPSELROOTFS}/bison_configure ] || \
  CC=${CC} ${SRCMIPSELROOTFS}/bison-${BISON_VERSION}/configure \
  --build=${CROSS_HOST} --host=${CROSS_TARGET32} \
  --prefix=/usr || \
    die "***config bison error" && \
      touch ${METADATAMIPSELROOTFS}/bison_configure
cat >> config.h << "EOF"
#define YYENABLE_NLS 1
EOF
[ -f ${METADATAMIPSELROOTFS}/bison_build ] || \
  make -j${JOBS} || \
    die "***build bison error" && \
      touch ${METADATAMIPSELROOTFS}/bison_build
[ -f ${METADATAMIPSELROOTFS}/bison_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} install || \
    die "***install bison error" && \
      touch ${METADATAMIPSELROOTFS}/bison_install
popd

pushd ${SRCMIPSELROOTFS}
cd procps-${PROCPS_VERSION}
[ -f ${METADATAMIPSELROOTFS}/procps_build ] || \
  make CPPFLAGS= lib64=lib m64= || \
    die "***build procps error" && \
      touch ${METADATAMIPSELROOTFS}/procps_build
[ -f ${METADATAMIPSELROOTFS}/procps_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} lib64=lib m64= ldconfig= \
  install="install -D" install || \
    die "***install procps error" && \
      touch ${METADATAMIPSELROOTFS}/procps_install
popd

pushd ${BUILDMIPSELROOTFS}
[ -d libtool_build ] || mkdir libtool_build
cd libtool_build
[ -f ${METADATAMIPSELROOTFS}/libtool_configure ] || \
  ${SRCMIPSELROOTFS}/libtool-${LIBTOOL_VERSION}/configure \
  --build=${CROSS_HOST} \
  --host=${CROSS_TARGET32} \
  --prefix=/usr || \
    die "***config libtool error" && \
      touch ${METADATAMIPSELROOTFS}/libtool_configure
[ -f ${METADATAMIPSELROOTFS}/libtool_build ] || \
  make -j${JOBS} || \
    die "***build libtool error" && \
      touch ${METADATAMIPSELROOTFS}/libtool_build
[ -f ${METADATAMIPSELROOTFS}/libtool_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} install || \
    die "***install libtool error" && \
      touch ${METADATAMIPSELROOTFS}/libtool_install
popd

pushd ${SRCMIPSELROOTFS}
cd flex-${FLEX_VERSION}
cp -v Makefile.in{,.orig}
sed "s/-I@includedir@//g" Makefile.in.orig > Makefile.in

cat > config.cache << EOF
ac_cv_func_malloc_0_nonnull=yes
ac_cv_func_realloc_0_nonnull=yes
EOF
[ -f ${METADATAMIPSELROOTFS}/flex_configure ] || \
  CC=${CC} ./configure \
  --build=${CROSS_HOST} --host=${CROSS_TARGET32} \
  --prefix=/usr --cache-file=config.cache || \
    die "***config flex error" && \
      touch ${METADATAMIPSELROOTFS}/flex_configure
[ -f ${METADATAMIPSELROOTFS}/flex_makelibfl ] || \
  make CC="${CC} -fPIC" libfl.a || \
    die "***make flex libfl.a error" && \
      touch ${METADATAMIPSELROOTFS}/flex_makelibfl
[ -f ${METADATAMIPSELROOTFS}/flex_build ] || \
make -j${JOBS} || die "***build flex error" && \
      touch ${METADATAMIPSELROOTFS}/flex_build
[ -f ${METADATAMIPSELROOTFS}/flex_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} install || \
    die "***install flex error" && \
      touch ${METADATAMIPSELROOTFS}/flex_install
ln -sfv libfl.a ${PREFIXMIPSELROOTFS}/usr/lib/libl.a
[ -f ${METADATAMIPSELROOTFS}/flex_cat ] || \
`cat > ${PREFIXMIPSELROOTFS}/usr/bin/lex << "EOF"
#!/bin/sh
# Begin /usr/bin/lex

exec /usr/bin/flex -l "$@"

# End /usr/bin/lex
EOF` || \
  die "***cat /usr/bin/lex flex error" && \
    touch ${METADATAMIPSELROOTFS}/flex_cat
chmod -v 755 ${PREFIXMIPSELROOTFS}/usr/bin/lex
popd

pushd ${BUILDMIPSELROOTFS}
cd iproute2-${IPROUTE2_VERSION}
for dir in ip misc tc; do
    cp ${dir}/Makefile{,.orig}
    sed 's/0755 -s/0755/' ${dir}/Makefile.orig > ${dir}/Makefile
done
cp misc/Makefile{,.orig}
sed '/^TARGETS/s@arpd@@g' misc/Makefile.orig > misc/Makefile
[ -f ${METADATAMIPSELROOTFS}/iproute2_build1 ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} CC="${CC}" \
       DOCDIR=/usr/share/doc/iproute2 \
       MANDIR=/usr/share/man  || \
         die "***build iproute2 error" && \
           touch ${METADATAMIPSELROOTFS}/iproute2_build1
[ -f ${METADATAMIPSELROOTFS}/iproute2_build2 ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS}  \
       DOCDIR=/usr/share/doc/iproute2 \
       MANDIR=/usr/share/man install || \
         die "***install iproute2 error"
             touch ${METADATAMIPSELROOTFS}/iproute2_build2
popd

pushd ${BUILDMIPSELROOTFS}
cd perl-${PERL_VERSION}
[ -f ${METADATAMIPSELROOTFS}/perl_cross_configure ] || \
  ./configure --prefix=/usr --target=mipsel-unknown-linux-gnu || \
     die "***config cross perl error" && \
       touch ${METADATAMIPSELROOTFS}/perl_cross_configure

[ -f ${METADATAMIPSELROOTFS}/perl_cross_build ] || \
  make || \
    die "***build cross perl error" && \
      touch ${METADATAMIPSELROOTFS}/perl_cross_build

[ -f ${METADATAMIPSELROOTFS}/perl_cross_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} install || \
    die "***install cross perl error" && \
      touch ${METADATAMIPSELROOTFS}/perl_cross_install

popd

pushd ${BUILDMIPSELROOTFS}
[ -d readline_build ] || mkdir readline_build
cd readline_build
[ -f ${METADATAMIPSELROOTFS}/readline_configure ] || \
  ${SRCMIPSELROOTFS}/readline-${READLINE_VERSION}/configure \
  --build=${CROSS_HOST} --host=${CROSS_TARGET32} \
  --prefix=/usr --libdir=/lib || \
    die "***config readline error" && \
      touch ${METADATAMIPSELROOTFS}/readline_configure
[ -f ${METADATAMIPSELROOTFS}/readline_build ] || \
  make -j${JOBS} || \
    die "***build readline error" && \
      touch ${METADATAMIPSELROOTFS}/readline_build
[ -f ${METADATAMIPSELROOTFS}/readline_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} install || \
    die "***install readline error" && \
      touch ${METADATAMIPSELROOTFS}/readline_install
[ -f ${METADATAMIPSELROOTFS}/readline_installdoc ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} install-doc || \
    die "***install readline doc error" && \
      touch ${METADATAMIPSELROOTFS}/readline_installdoc
[ -f ${METADATAMIPSELROOTFS}/readline_mva ] || \
  mv -v ${PREFIXMIPSELROOTFS}/lib/lib{readline,history}.a ${PREFIXMIPSELROOTFS}/usr/lib || \
    die "***move *.a readline doc error" && \
      touch ${METADATAMIPSELROOTFS}/readline_mva
[ -f ${METADATAMIPSELROOTFS}/readline_rmso ] || \
  rm -v ${PREFIXMIPSELROOTFS}/lib/lib{readline,history}.so || \
    die "***remove *.a readline doc error" && \
      touch ${METADATAMIPSELROOTFS}/readline_rmso
ln -sfv ../../lib/libreadline.so.6 ${PREFIXMIPSELROOTFS}/usr/lib/libreadline.so
ln -sfv ../../lib/libhistory.so.6 ${PREFIXMIPSELROOTFS}/usr/lib/libhistory.so
popd

pushd ${BUILDMIPSELROOTFS}
[ -d autoconf_build ] || mkdir autoconf_build
cd autoconf_build
[ -f ${METADATAMIPSELROOTFS}/autoconf_configure ] || \
  ${SRCMIPSELROOTFS}/autoconf-${AUTOCONF_VERSION}/configure \
  --build=${CROSS_HOST} \
  --host=${CROSS_TARGET32} --prefix=/usr || \
    die "***config autoconf error" && \
      touch ${METADATAMIPSELROOTFS}/autoconf_configure
[ -f ${METADATAMIPSELROOTFS}/autoconf_build ] || \
  make -j${JOBS} || \
    die "***build autoconf error" && \
      touch ${METADATAMIPSELROOTFS}/autoconf_build
[ -f ${METADATAMIPSELROOTFS}/autoconf_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} install || \
    die "***install autoconf error" && \
      touch ${METADATAMIPSELROOTFS}/autoconf_install
popd

pushd ${BUILDMIPSELROOTFS}
[ -d automake_build ] || mkdir automake_build
cd automake_build
[ -f ${METADATAMIPSELROOTFS}/automake_configure ] || \
  ${SRCMIPSELROOTFS}/automake-${AUTOMAKE_VERSION}/configure \
  --build=${CROSS_HOST} \
  --host=${CROSS_TARGET32} --prefix=/usr || \
    die "***config automake error" && \
      touch ${METADATAMIPSELROOTFS}/automake_configure
[ -f ${METADATAMIPSELROOTFS}/automake_build ] || \
  make -j${JOBS} || \
    die "***build automake error" && \
      touch ${METADATAMIPSELROOTFS}/automake_build
[ -f ${METADATAMIPSELROOTFS}/automake_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} install || \
    die "***install automake error" && \
      touch ${METADATAMIPSELROOTFS}/automake_install
popd

pushd ${BUILDMIPSELROOTFS}
[ -f ${METADATAMIPSELROOTFS}/python_cross_copy ] || \
  cp -ar ${SRCMIPSELROOTFS}/Python-${PYTHON_VERSION} python-cross-build || \
    die "***copy cross python error" && \
      touch ${METADATAMIPSELROOTFS}/python_cross_copy
cd python-cross-build

cat > config.cache << "EOF"
ac_cv_have_long_long_format=yes
ac_cv_file__dev_ptmx=no
ac_cv_file__dev_ptc=no
EOF
sed -e 's/\${SYSROOT}/${PREFIXMIPSELROOTFS}/g' \
    -e 's/lib64/lib/g' \
       ${PATCH}/python-3.3-cross-mips64.patch > tmp.patch
[ -f ${METADATAMIPSELROOTFS}/python_cross_patch ] || \
  patch -p1 < tmp.patch || \
    die "***patch cross python error" && \
      touch ${METADATAMIPSELROOTFS}/python_cross_patch
[ -f ${METADATAMIPSELROOTFS}/python_cross_configure ] || \
  CC=${CC} CXX=${CXX} \
  LDFLAGS="-L${PREFIXMIPSELROOTFS}/cross-tools/lib" \
  ./configure \
  --build=${CROSS_HOST} --host=${CROSS_TARGET32} \
  --libdir=/lib \
  --prefix=/usr \
  --cache-file=config.cache || \
    die "***config cross python error" && \
      touch ${METADATAMIPSELROOTFS}/python_cross_configure

[ -f ${METADATAMIPSELROOTFS}/python_cross_build ] || \
  make -j${JOBS} || \
    die "***build cross python error" && \
      touch ${METADATAMIPSELROOTFS}/python_cross_build

[ -f ${METADATAMIPSELROOTFS}/python_cross_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} install || \
    die "***install cross python error" && \
      touch ${METADATAMIPSELROOTFS}/python_cross_install
popd

pushd ${BUILDMIPSELROOTFS}
[ -d "gdb_build" ] || mkdir gdb_build
cd gdb_build
[ -f ${METADATAMIPSELROOTFS}/gdb_configure ] || \
  ${SRCMIPSELROOTFS}/gdb-${GDB_VERSION}/configure \
  --prefix=/usr --libexecdir=/usr/lib \
  --build=${CROSS_HOST}  \
  --host=${CROSS_TARGET32}\
  --enable-build-with-cxx \
  --with-gmp-lib=${PREFIXMIPSELROOTFS}/usr/lib  \
  --with-mpfr-lib=${PREFIXMIPSELROOTFS}/usr/lib \
  --with-mpc-lib=${PREFIXMIPSELROOTFS}/usr/lib \
  --enable-poison-system-directories || \
    die "***config gdb error" && \
      touch ${METADATAMIPSELROOTFS}/gdb_configure
[ -f ${METADATAMIPSELROOTFS}/gdb_build ] || \
  make -j${JOBS} || \
    die "***build gdb error" && \
      touch ${METADATAMIPSELROOTFS}/gdb_build
[ -f ${METADATAMIPSELROOTFS}/gdb_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} install || \
    die "***install gdb error" && \
      touch ${METADATAMIPSELROOTFS}/gdb_install
popd

pushd ${SRCMIPSELROOTFS}
cd bash-${BASH_VERSION}
[ -f ${METADATAMIPSELROOTFS}/bash_patch ] || \
  patch -Np1 -i ${PATCH}/bash-4.2-branch_update-4.patch || \
    die "***Patch bash error" && \
      touch ${METADATAMIPSELROOTFS}/bash_patch
popd

pushd ${BUILDMIPSELROOTFS}
[ -d bash_build ] || mkdir bash_build
cd bash_build
cat > config.cache << "EOF"
ac_cv_func_mmap_fixed_mapped=yes
ac_cv_func_strcoll_works=yes
ac_cv_func_working_mktime=yes
bash_cv_func_sigsetjmp=present
bash_cv_getcwd_malloc=yes
bash_cv_job_control_missing=present
bash_cv_printf_a_format=yes
bash_cv_sys_named_pipes=present
bash_cv_ulimit_maxfds=yes
bash_cv_under_sys_siglist=yes
bash_cv_unusable_rtsigs=no
gt_cv_int_divbyzero_sigfpe=yes
EOF
[ -f ${METADATAMIPSELROOTFS}/bash_configure ] || \
  ${SRCMIPSELROOTFS}/bash-${BASH_VERSION}/configure \
  --build=${CROSS_HOST} --host=${CROSS_TARGET32} \
  --prefix=/usr --bindir=/bin --cache-file=config.cache \
  --without-bash-malloc --with-installed-readline || \
    die "***config bash error" && \
      touch ${METADATAMIPSELROOTFS}/bash_configure
[ -f ${METADATAMIPSELROOTFS}/bash_build ] || \
  make -j${JOBS} || \
    die "***build bash error" && \
      touch ${METADATAMIPSELROOTFS}/bash_build
[ -f ${METADATAMIPSELROOTFS}/bash_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} htmldir=/usr/share/doc/bash-4.2 install || \
    die "***install bash error" && \
      touch ${METADATAMIPSELROOTFS}/bash_install
[ -f ${METADATAMIPSELROOTFS}/bash_link ] || \
  ln -svf bash ${PREFIXMIPSELROOTFS}/bin/sh || \
    die "***link bash error" && \
      touch ${METADATAMIPSELROOTFS}/bash_link
popd

pushd ${BUILDMIPSELROOTFS}
cd bzip2-${BZIP2_VERSION}
cp Makefile{,.orig}
sed -e "/^all:/s/ test//" Makefile.orig > Makefile
sed -i -e 's:ln -s -f $(PREFIX)/bin/:ln -s :' Makefile
[ -f ${METADATAMIPSELROOTFS}/bzip2_make ] || \
  make -f Makefile-libbz2_so CC="${CC}" AR="${AR}" RANLIB="${RANLIB}" || \
    die "***bzip make -f Makefile-libbz2_so error" && \
      touch ${METADATAMIPSELROOTFS}/bzip2_make
[ -f ${METADATAMIPSELROOTFS}/bzip2_clean ] || \
  make clean || \
    die "***clean bzip error" && \
      touch ${METADATAMIPSELROOTFS}/bzip2_clean
[ -f ${METADATAMIPSELROOTFS}/bzip2_build ] || \
  make CC="${CC}" AR="${AR}" RANLIB="${RANLIB}" || \
    die "***build bzip2 error" && \
      touch ${METADATAMIPSELROOTFS}/bzip2_build
[ -f ${METADATAMIPSELROOTFS}/bzip2_install ] || \
  make PREFIX=${PREFIXMIPSELROOTFS}/usr install || \
    die "***install bzip2 error" && \
      touch ${METADATAMIPSELROOTFS}/bzip2_install
[ -f ${METADATAMIPSELROOTFS}/bzip2_copy_shared ] || \
  cp -v bzip2-shared ${PREFIXMIPSELROOTFS}/bin/bzip2 || \
    die "***copy bzip2 error" && \
        touch ${METADATAMIPSELROOTFS}/bzip2_copy_shared
[ -f ${METADATAMIPSELROOTFS}/bzip2_copy_lib ] || \
  cp -av libbz2.so* ${PREFIXMIPSELROOTFS}/lib || \
    die "***copy bzip2 error" && \
      touch ${METADATAMIPSELROOTFS}/bzip2_copy_lib
ln -sfv ../../lib/libbz2.so.1.0 ${PREFIXMIPSELROOTFS}/usr/lib/libbz2.so
[ -f ${METADATAMIPSELROOTFS}/bzip2_remove ] || \
  rm -v ${PREFIXMIPSELROOTFS}/usr/bin/{bunzip2,bzcat,bzip2} || \
    die "***remove bzip2 error" && \
      touch ${METADATAMIPSELROOTFS}/bzip2_remove
ln -sfv bzip2 ${PREFIXMIPSELROOTFS}/bin/bunzip2
ln -sfv bzip2 ${PREFIXMIPSELROOTFS}/bin/bzcat
popd

pushd ${SRCMIPSELROOTFS}
cd diffutils-${DIFFUTILS_VERSION}
[ -f ${METADATAMIPSELROOTFS}/diffutils_patch ] || \
  sed -i '/gets is a security hole/d' lib/stdio.in.h || \
    die "***patch diffutils error" && \
      touch ${METADATAMIPSELROOTFS}/diffutils_patch
popd

pushd ${BUILDMIPSELROOTFS}
[ -d diffutils_build ] || mkdir diffutils_build
cd diffutils_build
[ -f ${METADATAMIPSELROOTFS}/diffutils_configure ] || \
  ${SRCMIPSELROOTFS}/diffutils-${DIFFUTILS_VERSION}/configure \
  --prefix=/usr --build=${CROSS_HOST} \
  --host=${CROSS_TARGET32} || \
    die "***config diffutils error" && \
      touch ${METADATAMIPSELROOTFS}/diffutils_configure
#sed -i 's@\(^#define DEFAULT_EDITOR_PROGRAM \).*@\1"vi"@' config.h
touch man/*.1
[ -f ${METADATAMIPSELROOTFS}/diffutils_build ] || \
  make -j${JOBS} || \
    die "***build diffutils error" && \
      touch ${METADATAMIPSELROOTFS}/diffutils_build
[ -f ${METADATAMIPSELROOTFS}/diffutils_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} install || \
    die "***install diffutils error" && \
      touch ${METADATAMIPSELROOTFS}/diffutils_install
popd

pushd ${BUILDMIPSELROOTFS}
[ -d file_cross_build ] || mkdir file_cross_build
cd file_cross_build
[ -f ${METADATAMIPSELROOTFS}/file_cross_configure ] || \
  ${SRCMIPSELROOTFS}/file-${FILE_VERSION}/configure \
  --prefix=/usr --build=${CROSS_HOST} \
  --host=${CROSS_TARGET32} || \
    die "***config cross file error" && \
      touch ${METADATAMIPSELROOTFS}/file_cross_configure
[ -f ${METADATAMIPSELROOTFS}/file_cross_build ] || \
  make -j${JOBS} || \
    die "***build cross file error" && \
      touch ${METADATAMIPSELROOTFS}/file_cross_build
[ -f ${METADATAMIPSELROOTFS}/file_cross_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} install || \
    die "***install file error" && \
      touch ${METADATAMIPSELROOTFS}/file_cross_install
popd

pushd ${BUILDMIPSELROOTFS}
[ -d findutils_cross_build ] || mkdir findutils_cross_build
cd findutils_cross_build
cat > config.cache << EOF
gl_cv_func_wcwidth_works=yes
gl_cv_header_working_fcntl_h=yes
ac_cv_func_fnmatch_gnu=yes
EOF
[ -f ${METADATAMIPSELROOTFS}/findutils_configure ] || \
  ${SRCMIPSELROOTFS}/findutils-${FINDUTILS_VERSION}/configure \
  --build=${CROSS_HOST} \
  --host=${CROSS_TARGET32} \
  --prefix=/usr --cache-file=config.cache \
  --libexecdir=/usr/lib/locate \
  --localstatedir=/var/lib/locate || \
    die "***config findutils error" && \
      touch ${METADATAMIPSELROOTFS}/findutils_configure
[ -f ${METADATAMIPSELROOTFS}/findutils_build ] || \
  make -j${JOBS} || \
    die "***build findutils error" && \
      touch ${METADATAMIPSELROOTFS}/findutils_build
[ -f ${METADATAMIPSELROOTFS}/findutils_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} install || \
    die "***install findutils error" && \
      touch ${METADATAMIPSELROOTFS}/findutils_install
[ -f ${METADATAMIPSELROOTFS}/findutils_mv ] || \
  mv -v ${PREFIXMIPSELROOTFS}/usr/bin/find ${PREFIXMIPSELROOTFS}/bin || \
    die "***move find findutils error" && \
      touch ${METADATAMIPSELROOTFS}/findutils_mv
[ -f ${METADATAMIPSELROOTFS}/findutils_cp ] || \
  cp ${PREFIXMIPSELROOTFS}/usr/bin/updatedb{,.orig} || \
    die "***copy findutils error" && \
      touch ${METADATAMIPSELROOTFS}/findutils_cp
[ -f ${METADATAMIPSELROOTFS}/findutils_sed ] || \
  sed 's@find:=${BINDIR}@find:=/bin@' ${PREFIXMIPSELROOTFS}/usr/bin/updatedb.orig > \
    ${PREFIXMIPSELROOTFS}/usr/bin/updatedb || \
    die "***copy findutils error" && \
      touch ${METADATAMIPSELROOTFS}/findutils_sed
[ -f ${METADATAMIPSELROOTFS}/findutils_rm ] || \
  rm ${PREFIXMIPSELROOTFS}/usr/bin/updatedb.orig || \
    die "***remove updatedb.orig findutils error" && \
      touch ${METADATAMIPSELROOTFS}/findutils_rm
popd

pushd ${BUILDMIPSELROOTFS}
[ -d gawk_build ] || mkdir gawk_build
cd gawk_build
[ -f ${METADATAMIPSELROOTFS}/gawk_configure ] || \
  ${SRCMIPSELROOTFS}/gawk-${GAWK_VERSION}/configure \
  --build=${CROSS_HOST} \
  --host=${CROSS_TARGET32} \
  --prefix=/usr --libexecdir=/usr/lib \
  --disable-libsigsegv || \
    die "***config gawk error" && \
      touch ${METADATAMIPSELROOTFS}/gawk_configure
[ -f ${METADATAMIPSELROOTFS}/gawk_build ] || \
  make -j${JOBS} || \
    die "***build gawk error" && \
      touch ${METADATAMIPSELROOTFS}/gawk_build
[ -f ${METADATAMIPSELROOTFS}/gawk_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} install || \
    die "***install gawk error" && \
      touch ${METADATAMIPSELROOTFS}/gawk_install
popd

pushd ${BUILDMIPSELROOTFS}
[ -d gettext_build ] || mkdir gettext_build
cd gettext_build
cat > config.cache << EOF
am_cv_func_iconv_works=yes
gl_cv_func_wcwidth_works=yes
gt_cv_func_printf_posix=yes
gt_cv_int_divbyzero_sigfpe=yes
EOF
[ -f ${METADATAMIPSELROOTFS}/gettext_configure ] || \
  ${SRCMIPSELROOTFS}/gettext-${GETTEXT_VERSION}/configure \
  --build=${CROSS_HOST} \
  --host=${CROSS_TARGET32} \
  --prefix=/usr --cache-file=config.cache || \
    die "***config gettext error" && \
      touch ${METADATAMIPSELROOTFS}/gettext_configure
[ -f ${METADATAMIPSELROOTFS}/gettext_build ] || \
  make -j${JOBS} || \
    die "***build gettext error" && \
      touch ${METADATAMIPSELROOTFS}/gettext_build
[ -f ${METADATAMIPSELROOTFS}/gettext_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} install || \
    die "***install gettext error" && \
      touch ${METADATAMIPSELROOTFS}/gettext_install
popd

pushd ${BUILDMIPSELROOTFS}
[ -d "grep_build" ] || mkdir grep_build
cd grep_build
[ -f ${METADATAMIPSELROOTFS}/grep_configure ] || \
  ${SRCMIPSELROOTFS}/grep-${GREP_VERSION}/configure \
  --build=${CROSS_HOST} --host=${CROSS_TARGET32} \
  --prefix=/usr --bindir=/bin --disable-perl-regexp || \
    die "***config grep error" && \
      touch ${METADATAMIPSELROOTFS}/grep_configure
[ -f ${METADATAMIPSELROOTFS}/grep_build ] || \
  make -j${JOBS} || \
    die "***build grep error" && \
      touch ${METADATAMIPSELROOTFS}/grep_build
[ -f ${METADATAMIPSELROOTFS}/grep_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} install || \
    die "***install grep error" && \
      touch ${METADATAMIPSELROOTFS}/grep_install
popd

pushd ${BUILDMIPSELROOTFS}
cd groff-${GROFF_VERSION}
# FIXME This is a sub dir config, it's very strange.
  pushd src/libs/gnulib/
  [ -f ${METADATAMIPSELROOTFS}/groff_cross_configure0 ] || \
    ./configure --build=${CROSS_HOST} \
    --host=${CROSS_TARGET32} --prefix=/usr || \
      die "confgure groff/src/libs/gnulib" && \
        touch ${METADATAMIPSELROOTFS}/groff_cross_configure0
  popd
[ -f ${METADATAMIPSELROOTFS}/groff_cross_configure ] || \
  PAGE=A4 ./configure --build=${CROSS_HOST} \
  --host=${CROSS_TARGET32} --prefix=/usr || \
    die "***config groff error" && \
      touch ${METADATAMIPSELROOTFS}/groff_cross_configure
[ -f ${METADATAMIPSELROOTFS}/groff_cross_build ] || \
  make TROFFBIN=troff GROFFBIN=groff GROFF_BIN_PATH= || \
    die "***build groff error" && \
      touch ${METADATAMIPSELROOTFS}/groff_cross_build
[ -f ${METADATAMIPSELROOTFS}/groff_cross_install ] || \
  make prefix=${PREFIXMIPSELROOTFS}/usr install || \
    die "***install cross groff error" && \
      touch ${METADATAMIPSELROOTFS}/groff_cross_install
[ -f ${METADATAMIPSELROOTFS}/groff_cross_link1 ] || \
  ln -sfv soelim ${PREFIXMIPSELROOTFS}/usr/bin/zsoelim || \
    die "***link1 cross groff error" && \
      touch ${METADATAMIPSELROOTFS}/groff_cross_link1 || \
[ -f ${METADATAMIPSELROOTFS}/groff_cross_link2 ] || \
  ln -sfv eqn ${PREFIXMIPSELROOTFS}/usr/bin/geqn || \
    die "***link2 cross groff error" && \
      touch ${METADATAMIPSELROOTFS}/groff_cross_link2
[ -f ${METADATAMIPSELROOTFS}/groff_cross_link3 ] || \
  ln -sfv tbl ${PREFIXMIPSELROOTFS}/usr/bin/gtbl || \
    die "***link3 cross groff error" && \
      touch ${METADATAMIPSELROOTFS}/groff_cross_link3
popd

pushd ${SRCMIPSELROOTFS}
cd gzip-${GZIP_VERSION}
[ -f ${METADATAMIPSELROOTFS}/gzip_sed ] || \
for file in $(grep -lr futimens *); do
  cp -v ${file}{,.orig}
  sed -e "s/futimens/gl_&/" ${file}.orig > ${file}
done || \
    die "***config gzip error" && \
      touch ${METADATAMIPSELROOTFS}/gzip_sed
popd

pushd ${BUILDMIPSELROOTFS}
[ -d gzip_build ] || mkdir gzip_build
cd gzip_build
[ -f ${METADATAMIPSELROOTFS}/gzip_configure ] || \
  ${SRCMIPSELROOTFS}/gzip-${GZIP_VERSION}/configure \
  --build=${CROSS_HOST} \
  --host=${CROSS_TARGET32} \
  --prefix=/usr --bindir=/bin || \
    die "***config gzip error" && \
      touch ${METADATAMIPSELROOTFS}/gzip_configure
[ -f ${METADATAMIPSELROOTFS}/gzip_build ] || \
  make -j${JOBS} || \
    die "***build gzip error" && \
      touch ${METADATAMIPSELROOTFS}/gzip_build
[ -f ${METADATAMIPSELROOTFS}/gzip_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} install || \
    die "***install gzip error" && \
      touch ${METADATAMIPSELROOTFS}/gzip_install
[ -f ${METADATAMIPSELROOTFS}/gzip_mv ] || \
  mv ${PREFIXMIPSELROOTFS}/bin/z{egrep,cmp,diff,fgrep,force,grep,less,more,new} \
  ${PREFIXMIPSELROOTFS}/usr/bin || \
    die "***move gzip error" && \
      touch ${METADATAMIPSELROOTFS}/gzip_mv
popd


# FIXME This use gcc, Not PREFIXMIPSELROOTFS-GCC
pushd ${BUILDMIPSELROOTFS}
cd iputils-${IPUTILS_VERSION}
[ -f ${METADATAMIPSELROOTFS}/iputilsfix_patch ] || \
  patch -p1 < ${PATCH}/iputils-s20121221-fixes-1.patch || \
    die "***patch fix iputils error" && \
      touch ${METADATAMIPSELROOTFS}/iputilsfix_patch
[ -f ${METADATAMIPSELROOTFS}/iputilsdoc_patch ] || \
  patch -p1 < ${PATCH}/iputils-s20121221-doc-1.patch || \
    die "***patch doc iputils error" && \
      touch ${METADATAMIPSELROOTFS}/iputilsdoc_patch
[ -f ${METADATAMIPSELROOTFS}/iputils_install ] || \
  make USE_CAP=no \
  IPV4_TARGETS="tracepath ping clockdiff rdisc" \
  IPV6_TARGETS="tracepath6 traceroute6" || \
    die "***build iputils error" && \
      touch ${METADATAMIPSELROOTFS}/iputils_install
[ -f ${METADATAMIPSELROOTFS}/iputilsping_install ] || \
  install -v -m755 ping ${PREFIXMIPSELROOTFS}/bin || \
    die "***install ping iputils error" && \
      touch ${METADATAMIPSELROOTFS}/iputilsping_install
[ -f ${METADATAMIPSELROOTFS}/iputilsclockdiff_install ] || \
  install -v -m755 clockdiff ${PREFIXMIPSELROOTFS}/usr/bin || \
    die "***install clockdiff iputils error" && \
      touch ${METADATAMIPSELROOTFS}/iputilsclockdiff_install
[ -f ${METADATAMIPSELROOTFS}/iputilsrdisc_install ] || \
  install -v -m755 rdisc ${PREFIXMIPSELROOTFS}/usr/bin || \
    die "***install rdisc iputils error" && \
      touch ${METADATAMIPSELROOTFS}/iputilsrdisc_install
[ -f ${METADATAMIPSELROOTFS}/iputilstrace_install ] || \
  install -v -m755 tracepath ${PREFIXMIPSELROOTFS}/usr/bin || \
    die "***install trace iputils error" && \
      touch ${METADATAMIPSELROOTFS}/iputilstrace_install
[ -f ${METADATAMIPSELROOTFS}/iputilsroute_install ] || \
  install -v -m755 trace{path,route}6 ${PREFIXMIPSELROOTFS}/usr/bin || \
    die "***install rdisc iputils error" && \
      touch ${METADATAMIPSELROOTFS}/iputilsroute_install
[ -f ${METADATAMIPSELROOTFS}/iputilsdoc_install ] || \
  install -v -m644 doc/*.8 ${PREFIXMIPSELROOTFS}/usr/share/man/man8 || \
    die "***install rdisc iputils error" && \
      touch ${METADATAMIPSELROOTFS}/iputilsdoc_install
popd

pushd ${SRCMIPSELROOTFS}
cd kbd-${KBD_VERSION}
[ -f ${METADATAMIPSELROOTFS}/kbd_patch ] || \
  patch -p1 < ${PATCH}/kbd-1.15.3-es.po_fix-1.patch || \
    die "patch kbd error" && \
      touch ${METADATAMIPSELROOTFS}/kbd_patch
popd

pushd ${BUILDMIPSELROOTFS}
[ -d kbd_build ] || mkdir kbd_build
cd kbd_build
cat > config.cache << EOF
ac_cv_func_setpgrp_void=yes
ac_cv_func_malloc_0_nonnull=yes
ac_cv_func_realloc_0_nonnull=yes
EOF
[ -f ${METADATAMIPSELROOTFS}/kbd_configure ] || \
  ${SRCMIPSELROOTFS}/kbd-${KBD_VERSION}/configure \
  --build=${CROSS_HOST} --host=${CROSS_TARGET32} \
  --disable-vlock \
  --prefix=/usr --cache-file=config.cache || \
    die "***config kbd error" && \
      touch ${METADATAMIPSELROOTFS}/kbd_configure
[ -f ${METADATAMIPSELROOTFS}/kbd_build ] || \
  make -j${JOBS} || \
    die "***build kbd error" && \
      touch ${METADATAMIPSELROOTFS}/kbd_build
[ -f ${METADATAMIPSELROOTFS}/kbd_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} install || \
    die "***install kbd error" && \
      touch ${METADATAMIPSELROOTFS}/kbd_install
[ -f ${METADATAMIPSELROOTFS}/kbd_mv ] || \
  mv -v ${PREFIXMIPSELROOTFS}/usr/bin/{kbd_mode,dumpkeys,loadkeys,openvt,setfont} ${PREFIXMIPSELROOTFS}/bin || \
    die "***move kbd error" && \
      touch ${METADATAMIPSELROOTFS}/kbd_mv
popd

pushd ${BUILDMIPSELROOTFS}
[ -d less_build ] || mkdir less_build
cd less_build
[ -f ${METADATAMIPSELROOTFS}/less_configure ] || \
  ${SRCMIPSELROOTFS}/less-${LESS_VERSION}/configure \
  --build=${CROSS_HOST} --host=${CROSS_TARGET32} \
  --prefix=/usr --sysconfdir=/etc || \
    die "***config less error" && \
      touch ${METADATAMIPSELROOTFS}/less_configure
[ -f ${METADATAMIPSELROOTFS}/less_build ] || \
  make -j${JOBS} || \
    die "***build less error" && \
      touch ${METADATAMIPSELROOTFS}/less_build
[ -f ${METADATAMIPSELROOTFS}/less_install ] || \
  make prefix=${PREFIXMIPSELROOTFS}/usr install || \
    die "***install less error" && \
      touch ${METADATAMIPSELROOTFS}/less_install
[ -f ${METADATAMIPSELROOTFS}/less_mv ] || \
  mv -v ${PREFIXMIPSELROOTFS}/usr/bin/less ${PREFIXMIPSELROOTFS}/bin || \
    die "***move less error" && \
      touch ${METADATAMIPSELROOTFS}/less_mv
popd

pushd ${BUILDMIPSELROOTFS}
[ -d make_build ] || mkdir make_build
cd make_build
[ -f ${METADATAMIPSELROOTFS}/make_configure ] || \
  ${SRCMIPSELROOTFS}/make-${MAKE_VERSION}/configure \
  --build=${CROSS_HOST} \
  --host=${CROSS_TARGET32} \
  --prefix=/usr || \
    die "***config make error" && \
      touch ${METADATAMIPSELROOTFS}/make_configure
[ -f ${METADATAMIPSELROOTFS}/make_build ] || \
  make -j${JOBS} || \
    die "***build make error" && \
      touch ${METADATAMIPSELROOTFS}/make_build
[ -f ${METADATAMIPSELROOTFS}/make_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} install || \
    die "***install make error" && \
      touch ${METADATAMIPSELROOTFS}/make_install
popd

pushd ${BUILDMIPSELROOTFS}
cd man-${MAN_VERSION}
cp configure{,.orig}
sed -e "/PREPATH=/s@=.*@=\"$(eval echo ${PREFIXMIPSELROOTFS}/{,usr/}{sbin,bin})\"@g" \
    -e 's@-is@&R@g' configure.orig > configure
cp src/man.conf.in{,.orig}
sed -e 's@MANPATH./usr/man@#&@g' \
    -e 's@MANPATH./usr/local/man@#&@g' \
    src/man.conf.in.orig > src/man.conf.in
[ -f ${METADATAMIPSELROOTFS}/man_configure ] || \
  ./configure -confdir=/etc || \
    die "***config man error" && \
      touch ${METADATAMIPSELROOTFS}/man_configure
[ -f ${METADATAMIPSELROOTFS}/man_cpconf ] || \
  cp conf_script{,.orig} || \
    die "***config man error" && \
      touch ${METADATAMIPSELROOTFS}/man_cpconf
sed "s@${PREFIXMIPSELROOTFS}@@" conf_script.orig > conf_script
[ -f ${METADATAMIPSELROOTFS}/man_gcc ] || \
  gcc src/makemsg.c -o src/makemsg || \
    die "***gcc man error" && \
      touch ${METADATAMIPSELROOTFS}/man_gcc
[ -f ${METADATAMIPSELROOTFS}/man_build ] || \
  make -j${JOBS} || \
    die "***build man error" && \
      touch ${METADATAMIPSELROOTFS}/man_build
[ -f ${METADATAMIPSELROOTFS}/man_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} PREFIX="" install || \
    die "***install man error" && \
      touch ${METADATAMIPSELROOTFS}/man_install
popd

pushd ${BUILDMIPSELROOTFS}
[ -d module_build ] || mkdir module_build
cd module_build
[ -f ${METADATAMIPSELROOTFS}/module_configure ] || \
  ${SRCMIPSELROOTFS}/module-init-tools-${MODULE_VERSION}/configure \
  --build=${CROSS_HOST} --host=${CROSS_TARGET32} \
  --prefix=/usr --bindir=/bin \
  --sbindir=/sbin --enable-zlib-dynamic || \
    die "***config module-init-tools error" && \
      touch ${METADATAMIPSELROOTFS}/module_configure
[ -f ${METADATAMIPSELROOTFS}/module_build ] || \
  make DOCBOOKTOMAN= || \
    die "***build module-init-tools error" && \
      touch ${METADATAMIPSELROOTFS}/module_build
[ -f ${METADATAMIPSELROOTFS}/module_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} INSTALL=install install || \
    die "***install module-init-tools error" && \
      touch ${METADATAMIPSELROOTFS}/module_install
popd

pushd ${BUILDMIPSELROOTFS}
[ -d patch_build ] || mkdir patch_build
cd patch_build
cat > config.cache << EOF
ac_cv_path_ed_PROGRAM=ed
ac_cv_func_strnlen_working=yes
EOF
[ -f ${METADATAMIPSELROOTFS}/patch_configure ] || \
  ${SRCMIPSELROOTFS}/patch-${PATCH_VERSION}/configure \
  --build=${CROSS_HOST} \
  --host=${CROSS_TARGET32} \
  --prefix=/usr --cache-file=config.cache || \
    die "***config patch error" && \
      touch ${METADATAMIPSELROOTFS}/patch_configure
[ -f ${METADATAMIPSELROOTFS}/patch_build ] || \
  make -j${JOBS} || \
    die "***build patch error" && \
      touch ${METADATAMIPSELROOTFS}/patch_build
[ -f ${METADATAMIPSELROOTFS}/patch_install ] || \
  make prefix=${PREFIXMIPSELROOTFS}/usr install || \
    die "***install patch error" && \
      touch ${METADATAMIPSELROOTFS}/patch_install
popd

pushd ${BUILDMIPSELROOTFS}
[ -d psmisc_build ] || mkdir psmisc_build
cd psmisc_build
cat > config.cache << EOF
ac_cv_func_malloc_0_nonnull=yes
ac_cv_func_realloc_0_nonnull=yes
EOF
[ -f ${METADATAMIPSELROOTFS}/psmisc_configure ] || \
  ${SRCMIPSELROOTFS}/psmisc-${PSMISC_VERSION}/configure \
  --build=${CROSS_HOST} \
  --host=${CROSS_TARGET32} \
  --prefix=/usr --exec-prefix="" \
  --cache-file=config.cache || \
    die "***config psmisc error" && \
      touch ${METADATAMIPSELROOTFS}/psmisc_configure
[ -f ${METADATAMIPSELROOTFS}/psmisc_build ] || \
  make -j${JOBS} || \
    die "***build psmisc error" && \
      touch ${METADATAMIPSELROOTFS}/psmisc_build
[ -f ${METADATAMIPSELROOTFS}/psmisc_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} install || \
    die "***install psmisc error" && \
      touch ${METADATAMIPSELROOTFS}/psmisc_install
[ -f ${METADATAMIPSELROOTFS}/psmisc_mv ] || \
  mv -v ${PREFIXMIPSELROOTFS}/bin/pstree* ${PREFIXMIPSELROOTFS}/usr/bin || \
    die "***move psmisc error" && \
      touch ${METADATAMIPSELROOTFS}/psmisc_mv
[ -f ${METADATAMIPSELROOTFS}/psmisc_link ] || \
  ln -sfv killall ${PREFIXMIPSELROOTFS}/bin/pidof || \
    die "***link psmisc error" && \
      touch ${METADATAMIPSELROOTFS}/psmisc_link
popd

pushd ${BUILDMIPSELROOTFS}
[ -d shadow_cross_build ] || mkdir shadow_cross_build
cd shadow_cross_build
cat > config.cache << EOF
ac_cv_func_setpgrp_void=yes
EOF
[ -f ${METADATAMIPSELROOTFS}/shadow_cross_configure ] || \
  ${SRCMIPSELROOTFS}/shadow-${SHADOW_VERSION}/configure \
  --build=${CROSS_HOST} --host=${CROSS_TARGET32} \
  --sysconfdir=/etc --without-libpam \
  --without-audit --without-selinux \
  --cache-file=config.cache || \
    die "***config shadow error" && \
      touch ${METADATAMIPSELROOTFS}/shadow_cross_configure
cp src/Makefile{,.orig}
sed 's/groups$(EXEEXT) //' src/Makefile.orig > src/Makefile
for mkf in $(find man -name Makefile)
do
  cp ${mkf}{,.orig}
  sed -e '/groups.1.xml/d' -e 's/groups.1 //' ${mkf}.orig > ${mkf}
done
[ -f ${METADATAMIPSELROOTFS}/shadow_cross_build ] || \
  make -j${JOBS} || \
    die "***build shadow error" && \
      touch ${METADATAMIPSELROOTFS}/shadow_cross_build
[ -f ${METADATAMIPSELROOTFS}/shadow_cross_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} install || \
    die "***install shadow error" && \
      touch ${METADATAMIPSELROOTFS}/shadow_cross_install
[ -f ${METADATAMIPSELROOTFS}/shadow_cross_cp ] || \
  cp ${PREFIXMIPSELROOTFS}/etc/login.defs login.defs.orig || \
    die "***copy shadow error" && \
      touch ${METADATAMIPSELROOTFS}/shadow_cross_cp
[ -f ${METADATAMIPSELROOTFS}/shadow_cross_sed ] || \
  sed -e's@#MD5_CRYPT_ENAB.no@MD5_CRYPT_ENAB yes@' \
  -e 's@/var/spool/mail@/var/mail@' \
  login.defs.orig > ${PREFIXMIPSELROOTFS}/etc/login.defs || \
    die "***sed shadow error" && \
      touch ${METADATAMIPSELROOTFS}/shadow_cross_sed
[ -f ${METADATAMIPSELROOTFS}/shadow_cross_mv ] || \
  mv -v ${PREFIXMIPSELROOTFS}/usr/bin/passwd ${PREFIXMIPSELROOTFS}/bin || \
    die "***move shadow error" && \
      touch ${METADATAMIPSELROOTFS}/shadow_cross_mv
popd

# Use make, not make -j${JOBS}
pushd ${BUILDMIPSELROOTFS}
[ -d libestr_build ] || mkdir libestr_build
cd libestr_build
cat > config.cache << EOF
ac_cv_func_malloc_0_nonnull=yes
ac_cv_func_realloc_0_nonnull=yes
EOF
[ -f ${METADATAMIPSELROOTFS}/libestr_configure ] || \
  ${SRCMIPSELROOTFS}/libestr-${LIBESTR_VERSION}/configure \
  --build=${CROSS_HOST} \
  --host=${CROSS_TARGET32} --prefix=/usr --sbindir=/sbin \
  --cache-file=config.cache || \
    die "***config libestr error" && \
      touch ${METADATAMIPSELROOTFS}/libestr_configure
[ -f ${METADATAMIPSELROOTFS}/libestr_build ] || \
  make || \
    die "***build libestr error" && \
      touch ${METADATAMIPSELROOTFS}/libestr_build
[ -f ${METADATAMIPSELROOTFS}/libestr_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} install || \
    die "***install libestr error" && \
      touch ${METADATAMIPSELROOTFS}/libestr_install
[ -f ${METADATAMIPSELROOTFS}/libestr_rmla ] || \
  rm ${PREFIXMIPSELROOTFS}/usr/lib/libestr.la || \
    die "***rm libestr.la error" && \
      touch ${METADATAMIPSELROOTFS}/libestr_rmla
popd

# Use make, not make -j${JOBS}
pushd ${BUILDMIPSELROOTFS}
[ -d libee_build ] || mkdir libee_build
cd libee_build
cat > config.cache << EOF
ac_cv_func_malloc_0_nonnull=yes
ac_cv_func_realloc_0_nonnull=yes
EOF
[ -f ${METADATAMIPSELROOTFS}/libee_configure ] || \
  PKG_CONFIG_LIBDIR=${PREFIXMIPSELROOTFS}/usr/lib \
  PKG_CONFIG_PATH=${PREFIXMIPSELROOTFS}/usr/lib/pkgconfig \
  ${SRCMIPSELROOTFS}/libee-${LIBEE_VERSION}/configure \
  --build=${CROSS_HOST} \
  --host=${CROSS_TARGET32} --prefix=/usr --sbindir=/sbin \
  --cache-file=config.cache || \
    die "***config libee error" && \
      touch ${METADATAMIPSELROOTFS}/libee_configure
[ -f ${METADATAMIPSELROOTFS}/libee_build ] || \
  make || \
    die "***build libee error" && \
      touch ${METADATAMIPSELROOTFS}/libee_build
[ -f ${METADATAMIPSELROOTFS}/libee_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} install || \
    die "***install libee error" && \
      touch ${METADATAMIPSELROOTFS}/libee_install
[ -f ${METADATAMIPSELROOTFS}/libee_rmla ] || \
  rm ${PREFIXMIPSELROOTFS}/usr/lib/libee.la || \
    die "***rm libee.la error" && \
      touch ${METADATAMIPSELROOTFS}/libee_rmla
popd


pushd ${BUILDMIPSELROOTFS}
[ -d jsonc_build ] || mkdir jsonc_build
cd jsonc_build
cat > config.cache << EOF
ac_cv_func_malloc_0_nonnull=yes
ac_cv_func_realloc_0_nonnull=yes
EOF
[ -f ${METADATAMIPSELROOTFS}/jsonc_configure ] || \
  PKG_CONFIG_LIBDIR=${PREFIXMIPSELROOTFS}/usr/lib \
  PKG_CONFIG_PATH=${PREFIXMIPSELROOTFS}/usr/lib/pkgconfig \
  ${SRCMIPSELROOTFS}/json-c-${JSONC_VERSION}/configure \
  --build=${CROSS_HOST} \
  --host=${CROSS_TARGET32} --prefix=/usr --sbindir=/sbin \
  --cache-file=config.cache || \
    die "***config jsonc error" && \
      touch ${METADATAMIPSELROOTFS}/jsonc_configure
[ -f ${METADATAMIPSELROOTFS}/jsonc_build ] || \
  make || \
    die "***build jsonc error" && \
      touch ${METADATAMIPSELROOTFS}/jsonc_build
[ -f ${METADATAMIPSELROOTFS}/jsonc_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} install || \
    die "***install jsonc error" && \
      touch ${METADATAMIPSELROOTFS}/jsonc_install

[ -f ${METADATAMIPSELROOTFS}/libjson_rmla ] || \
  rm ${PREFIXMIPSELROOTFS}/usr/lib/libjson.la || \
    die "***rm libjson.la error" && \
      touch ${METADATAMIPSELROOTFS}/libjson_rmla
popd

pushd ${BUILDMIPSELROOTFS}
[ -d rsyslog_build ] || mkdir rsyslog_build
cd rsyslog_build
cat > config.cache << EOF
ac_cv_func_malloc_0_nonnull=yes
ac_cv_func_realloc_0_nonnull=yes
_pkg_short_errors_supported=no
EOF
[ -f ${METADATAMIPSELROOTFS}/rsyslog_configure ] || \
  PKG_CONFIG_LIBDIR=${PREFIXMIPSELROOTFS}/usr/lib \
  PKG_CONFIG_PATH=${PREFIXMIPSELROOTFS}/usr/lib/pkgconfig \
  LDFLAGS="-L${PREFIXMIPSELROOTFS}/usr/lib -lestr" \
  ${SRCMIPSELROOTFS}/rsyslog-${RSYSLOG_VERSION}/configure \
  --build=${CROSS_HOST} \
  --host=${CROSS_TARGET32} \
  --prefix=/usr --sbindir=/sbin --libdir=/usr/lib \
  --cache-file=config.cache || \
    die "***config rsyslog error" && \
      touch ${METADATAMIPSELROOTFS}/rsyslog_configure
[ -f ${METADATAMIPSELROOTFS}/rsyslog_build ] || \
  make -j${JOBS}|| \
    die "***build rsyslog error" && \
      touch ${METADATAMIPSELROOTFS}/rsyslog_build
[ -f ${METADATAMIPSELROOTFS}/rsyslog_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} install || \
    die "***install rsyslog error" && \
      touch ${METADATAMIPSELROOTFS}/rsyslog_install
[ -f ${METADATAMIPSELROOTFS}/rsyslog_install_d ] || \
  install -dv ${PREFIXMIPSELROOTFS}/etc/rsyslog.d || \
    die "***install rsyslog rsyslog.d error" && \
      touch ${METADATAMIPSELROOTFS}/rsyslog_install_d
popd

[ -f ${METADATAMIPSELROOTFS}/rsyslog_cat ] || \
`cat > ${PREFIXMIPSELROOTFS}/etc/rsyslog.conf << "EOF"
# Begin /etc/rsyslog.conf

# PREFIXMIPSELROOTFS configuration of rsyslog. For more info use man rsyslog.conf

#######################################################################
# Rsyslog Modules

# Support for Local System Logging
$ModLoad imuxsock.so

# Support for Kernel Logging
$ModLoad imklog.so

#######################################################################
# Global Options

# Use traditional timestamp format.
$ActionFileDefaultTemplate RSYSLOG_TraditionalFileFormat

# Set the default permissions for all log files.
$FileOwner root
$FileGroup root
$FileCreateMode 0640
$DirCreateMode 0755

# Provides UDP reception
$ModLoad imudp
$UDPServerRun 514

# Disable Repating of Entries
$RepeatedMsgReduction on

#######################################################################
# Include Rsyslog Config Snippets

$IncludeConfig /etc/rsyslog.d/*.conf

#######################################################################
# Standard Log Files

auth,authpriv.*                        /var/log/auth.log
*.*;auth,authpriv.none                -/var/log/syslog
daemon.*                        -/var/log/daemon.log
kern.*                                -/var/log/kern.log
lpr.*                                -/var/log/lpr.log
mail.*                                -/var/log/mail.log
user.*                                -/var/log/user.log

# Catch All Logs
*.=debug;\
        auth,authpriv.none;\
        news.none;mail.none        -/var/log/debug
        *.=info;*.=notice;*.=warn;\
        auth,authpriv.none;\
        cron,daemon.none;\
        mail,news.none                -/var/log/messages

# Emergency are shown to everyone
*.emerg                                *

# End /etc/rsyslog.conf
EOF` || \
  die "***cat rsyslog rsyslog.d error" && \
    touch ${METADATAMIPSELROOTFS}/rsyslog_cat

pushd ${SRCMIPSELROOTFS}
cd sysvinit-${SYSVINIT_VERSION}
[ -f ${METADATAMIPSELROOTFS}/sysvinit_cpsed ] || \
  cp -v src/Makefile src/Makefile.orig && \
  sed -e 's@/dev/initctl@$(ROOT)&@g' \
      -e 's@\(mknod \)-m \([0-9]* \)\(.* \)p@\1\3p; chmod \2\3@g' \
      -e '/^ifeq/s/$(ROOT)//' \
      -e 's@/usr/lib@$(ROOT)&@' \
      src/Makefile.orig > src/Makefile || \
        die "***copy sed sysvinit error" && \
         touch ${METADATAMIPSELROOTFS}/sysvinit_cpsed
[ -f ${METADATAMIPSELROOTFS}/cat_inittab_1 ] || \
`cat > ${PREFIXMIPSELROOTFS}/etc/inittab << "EOF"
# Begin /etc/inittab

id:3:initdefault:

si::sysinit:/etc/rc.d/init.d/rc sysinit

l0:0:wait:/etc/rc.d/init.d/rc 0
l1:S1:wait:/etc/rc.d/init.d/rc 1
l2:2:wait:/etc/rc.d/init.d/rc 2
l3:3:wait:/etc/rc.d/init.d/rc 3
l4:4:wait:/etc/rc.d/init.d/rc 4
l5:5:wait:/etc/rc.d/init.d/rc 5
l6:6:wait:/etc/rc.d/init.d/rc 6

ca:12345:ctrlaltdel:/sbin/shutdown -t1 -a -r now

su:S016:once:/sbin/sulogin

EOF` || \
    die "***cat inittab first error" && \
      touch ${METADATAMIPSELROOTFS}/cat_inittab_1
[ -f ${METADATAMIPSELROOTFS}/sysvinit_build_clobber ] || \
  make -C src clobber  || \
    die "***build sysvinit clobber error" && \
      touch ${METADATAMIPSELROOTFS}/sysvinit_build_clobber
[ -f ${METADATAMIPSELROOTFS}/sysvinit_build ] || \
  make -C src ROOT=${PREFIXMIPSELROOTFS} CC="${CC}" || \
    die "***build sysvinit error" && \
      touch ${METADATAMIPSELROOTFS}/sysvinit_build
[ -f ${METADATAMIPSELROOTFS}/sysvinit_install ] || \
  make -C src ROOT=${PREFIXMIPSELROOTFS} INSTALL="install" install || \
    die "***install sysvinit error" && \
      touch ${METADATAMIPSELROOTFS}/sysvinit_install
popd

[ -f ${METADATAMIPSELROOTFS}/cat_inittab_2 ] || \
`cat >> ${PREFIXMIPSELROOTFS}/etc/inittab << "EOF"
1:2345:respawn:/sbin/agetty -I '\033(K' tty1 9600
2:2345:respawn:/sbin/agetty -I '\033(K' tty2 9600
3:2345:respawn:/sbin/agetty -I '\033(K' tty3 9600
4:2345:respawn:/sbin/agetty -I '\033(K' tty4 9600
5:2345:respawn:/sbin/agetty -I '\033(K' tty5 9600
6:2345:respawn:/sbin/agetty -I '\033(K' tty6 9600

EOF` || \
  die "***cat inittab second error" && \
    touch ${METADATAMIPSELROOTFS}/cat_inittab_2

[ -f ${METADATAMIPSELROOTFS}/cat_inittab_3 ] || \
`cat >> ${PREFIXMIPSELROOTFS}/etc/inittab << "EOF"
c0:12345:respawn:/sbin/agetty 115200 ttyS0 vt100
EOF` || \
  die "***cat inittab third error" && \
    touch ${METADATAMIPSELROOTFS}/cat_inittab_3

[ -f ${METADATAMIPSELROOTFS}/cat_inittab_4 ] || \
`cat >> ${PREFIXMIPSELROOTFS}/etc/inittab << "EOF"
# End /etc/inittab
EOF` || \
  die "***cat inittab forth error" && \
    touch ${METADATAMIPSELROOTFS}/cat_inittab_4



pushd ${SRCMIPSELROOTFS}
cd tar-${TAR_VERSION}
[ -f ${METADATAMIPSELROOTFS}/tar_patch ] || \
  sed -i '/gets is a security hole/d' gnu/stdio.in.h || \
    die "***patch tar error"
      touch ${METADATAMIPSELROOTFS}/tar_patch
popd

pushd ${BUILDMIPSELROOTFS}
[ -d "tar-build" ] || mkdir tar-build
cd tar-build
cat > config.cache << EOF
gl_cv_func_wcwidth_works=yes
gl_cv_func_btowc_eof=yes
ac_cv_func_malloc_0_nonnull=yes
ac_cv_func_realloc_0_nonnull=yes
gl_cv_func_mbrtowc_incomplete_state=yes
gl_cv_func_mbrtowc_nul_retval=yes
gl_cv_func_mbrtowc_null_arg=yes
gl_cv_func_mbrtowc_retval=yes
gl_cv_func_wcrtomb_retval=yes
EOF
[ -f ${METADATAMIPSELROOTFS}/tar_configure ] || \
  ${SRCMIPSELROOTFS}/tar-${TAR_VERSION}/configure \
  --build=${CROSS_HOST} --host=${CROSS_TARGET32} \
  --prefix=/usr --bindir=/bin --libexecdir=/usr/sbin \
  --cache-file=config.cache || \
    die "***config tar error" && \
      touch ${METADATAMIPSELROOTFS}/tar_configure
[ -f ${METADATAMIPSELROOTFS}/tar_build ] || \
  make -j${JOBS} || \
    die "***build tar error" && \
      touch ${METADATAMIPSELROOTFS}/tar_build
[ -f ${METADATAMIPSELROOTFS}/tar_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} install || \
    die "***install tar error" && \
      touch ${METADATAMIPSELROOTFS}/tar_install
popd

pushd ${BUILDMIPSELROOTFS}
[ -d "texinfo_build" ] || mkdir texinfo_build
cd texinfo_build
[ -f ${METADATAMIPSELROOTFS}/texinfo_configure ] || \
  ${SRCMIPSELROOTFS}/texinfo-${TEXINFO_VERSION}/configure \
  --build=${CROSS_HOST} --host=${CROSS_TARGET32} \
  --prefix=/usr || \
    die "***config texinfo error" && \
      touch ${METADATAMIPSELROOTFS}/texinfo_configure
[ -f ${METADATAMIPSELROOTFS}/texinfo_build_lib ] || \
  make -C tools/gnulib/lib || \
    die "***build texinfo lib error" && \
      touch ${METADATAMIPSELROOTFS}/texinfo_build_lib
[ -f ${METADATAMIPSELROOTFS}/texinfo_build_tools ] || \
  make -C tools || \
    die "***build texinfo tools error" && \
      touch ${METADATAMIPSELROOTFS}/texinfo_build_tools
[ -f ${METADATAMIPSELROOTFS}/texinfo_build ] || \
  make -j${JOBS} || \
    die "***build texinfo error" && \
      touch ${METADATAMIPSELROOTFS}/texinfo_build
[ -f ${METADATAMIPSELROOTFS}/texinfo_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} install || \
    die "***install texinfo error" && \
      touch ${METADATAMIPSELROOTFS}/texinfo_install
cd ${PREFIXMIPSELROOTFS}/usr/share/info
[ -f ${METADATAMIPSELROOTFS}/texinfo_rmdir ] || \
  rm dir || \
    die "***remove dir texinfo error" && \
      touch ${METADATAMIPSELROOTFS}/texinfo_rmdir
for f in *
do install-info ${f} dir 2>/dev/null
done
popd

pushd ${BUILDMIPSELROOTFS}
[ -d "kmod_build" ] || mkdir kmod_build
cd kmod_build
[ -f ${METADATAMIPSELROOTFS}/kmod_configure ] || \
  ${SRCMIPSELROOTFS}/kmod-${KMOD_VERSION}/configure \
  --build=${CROSS_HOST} \
  --host=${CROSS_TARGET32} --target=${CROSS_TARGET32} \
  --prefix=/usr --bindir=/bin --disable-manpages || \
    die "***config kmod error" && \
      touch ${METADATAMIPSELROOTFS}/kmod_configure
[ -f ${METADATAMIPSELROOTFS}/kmod_build ] || \
  make -j${JOBS} || \
    die "***build kmod error" && \
      touch ${METADATAMIPSELROOTFS}/kmod_build
[ -f ${METADATAMIPSELROOTFS}/kmod_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} install || \
    die "***install kmod error" && \
      touch ${METADATAMIPSELROOTFS}/kmod_install
[ -f ${METADATAMIPSELROOTFS}/kmod_rmla ] || \
  rm -rf ${PREFIXMIPSELROOTFS}/usr/lib/libkmod.la || \
    die "***remove libkmod.la error" && \
      touch ${METADATAMIPSELROOTFS}/kmod_rmla
popd

pushd ${PREFIXMIPSELROOTFS}/usr/share/misc
[ -f ${METADATAMIPSELROOTFS}/patch_pci ] || \
  patch -p1 < ${PATCH}/pci-ids-2.0.patch || \
    die "***pci ids error" && \
      touch ${METADATAMIPSELROOTFS}/patch_pci
popd

## FIXME Now we use --disable-gudev, so the glib is disabled
pushd ${BUILDMIPSELROOTFS}
[ -d "udev_build" ] || mkdir udev_build
cd udev_build
[ -f ${METADATAMIPSELROOTFS}/udev_configure ] || \
  PKG_CONFIG=true \
  LDFLAGS="-lblkid -luuid -lkmod -lrt" \
  CC=${CC} \
  ${SRCMIPSELROOTFS}/udev-${UDEV_VERSION}/configure \
  --build=${CROSS_HOST} --host=${CROSS_TARGET32} \
  --exec-prefix="" --sysconfdir=/etc \
  --libexecdir=/lib --libdir=/usr/lib -disable-gudev \
  --disable-manpages  \
  --with-pci-ids-path=${PREFIXMIPSELROOTFS}/usr/share/misc || \
    die "***config udev error" && \
      touch ${METADATAMIPSELROOTFS}/udev_configure
[ -f ${METADATAMIPSELROOTFS}/udev_build ] || \
  make -j${JOBS} || \
    die "***build udev error" && \
      touch ${METADATAMIPSELROOTFS}/udev_build
[ -f ${METADATAMIPSELROOTFS}/udev_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} install || \
    die "***install udev error" && \
      touch ${METADATAMIPSELROOTFS}/udev_install
popd

pushd ${BUILDMIPSELROOTFS}
cd ${VIM_DIR}
[ -f ${METADATAMIPSELROOTFS}/vim_patch ] || \
  patch -Np1 -i ${PATCH}/vim-7.3-branch_update-4.patch || \
    die "*** patch vim error" && \
      touch ${METADATAMIPSELROOTFS}/vim_patch
cat >> src/feature.h << "EOF"
#define SYS_VIMRC_FILE "/etc/vimrc"
EOF
cat > src/auto/config.cache << "EOF"
vim_cv_getcwd_broken=no
vim_cv_memmove_handles_overlap=yes
vim_cv_stat_ignores_slash=no
vim_cv_terminfo=yes
vim_cv_tgent=zero
vim_cv_toupper_broken=no
vim_cv_tty_group=world
ac_cv_sizeof_int=4
EOF
[ -f ${METADATAMIPSELROOTFS}/vim_configure ] || \
  CPPFLAGS="-DUNUSED=" ./configure --build=${CROSS_HOST} \
  --host=${CROSS_TARGET32} \
  --prefix=/usr --enable-multibyte --enable-gui=no \
  --disable-gtktest --disable-xim --with-features=normal \
  --disable-gpm --without-x --disable-netbeans \
  --with-tlib=ncurses || \
    die "***config vim error" && \
      touch ${METADATAMIPSELROOTFS}/vim_configure
[ -f ${METADATAMIPSELROOTFS}/vim_build ] || \
  make -j${JOBS} || \
    die "***build vim error" && \
      touch ${METADATAMIPSELROOTFS}/vim_build
[ -f ${METADATAMIPSELROOTFS}/vim_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS}  install || \
    die "***install vim error" && \
      touch ${METADATAMIPSELROOTFS}/vim_install
ln -sfv vim ${PREFIXMIPSELROOTFS}/usr/bin/vi
ln -sfnv ../vim/vim72/doc ${PREFIXMIPSELROOTFS}/usr/share/doc/vim-7.2
popd

pushd ${BUILDMIPSELROOTFS}
[ -d "xz_build" ] || mkdir xz_build
cd xz_build
[ -f ${METADATAMIPSELROOTFS}/xz_configure ] || \
  ${SRCMIPSELROOTFS}/xz-${XZ_VERSION}/configure \
  --build=${CROSS_HOST} \
  --host=${CROSS_TARGET32} \
  --prefix=/usr || \
    die "***config xz error" && \
      touch ${METADATAMIPSELROOTFS}/xz_configure
[ -f ${METADATAMIPSELROOTFS}/xz_build ] || \
  make -j${JOBS} || \
    die "***build xz error" && \
      touch ${METADATAMIPSELROOTFS}/xz_build
[ -f ${METADATAMIPSELROOTFS}/xz_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} install || \
    die "***install xz error" && \
      touch ${METADATAMIPSELROOTFS}/xz_install
[ -f ${METADATAMIPSELROOTFS}/xz_mv ] || \
  mv -v ${PREFIXMIPSELROOTFS}/usr/bin/{xz,lzma,lzcat,unlzma,unxz,xzcat} ${PREFIXMIPSELROOTFS}/bin || \
    die "***move xz error" && \
      touch ${METADATAMIPSELROOTFS}/xz_mv
popd

pushd ${BUILDMIPSELROOTFS}
cd dhcpcd-${DHCPCD_VERSION}
[ -f ${METADATAMIPSELROOTFS}/dhcpcd_configure ] || \
  PREFIX="" ./configure \
  --target=${CROSS_TARGET32} --host=${CROSS_HOST} || \
    die "***config dhcpcd error" && \
      touch ${METADATAMIPSELROOTFS}/dhcpcd_configure
[ -f ${METADATAMIPSELROOTFS}/dhcpcd_build ] || \
  make PREFIX=/usr BINDIR=/sbin SYSCONFDIR=/etc \
       DBDIR=/var/lib/dhcpcd LIBEXECDIR=/usr/lib/dhcpcd || \
    die "***build dhcpcd error" && \
      touch ${METADATAMIPSELROOTFS}/dhcpcd_build
[ -f ${METADATAMIPSELROOTFS}/dhcpcd_install ] || \
  make PREFIX=/usr BINDIR=/sbin SYSCONFDIR=/etc \
       DBDIR=/var/lib/dhcpcd LIBEXECDIR=/usr/lib/dhcpcd \
       DESTDIR=${PREFIXMIPSELROOTFS} install || \
    die "***install dhcpcd error" && \
      touch ${METADATAMIPSELROOTFS}/dhcpcd_install
popd

pushd ${BUILDMIPSELROOTFS}
cd bootscripts-cross-lfs-${BOOTSCRIPTS_VERSION}
[ -f ${METADATAMIPSELROOTFS}/bootscript_build ] || \
   make DESTDIR=${PREFIXMIPSELROOTFS} install-bootscripts || \
    die "***install bootscripts error" && \
      touch ${METADATAMIPSELROOTFS}/bootscript_build
[ -f ${METADATAMIPSELROOTFS}/bootscript_install ] || \
  make DESTDIR=${PREFIXMIPSELROOTFS} install-network || \
    die "***install network error" && \
      touch ${METADATAMIPSELROOTFS}/bootscript_install
popd

#########################################################################
#
# Now we add config file to the file system.
#
#########################################################################

[ -f ${METADATAMIPSELROOTFS}/create_clock ] || \
`cat > ${PREFIXMIPSELROOTFS}/etc/sysconfig/clock << "EOF"
# Begin /etc/sysconfig/clock

UTC=1

# End /etc/sysconfig/clock
EOF` || \
  die "Create clock error" && \
      touch ${METADATAMIPSELROOTFS}/create_clock


[ -f ${METADATAMIPSELROOTFS}/create_inputrc ] || \
`cat > ${PREFIXMIPSELROOTFS}/etc/inputrc << "EOF"
# Begin /etc/inputrc
# Modified by Chris Lynn <roryo@roryo.dynup.net>

# Allow the command prompt to wrap to the next line
set horizontal-scroll-mode Off

# Enable 8bit input
set meta-flag On
set input-meta On

# Turns off 8th bit stripping
set convert-meta Off

# Keep the 8th bit for display
set output-meta On

# none, visible or audible
set bell-style none

# All of the following map the escape sequence of the
# value contained inside the 1st argument to the
# readline specific functions

"\eOd": backward-word
"\eOc": forward-word

# for linux console
"\e[1~": beginning-of-line
"\e[4~": end-of-line
"\e[5~": beginning-of-history
"\e[6~": end-of-history
"\e[3~": delete-char
"\e[2~": quoted-insert

# for xterm
"\eOH": beginning-of-line
"\eOF": end-of-line

# for Konsole
"\e[H": beginning-of-line
"\e[F": end-of-line

# End /etc/inputrc
EOF` || die "Create inputrc error" && \
  touch ${METADATAMIPSELROOTFS}/create_inputrc

[ -f ${METADATAMIPSELROOTFS}/create_network ] || \
`cat > ${PREFIXMIPSELROOTFS}/etc/sysconfig/network << EOF
HOSTNAME=mipsel-gnu-linux
EOF` || die "create network error" && \
  touch ${METADATAMIPSELROOTFS}/create_network

[ -f ${METADATAMIPSELROOTFS}/create_host ] || \
`cat > ${PREFIXMIPSELROOTFS}/etc/hosts << "EOF"
# Begin /etc/hosts (network card version)

127.0.0.1 localhost

# End /etc/hosts (network card version)
EOF` || die "crete host error" && \
  touch ${METADATAMIPSELROOTFS}/create_host

[ -f ${METADATAMIPSELROOTFS}/create_host ] || \
`cat > ${PREFIXMIPSELROOTFS}/etc/resolv.conf << "EOF"
# Generated by NetworkManager
nameserver 127.0.1.1
EOF` || die "crete resolv.conf error" && \
  touch ${METADATAMIPSELROOTFS}/create_host

[ -d ${PREFIXMIPSELROOTFS}/etc/sysconfig/network-devices ] || \
  mkdir -pv ${PREFIXMIPSELROOTFS}/etc/sysconfig/network-devices
pushd ${PREFIXMIPSELROOTFS}/etc/sysconfig/network-devices &&
[ -f ${METADATAMIPSELROOTFS}/mkdir_ifconfig ] || \
[ -d ifconfig.eth0 ] || mkdir -v ifconfig.eth0 || \
  die "***create static ip address error" && \
    touch ${METADATAMIPSELROOTFS}/mkdir_ifconfig
[ -f ${METADATAMIPSELROOTFS}/create_static_ip ] || \
`cat > ifconfig.eth0/ipv4 << "EOF"
ONBOOT=yes
SERVICE=ipv4-static
IP=192.168.1.1
GATEWAY=192.168.1.2
PREFIX=24
BROADCAST=192.168.1.255
EOF` || \
  die "***create static ip address error" && \
    touch ${METADATAMIPSELROOTFS}/create_static_ip
popd

[ -f ${METADATAMIPSELROOTFS}/create_fstab ] || \
`cat > ${PREFIXMIPSELROOTFS}/etc/fstab << "EOF"
# Begin /etc/fstab

# file system  mount-point  type   options          dump  fsck
#                                                         order

/dev/hda       /            ext3   defaults         1     1
#/dev/[yyy]     swap         swap   pri=1           0     0
proc           /proc        proc   defaults         0     0
sysfs          /sys         sysfs  defaults         0     0
devpts         /dev/pts     devpts gid=4,mode=620   0     0
shm            /dev/shm     tmpfs  defaults         0     0
tmpfs          /run         tmpfs  defaults         0     0
# End /etc/fstab
EOF` || \
  die "create fstab error" && \
    touch ${METADATAMIPSELROOTFS}/create_fstab

[ -f ${METADATAMIPSELROOTFS}/create_bash_profile ] || \
`cat > ${PREFIXMIPSELROOTFS}/root/.bash_profile << EOF
set +h
PS1='\u:\w\$ '
LC_ALL=POSIX
PATH=$PATH:/bin:/usr/bin:/sbin:/usr/sbin
export LC_ALL PATH PS1

source .bashrc
EOF` || \
  die "***create bash_profile error"
    touch ${METADATAMIPSELROOTFS}/create_bash_profile

[ -f ${METADATAMIPSELROOTFS}/create_bashrc ] || \
`cat > ${PREFIXMIPSELROOTFS}/root/.bashrc << EOF
set +h
umask 022
export PYTHONHOME=/usr
EOF` || \
  die "***create bashrc error"
    touch ${METADATAMIPSELROOTFS}/create_bashrc

pushd ${BUILDMIPSELROOTFS}
cd linux-${LINUX_VERSION}
[ -f ${METADATAMIPSELROOTFS}/linux_cross_mrpro ] || \
  make mrproper || \
    die "clean cross linux error" && \
      touch ${METADATAMIPSELROOTFS}/linux_cross_mrpro
[ -f ${METADATAMIPSELROOTFS}/linux_config_patch ] || \
  patch -p1 < ${PATCH}/linux-mipsel-sysroot-defconfig.patch || \
    die "***Patch linux config error" && \
      touch ${METADATAMIPSELROOTFS}/linux_config_patch
[ -f ${METADATAMIPSELROOTFS}/linux_defconfig ] || \
  make ARCH=mips mipsel_sysroot_defconfig || \
    die "***Patch linux config error" && \
      touch ${METADATAMIPSELROOTFS}/linux_defconfig
[ -f ${METADATAMIPSELROOTFS}/linux_cross_build ] || \
make -j${JOBS} ARCH=mips PREFIXMIPSELSYSROOT_COMPILE=${CROSS_TARGET32}- || \
  die "build cross linux error" && \
      touch ${METADATAMIPSELROOTFS}/linux_cross_build
[ -f ${METADATAMIPSELROOTFS}/linux_cross_install ] || \
  make ARCH=mips PREFIXMIPSELSYSROOT_COMPILE=${CROSS_TARGET32}- \
  INSTALL_MOD_PATH=${PREFIXMIPSELROOTFS} modules_install || \
    die "install cross linux module error" && \
      touch ${METADATAMIPSELROOTFS}/linux_cross_install
[ -f ${METADATAMIPSELROOTFS}/linux_cross_cpvmlinux ] || \
  cp vmlinux ${PREFIXMIPSELROOTFS}/boot/ || \
    die "cp vmlinux error" && \
      touch ${METADATAMIPSELROOTFS}/linux_cross_cpvmlinux
[ -f ${METADATAMIPSELROOTFS}/linux_cross_cpsystemmap ] || \
  cp System.map ${PREFIXMIPSELROOTFS}/boot/System.map-3.3.7 || \
    die "cp System.map error" && \
      touch ${METADATAMIPSELROOTFS}/linux_cross_cpsystemmap
[ -f ${METADATAMIPSELROOTFS}/linux_cross_cpconfig ] || \
  cp .config ${PREFIXMIPSELROOTFS}/boot/config-3.3.7 || \
    die "***cp config file error" && \
      touch ${METADATAMIPSELROOTFS}/linux_cross_cpconfig
popd

[ -f ${METADATAMIPSELROOTFS}/create_vernu ] || \
`cat > ${PREFIXMIPSELROOTFS}/etc/clfs-release << EOF
PREFIXMIPSELROOTFS-Sysroot
EOF` || \
  die "***create version number error" && \
    touch ${METADATAMIPSELROOTFS}/create_vernu
############### Change Own Ship ########################
[ -f ${METADATAMIPSELROOTFS}/change_own ] || \
  sudo chown -Rv 0:0 ${PREFIXMIPSELROOTFS} || \
    die "***Change own error" && \
      touch ${METADATAMIPSELROOTFS}/change_own

[ -f ${METADATAMIPSELROOTFS}/touch_file ] || \
  sudo touch ${PREFIXMIPSELROOTFS}/var/run/utmp ${PREFIXMIPSELROOTFS}/var/log/{btmp,lastlog,wtmp} || \
    die "***touch file error" && \
      touch ${METADATAMIPSELROOTFS}/touch_file

[ -f ${METADATAMIPSELROOTFS}/change_utmp ] || \
  sudo chmod -v 664 ${PREFIXMIPSELROOTFS}/var/run/utmp ${PREFIXMIPSELROOTFS}/var/log/lastlog || \
    die "***Change utmp/lastlog group error" && \
      touch ${METADATAMIPSELROOTFS}/change_utmp

[ -f ${METADATAMIPSELROOTFS}/write_group ] || \
  sudo chgrp -v 4 ${PREFIXMIPSELROOTFS}/usr/bin/write || \
    die "***Change write group error" && \
      touch ${METADATAMIPSELROOTFS}/write_group

[ -f ${METADATAMIPSELROOTFS}/write_mode ] || \
  sudo chmod g+s ${PREFIXMIPSELROOTFS}/usr/bin/write || \
    die "Change write mode error" && \
      touch ${METADATAMIPSELROOTFS}/write_mode

[ -f ${METADATAMIPSELROOTFS}/create_null ] || \
  sudo mknod -m 0666 ${PREFIXMIPSELROOTFS}/dev/null c 1 3 || \
    die "***Create null error" && \
      touch ${METADATAMIPSELROOTFS}/create_null

[ -f ${METADATAMIPSELROOTFS}/create_console ] || \
  sudo mknod -m 0600 ${PREFIXMIPSELROOTFS}/dev/console c 5 1 || \
    die "***Create console error" && \
      touch ${METADATAMIPSELROOTFS}/create_console

[ -f ${METADATAMIPSELROOTFS}/create_rtc0 ] || \
  sudo mknod -m 0666 ${PREFIXMIPSELROOTFS}/dev/rtc0 c 254 0 || \
    die "***Create rtc0 error" && \
      touch ${METADATAMIPSELROOTFS}/create_rtc0

[ -f ${METADATAMIPSELROOTFS}/link_rtc ] || \
  sudo ln -sv ${PREFIXMIPSELROOTFS}/dev/rtc0 ${PREFIXMIPSELROOTFS}/dev/rtc || \
    die "***Link rtc error" && \
      touch ${METADATAMIPSELROOTFS}/link_rtc

pushd ${PREFIXMIPSELROOTFS}
[ -f ${METADATAMIPSELROOTFS}/cross_tools_rm ] || \
  sudo rm -rf ${PREFIXMIPSELROOTFS}/cross-tools || \
    die "***remove cross tools error" && \
      touch ${METADATAMIPSELROOTFS}/cross_tools_rm
popd

pushd ${PREFIXGNULINUX}
[ -f ${METADATAMIPSELROOTFS}/mipsel_sysroot_ddimg ] || \
 dd if=/dev/zero of=mipsel-rootfs.img bs=1M count=10000 || \
    die "***dd mipsel sysroot.img error" && \
      touch ${METADATAMIPSELROOTFS}/mipsel_sysroot_ddimg

[ -f ${METADATAMIPSELROOTFS}/mipsel_sysroot_mkfsimg ] || \
  echo y | mkfs.ext3 mipsel-rootfs.img || \
    die "***mkfs mipsel sysroot.img error" && \
      touch ${METADATAMIPSELROOTFS}/mipsel_sysroot_mkfsimg

[ -f ${METADATAMIPSELROOTFS}/mipsel_sysroot_dirmnt ] || \
  mkdir mnt_tmp || \
    die "***mkdir mnt error" && \
      touch ${METADATAMIPSELROOTFS}/mipsel_sysroot_dirmnt

[ -f ${METADATAMIPSELROOTFS}/mipsel_sysroot_mnt ] || \
  sudo mount -o loop mipsel-rootfs.img ./mnt_tmp || \
    die "***mount mipsel sysroot.img error" && \
      touch ${METADATAMIPSELROOTFS}/mipsel_sysroot_mnt

[ -f ${METADATAMIPSELROOTFS}/mipsel_sysroot_copy ] || \
  sudo cp -ar ${PREFIXMIPSELROOTFS}/* ./mnt_tmp/ || \
    die "***copy to mipsel sysroot.img error" && \
      touch ${METADATAMIPSELROOTFS}/mipsel_sysroot_copy

[ -f ${METADATAMIPSELROOTFS}/mipsel_sysroot_umnt ] || \
  sudo umount ./mnt_tmp/ || \
    die "***copy to mipsel sysroot.img error" && \
      touch ${METADATAMIPSELROOTFS}/mipsel_sysroot_umnt

[ -f ${METADATAMIPSELROOTFS}/mipsel_sysroot_rmmnt ] || \
  rm -rf  mnt_tmp || \
    die "***remove mnt error" && \
      touch ${METADATAMIPSELROOTFS}/mipsel_sysroot_rmmnt

popd
