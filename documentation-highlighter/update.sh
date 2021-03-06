#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl -p unzip

set -eu
set -o pipefail

root=$(pwd)

if [ ! -f "./update.sh" ]; then
    echo "Please run this script from within ./documentation-highlighter/!"
    exit 1
fi

scratch=$(mktemp -d -t tmp.XXXXXXXXXX)
function finish {
  rm -rf "$scratch"
}
trap finish EXIT


mkdir $scratch/src
cd $scratch/src

token=$(curl https://highlightjs.org/download/ -c "$scratch/jar" \
    | grep csrf \
    | cut -d"'" -f6)

curl --header "Referer: https://highlightjs.org/download/"\
    -b "$scratch/jar" \
    --data "csrfmiddlewaretoken=$token&bash.js=on&xml.js=on&" \
    https://highlightjs.org/download/ > $scratch/out.zip

unzip "$scratch/out.zip"
out="$root/"
mkdir -p "$out"
cp ./{highlight.pack.js,LICENSE} "$out"

(
    echo "This file was generated with ./documentation-highlighter/update.sh"
    echo ""
    cat README.md
) > "$out/README.md"
