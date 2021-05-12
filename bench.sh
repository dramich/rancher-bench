#!/usr/bin/env bash
SKIP_DAPPER_BENCHMARKS=false
if [ $1 ]; then
    case $1 in
        "-h" | "--help" | "help")
            printf "Source: https://github.com/nickgerace/rancher-bench\n\n"
            echo "Flags:"
            echo "  -h/--help                   Displays this message and exits"
            echo "  --skip-dapper-benchmarks    Skips dapper-related tests for rancher/rancher"
            exit 0
            ;;
        "--skip-dapper-benchmarks")
            SKIP_DAPPER_BENCHMARKS=true
            ;;
    esac
fi

ROOT_DIR=/tmp/rancher-bench
if [ ! -d $ROOT_DIR ]; then
    mkdir -p $ROOT_DIR;
fi
DIR=$(mktemp -d $ROOT_DIR/$USER-XXXXXXX)
VERSIONS=$DIR/versions.txt
PATHS=$DIR/paths.txt
TIMES=$DIR/times.txt

function prepare-path {
    touch $1
    chmod 644 $1
}

function get-binary-info {
    local FULL=$1
    set -- $FULL
    local SHORT=$1
    if [ ! $(command -v ${SHORT}) ]; then
        echo "Required binary not installed or not in PATH: $SHORT"
        exit 1
    fi
    printf "$FULL\n$(${FULL})\n---\n" >> $VERSIONS
    echo "$(command -v ${SHORT})" >> $PATHS
}

function bench {
    echo "Starting bench: $1"
    local WORKING_DIR=$DIR
    if [ $2 ]; then
        WORKING_DIR=$2
    fi
    echo "$1" >> $TIMES
    START=$(date +%s)
    ( cd $WORKING_DIR; ${1} )
    printf "$(($(date +%s)-$START)) sec\n---\n" >> $TIMES
}

prepare-path $VERSIONS
prepare-path $PATHS
prepare-path $TIMES

if [ "$(uname -s)" = "Darwin" ]; then
    printf "$(sw_vers)\n---\n" >> $VERSIONS
fi

get-binary-info "go version"
get-binary-info "git --version"
get-binary-info "docker version"
get-binary-info "golangci-lint version"
get-binary-info "make --version"
get-binary-info "bash --version"

bench "git clone https://github.com/rancher/rancher.git"
bench "git checkout --track origin/release/v2.4" "$DIR/rancher"
bench "git checkout master" "$DIR/rancher"
bench "go build -a" "$DIR/rancher"
bench "golangci-lint cache clean" "$DIR/rancher"
bench "golangci-lint run" "$DIR/rancher"
bench "go generate" "$DIR/rancher"

if [ "$SKIP_DAPPER_BENCHMARKS" != true ]; then
    bench "make build" "$DIR/rancher"
fi

rm -rf $DIR/rancher
echo "You may want to cleanup tmp directories used for benchmarking"
du -h $ROOT_DIR
echo "Results stored in txt file(s): $DIR"
echo "Entire script duration: $SECONDS seconds"
