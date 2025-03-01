#!/bin/bash -e

# TODO: Review and if possible fix shellcheck errors.
# shellcheck disable=SC1003,SC1035,SC1083,SC1090
# shellcheck disable=SC2001,SC2002,SC2005,SC2016,SC2091,SC2034,SC2046,SC2086,SC2089,SC2090
# shellcheck disable=SC2124,SC2129,SC2144,SC2153,SC2154,SC2155,SC2163,SC2164,SC2166
# shellcheck disable=SC2235,SC2237

[ "${BASH_SOURCE[0]}" ] && SCRIPT_NAME="${BASH_SOURCE[0]}" || SCRIPT_NAME=${0}
SCRIPT_DIR="$(cd "$(dirname "${SCRIPT_NAME}")/.." && pwd -P)"

source "${SCRIPT_DIR}"/common_vars.sh
source "${SCRIPT_DIR}"/tool_kit.sh
source "${SCRIPT_DIR}"/signal_trap.sh
source "${INSTALLDIR}"/toolchain.conf
source "${INSTALLDIR}"/toolchain.env

[ -f "${BUILDDIR}/setup_intel" ] && rm "${BUILDDIR}/setup_intel"

INTEL_CFLAGS=""
INTEL_LDFLAGS=""
INTEL_LIBS=""
mkdir -p "${BUILDDIR}"
cd "${BUILDDIR}"

case "${with_intel}" in
  __INSTALL__)
    echo "==================== Installing the Intel compiler ===================="
    echo "__INSTALL__ is not supported; please install the Intel compiler manually"
    exit 1
    ;;
  __SYSTEM__)
    echo "==================== Finding Intel compiler from system paths ===================="
    check_command icc "intel" && CC="$(command -v icc)" || exit 1
    check_command icpc "intel" && CXX="$(command -v icpc)" || exit 1
    check_command ifort "intel" && FC="$(command -v ifort)" || exit 1
    F90="${FC}"
    F77="${FC}"
    ;;
  __DONTUSE__)
    # Nothing to do
    ;;
  *)
    echo "==================== Linking Intel compiler to user paths ===================="
    pkg_install_dir="${with_intel}"
    check_dir "${pkg_install_dir}/bin"
    check_dir "${pkg_install_dir}/lib"
    check_dir "${pkg_install_dir}/include"
    check_command ${pkg_install_dir}/bin/icc "intel" && CC="${pkg_install_dir}/bin/icc" || exit 1
    check_command ${pkg_install_dir}/bin/icpc "intel" && CXX="${pkg_install_dir}/bin/icpc" || exit 1
    check_command ${pkg_install_dir}/bin/ifort "intel" && FC="${pkg_install_dir}/bin/ifort" || exit 1
    F90="${FC}"
    F77="${FC}"
    INTEL_CFLAGS="-I'${pkg_install_dir}/include'"
    INTEL_LDFLAGS="-L'${pkg_install_dir}/lib' -Wl,-rpath='${pkg_install_dir}/lib'"
    ;;
esac
if [ "${with_intel}" != "__DONTUSE__" ]; then
  cat << EOF > "${BUILDDIR}/setup_intel"
export CC="${CC}"
export CXX="${CXX}"
export FC="${FC}"
export F90="${F90}"
export F77="${F77}"
EOF
  if [ "${with_intel}" != "__SYSTEM__" ]; then
    cat << EOF >> "${BUILDDIR}/setup_intel"
prepend_path PATH "${pkg_install_dir}/bin"
prepend_path LD_LIBRARY_PATH "${pkg_install_dir}/lib"
prepend_path LD_RUN_PATH "${pkg_install_dir}/lib"
prepend_path LIBRARY_PATH "${pkg_install_dir}/lib"
prepend_path CPATH "${pkg_install_dir}/include"
EOF
  fi
  cat << EOF >> "${BUILDDIR}/setup_intel"
export INTEL_CFLAGS="${INTEL_CFLAGS}"
export INTEL_LDFLAGS="${INTEL_LDFLAGS}"
export INTEL_LIBS="${INTEL_LIBS}"
EOF
  cat "${BUILDDIR}/setup_intel" >> ${SETUPFILE}
fi

load "${BUILDDIR}/setup_intel"
write_toolchain_env "${INSTALLDIR}"

cd "${ROOTDIR}"
report_timing "intel"
