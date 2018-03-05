#!/bin/bash

echo "DEBUG: LFS variable is $LFS at beggining of this script"
echo "DEBUG: Setting the variable anyway" # TODO find why LFS variable is not loaded when the commands run
LFS=/mnt/lfs



function usage {
	# TODO create usage message
	echo "TODO - usage message"
}

function provisioning {
	mkdir -p /mnt/lfs
	grep -qF "/dev/sdb1   /mnt/lfs" /etc/fstab  || echo "/dev/sdb1   /mnt/lfs" | sudo tee --append /etc/fstab
}


function download_sources {
	echo "DEBUG: LFS variable is $LFS"
	# From http://www.linuxfromscratch.org/lfs/view/stable-systemd/chapter03/introduction.html

	# Prepare the sources sub-directory
	mkdir -v $LFS/sources
	echo "DEBUG: sources is $LFS/sources"
	chmod -v a+wt $LFS/sources
	pushd $LFS/sources

	# Download the sources files list and respective hashes
	wget http://www.linuxfromscratch.org/lfs/view/stable-systemd/wget-list
	wget http://www.linuxfromscratch.org/lfs/view/stable-systemd/md5sums
	wget --input-file=wget-list --continue --directory-prefix=$LFS/sources
	md5sum -c md5sums

	# Return to original directory
	popd
}


function download_patches {
	# From http://www.linuxfromscratch.org/lfs/view/stable-systemd/chapter03/patches.html
	mkdir -v -p $LFS/sources/patches
	pushd $LFS/sources/patches
	cat > patches-list <<- "EOF"
http://www.linuxfromscratch.org/patches/lfs/8.2/bzip2-1.0.6-install_docs-1.patch
http://www.linuxfromscratch.org/patches/lfs/8.2/coreutils-8.29-i18n-1.patch
http://www.linuxfromscratch.org/patches/lfs/8.2/glibc-2.27-fhs-1.patch
http://www.linuxfromscratch.org/patches/lfs/8.2/kbd-2.0.4-backspace-1.patch
http://www.linuxfromscratch.org/patches/lfs/8.2/ninja-1.8.2-add_NINJAJOBS_var-1.patch
EOF
	wget --input-file=patches-list --continue
	## TODO make md5sum check
	popd

}



# Initial sanity checks

if [[ -z $LFS ]]; then
	echo "LFS variable is not set."
	echo "Exiting"
	exit 1
fi

echo "DEBUG: Current value for LFS variable: " $LFS

if mount | grep -q "$LFS"; then
	echo "$LFS is mounted"
else
	echo "$LFS is not mounted"
	echo "Exiting"
	exit 1
fi

# Call apropriate command(s) based on the first command-line parameter
case "$1" in
	"")
		usage
		;;
	"provisioning")
		provisioning
		;;
	"download_sources")
		download_sources
		;;
	"download_patches")
		download_patches
		;;
	*)
		usage
		;;
esac


