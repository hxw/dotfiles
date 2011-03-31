#!/bin/sh

kwriteconfig --file kres-migratorrc --group Migration --key Enabled --type bool false


# some things to try to reduce kde footprint from:
# http://lwn.net/Articles/435597/

# Configure what services run in my default runlevel with 'rcconf'

# Ran 'kwriteconfig –file kres-migratorrc –group Migration –key
# Enabled –type bool false' (once) to stop Nepomuk's migration
# business on every login. (I believe).

# Turn off un-needed taskbar applets in KDE.

# Run the 'System Settings' applet/program in KDE and performed the
# following:

# In network settings -> network monitor unchecked "Start Knemo...."

# In autostart uncheck the services not needed to autostart.

# In desktop search uncheck nepomuk and strigi.

# In service manager uncheck all the startup services not needed. The
# ones I have unchecked in my system are: KDE write daemon and
# PowerDevil.
