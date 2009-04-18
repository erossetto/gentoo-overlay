# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: 

EAPI="2"

inherit autotools eutils git

EGIT_REPO_URI="git://anongit.freedesktop.org/NetworkManager/NetworkManager.git"

# NetworkManager likes itself with capital letters
MY_P=${P/networkmanager/NetworkManager}

DESCRIPTION="Network configuration and management in an easy way. Desktop environment independent."
HOMEPAGE="http://www.gnome.org/projects/NetworkManager/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="doc nss gnutls dhclient dhcpcd resolvconf"

RDEPEND=">=sys-apps/dbus-1.2
	>=dev-libs/dbus-glib-0.75
	>=sys-apps/hal-0.5.10
	>=net-wireless/wireless-tools-28_pre9
	>=dev-libs/glib-2.16
	>=sys-auth/policykit-0.8
	>=dev-libs/libnl-1.1
	>=net-wireless/wpa_supplicant-0.5.10
	|| ( sys-libs/e2fsprogs-libs <sys-fs/e2fsprogs-1.41.0 )

	gnutls? (
		nss? ( >=dev-libs/nss-3.11 )
		!nss? ( dev-libs/libgcrypt
			net-libs/gnutls ) )
	!gnutls? ( >=dev-libs/nss-3.11 )

	dhclient? (
		dhcpcd? ( >=net-misc/dhcpcd-4.0.0_rc3 )
		!dhcpcd? ( >=net-misc/dhcp-3.0.0 ) )
	!dhclient? ( >=net-misc/dhcpcd-4.0.0_rc3 )

	resolvconf? ( net-dns/openresolv )"

DEPEND="${RDEPEND}
	dev-util/pkgconfig
	dev-util/intltool
	net-dialup/ppp
	>=dev-util/gtk-doc-1.8"

S=${WORKDIR}/${MY_P}

ECONF="--disable-more-warnings \
		--localstatedir=/var \
		--with-distro=gentoo \
		--with-dbus-sys-dir=/etc/dbus-1/system.d \
		--with-system-ca-path=/etc/ssl/certs
		$(use_enable doc gtk-doc)
		$(use_with doc docs)
		$(use_with resolvconf)"

pkg_setup() {
	elog ""
	elog "This is a live ebuild with installs the latest NetworkManager"
	elog "daemon from git"
	elog ""

	if ! built_with_use net-wireless/wpa_supplicant dbus ; then
		eerror "Please rebuild net-wireless/wpa_supplicant with the dbus useflag."
		die "Fix wpa_supplicant first."
	fi
}

src_unpack() {
	git_src_unpack ${A}
	cd "${S}"
}

src_prepare() {
	# Fix up the dbus conf file to use plugdev group
	epatch "${FILESDIR}/networkmanager-confchanges.patch"
	gtkdocize
	intltoolize
	eautoreconf
}

src_configure() {
	# default is dhcpcd (if none or both are specified), ISC dchclient otherwise
	if use dhclient ; then
		if use dhcpcd ; then
			ECONF="${ECONF} --with-dhcp-client=dhcpcd"
		else
			ECONF="${ECONF} --with-dhcp-client=dhclient"
		fi
	else
		ECONF="${ECONF} --with-dhcp-client=dhcpcd"
	fi

	# default is NSS (if none or both are specified), GnuTLS otherwise
	if use gnutls ; then
		if use nss ; then
			ECONF="${ECONF} --with-crypto=nss"
		else
			ECONF="${ECONF} --with-crypto=gnutls"
		fi
	else
		ECONF="${ECONF} --with-crypto=nss"
	fi

	econf ${ECONF}
}

src_compile() {
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	# Need to keep the /var/run/NetworkManager directory
	keepdir /var/run/NetworkManager

	# Need to keep the /etc/NetworkManager/dispatched.d for dispatcher scripts
	keepdir /etc/NetworkManager/dispatcher.d

	dodoc AUTHORS ChangeLog NEWS README TODO || die "dodoc failed"

	# Add keyfile plugin support
	keepdir /etc/NetworkManager/system-connections
	insinto /etc/NetworkManager
	newins "${FILESDIR}/nm-system-settings.conf" nm-system-settings.conf \
		|| die "newins failed"
}

pkg_postinst() {
	elog "You need to be in the plugdev group in order to use NetworkManager"
	elog "Problems with your hostname getting changed?"
	elog ""
	elog "Add the following to /etc/dhcp/dhclient.conf"
	elog 'send host-name "YOURHOSTNAME";'
	elog 'supersede host-name "YOURHOSTNAME";'
	elog ""
	elog "You will need to restart DBUS if this is your first time"
	elog "installing NetworkManager."
	elog ""
	elog "To save system-wide settings as a user, that user needs to have the"
	elog "right policykit privileges. You can add them by running:"
	elog 'polkit-auth --grant org.freedesktop.network-manager-settings.system.modify --user "USERNAME"'
}
