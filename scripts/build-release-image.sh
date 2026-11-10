#!/usr/bin/env bash
# Build the released image: the V610-Buildroot image plus the hardware test
# programs, which images built by users do not contain.
#
#   scripts/build-release-image.sh --buildroot /path/to/V610-Buildroot
#
# The test programs are V610-App-SDK examples, built from the V610-App-SDK
# checkout inside V610-Buildroot, and scripts/board-test. They are added as
# an extra rootfs overlay in a separate output directory, build/release-image
# of this repository, so neither V610-Buildroot nor its regular output
# changes. Pass the resulting build/release-image/images/flash to
# make-release.sh --image.
set -euo pipefail

TOPDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
BUILDROOT=
EXAMPLES=(camera_record audio_loopback lvgl_widgets)

usage()
{
    sed -n '2,12s/^# \{0,1\}//p' "${BASH_SOURCE[0]}"
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --buildroot) BUILDROOT=$(cd "$2" && pwd); shift 2 ;;
        -h|--help) usage; exit 0 ;;
        *) usage >&2; exit 1 ;;
    esac
done
[[ -n $BUILDROOT ]] || { usage >&2; exit 1; }
SDK=$BUILDROOT/V610-App-SDK
[[ -f $SDK/export.sh ]] || { echo "missing $SDK" >&2; exit 1; }

OUT=$TOPDIR/build/release-image
OVERLAY=$OUT/board-test-overlay
# Buildroot copies overlays into target/ but never removes anything there, so
# drop the files of the previous overlay before building a new one.
if [[ -d $OVERLAY ]]; then
    (cd "$OVERLAY" && find . -type f) | while read -r f; do rm -f "$OUT/target/$f"; done
fi
rm -rf "$OVERLAY"
mkdir -p "$OVERLAY/usr/bin"

# Build the examples in a subshell, so the SDK environment stays there.
(
    set +u
    # shellcheck source=/dev/null
    source "$SDK/export.sh" >/dev/null
    # export.sh unsets the compiler settings; read them again for strip.
    # shellcheck source=/dev/null
    . "$SDK/compiler.conf"
    for name in "${EXAMPLES[@]}"; do
        hifw.py -C "$SDK/examples/$name" set-target hi3516cv610 >/dev/null
        hifw.py -C "$SDK/examples/$name" build -j "$(nproc)" >/dev/null
        "${CROSS_PREFIX:-$COMPILER_PREFIX}strip" -o "$OVERLAY/usr/bin/$name" "$SDK/examples/$name/out/$name"
    done
)
install -m 0755 "$TOPDIR/scripts/board-test" "$OVERLAY/usr/bin/board-test"
ls -l "$OVERLAY/usr/bin"

# Load the board defconfig, then append the overlay to this output only.
make -C "$BUILDROOT" O="$OUT" cove_610_defconfig >/dev/null
sed -i "s#^BR2_ROOTFS_OVERLAY=\"\\(.*\\)\"#BR2_ROOTFS_OVERLAY=\"\\1 $OVERLAY\"#" "$OUT/.config"
grep '^BR2_ROOTFS_OVERLAY=' "$OUT/.config"
make -C "$BUILDROOT" O="$OUT"

echo "release image: $OUT/images/flash"
