# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake linux-info toolchain-funcs

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/IntelRealSense/${PN}.git"
else
	SRC_URI="https://github.com/IntelRealSense/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

DESCRIPTION="Intel's RealSense 3D Camera API"
HOMEPAGE="https://github.com/IntelRealSense/librealsense"

LICENSE="Apache-2.0"
SLOT="0"
IUSE="+examples"

RDEPEND="
	virtual/libusb:1
	examples? ( media-libs/glfw )
"
DEPEND="${RDEPEND}
	sys-kernel/linux-headers
	virtual/pkgconfig
	dev-util/cmake
"

CONFIG_CHECK="USB_VIDEO_CLASS"
ERROR_USB_VIDEO_CLASS="librealsense requires CONFIG_USB_VIDEO_CLASS enabled."

#~ DOCS=( AUTHORS CLA.md CONTRIBUTING.md readme.md )
BUILD_DIR="${WORKDIR}/${P}_build"

pkg_pretend() {
	kernel_is ge 4 4 || die "Upstream has deprecated support for kernels < 4.4."

	if tc-is-gcc && [[ gcc-version < 5.0 ]]; then
		die "Upstream requires at least GCC-5.0"
	fi
}

src_configure() {
	local mycmakeargs=()

	use examples && mycmakeargs+=(
		-DBUILD_EXAMPLES=true
	)

	cmake_src_configure
}

src_compile() {
	cmake_src_compile
}

src_install() {
	#~ einstalldocs

	local majmin="$(ver_cut 1-2)"

	newlib.so "${BUILD_DIR}"/librealsense2.so.${PV} librealsense2.so.${majmin}
	newlib.so "${BUILD_DIR}"/src/gl/librealsense2-gl.so.${PV} librealsense2-gl.so.${majmin}
	dolib.a "${BUILD_DIR}"/third-party/realsense-file/librealsense-file.a

	insinto /usr/include/
	doins -r include/librealsense2
	doins -r include/librealsense2-gl
	doins -r include/librealsense2-net

	insinto /lib/udev/rules.d/
	doins config/99-realsense-libusb.rules

	insinto /usr/share/${PF}/
	doins scripts/realsense-camera-formats-bionic-hwe-5.4.patch
	doins scripts/realsense-hid-bionic-hwe-5.4.patch
	doins scripts/realsense-metadata-bionic-hwe-5.4.patch
	doins scripts/realsense-powerlinefrequency-control-fix.patch
	#~ doins -r scripts/*.patch

	exeinto /usr/bin/
	doexe "${BUILD_DIR}"/tools/benchmark/rs-benchmark
	doexe "${BUILD_DIR}"/tools/convert/rs-convert
	doexe "${BUILD_DIR}"/tools/data-collect/rs-data-collect
	doexe "${BUILD_DIR}"/tools/depth-quality/rs-depth-quality
	doexe "${BUILD_DIR}"/tools/enumerate-devices/rs-enumerate-devices
	doexe "${BUILD_DIR}"/tools/fw-logger/rs-fw-logger
	doexe "${BUILD_DIR}"/tools/fw-update/rs-fw-update
	doexe "${BUILD_DIR}"/tools/realsense-viewer/realsense-viewer
	doexe "${BUILD_DIR}"/tools/recorder/rs-record
	doexe "${BUILD_DIR}"/tools/rosbag-inspector/rs-rosbag-inspector
	doexe "${BUILD_DIR}"/tools/terminal/rs-terminal

	if use examples; then
		insinto /usr/share/${PF}/examples/src
		doins examples/*
	fi
}

pkg_postinst() {
	#~ ewarn "${PN} requires a patched usbvideo.ko to work properly. The patch is"
	#~ ewarn "${EROOT%/}/usr/share/${PF}/realsense-camera-formats.patch"
	ewarn "Patches for kernel 5.4 are in ${EROOT%/}/usr/share/${PF}/"
	ewarn " - realsense-camera-formats-bionic-hwe-5.4.patch"
	ewarn " - realsense-hid-bionic-hwe-5.4.patch"
	ewarn " - realsense-metadata-bionic-hwe-5.4.patch"
	ewarn " - realsense-powerlinefrequency-control-fix.patch"
	ewarn "These patches may be applied manually or autoapplied by copying it to"
	ewarn "/etc/portage/patches/sys-kernel/gentoo-sources"
}
