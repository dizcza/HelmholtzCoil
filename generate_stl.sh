#!/bin/bash
#
# Normal usage: ./generate_stl.sh
# Enable fast rendering: ./generate_stl.sh --fast


mkdir -p stl

partnames=("HelmholtzAssembled" "CoilHalf1" "CoilHalf2" "CoilFull" "HorizontalBarsSupport" "Retainers" "Pillars" "PlatformTable" "Platform" "TestParts")

openscad_bin="openscad"

if [ $# -eq 1 ] && [ $1 == "--fast" ]; then
    echo -e "\033[33mEnabled fast-cfg and fast-csg-trust-corefinement render options\033[0m"
    openscad_bin="$openscad_bin --enable fast-csg --enable fast-csg-trust-corefinement"
fi

for partnum in `seq 0 9`
do
    echo "generating part $partnum ..."
    $openscad_bin Helmholtz.scad -o "stl/part${partnum}_${partnames[$partnum]}.stl" -D partnum=$partnum
done
