#!/bin/bash

# update iperf_test_scripts from bitbucket
# this is similar to "git pull"
# but can avoid merge conflict if we change git history
cd /home/vagrant/
git fetch origin-ssh
git reset --hard origin-ssh/master
