#!/bin/bash

# Select ONE of the following git reposities
# this one loosely corresponds to "stable"
export LBX2GO_CONFIG='git://code.x2go.org/live-build-x2go.git::feature/openbox-magic-pixel-workaround'
# this one loosely corresponds to "heuler"
#export LBX2GO_CONFIG='https://github.com/LinuxHaus/live-build-x2go::feature/openbox-magic-pixel-workaround'
# NOTE: Add "-stretch" to the end of the LBX2GO_CONFIG string to create a stretch build

# Select ONE of the following LBX2GO_ARCH lines and comment out the others
# (feel free to use long or short options)
# for 64-Bit builds, use:
export LBX2GO_ARCH='-a amd64 -k amd64'
# 32-Bit, larger memory footprint, but faster performance on i686 and newer
# export LBX2GO_ARCH='-a i386 -k 686-pae'
# 32-Bit, smallest memory footprint
# export LBX2GO_ARCH='--architectures i386 --linux-flavours 586'

if [ -z "${LBX2GO_CONFIG##*-stretch}" ] ; then
        export LBX2GO_DEBVERSION="stretch"
        else
        export LBX2GO_DEBVERSION="jessie"
fi

# These options are meant to reduce the image size.
# Feel free to adapt them after consulting "man lb_config"
export LBX2GO_SPACE='--apt-indices none
                     --apt-recommends false
                     --cache false
                     --checksums none
                     --firmware-binary false
                     --memtest none
                     --win32-loader false'

# These are default values that should not require tuning
export LBX2GO_DEFAULTS="--backports true
                        --firmware-chroot true
                        --initsystem sysvinit
                        --security true
                        --updates true
                        --distribution $LBX2GO_DEBVERSION"

export LBX2GO_ARCHIVE_AREAS="main contrib non-free"

# This is to optimize squashfs size, based on a suggestion by intrigeri from the TAILS team
# note that this will permanently change /usr/lib/live/build/binary_rootfs
sed -i -e 's#MKSQUASHFS_OPTIONS="${MKSQUASHFS_OPTIONS} -comp xz"#MKSQUASHFS_OPTIONS="${MKSQUASHFS_OPTIONS} -comp xz -Xbcj x86 -b 1024K -Xdict-size 1024K"#' /usr/lib/live/build/binary_rootfs

# This removes documentation, locales and man pages
# You can safely enable this if you intend to run X2GoClient in fullscreen mode all the time, or when building the ssh-only rescue image.
# For all other uses of the TCE-Live image creator (i.e. Minidesktop), your results may vary ... use at your own risk.
export LBX2GO_TCE_SHRINK="true"

# This patches the squashfs file into the initrd. Only parsed when image type "netboot" is set.
# Will require boot parameter live-media=/ instead of fetch=...
# Both TFTP client and TFTP server must support file transfers >32MB for this to work, if you want to deploy this initrd via TFTP.
# When using iPXE, you can use http instead of TFTP.
# This is especially helpful if you want to netboot via http and cannot use the server's IP, but must specify a DNS name - as "fetch=..." only understands IPs.
export LBX2GO_NOSQUASHFS="false"

# Select ONE of the following LBX2GO_IMAGETYPE lines and comment out the others
# to create an iso image:
# export LBX2GO_IMAGETYPE='iso'
# to create an iso image that can also be dd'ed to USB media:
# export LBX2GO_IMAGETYPE='iso-hybrid'
# to create a netboot-image:
export LBX2GO_IMAGETYPE='netboot'
# NOT RECOMMENDED:
# to create an image that can be written to a hard disk (always results
# in a "build failed" message, even though the build might have worked):
# export LBX2GO_IMAGETYPE='hdd'
# to create a tar file only (seems to be broken in live-build):
# export LBX2GO_IMAGETYPE='tar'
