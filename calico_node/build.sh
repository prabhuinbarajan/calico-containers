#!/bin/sh
set -e
set -x

# Ensure the main and testing repros are present. Needed for runit
echo "http://alpine.gliderlabs.com/alpine/edge/testing" >> /etc/apk/repositories

# These packages make it into the final image.
apk -U add runit python py-setuptools libffi ip6tables ipset iputils iproute2 yajl

# These packages are only used for building and get removed.
apk add --virtual temp python-dev libffi-dev py-pip alpine-sdk curl

# Install Confd
curl -L https://github.com/projectcalico/confd/releases/download/v0.10.0-scale/confd.static -o /sbin/confd

# Copy patched BIRD daemon with tunnel support.
curl -L https://github.com/projectcalico/calico-bird/releases/download/v0.1.0/bird -o /sbin/bird
curl -L https://github.com/projectcalico/calico-bird/releases/download/v0.1.0/bird6 -o /sbin/bird6
curl -L https://github.com/projectcalico/calico-bird/releases/download/v0.1.0/birdcl -o /sbin/birdcl
chmod +x /sbin/*

# Install Felix and libcalico
pip install git+https://github.com/projectcalico/calico.git@e4ed181f61b55fceb22bc277f1634873b4d51483
pip install git+https://github.com/projectcalico/libcalico.git

# Output the python library list
pip list > libraries.txt

# Cleanup
apk del temp && rm -rf /var/cache/apk/*
