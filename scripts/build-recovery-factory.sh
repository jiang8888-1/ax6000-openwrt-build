#!/usr/bin/env bash
set -euo pipefail
src="$RUNNER_TEMP/immortalwrt-mt798x"
git clone --depth 1 --branch openwrt-21.02 https://github.com/hanwckf/immortalwrt-mt798x.git "$src"
cd "$src"
./scripts/feeds update -a
./scripts/feeds install -a
cat > .config <<'EOF'
CONFIG_TARGET_mediatek=y
CONFIG_TARGET_mediatek_mt7986=y
CONFIG_TARGET_mediatek_mt7986_DEVICE_xiaomi_redmi-router-ax6000=y
CONFIG_PACKAGE_luci=y
CONFIG_PACKAGE_luci-ssl=y
CONFIG_PACKAGE_luci-i18n-base-zh-cn=y
CONFIG_PACKAGE_ttyd=y
CONFIG_PACKAGE_luci-app-ttyd=y
EOF
make defconfig
make download -j"$(nproc)"
make -j"$(nproc)" V=s
mkdir -p "$GITHUB_WORKSPACE/recovery-factory"
f="$(find bin/targets/mediatek/mt7986 -type f -name '*xiaomi_redmi-router-ax6000*factory.bin' -print -quit)"
test -n "$f"
cp "$f" "$GITHUB_WORKSPACE/recovery-factory/"
sha256sum "$GITHUB_WORKSPACE/recovery-factory/$(basename "$f")" > "$GITHUB_WORKSPACE/recovery-factory/$(basename "$f").sha256"
