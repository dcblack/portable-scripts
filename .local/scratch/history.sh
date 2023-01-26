#!/usr/bin/bash

sudo yum install -y dh-autoreconf curl-devel expat-devel gettext-devel   openssl-devel perl-devel zlib-devel
sudo yum install -y asciidoc
sudo yum install -y xmlto
sudo yum install -y docbook2X
sudo yum install -y gtk3-devel
sudo yum install -y libX11-devel
./configure --prefix "{$HOME}/.local" --enable-gui=auto --with-x
