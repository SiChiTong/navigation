#!/bin/bash

if [ $# -eq 0 ]
 then
  echo "Need navit commit version"
  exit
fi

navit_version=$1


rm -rf build/navit
rm -rf navit

git clone https://github.com/navit-gps/navit.git
cd navit
git checkout $navit_version
patch -p0 -i ../patches/search_list_get_unique.diff
patch -p0 -i ../patches/fsa_issue_padding.diff
cd ../

