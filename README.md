# Configuration files for shells, editors and others

These files are text configuration file for various programs, that
usually exist in ${HOME} and mostly begin with a '.'.

# install.sh

A script to install only the dot files and desktop files

# bin

A collection of the utilities to install on a fresh system
pick and choose as required

# License

These are in the public domain, but if any copyright system lacks such
a feature the consider them under a two clause BSD license

# FreeBSD Audio

The pcmX devices often are setup wrongly on FreeBSD with two separate devices created
often with swapped I/O i.e., headphones + interal mic, and speaker + headset mic
so nothing is usable at leats on: T420s, T580, E495.

The configuration is to set: (separate associations for in and out, seq=15 for 1/8" jack items)
~~~
speaker      as=1 seq=0
headphones   as=1 seq=15
internal mic as=2 seq=0
headset mic  as=2 seq=15
~~~

## T580

The /boot/device.hints additions to turn pcm0/pcm1 into a single pcm0
that auto switches on plugging a headset.

~~~
# local configuration
# ===================

# default mic (separate devices)
#dev.hdaa.0.nid18_original: 0x90a60120 as=2 seq=0 device=Mic conn=Fixed ctype=Digital loc=Internal color=Unknown misc=1
#dev.hdaa.0.nid25_original: 0x04a11030 as=3 seq=0 device=Mic conn=Jack ctype=1/8 loc=Right color=Black misc=0

# default speaker (seems OK)
#dev.hdaa.0.nid20_original: 0x90170110 as=1 seq=0 device=Speaker conn=Fixed ctype=Analog loc=Internal color=Unknown misc=1
#dev.hdaa.0.nid33_original: 0x0421101f as=1 seq=15 device=Headphones conn=Jack ctype=1/8 loc=Right color=Black misc=0

# allow internal/external mic switching on one device
hint.hdac.0.cad0.nid18.config="as=2 seq=0"
hint.hdac.0.cad0.nid25.config="as=2 seq=15"
~~~

