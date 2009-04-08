# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="1"

ESVN_REPO_URI="http://svn.gnome.org/svn/murrine/trunk/"
ESVN_BOOTSTRAP="NOCONFIGURE=1 ./autogen.sh"

inherit eutils subversion

DESCRIPTION="Murrine GTK+2 Cairo Engine"
HOMEPAGE="http://www.cimitan.com/murrine/"

RDEPEND=">=x11-libs/gtk+-2.8"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

S="${WORKDIR}"

pkg_setup() {
	elog ""
	elog "This is a live ebuild with installs the latest Murrine's"
	elog "gtk engine from subversion"
	elog ""
}

src_unpack() {
	subversion_src_unpack

	cd "$S"
}

src_compile() {
	econf --enable-animation || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dodir /usr/share/themes
	insinto /usr/share/themes

	dodoc AUTHORS ChangeLog CREDITS
}
