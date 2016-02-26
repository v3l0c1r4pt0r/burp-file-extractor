#!/bin/sh
# extract files from burp item exporter
if [ $# -lt 1 ]; then
    echo "Error: Insufficient arguments!";
    echo "Usage $0 input [.extension]";
    exit;
fi;
INPUT=$1
PORT=31337
OUTSUFFIX=.html
if [ $# -ge 2 ]; then
    OUTSUFFIX=$2;
fi;
FAILCLR=
OKCLR=
ENDCLR=

if [ $(tput colors) -ge 8 ]; then
    FAILCLR="\e[38;5;1m"
    OKCLR="\e[38;5;2m"
    ENDCLR="\e[0m"
fi;

function step {
    if [ $# -lt 1 ]; then
        echo -ne "\t Unnamed operation\r"
    fi;
    echo -ne "\t $1\r"
}

function ok {
    echo -ne "[$OKCLR  OK  $ENDCLR]\n";
}

function fail {
    echo -ne "[$FAILCLR FAIL $ENDCLR]\n";
}

step "Generating CSV file";
CSV=$(xsltproc xml2csv.xsl $INPUT 2>/dev/null);
if [ -z "$CSV" ]; then
    fail;
    exit 1;
fi;
ok;

step "Extracting responses from CSV file";
mkdir base64 2>/dev/null;
i=0;
for line in $CSV; do
    let i++;
    CONTENT=$(echo $line | cut -d',' -f2);
    echo $CONTENT > base64/$i.base64;
done;
ok;

step "Decoding base64 files";
mkdir http 2>/dev/null;
for file in $(ls -1 base64/*.base64); do
    fn=$(echo $file | sed 's/^.*\/\(.*\)\..*$/\1/g');
    cat $file | base64 -d > http/$fn.http;
done;
ok;

step "Downloading files";
mkdir output 2>/dev/null;
for file in $(ls -1 http/*.http); do
    fn=$(echo $file | sed 's/^.*\/\(.*\)\..*$/\1/g');
    nc -l $PORT < $file &>/dev/null &
    wget http://localhost:$PORT/ -Ooutput/$fn$OUTSUFFIX &>/dev/null;
done
ok;

step "Cleaning working directory";
rm -fr base64/;
rm -fr http/;
ok;
