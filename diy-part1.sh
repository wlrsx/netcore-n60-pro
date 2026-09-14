#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Uncomment a feed source
#sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# Add a feed source
# echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default
# #echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall' >>feeds.conf.default
echo "src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main" >> "feeds.conf.default"

# # Add ADGuardHome source
# git clone https://github.com/rufengsuixing/luci-app-adguardhome package/luci-app-adguardhome
# chmod -R 755 ./package/luci-app-adguardhome/*


# /etc/opkg/distfeeds.conf
# src/gz immortalwrt_core https://downloads.immortalwrt.org/releases/24.10-SNAPSHOT/targets/mediatek/filogic/packages
# src/gz immortalwrt_base https://downloads.immortalwrt.org/releases/24.10-SNAPSHOT/packages/aarch64_cortex-a53/base
# src/gz immortalwrt_luci https://downloads.immortalwrt.org/releases/24.10-SNAPSHOT/packages/aarch64_cortex-a53/luci
# src/gz immortalwrt_packages https://downloads.immortalwrt.org/releases/24.10-SNAPSHOT/packages/aarch64_cortex-a53/packages
# src/gz immortalwrt_routing https://downloads.immortalwrt.org/releases/24.10-SNAPSHOT/packages/aarch64_cortex-a53/routing
# src/gz immortalwrt_telephony https://downloads.immortalwrt.org/releases/24.10-SNAPSHOT/packages/aarch64_cortex-a53/telephony
