#!/bin/bash

printf "
🔧 ${LCY}Make${END}, 🔨 ${LBL}Build${END}, 🧪 ${LGR}Test${END}, 🚀 ${LYE}Push${END}

USAGE:
    buildx [OPTIONS]

OPTIONS:
    -m, make            Make builds artifacts
    -b, build           Build docker images
    -t, test <ARCH>     Test on <ARCH>/all architectures
    -p, push            Build (if not cached) for all architectures, and Push
    -h, help            Prints help information
"
