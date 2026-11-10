#!/usr/bin/env bash
# Collect the files attached to a V610-Solution release into dist/<version>/
# and write SHA256SUMS.
#
#   scripts/make-release.sh --version 1.0.0 \
#       --image  build/release-image/images/flash \
#       --app-sdk /path/to/V610-App-SDK-1.0.0.tar.gz
#
# --app-sdk is optional. The burn tools live in tools/ and are not attached.
# Build the image first with scripts/build-release-image.sh, which adds the
# hardware tests.
set -euo pipefail

TOPDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
VERSION= IMAGE_DIR= APP_SDK=

usage()
{
    sed -n '2,8s/^# \{0,1\}//p' "${BASH_SOURCE[0]}"
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --version) VERSION=$2; shift 2 ;;
        --image) IMAGE_DIR=$2; shift 2 ;;
        --app-sdk) APP_SDK=$2; shift 2 ;;
        -h|--help) usage; exit 0 ;;
        *) usage >&2; exit 1 ;;
    esac
done

if [[ -z $VERSION || -z $IMAGE_DIR ]]; then
    usage >&2
    exit 1
fi

IMAGE_FILES=(boot_image.bin nand_burn_table.xml nand_env.bin uImage)
for f in "${IMAGE_FILES[@]}"; do
    [[ -f $IMAGE_DIR/$f ]] || { echo "missing $IMAGE_DIR/$f" >&2; exit 1; }
done
ROOTFS=$(cd "$IMAGE_DIR" && ls rootfs_*.ubifs)

OUT="$TOPDIR/dist/$VERSION"
rm -rf "$OUT"
mkdir -p "$OUT"

# The image archive unpacks into a directory of its own name, the layout
# docs/burntool.md describes.
IMAGE_NAME="cove_610-image-$VERSION"
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir "$STAGE/$IMAGE_NAME"
for f in "${IMAGE_FILES[@]}" $ROOTFS; do
    cp "$IMAGE_DIR/$f" "$STAGE/$IMAGE_NAME/"
done
(cd "$STAGE" && zip -qr "$OUT/$IMAGE_NAME.zip" "$IMAGE_NAME")

[[ -z $APP_SDK ]] || cp "$APP_SDK" "$OUT/"

(cd "$OUT" && sha256sum -- * > SHA256SUMS)
ls -l "$OUT"
