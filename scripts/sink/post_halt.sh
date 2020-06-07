#!/usr/bin/env bash
# Removing NAT

for f in user_scripts/source/halt/* ; do 
	if [[ -x $f ]] ; then
		$f
	else
		echo "Not executable! Skipping $f"
	fi
done
