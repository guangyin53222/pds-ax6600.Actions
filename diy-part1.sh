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

# --- 1. JDC AX6600 Athena LED Controller ---
# 包含 athena-led (核心驱动) + luci-app-athena-led (Web 界面) 两个包
# 仓库子目录各自有独立 Makefile，feeds 会递归扫描自动发现
rm -rf package/JDC-AX6600-Athena-LED-Controller
git clone --depth=1 https://github.com/unraveloop/JDC-AX6600-Athena-LED-Controller package/JDC-AX6600-Athena-LED-Controller

# --- 2. 其余插件源 ---
# Harbor File
rm -rf package/luci-app-harbor-file
git clone --depth=1 https://github.com/destan19/luci-app-harbor-file package/luci-app-harbor-file

# OpenAppFilter
rm -rf package/OpenAppFilter
git clone --depth 1 -b v6.1.8 https://github.com/destan19/OpenAppFilter package/OpenAppFilter

# iStore (LuCI app store)
rm -rf package/luci-app-store
git clone --depth=1 https://github.com/linkease/istore.git package/luci-app-store

# Gecoos AC (集客 AC 控制器)
rm -rf package/luci-app-gecoosac
git clone --depth=1 https://github.com/laipeng668/luci-app-gecoosac package/luci-app-gecoosac

# --- 3. 更新并安装插件源 ---
./scripts/feeds update -a
./scripts/feeds install -a
