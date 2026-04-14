#!/bin/sh

# Dump installed package info. Can be useful when recreating a machine setup.

set -e

dpkg -l >/var/log/dpkg-l
apt-mark showmanual >/var/log/apt-mark-showmanual
apt-mark showauto >/var/log/apt-mark-showauto
