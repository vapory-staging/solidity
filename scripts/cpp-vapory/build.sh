#!/usr/bin/env sh

# Script to build the vap binary from latest develop
# for ubuntu trusty and ubuntu artful.
# Requires docker.

set -e

REPO_ROOT="$(dirname "$0")"/../..

for rel in artful trusty
do
    docker build -t vap_$rel -f "$REPO_ROOT"/scripts/cpp-vapory/vap_$rel.docker .
    tmp_container=$(docker create vap_$rel sh)
    echo "Built vap ($rel) at $REPO_ROOT/build/vap_$rel"
    docker cp ${tmp_container}:/build/eth/vap "$REPO_ROOT"/build/vap_$rel
done