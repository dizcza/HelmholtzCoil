#!/bin/bash

mkdir -p stl

for partnum in `seq 0 9`
do
    echo "generating part $partnum ..."
    openscad --enable fast-csg --enable fast-csg-trust-corefinement Helmholtz.scad -o "stl/part${partnum}.stl" -D partnum=$partnum
done
