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
sed -i 's/192.168.6.1/10.10.5.1/g' package/base-files/files/bin/config_generate

sed -i 's,https://mirrors.vsean.net/openwrt,https://downloads.immortalwrt.org,g' package/emortal/default-settings/files/99-default-settings-chinese
# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
sed -i 's/ImmortalWrt/N60-Pro/g' package/base-files/files/bin/config_generate

# ==========================================
# 允许从 WAN 口访问本机 1080 端口 (uci-defaults注入法)
# ==========================================
mkdir -p files/etc/uci-defaults
cat > files/etc/uci-defaults/99-custom-firewall << "EOF"
#!/bin/sh
uci -q get firewall.allow_1080 >/dev/null && exit 0

uci set firewall.allow_1080=rule
uci set firewall.allow_1080.name='Allow-WAN-1080'
uci set firewall.allow_1080.src='wan'
uci set firewall.allow_1080.dest_port='1080'
uci set firewall.allow_1080.proto='tcp udp'
uci set firewall.allow_1080.target='ACCEPT'
uci commit firewall
exit 0
EOF

# # 允许从 WAN 口访问本机 1080 端口
# cat >> package/network/config/firewall/files/firewall.config <<EOF
# config rule
#         option name 'Allow-WAN-1080'
#         option src 'wan'
#         option dest_port '1080'
#         option proto 'tcp udp'
#         option target 'ACCEPT'
# EOF

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

# ===== LED 配置完全对齐参照固件（section名/显示名/mode 全部一致）=====
python3 - <<'PYEOF'
import pathlib

led_file = pathlib.Path("target/linux/mediatek/filogic/base-files/etc/board.d/01_leds")
text = led_file.read_text()

old = '''netcore,n60-pro)
	ucidef_set_led_netdev "lan1" "LAN1" "mdio-bus:05:green:lan" "lan1" "link tx rx"
	ucidef_set_led_netdev "wanact" "WANACT" "mdio-bus:06:green:wan" "eth1" "tx rx"
	ucidef_set_led_netdev "wanlink" "WANLINK" "blue:wan" "eth1" "link"
	ucidef_set_led_netdev "wlan" "WLAN" "blue:wlan" "rax0" "link"
	ucidef_set_led_usbport "usb" "USB" "blue:usb" "usb2-port1"
	;;'''

new = '''netcore,n60-pro)
	ucidef_set_led_netdev "wanlink" "WANLINK" "mdio-bus:06:green:wan" "eth1" "link_10 link_100 link_1000 link_2500 tx rx"
	ucidef_set_led_netdev "lan_1" "LAN-1" "mdio-bus:05:green:lan" "lan1" "link_10 link_100 link_1000 link_2500 tx rx"
	ucidef_set_led_netdev "wan" "WAN" "blue:wan" "eth1" "link"
	ucidef_set_led_netdev "WIFI" "WIFI" "blue:wlan" "rax0" "link"
	ucidef_set_led_usbport "USB" "USB" "blue:usb" "usbport" "usb1-port2"
	ucidef_set_led_netdev "lan" "LAN" "blue:wps" "br-lan" "link_10 link_100 link_1000 link_2500 tx rx"
	;;'''

assert old in text, "01_leds 脚本内容跟预期不一致，可能源码已更新，请检查后再编译！"
text = text.replace(old, new)

led_file.write_text(text)
print("[OK] LED配置已完全对齐参照固件（section名、显示名、mode全部一致）")
PYEOF

# 正常 LED 数据
# root@N60PRO:~# ls -l /sys/class/leds/
# lrwxrwxrwx    1 root     root             0 Jan 29  2026 blue:power -> ../../devices/platform/gpio-leds/leds/blue:power
# lrwxrwxrwx    1 root     root             0 Jan 29  2026 blue:usb -> ../../devices/platform/gpio-leds/leds/blue:usb
# lrwxrwxrwx    1 root     root             0 Jan 29  2026 blue:wan -> ../../devices/platform/gpio-leds/leds/blue:wan
# lrwxrwxrwx    1 root     root             0 Jan 29  2026 blue:wlan -> ../../devices/platform/gpio-leds/leds/blue:wlan
# lrwxrwxrwx    1 root     root             0 Jan 29  2026 blue:wps -> ../../devices/platform/gpio-leds/leds/blue:wps
# lrwxrwxrwx    1 root     root             0 Sep 15 05:36 led -> ../../devices/platform/soc/15100000.ethernet/mdio_bus/mdio-bus/mdio-bus:05/leds/led
# lrwxrwxrwx    1 root     root             0 Sep 15 05:36 led_1 -> ../../devices/platform/soc/15100000.ethernet/mdio_bus/mdio-bus/mdio-bus:06/leds/led_1

# ===== 固定 ttyd 网页终端配置：免登录直接进 root shell =====
mkdir -p files/etc/config
cat > files/etc/config/ttyd <<-'EOF'
config ttyd
	option interface '@lan'
	option command '/bin/login -f root'
EOF
echo "[OK] 已写入 files/etc/config/ttyd，ttyd 将免登录直接进入 root shell"