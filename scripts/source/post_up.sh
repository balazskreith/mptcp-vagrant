#!/bin/bash
# Setting up NAT

for f in user_scripts/source/up/* ; do 
	if [[ -x $f ]] ; then
		$f
	else
		echo "Skipping $f"
	fi
done
