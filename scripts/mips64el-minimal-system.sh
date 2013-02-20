#! /bin/bash

source common/source.env

export MOD="busybox"

[ -f "${METADATAHOSTTOOLS}/host_tools_finished" ] || \
  source common/host-tools.step || \
    die "build host-tools error" && \
      touch ${METADATAHOSTTOOLS}/host_tools_finished

[ -f "${METADATAMIPS64ELTOOLCHAIN}/mips64el_tools_finished" ] || \
  source mips64el/mips64el-linux-gnu.step || \
    die "build mips64el tools error" && \
      touch ${METADATAMIPS64ELTOOLCHAIN}/mips64el_tools_finished

[ -f "${METADATAMIPS64ELKERNEL}/linux_n32_64_kernel_finished" ] || \
  source mips64el/mips64el-linux.step || \
    die "build mipsel linux n32/64 kernel and modules error" && \
      touch ${METADATAMIPS64ELKERNEL}/linux_n32_64_kernel_finished

[ -f "${METADATABUSYBOX_64}/mips64el_busybox_finished" ] || \
  source mips64el/mips64el-busybox.step || \
    die "build mipsel busybox error" && \
      touch ${METADATABUSYBOX_64}/mips64el_busybox_finished

[ -f "${METADATAMIPS64ELBUSYBOXCREATEIMG}/mips64el_busybox_create_img_finished" ] || \
  source mips64el/mips64el-busybox-img.step || \
    die "create mipsel busybox img error" && \
      touch ${METADATAMIPS64ELBUSYBOXCREATEIMG}/mips64el_busybox_create_img_finished
