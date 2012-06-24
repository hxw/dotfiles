# Ubuntu initial packages system setup
# run this on a fresh install to install some tools

apt-get install mg lynx-cur curl
apt-get install rxvt-unicode aptitude
apt-get install git gitk

apt-get install emacs emacs23-el emacs-goodies-el haskell-mode ocaml-mode tuareg-mode

# fonts so emacs hello (CTRL-H H) show no missing fonts
apt-get install emacs-intl-fonts  \
 xfonts-intl-arabic xfonts-intl-asian xfonts-intl-chinese xfonts-intl-chinese-big  \
 xfonts-intl-european xfonts-intl-japanese xfonts-intl-japanese-big xfonts-intl-phonetic  \
 fonts-tibetan-machine fonts-sil-padauk fonts-arphic-ukai fonts-arphic-uming

apt-get install build-essential g++-multilib gcc-multilib flex bison m4 gawk

apt-get install ghc libghc-missingh-dev libghc-x11-dev libx11-dev
apt-get install ocaml

apt-get install slime sbcl cl-asdf cl-swank

apt-get install imagemagick

# vim?
#  apt-get install vim-gtk
#  apt-get install w3m
