#! /bin/bash

set -x

### Update sources

wget -qO /etc/apt/sources.list.d/nitrux-depot.list https://raw.githubusercontent.com/Nitrux/iso-tool/legacy/configs/files/sources/sources.list.nitrux
wget -qO /etc/apt/sources.list.d/nitrux-testing.list https://raw.githubusercontent.com/Nitrux/iso-tool/legacy/configs/files/sources/sources.list.nitrux.testing

curl -L https://packagecloud.io/nitrux/depot/gpgkey | apt-key add -;
curl -L https://packagecloud.io/nitrux/testing/gpgkey | apt-key add -;
curl -L https://packagecloud.io/nitrux/unison/gpgkey | apt-key add -;

apt update

### Install Package Build Dependencies #2

apt -qq -yy install --no-install-recommends \
	mauikit-git \
	mauikit-accounts-git \
	mauikit-filebrowsing-git \
	mauikit-texteditor-git

### Download Source

git clone --depth 1 --branch $BUHO_BRANCH https://invent.kde.org/maui/buho.git

### Compile Source

mkdir -p build && cd build

cmake \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DENABLE_BSYMBOLICFUNCTIONS=OFF \
	-DQUICK_COMPILER=ON \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_SYSCONFDIR=/etc \
	-DCMAKE_INSTALL_LOCALSTATEDIR=/var \
	-DCMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON \
	-DCMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY=ON \
	-DCMAKE_INSTALL_RUNSTATEDIR=/run "-GUnix Makefiles" \
	-DCMAKE_VERBOSE_MAKEFILE=ON \
	-DCMAKE_INSTALL_LIBDIR=/usr/lib/x86_64-linux-gnu ../buho/

make -j$(nproc)

make install

### Run checkinstall and Build Debian Package

>> description-pak printf "%s\n" \
	'MauiKit Note Taking App.' \
	'' \
	'Buho allows you to save links, write quick notes and organize pages as books.' \
	'' \
	'Buho works on desktops, Android and Plasma Mobile.' \
	'' \
	''

checkinstall -D -y \
	--install=no \
	--fstrans=yes \
	--pkgname=buho-git \
	--pkgversion=$PACKAGE_VERSION \
	--pkgarch=amd64 \
	--pkgrelease="1" \
	--pkglicense=LGPL-3 \
	--pkggroup=utils \
	--pkgsource=buho \
	--pakdir=. \
	--maintainer=uri_herrera@nxos.org \
	--provides=buho \
	--requires="libc6,libkf5coreaddons5,libkf5i18n5,libqt5core5a,libqt5gui5,libqt5network5,libqt5qml5,libqt5sql5,libqt5widgets5,libstdc++6,mauikit-git \(\>= 3.1.0+git\),mauikit-accounts-git \(\>= 3.1.0+git\),mauikit-filebrowsing-git \(\>= 3.1.0+git\),mauikit-texteditor-git \(\>= 3.1.0+git\),qml-module-qt-labs-platform,qml-module-qtwebview" \
	--nodoc \
	--strip=no \
	--stripso=yes \
	--reset-uids=yes \
	--deldesc=yes
