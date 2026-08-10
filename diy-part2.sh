#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# ============================================================
# 修改默认 IP 为 192.168.100.1
# ============================================================
sed -i 's/192.168.1.1/192.168.100.1/g' package/base-files/files/bin/config_generate

# ============================================================
# 修改默认主题为 Argon
# ============================================================
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# ============================================================
# 修改主机名（取消注释可启用）
# ============================================================
# sed -i 's/OpenWrt/JDC-Athens/g' package/base-files/files/bin/config_generate

echo "============================================"
echo " DIY Part 2 Complete!"
echo " Default IP: 192.168.100.1"
echo " Default Theme: Argon"
echo "============================================"
