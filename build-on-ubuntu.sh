#!/usr/bin/env bash



#
#   XXX: This script is doining the automation of build and install setup on
#   ubuntu. Setup details:
#
#   ss@ss2:~/rsyslog$  lsb_release -a
#   No LSB modules are available.
#   Distributor ID:	Ubuntu
#   Description:	Ubuntu 25.04
#   Release:	25.04
#   Codename:	plucky
#
#   NOTE: we should have installed the rsyslog on the system before, so that all
#   the conf files for rsyslogs are present; one more thig to notic here is that
#   we can configuring the build before so that installation process install the
#   binary, library, conf files on the respective directories.
#
#   As ob build we dont have some of the conf files and they are not even inited
#   appropreatly, so already installed rsyslog will have all tjhose missing
#   things.
#
#   When we are installing the rsyslog, we are not uninstalling the installed
#   one, so that we get the conf files etc, just over-writing the binaries etc.
#
#   We have to install all the build dependencies mannually tho, I havent
#   automated that part yet.
#
#   Never sattle, work hard, do something productive, think, make plan and work.
#   Fortune favours the brave!
#
set -euo pipefail

# ===============================
# Build + Install Rsyslog (debug)
# ===============================

# 1. Remove any distro-installed rsyslog to avoid conflicts
#echo "[*] Removing system rsyslog packages..."
#if command -v apt >/dev/null 2>&1; then
#    sudo systemctl stop rsyslog || true
#    sudo apt remove -y rsyslog rsyslog-gnutls rsyslog-doc || true
#elif command -v yum >/dev/null 2>&1; then
#    sudo systemctl stop rsyslog || true
#    sudo yum remove -y rsyslog || true
#fi

# 2. Clean old build artifacts
#echo "[*] Cleaning old build..."
#make distclean >/dev/null 2>&1 || true
#git clean -fdx

# 3. Regenerate build system
echo "[*] Running autogen.sh..."
./autogen.sh

# 4. Configure with full debug enabled
echo "[*] Configuring..."
./configure \
  --prefix=/usr \
  --sbindir=/usr/sbin \
  --libdir=/usr/lib/ \
  --sysconfdir=/etc \
  --localstatedir=/var \
  --runstatedir=/run/ \
  --enable-valgrind \
  --enable-debug \
   --disable-debug-symbols \
   --enable-imfile \
   -enable-omfile-hardened \
  --enable-imptcp \
  --enable-omfwd \
	--enable-omfile \
	--enable-gnutls \
  --enable-impstats \
  --enable-inet \
  --enable-mmjsonparse

# 5. Compile
echo "[*] Building..."
make -j4

# 6. Install
echo "[*] Installing..."
sudo make install

# 7. Verify
echo "[*] Installed rsyslogd version:"
/usr/sbin/rsyslogd -v || rsyslogd -v

sudo systemctl stop rsyslog.service
sudo systemctl disable rsyslog.service
sudo systemctl daemon-reload
sudo systemctl enable rsyslog.service
sudo systemctl restart rsyslog.service
sudo systemctl status rsyslog.service
