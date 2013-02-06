#! /bin/bash

source source.env

[ -d "${SRCUNIVERSAL}" ] ||  mkdir -p "${SRCUNIVERSAL}"
[ -d "${BUILDUNIVERSAL}" ] ||  mkdir -p "${BUILDUNIVERSAL}"
[ -d "${METADATAUNIVERSAL}" ] || mkdir -p "${METADATAUNIVERSAL}"

#################################################################
### universal extract
#################################################################
pushd ${SRCUNIVERSAL}
[ -f ${METADATAUNIVERSAL}/qtc_extract ] || \
tar xf ${TARBALL}/qt-creator-${QTC_VERSION}.${QTC_SUFFIX} || \
  die "extract qtc error" && \
    touch ${METADATAUNIVERSAL}/qtc_extract
popd

#################################################################
### qt-creator build
#################################################################
pushd ${BUILDUNIVERSAL}
[ -d "qt-creator-build" ] || mkdir qt-creator-build
cd qt-creator-build
[ -f "${METADATAUNIVERSAL}/qt-creator_configure" ] || \
  qmake PREFIX=${PREFIXQTC} \
   ${SRCUNIVERSAL}/qt-creator-${QTC_VERSION} || \
    die "***config qt-creator error" &&
      touch ${METADATAUNIVERSAL}/qt-creator_configure
[ -f "${METADATAUNIVERSAL}/qt-creator_build" ] || \
  make -j${JOBS} || die "***build qt-creator error" && \
    touch ${METADATAUNIVERSAL}/qt-creator_build
[ -f "${METADATAUNIVERSAL}/qt-creator_install" ] || \
  INSTALL_ROOT=${PREFIX}/qt-creator make install || \
    die "***install qt-creator error" && \
      touch ${METADATAUNIVERSAL}/qt-creator_install
popd
