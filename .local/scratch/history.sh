sudo yum install dh-autoreconf curl-devel expat-devel gettext-devel   openssl-devel perl-devel zlib-devel
sudo yum install asciidoc
sudo yum install xmlto
sudo yum install docbook2X
sudo yum install gtk3-devel
sudo yum search X11-devel
sudo yum install libX11-devel
./configure --prefix $HOME/.local --enable-gui=auto --with-x
