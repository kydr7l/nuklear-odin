#!/usr/bin/env sh
# Build the Nuklear static library into lib/libnuklear.a.
# Also build lib/libnuklear_layout.a for the layout test.
# Usage: ./build.sh [debug]
# Set the CC environment variable to select the compiler (default: cc).
set -eu

debug=0
for arg in "$@"; do
	case "$arg" in
		debug) debug=1 ;;
		*) echo "build.sh: unknown option \"$arg\". Use debug." >&2; exit 1 ;;
	esac
done

cc="${CC:-cc}"

if [ ! -f nuklear/nuklear.h ]; then
	echo "build.sh: nuklear is empty. Run \"git submodule update --init\"." >&2
	exit 1
fi

cflags="-std=c99 -Wall -Wno-unused-function"
if [ "$debug" = 1 ]; then cflags="$cflags -O0 -g"; else cflags="$cflags -O3 -DNDEBUG"; fi

rm -rf build
mkdir -p build/obj lib

$cc $cflags -c nuklear.c -o build/obj/nuklear.o

rm -f lib/libnuklear.a
ar rcs lib/libnuklear.a build/obj/nuklear.o

$cc $cflags -c tests/layout.c -o build/obj/nuklear_layout.o
rm -f lib/libnuklear_layout.a
ar rcs lib/libnuklear_layout.a build/obj/nuklear_layout.o

echo "Built lib/libnuklear.a and lib/libnuklear_layout.a"
