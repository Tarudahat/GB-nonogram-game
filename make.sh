#!/usr/bin/bash
rm ./build/*
USER=$(whoami) 

for FILE in ./src/*.asm
do
FILE_NAME=${FILE#./src/}
#echo $FILE_NAME
rgbasm -o "./build/${FILE_NAME%.asm}.o" "${FILE%.asm}.asm" 
done

rgblink -o ./build/main.gb ./build/*.o -m ./build/main.map
rgbfix -v -p 0xFF ./build/main.gb
wine /home/$USER/Documents/GB_dev_tools/bgb/bgb.exe ./build/main.gb