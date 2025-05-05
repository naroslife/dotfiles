#!/bin/sh

# This script installs the Nix package manager on your system by
# downloading a binary distribution and running its installer script
# (which in turn creates and populates /nix).

{ # Prevent execution if this script was only partially downloaded
oops() {
    echo "$0:" "$@" >&2
    exit 1
}

umask 0022

tmpDir="$(mktemp -d -t nix-binary-tarball-unpack.XXXXXXXXXX || \
          oops "Can't create temporary directory for downloading the Nix binary tarball")"
cleanup() {
    rm -rf "$tmpDir"
}
trap cleanup EXIT INT QUIT TERM

require_util() {
    command -v "$1" > /dev/null 2>&1 ||
        oops "you do not have '$1' installed, which I need to $2"
}

case "$(uname -s).$(uname -m)" in
    Linux.x86_64)
        hash=85d1847d06d5d56167796d3f61cd992908de84584db3e700da031a782b59ea22
        path=cgjd0gajsh9zwsbkfb7f6zs2p2rsw4gg/nix-2.28.3-x86_64-linux.tar.xz
        system=x86_64-linux
        ;;
    Linux.i?86)
        hash=952afcd1376d28ef5458cf7448a69c8ed719aedd97e14252fdef5303481c7f90
        path=sy5vc4hja98jv4mk19h1r74w36lf46f5/nix-2.28.3-i686-linux.tar.xz
        system=i686-linux
        ;;
    Linux.aarch64)
        hash=3dffb118772382e35526806fb97acc05df7ad6dc29dbe52b921b77e52e39f571
        path=7q8avbwbympndjdnznidf7wjm6phqppz/nix-2.28.3-aarch64-linux.tar.xz
        system=aarch64-linux
        ;;
    Linux.armv6l)
        hash=c6f2041a0e99178a1225928d8ace315501221986bc19c62ddabcde9800d036b0
        path=1sywrv2gnfhl9gziz5ibalmznhxqf96v/nix-2.28.3-armv6l-linux.tar.xz
        system=armv6l-linux
        ;;
    Linux.armv7l)
        hash=1c451dfdf58300165b16b12baa8c300c0b52e1c624c533c2f5b137efd1667585
        path=1xz4wmqh74cwvq8fg5m0agw3lasvg94y/nix-2.28.3-armv7l-linux.tar.xz
        system=armv7l-linux
        ;;
    Linux.riscv64)
        hash=8fb7ffcbdd5ac9557e7bd50a837d1fd710e3b9dc03a8255351bb23ec9c015141
        path=8qcwcxn8zwa9nlbq2pfk2qbs96daz9mp/nix-2.28.3-riscv64-linux.tar.xz
        system=riscv64-linux
        ;;
    Darwin.x86_64)
        hash=942d55db022961eec7b35b3bdd6bce748d32cc0cc17bafb143e305434ae30643
        path=0wdxd8l0q7w8zhs3sl3fdcpj7hjm910l/nix-2.28.3-x86_64-darwin.tar.xz
        system=x86_64-darwin
        ;;
    Darwin.arm64|Darwin.aarch64)
        hash=6befec86f4e8effa5b0112ad0491dc8e2b1c26e5a95c1cc40c1ea60194d53c88
        path=ccy6c8q6qpnl97j6pbnhmy986viab61d/nix-2.28.3-aarch64-darwin.tar.xz
        system=aarch64-darwin
        ;;
    *) oops "sorry, there is no binary distribution of Nix for your platform";;
esac

# Use this command-line option to fetch the tarballs using nar-serve or Cachix
if [ "${1:-}" = "--tarball-url-prefix" ]; then
    if [ -z "${2:-}" ]; then
        oops "missing argument for --tarball-url-prefix"
    fi
    url=${2}/${path}
    shift 2
else
    url=https://releases.nixos.org/nix/nix-2.28.3/nix-2.28.3-$system.tar.xz
fi

tarball=$tmpDir/nix-2.28.3-$system.tar.xz

require_util tar "unpack the binary tarball"
if [ "$(uname -s)" != "Darwin" ]; then
    require_util xz "unpack the binary tarball"
fi

if command -v curl > /dev/null 2>&1; then
    fetch() { curl --fail -L "$1" -o "$2"; }
elif command -v wget > /dev/null 2>&1; then
    fetch() { wget "$1" -O "$2"; }
else
    oops "you don't have wget or curl installed, which I need to download the binary tarball"
fi

echo "downloading Nix 2.28.3 binary tarball for $system from '$url' to '$tmpDir'..."
fetch "$url" "$tarball" || oops "failed to download '$url'"

if command -v sha256sum > /dev/null 2>&1; then
    hash2="$(sha256sum -b "$tarball" | cut -c1-64)"
elif command -v shasum > /dev/null 2>&1; then
    hash2="$(shasum -a 256 -b "$tarball" | cut -c1-64)"
elif command -v openssl > /dev/null 2>&1; then
    hash2="$(openssl dgst -r -sha256 "$tarball" | cut -c1-64)"
else
    oops "cannot verify the SHA-256 hash of '$url'; you need one of 'shasum', 'sha256sum', or 'openssl'"
fi

if [ "$hash" != "$hash2" ]; then
    oops "SHA-256 hash mismatch in '$url'; expected $hash, got $hash2"
fi

unpack=$tmpDir/unpack
mkdir -p "$unpack"
tar -xJf "$tarball" -C "$unpack" || oops "failed to unpack '$url'"

script=$(echo "$unpack"/*/install)

[ -e "$script" ] || oops "installation script is missing from the binary tarball!"
export INVOKED_FROM_INSTALL_IN=1
"$script" "$@"

} # nixEnd of wrapping
