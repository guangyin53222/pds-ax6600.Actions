#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#
# Copyright (c) 2019-2024 P3TERX
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# ============================================================
# 京东云 AX6600 (Athena) LED 控制器 - 源码集成
# 官方源: https://github.com/unraveloop/JDC-AX6600-Athena-LED-Controller
# 锁定版本: v2.4.0（官方已发布的稳定版，有预编译二进制）
# 注意: main 分支 Makefile 写的是 2.5.0，但 release 尚未发布，会 404
# ============================================================

echo "============================================"
echo " Adding JDC-AX6600 Athena LED Controller"
echo "============================================"

# --- 1. 添加 Athena LED Controller (Rust核心 + LuCI界面) ---
# 使用官方源 + 锁定 v2.4.0 tag，确保能下载到预编译的 Rust 二进制
rm -rf package/JDC-AX6600-Athena-LED-Controller
git clone --depth=1 --branch v2.4.0 https://github.com/unraveloop/JDC-AX6600-Athena-LED-Controller.git package/JDC-AX6600-Athena-LED-Controller

# 验证版本号
if [ -f "package/JDC-AX6600-Athena-LED-Controller/athena-led/Makefile" ]; then
  PKG_VER=$(grep 'PKG_VERSION' package/JDC-AX6600-Athena-LED-Controller/athena-led/Makefile | head -1 | cut -d'=' -f2)
  echo "✅ athena-led Makefile PKG_VERSION=${PKG_VER}"
fi

# --- 2. Harbor File ---
echo "============================================"
echo " Adding luci-app-harbor-file"
echo "============================================"
rm -rf package/luci-app-harbor-file
git clone --depth=1 https://github.com/destan19/luci-app-harbor-file package/luci-app-harbor-file

# --- 3. OpenAppFilter ---
echo "============================================"
echo " Adding OpenAppFilter"
echo "============================================"
rm -rf package/OpenAppFilter
git clone --depth 1 -b v6.1.8 https://github.com/destan19/OpenAppFilter package/OpenAppFilter

# --- 4. iStore (LuCI app store) ---
echo "============================================"
echo " Adding luci-app-store (iStore)"
echo "============================================"
rm -rf package/luci-app-store
git clone --depth=1 https://github.com/linkease/istore.git package/luci-app-store

# --- 5. Gecoos AC (集客AC控制器) ---
echo "============================================"
echo " Adding luci-app-gecoosac"
echo "============================================"
rm -rf package/luci-app-gecoosac
git clone --depth=1 https://github.com/laipeng668/luci-app-gecoosac package/luci-app-gecoosac
# 移除 openwrt feeds 自带的核心库
rm -rf feeds/packages/net/{xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,v2ray-plugin,xray-plugin,geoview,shadow-tls}
git clone https://github.com/Openwrt-Passwall/openwrt-passwall-packages package/passwall-packages

# 移除 openwrt feeds 过时的luci版本
rm -rf feeds/luci/applications/luci-app-passwall
git clone https://github.com/Openwrt-Passwall/openwrt-passwall package/passwall-luci

# --- 6. 更新并安装插件源 ---
echo "============================================"
echo " Updating and installing feeds"
echo "============================================"
./scripts/feeds update -a
./scripts/feeds install -a

echo "============================================"
echo " DIY Part 1 Complete!"
echo " Athena LED Controller: v2.4.0 (official release)"
echo " Remember to select in menuconfig:"
echo " - Utilities -> athena-led"
echo " - LuCI -> Applications -> luci-app-athena-led"
echo "============================================"
