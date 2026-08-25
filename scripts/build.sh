#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source_dir="${RUNNER_TEMP:-/tmp}/openwrt"
openwrt_tag="${OPENWRT_TAG:-v24.10.8}"

git clone --depth 1 --branch "$openwrt_tag" https://github.com/openwrt/openwrt.git "$source_dir"
cd "$source_dir"
cp "$project_root/config/feeds.conf" feeds.conf.default

./scripts/feeds update -a
./scripts/feeds install -a -p packages
./scripts/feeds install -a -p luci
./scripts/feeds install -a -p routing
./scripts/feeds install -a -p telephony
./scripts/feeds install -a -p passwall_packages
./scripts/feeds install -p passwall2 luci-app-passwall2

cp "$project_root/config/ax6000.config" .config
make defconfig

grep -qx 'CONFIG_PACKAGE_luci-app-passwall2_Nftables_Transparent_Proxy=y' .config
if grep -qx 'CONFIG_PACKAGE_luci-app-passwall2_Iptables_Transparent_Proxy=y' .config; then
  echo 'PassWall2 legacy iptables mode was selected unexpectedly.' >&2
  exit 1
fi

make download -j"$(nproc)"
make -j"$(nproc)" V=s

target_dir="bin/targets/mediatek/filogic"
image="$(find "$target_dir" -maxdepth 1 -type f -name '*xiaomi_redmi-router-ax6000-stock-squashfs-sysupgrade.bin' -print -quit)"
manifest="$(find "$target_dir" -maxdepth 1 -type f -name '*xiaomi_redmi-router-ax6000-stock.manifest' -print -quit)"

if [ -z "$image" ] || [ ! -f "$image" ]; then
  echo "Expected AX6000 sysupgrade image was not created." >&2
  find "$target_dir" -maxdepth 1 -type f -printf '%f\n' >&2
  exit 1
fi

if [ -z "$manifest" ] || [ ! -f "$manifest" ]; then
  echo "Expected AX6000 package manifest was not created." >&2
  find "$target_dir" -maxdepth 1 -type f -name '*.manifest' -printf '%f\n' >&2
  exit 1
fi

for package in adguardhome dnsmasq-full firewall4 luci-app-passwall2 nftables-json sing-box xray-core; do
  if ! grep -q "^${package} " "$manifest"; then
    echo "Required package is missing from the image: ${package}" >&2
    exit 1
  fi
done

output_dir="$project_root/firmware"
mkdir -p "$output_dir"
cp "$image" "$manifest" "$output_dir/"
sha256sum "$output_dir/$(basename "$image")" > "$output_dir/$(basename "$image").sha256"
