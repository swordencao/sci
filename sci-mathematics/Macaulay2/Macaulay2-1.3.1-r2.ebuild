# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit autotools elisp-common eutils flag-o-matic

IUSE="emacs"

DESCRIPTION="research tool for commutative algebra and algebraic geometry"
SRC_URI="http://www.math.uiuc.edu/Macaulay2/Downloads/SourceCode/Macaulay2-1.3.1-r9872-src.tar.bz2"

#	mirror://gentoo/${P}-src.tar.bz2

HOMEPAGE="http://www.math.uiuc.edu/Macaulay2/"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~x86 ~amd64"

# mpir 1.3.0_rc3 does not work!
DEPEND="sys-libs/gdbm
	>=dev-libs/ntl-5.5.2
	>=dev-libs/boehm-gc-7.1
	>=sci-mathematics/pari-2.3.4[gmp]
	>=sys-libs/readline-6.0
	dev-libs/libxml2
	>=sci-libs/factory-3.1.0[-singular]
	>=sci-libs/libfac-3.1.0[-singular]
	sci-mathematics/frobby
	sci-mathematics/4ti2
	sci-mathematics/normaliz
	sci-mathematics/gfan
	>=dev-libs/mpfr-2.4.1
	>=sci-libs/mpir-1.2.1[-nocxx]
	<sci-libs/mpir-1.3[-nocxx]
	sys-libs/gdbm
	virtual/blas
	virtual/lapack
	dev-util/ctags
	sys-libs/ncurses
	sys-process/time
	emacs? ( virtual/emacs )"
RDEPEND="${DEPEND}"

SITEFILE=70Macaulay2-gentoo.el

S="${WORKDIR}/Macaulay2-1.3.1-r9872"

src_prepare() {
	# Patching .m2 files to look for external programs in
	# /usr/bin
	cd "${S}"
	epatch "${FILESDIR}/paths-of-dependencies.patch"

	eautoreconf
}

src_configure (){

	# Recommended in bug #268064 Possibly unecessary
	# but should not hurt anybody.
	if ! use emacs; then
		tags="ctags"
	fi

	CPPFLAGS="-I/usr/include/frobby" \
		./configure --prefix="${D}/usr" --disable-encap \
		--with-unbuilt-programs="4ti2 gfan normaliz" \
		|| die "failed to configure Macaulay"
}

src_compile() {
	# Parallel build not yet supported
	emake -j1 || die "failed to build Macaulay"
}

src_test() {
	make check || die "tests failed"
}

src_install () {

	make install || die "install failed"

	use emacs && elisp-site-file-install "${FILESDIR}/${SITEFILE}"
}

pkg_postinst() {
	if use emacs; then
		elisp-site-regen
		elog "If you want to set a hot key for Macaulay2 in Emacs add a line similar to"
		elog "(global-set-key [ f12 ] 'M2)"
		elog "in order to set it to F12 (or choose a different one)."
	fi
}
pkg_postrm() {
	use emacs && elisp-site-regen
}
