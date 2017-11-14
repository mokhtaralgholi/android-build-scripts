#!/bin/bash

## Copyright (c) 2017, Cswl Coldwind (cswl1337@gmail.com)
## This work is licensed under a Creative Commons Attribution 4.0 International License 
## http://creativecommons.org/licenses/by/4.0/

## Dirtly cleans the android build

# We cannot get device info since we are not included by make
DEVICE="$1"

# Cleans all zip files
clean_ota() {
	rm -rf out/target/product/$DEVICE/obj/PACKAGING/
	rm -rf out/target/product/$DEVICE/ota_temp/
	rm out/target/product/$DEVICE/lineage*
}

# Cleans the system
clean_system() {
	rm -rf out/target/product/$DEVICE/system*
}

# Cleans the art oat files and odexes
clean_art() {
	rm -rf out/target/product/$DEVICE/dex_bootjars/
	find out/target/product/$DEVICE/obj/APPS -type f -name '*.odex' -exec rm -rf {} \+
	find out/target/product/$DEVICE/obj/JAVA_LIBRARIES -type f -name '*.odex' -exec rm -rf {} \+
}

case "$2" in
	"ota")
		clean_ota
		;;
	"system"
		clean_system
		;;
	"art"
		clean_art
		;;
	"all")
		clean_ota
		clean_system
		clean_art
		;;
esac

