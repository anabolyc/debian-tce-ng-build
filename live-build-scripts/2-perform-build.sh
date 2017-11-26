#!/bin/bash

# Create Timestamp
LBX2GO_TIMESTAMP=$(date +"%Y%m%d%H%M%S")

# Set Directory name
LBX2GO_TCEDIR=./live-build-x2go-$LBX2GO_TIMESTAMP

if [ -z "$LBX2GO_ARCH" ] ||
   [ -z "$LBX2GO_SPACE" ] ||
   [ -z "$LBX2GO_CONFIG" ] ||
   [ -z "$LBX2GO_DEFAULTS" ] ||
   [ -z "$LBX2GO_DEBVERSION" ] ||
   [ -z "$LBX2GO_IMAGETYPE" ] ||
   [ -z "$LBX2GO_TIMESTAMP" ] ||
   [ -z "$LBX2GO_ARCHIVE_AREAS" ]; then
    echo -e "One or more of the following variables is unset:"
    echo -e "LBX2GO_ARCH: '${LBX2GO_ARCH}'"
    echo -e "LBX2GO_SPACE: '${LBX2GO_SPACE}'"
    echo -e "LBX2GO_DEFAULTS: '${LBX2GO_DEFAULTS}'"
    echo -e "LBX2GO_DEBVERSION: '${LBX2GO_DEBVERSION}'"
    echo -e "LBX2GO_CONFIG: '${LBX2GO_CONFIG}'"
    echo -e "LBX2GO_IMAGETYPE: '${LBX2GO_IMAGETYPE}'"
    echo -e "LBX2GO_TIMESTAMP: '${LBX2GO_TIMESTAMP}'"
    echo -e "LBX2GO_ARCHIVE_AREAS: '${LBX2GO_ARCHIVE_AREAS}'"
    echo -e "Please visit http://wiki.x2go.org/doku.php/doc:howto:tce"
    echo -e "and read up on the general prerequisites for X2Go-TCE"
else
    # This will create a timestamped subdirectory for the build
    mkdir -p $LBX2GO_TCEDIR
    cd $LBX2GO_TCEDIR

    lb config $LBX2GO_ARCH $LBX2GO_SPACE $LBX2GO_DEFAULTS \
       --config $LBX2GO_CONFIG --binary-images $LBX2GO_IMAGETYPE \
       --archive-areas "$LBX2GO_ARCHIVE_AREAS"
    # This will copy any patches we have prepared
    if [ -d "../patch" ] ; then
        cp -a ../patch/* config/
    fi
    # This enables an i386-only package in the sources.list file when an i386 build is requested
    if echo "$LBX2GO_ARCH" | grep -q -i "i386" ; then
        sed -i -e 's/# for i386 only #//' config/package-lists/desktop.list.chroot
    fi
    if [ "$LBX2GO_TCE_SHRINK" = "true" ] ; then
        echo '#!/bin/sh' >./config/hooks/0112-remove-folders.hook.chroot
        echo 'set -e' >>./config/hooks/0112-remove-folders.hook.chroot
        echo '# Remove folders' >>./config/hooks/0112-remove-folders.hook.chroot
        echo 'rm -rf ./usr/share/doc/*' >>./config/hooks/0112-remove-folders.hook.chroot
        echo 'rm -rf ./usr/share/locale/*' >>./config/hooks/0112-remove-folders.hook.chroot
        echo 'rm -rf ./usr/share/man/*' >>./config/hooks/0112-remove-folders.hook.chroot
        [ "$LBX2GO_IMAGETYPE" != "netboot" ] && echo 'rm -rf ./var/lib/apt/lists/*' >>./config/hooks/0112-remove-folders.hook.chroot
        chmod 755 ./config/hooks/0112-remove-folders.hook.chroot
    fi
    if lb build ; then
        echo -e "Build is done: '$LBX2GO_TCEDIR'"
        ln ./binary/live/filesystem.squashfs ./x2go-tce-filesystem.squashfs
        if [ "$LBX2GO_IMAGETYPE" = "netboot" ] ; then
            ln ./tftpboot/live/vmlinuz ./x2go-tce-vmlinuz
            ln ./tftpboot/live/initrd.img ./x2go-tce-initrd.img
            if [ "$LBX2GO_NOSQUASHFS" = "true" ] ; then
                (cd binary; echo live$'\n'live/filesystem.squashfs |cpio -o -H newc | gzip --fast) >./x2go-tce-filesystem.cpio.gz
                cat ./x2go-tce-initrd.img ./x2go-tce-filesystem.cpio.gz >./x2go-tce-initrd-with-fs.img
                rm ./x2go-tce-filesystem.cpio.gz ./x2go-tce-filesystem.squashfs ./x2go-tce-initrd.img
            fi
        fi
        if [ "$LBX2GO_IMAGETYPE" = "iso" ] || [ "$LBX2GO_IMAGETYPE" = "iso-hybrid" ] ; then
            ln ./binary/live/vmlinuz ./x2go-tce-vmlinuz
            ln ./binary/live/initrd.img ./x2go-tce-initrd.img
            genisoimage -o ./x2go-tce-squashfs-only.iso -R -J -graft-points live/filesystem.squashfs=./x2go-tce-filesystem.squashfs
            [ -e ./live-image-amd64.hybrid.iso ] && ln ./live-image-amd64.hybrid.iso ./original-x2go-tce-live-image-amd64.hybrid.iso
            [ -e ./live-image-amd64.iso ] && ln ./live-image-amd64.iso ./original-x2go-tce-live-image-amd64.iso
            [ -e ./live-image-i386.hybrid.iso ] && ln ./live-image-i386.hybrid.iso ./original-x2go-tce-live-image-i386.hybrid.iso
            [ -e ./live-image-i386.iso ] && ln ./live-image-i386.iso ./original-x2go-tce-live-image-i386.iso
            mv ./x2go-tce-filesystem.squashfs ./original-x2go-tce-filesystem.squashfs
        fi
        # create timestamp file
        stat -c %Y ./config/includes.chroot/lib >./x2go-tce-timestamp
        touch -m -d @$(cat x2go-tce-timestamp) x2go-tce-timestamp
        lb clean
        rm -rf ./cache
    else
        # note that imagetype hdd always ends here,
        # due to a harmless error that can be safely ignored, but which sets the error code to != 0
        echo -e "Build failed: '$LBX2GO_TCEDIR'"
    fi
    cd ..
fi
