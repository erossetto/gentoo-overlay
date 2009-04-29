# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit base python bash-completion

DESCRIPTION="Native makefiles generator"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"
HOMEPAGE="http://bakefile.sourceforge.net"

LICENSE="MIT"

RDEPEND=">=dev-lang/python-2.3"
DEPEND=""
KEYWORDS="~x86 ~amd64"
SLOT="0"
IUSE="doc"

src_install () {
	base_src_install
	
	dodoc AUTHORS COPYING NEWS README THANKS
	if use doc ; then
		dohtml -r doc/html/* || die "dodoc failed"
	fi

	dobashcompletion bash_completion bakefile
}

