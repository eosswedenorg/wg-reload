#!/usr/bin/env bash

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

PACKAGE_DESCRIPTION="reload peering/private key configuration for WireGuard interfaces."
PACKAGE_TMPDIR="pack"

# Default to 1 if no release is set.
if [[ -z $RELEASE ]]; then
  RELEASE="1"
fi

PACKAGE_FULLNAME="${PACKAGE_NAME}_${PACKAGE_VERSION}-${RELEASE}_all"

rm -fr ${BASE_DIR}/${PACKAGE_TMPDIR}

# Create debian files.
mkdir -p ${BASE_DIR}/${PACKAGE_TMPDIR}/DEBIAN
echo "Package: ${PACKAGE_NAME}
Version: ${PACKAGE_VERSION}-${RELEASE}
Section: net
Priority: optional
Architecture: all
Homepage: https://github.com/eosswedenorg/wg-reload
Maintainer: Henrik Hautakoski <henrik@eossweden.org>
Description: ${PACKAGE_DESCRIPTION}
Depends: bash (>= 4.3-14ubuntu1), wireguard" &> ${BASE_DIR}/${PACKAGE_TMPDIR}/DEBIAN/control

cat ${BASE_DIR}/${PACKAGE_TMPDIR}/DEBIAN/control

mkdir -p ${BASE_DIR}/${PACKAGE_TMPDIR}/${PACKAGE_BINDIR}
mkdir -p ${BASE_DIR}/${PACKAGE_TMPDIR}/${PACKAGE_MANDIR}
mkdir -p ${BASE_DIR}/${PACKAGE_TMPDIR}/${PACKAGE_SHAREDIR}

cp ${BASE_DIR}/../wg-reload.sh ${BASE_DIR}/${PACKAGE_TMPDIR}/${PACKAGE_BINDIR}/${PACKAGE_NAME}
cp ${BASE_DIR}/../LICENSE  ${BASE_DIR}/${PACKAGE_TMPDIR}/${PACKAGE_SHAREDIR}
cp ${BASE_DIR}/../wg-reload.8  ${BASE_DIR}/${PACKAGE_TMPDIR}/${PACKAGE_MANDIR}

dpkg-deb --root-owner-group --build ${BASE_DIR}/${PACKAGE_TMPDIR} ${BASE_DIR}/${PACKAGE_FULLNAME}.deb
