#!/bin/bash -e

if [ -z "$1" ]; then 
    echo "Usage: $0 new-release-codename"
    echo "Example: $0 saucy"
    exit 1
fi

NEW_CODENAME="$1"

. /etc/lsb-release

test -e sources.list || cat /etc/apt/sources.list /etc/apt/sources.list.d/*.list \
    |grep -v "deb-src" |sed "s/$DISTRIB_CODENAME/$NEW_CODENAME/g" >sources.list 

test -d lists || mkdir lists
test -d debs || mkdir debs

cd debs

APT_ARGS="-o Dir::Etc::SourceList=../sources.list \
    -o Dir::Etc::SourceParts=/nonexistent \
    -o Dir::State::Lists=../lists \
    -o APT::Get::Simulate=true" 

apt-get $APT_ARGS update

echo "Calculating new packages, download will start soon"

apt-get $APT_ARGS download \
    `apt-get $APT_ARGS dist-upgrade |grep "^Inst " |cut -d ' ' -f2`
