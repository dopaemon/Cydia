#!/bin/bash
dpkg-scanpackages -m . /dev/null >Packages
rm -rf Packages.bz2
bzip2 -fks Packages

rm -rf Packages

git add -vAf
git commit -sm "repo: update Packages"
