#!/bin/bash

reset
echo "Is your model 3d or 2d? Enter 3 or 2:"
read model_type

if [ "$model_type" == "2" ]; then
    rm a.out
    rm graphics.o
    clang++ graphics.mm -c ../inout.c
    gcc stuff.c graphics.o -framework Cocoa ../inout.c
    ./a.out
elif [ "$model_type" == "3" ]; then
    rm a.out
    rm graphics.o
    clang++ graphics.mm -c ../inout.c -DThreeDimensional=40
    gcc stuff.c graphics.o -framework Cocoa -framework SceneKit ../inout.c
    ./a.out
else
    echo "Invalid input. Please enter 2 or 3."
fi
