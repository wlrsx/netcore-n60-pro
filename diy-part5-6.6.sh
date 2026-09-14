#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part5-6.6.sh
# Description: OpenWrt DIY script part 5 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate

# # 添加组播防火墙规则
# cat >> package/network/config/firewall/files/firewall.config <<EOF
# config rule
#         option name 'Allow-UDP-igmpproxy'
#         option src 'wan'
#         option dest 'lan'
#         option dest_ip '224.0.0.0/4'
#         option proto 'udp'
#         option target 'ACCEPT'        
#         option family 'ipv4'

# config rule
#         option name 'Allow-UDP-udpxy'
#         option src 'wan'
#         option dest_ip '224.0.0.0/4'
#         option proto 'udp'
#         option target 'ACCEPT'
# EOF

# ===== 硬改 N60 Pro：2GB内存 + 512MB闪存(400M ubi + 100M data) DTS 补丁 =====
python3 - <<'PYEOF'
import pathlib

dts = pathlib.Path("target/linux/mediatek/dts/mt7986a-netcore-n60-pro.dts")
text = dts.read_text()

# 内存改为 2GB
mem_old = "reg = <0 0x40000000 0 0x20000000>;"
mem_new = "reg = <0 0x40000000 0 0x80000000>;"
assert mem_old in text, "内存reg匹配失败，DTS文件内容已变化，请检查后再编译！"
text = text.replace(mem_old, mem_new)

# 闪存分区表：ubi 改为 400MB，并新增 100MB 的 data 分区（对应你路由现有的分区布局）
ubi_old = """partition@580000 {
				label = "ubi";
				reg = <0x0580000 0x7280000>;
			};"""
ubi_new = """partition@580000 {
				label = "ubi";
				reg = <0x580000 0x19000000>;
			};

			partition@19580000 {
				label = "data";
				reg = <0x19580000 0x6400000>;
			};"""
assert ubi_old in text, "分区表匹配失败，DTS文件内容已变化，请检查后再编译！"
text = text.replace(ubi_old, ubi_new)

dts.write_text(text)
print("[OK] DTS 已打上 2GB内存 + 512MB闪存 补丁")
PYEOF

# # ===== 硬改 N60 Pro：2GB内存 + 512MB闪存(单一大分区506.5MB) DTS 补丁 =====
# python3 - <<'PYEOF'
# import pathlib

# dts = pathlib.Path("target/linux/mediatek/dts/mt7986a-netcore-n60-pro.dts")
# text = dts.read_text()

# mem_old = "reg = <0 0x40000000 0 0x20000000>;"
# mem_new = "reg = <0 0x40000000 0 0x80000000>;"
# assert mem_old in text, "内存reg匹配失败，DTS文件内容已变化，请检查后再编译！"
# text = text.replace(mem_old, mem_new)

# ubi_old = """partition@580000 {
# 				label = "ubi";
# 				reg = <0x0580000 0x7280000>;
# 			};"""
# ubi_new = """partition@580000 {
# 				label = "ubi";
# 				reg = <0x580000 0x1FA80000>;
# 			};"""
# assert ubi_old in text, "分区表匹配失败，DTS文件内容已变化，请检查后再编译！"
# text = text.replace(ubi_old, ubi_new)

# dts.write_text(text)
# print("[OK] DTS 已打上 2GB内存 + 512MB闪存(单分区506.5MB) 补丁")
# PYEOF