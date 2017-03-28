#!/bin/bash

# do not use this script in Vagrant anymore since it requires Internet ready
# put in guest's /etc/init.d directory instead

echo "update iperf_test_scripts"
# this is similar to "git pull",
# but can avoid merge conflict if we change git history.
# Note that "origin-ssh" is the same remote repo as "origin",
# but the url type is 'ssh' instead of 'https'

cd /home/vagrant/
git fetch origin-ssh
git reset --hard origin-ssh/master

echo "update latest iperf3"
cd iperf/
git fetch origin-ssh
git reset --hard origin-ssh/mptcp-test

echo "compile and install iperf3"
make -j4  		   >/dev/null 2>&1
sudo make install  >/dev/null 2>&1
