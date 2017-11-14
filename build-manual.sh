# Copy paste into shell

#### ANDROID ########
Local enviroment variables set via ./config.build.
`virtualenv2 venv` to set up python2 virtual enviroment.

	  . ./config.build && . venv/bin/activate && . build/envsetup.sh


##### Repack and Unpack bootimg #####

cd recovery/root/
cat ramdisk-recovery.cpio | xz -4e > ramdisk-recovery.img
find . | cpio --create --format='newc' > ../ramdisk-recovery.cpio
find . | cpio --create --format='newc' | gzip > ../ramdisk-recovery.img
find . | cpio --create --format='newc' | gzip > ../ramdisk.img
find . | cpio --create --format='newc' | gzip > ../ramdisk.cpio.gz

## Extracting
gunzip -c ../ramdisk.img | cpio -iudm
gunzip -c ../ramdisk.cpio.gz | cpio -iudm


#zreladdr = pageoffset + text_offset		@ C0000000 + 4508000 = C4508000

	mkbootimg --base 0 --pagesize 2048 --kernel_offset 0x00008000 --ramdisk_offset 0x01000000 --second_offset 0x00f00000 --tags_offset 0x00000100 --cmdline 'console=ttyS1,115200n8 androidboot.selinux=permissive buildvariant=userdebug' --kernel kernel --ramdisk ramdisk.cpio.gz -o boot.img


###### KERNEL #######
1) Directly build kernel without calling soong

prebuilts/build-tools/linux-x86/bin/ninja -d keepdepfile bootimage -j8 \
  -f /home/cswl/android/oreo/out/combined-lineage_galaxysmtd.ninja

##### Debugging #####
f you want to see the full compile/link/whatever commands being run, use the special `showcommands`
target (which isn not a target to build per se, but a modifier to the output of the make command). 
E.g.: to build liblog you would do:

. build/envsetup.sh
lunch    
$ make showcommands 

##### Common problems during build #####

1) Lineage 15.0
** No rule to make target '7/.txt', 
needed by '/out/target/common/obj/PACKAGING/checkpublicapi-cm-last-timestamp'.
 Stop.

I've managed to finally find where the api check is. 
It's defined in vendor/lineage/build/tasks/apicheck.mk. 
There is a flag named WITHOUT_CHECK_API which allows you to disable the api check.