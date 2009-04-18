# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: 

EAPI="2"

ESVN_REPO_URI="svn://svn.gnome.org/svn/network-manager-applet/trunk"

inherit autotools gnome2 eutils subversion

MY_P="${P/nm-applet/network-manager-applet}"

DESCRIPTION="Gnome applet for NetworkManager."
HOMEPAGE="http://projects.gnome.org/NetworkManager/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND=">=sys-apps/dbus-1.2
	>=sys-apps/hal-0.5.10
	>=dev-libs/libnl-1.1
	>=net-misc/networkmanager-0.7.0
	>=net-wireless/wireless-tools-28_pre9
	>=net-wireless/wpa_supplicant-0.5.7
	>=dev-libs/glib-2.16
	>=x11-libs/libnotify-0.4.3
	>=x11-libs/gtk+-2.10
	>=gnome-base/libglade-2
	>=gnome-base/gnome-keyring-2.20
	|| ( >=gnome-base/gnome-panel-2 xfce-base/xfce4-panel )
	>=gnome-base/gconf-2.20
	>=gnome-base/libgnomeui-2.20
	>=gnome-extra/policykit-gnome-0.8"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	>=dev-util/intltool-0.35"

DOCS="AUTHORS COPYING ChangeLog INSTALL NEWS README"

S=${WORKDIR}/${MY_P}

G2CONF="${G2CONF} \
		--disable-more-warnings \
		--localstatedir=/var \
		--with-dbus-sys=/etc/dbus-1/system.d"

pkg_setup () {
	elog ""
	elog "This is a live ebuild with installs the latest NetworkManager"
	elog "applet from subversion"
	elog ""
}

src_unpack() {
	subversion_src_unpack ${A}
	cd "${S}"
}

src_prepare() {
	intltoolize
	eautoreconf
}

pkg_postinst() {
	gnome2_pkg_postinst
	elog "Your user needs to be in the plugdev group in order to use this"
	elog "package.  If it doesn't start in Gnome for you automatically after"
	elog 'you log back in, simply run "nm-applet --sm-disable"'
	elog "You also need the notification area applet on your panel for"
	elog "this to show up."
}
