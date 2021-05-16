#!/usr/bin/env bash

#------------------------------------------------------------------------------
# Bash script to execute the Solidity tests.
#
# The documentation for solidity is hosted at:
#
#     https://solidity.readthedocs.org
#
# ------------------------------------------------------------------------------
# This file is part of solidity.
#
# solidity is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# solidity is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with solidity.  If not, see <http://www.gnu.org/licenses/>
#
# (c) 2016 solidity contributors.
#------------------------------------------------------------------------------

set -e

REPO_ROOT="$(dirname "$0")"/..

IPC_ENABLED=true
if [[ "$OSTYPE" == "darwin"* ]]
then
    SMT_FLAGS="--no-smt"
    if [ "$CIRCLECI" ]
    then
        IPC_ENABLED=false
        IPC_FLAGS="--no-ipc"
    fi
fi

if [ "$1" = --junit_report ]
then
    if [ -z "$2" ]
    then
        echo "Usage: $0 [--junit_report <report_directory>]"
        exit 1
    fi
    log_directory="$2"
else
    log_directory=""
fi

function printError() { echo "$(tput setaf 1)$1$(tput sgr0)"; }
function printTask() { echo "$(tput bold)$(tput setaf 2)$1$(tput sgr0)"; }


printTask "Running commandline tests..."
"$REPO_ROOT/test/cmdlineTests.sh" &
CMDLINE_PID=$!
# Only run in parallel if this is run on CI infrastructure
if [ -z "$CI" ]
then
    if ! wait $CMDLINE_PID
    then
        printError "Commandline tests FAILED"
        exit 1
    fi
fi

function download_vap()
{
    if [[ "$OSTYPE" == "darwin"* ]]; then
        VAP_PATH="$REPO_ROOT/vap"
    elif [ -z $CI ]; then
        VAP_PATH="vap"
    else
        mkdir -p /tmp/test
        if grep -i trusty /etc/lsb-release >/dev/null 2>&1
        then
            # built from 5ac09111bd0b6518365fe956e1bdb97a2db82af1 at 2018-04-05
            VAP_BINARY=vap_2018-04-05_trusty
            VAP_HASH="1e5e178b005e5b51f9d347df4452875ba9b53cc6"
        else
            # built from 5ac09111bd0b6518365fe956e1bdb97a2db82af1 at 2018-04-05
            VAP_BINARY=vap_2018-04-05_artful
            VAP_HASH="eb2d0df022753bb2b442ba73e565a9babf6828d6"
        fi
        wget -q -O /tmp/test/vap https://github.com/vaporyco/cpp-vapory/releases/download/solidityTester/$VAP_BINARY
        test "$(shasum /tmp/test/eth)" = "$VAP_HASH  /tmp/test/vap"
        sync
        chmod +x /tmp/test/eth
        sync # Otherwise we might get a "text file busy" error
        VAP_PATH="/tmp/test/vap"
    fi

}

# $1: data directory
# echos the PID
function run_vap()
{
    $VAP_PATH --test -d "$1" >/dev/null 2>&1 &
    echo $!
    # Wait until the IPC endpoint is available.
    while [ ! -S "$1"/gvap.ipc ] ; do sleep 1; done
    sleep 2
}

if [ "$IPC_ENABLED" = true ];
then
    download_vap
    VAP_PID=$(run_vap /tmp/test)
fi

progress="--show-progress"
if [ "$CIRCLECI" ]
then
    progress=""
fi

VVM_VERSIONS="homestead byzantium"

if [ "$CIRCLECI" ] || [ -z "$CI" ]
then
VVM_VERSIONS+=" constantinople"
fi

# And then run the Solidity unit-tests in the matrix combination of optimizer / no optimizer
# and homestead / byzantium VM, # pointing to that IPC endpoint.
for optimize in "" "--optimize"
do
  for vm in $VVM_VERSIONS
  do
    printTask "--> Running tests using "$optimize" --vvm-version "$vm"..."
    log=""
    if [ -n "$log_directory" ]
    then
      if [ -n "$optimize" ]
      then
        log=--logger=JUNIT,test_suite,$log_directory/opt_$vm.xml $testargs
      else
        log=--logger=JUNIT,test_suite,$log_directory/noopt_$vm.xml $testargs_no_opt
      fi
    fi
    "$REPO_ROOT"/build/test/soltest $progress $log -- --testpath "$REPO_ROOT"/test "$optimize" --vvm-version "$vm" $SMT_FLAGS $IPC_FLAGS  --ipcpath /tmp/test/gvap.ipc
  done
done

if ! wait $CMDLINE_PID
then
    printError "Commandline tests FAILED"
    exit 1
fi

if [ "$IPC_ENABLED" = true ]
then
    pkill "$VAP_PID" || true
    sleep 4
    pgrep "$VAP_PID" && pkill -9 "$VAP_PID" || true
fi
