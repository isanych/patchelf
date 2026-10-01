#! /bin/sh -e

# strip after patchelf used to leave the added PT_LOAD with a file offset that
# does not match its virtual address; --fix-layout repairs that.

SCRATCH=scratch/$(basename "$0" .sh)

rm -rf "${SCRATCH}"
mkdir -p "${SCRATCH}"

cp simple-pie "${SCRATCH}/simple-pie"

# Add a large rpath so that patchelf has to add a segment
printf '=%.0s' $(seq 1 4096) > "${SCRATCH}/foo.bin"
../src/patchelf --add-rpath @"${SCRATCH}/foo.bin" "${SCRATCH}/simple-pie"

if ! command -v strip >/dev/null 2>&1; then
    exit 77
fi
strip "${SCRATCH}/simple-pie"

../src/patchelf --fix-layout "${SCRATCH}/simple-pie"

# Make sure we can still run it, and that a second run changes nothing
"${SCRATCH}/simple-pie"
cp "${SCRATCH}/simple-pie" "${SCRATCH}/simple-pie.1"
../src/patchelf --fix-layout "${SCRATCH}/simple-pie"
cmp "${SCRATCH}/simple-pie" "${SCRATCH}/simple-pie.1"
