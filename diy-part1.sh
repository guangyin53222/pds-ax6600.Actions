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
# Repository: https://github.com/xiaren2/JDC-AX6600-Athena-LED-Controller
# License: Apache-2.0
# Languages: Rust 77.6%, Lua 10.7%, Shell 5.9%, Makefile 2.6%
# ============================================================

echo "============================================"
echo "  Adding JDC-AX6600 Athena LED Controller"
echo "============================================"

# --- 1. 添加 Athena LED Controller (Rust核心 + LuCI界面) ---
# 从 xiaren2 的 fork 拉取（基于 unraveloop 原版修改界面）
# 包含: athena-led (Rust核心程序) + luci-app-athena-led (LuCI管理界面)

# 方式A: 直接克隆整个仓库到 package 目录
# 编译时通过各自的 Makefile 分别处理 Rust 核心和 LuCI 应用
rm -rf package/JDC-AX6600-Athena-LED-Controller
git clone --depth=1 https://github.com/xiaren2/JDC-AX6600-Athena-LED-Controller.git package/JDC-AX6600-Athena-LED-Controller

# 方式B (推荐): 分别克隆到独立目录，避免编译冲突
# Rust 核心程序 (athena-led)
#rm -rf package/athena-led
#git clone --depth=1 --single-branch \
 #   --filter=blob:none --sparse \
  #  https://github.com/xiaren2/JDC-AX6600-Athena-LED-Controller.git package/athena-led-tmp
# 上面的 sparse checkout 方式太复杂，直接用下面这个简单方式：
# (如果上面失败，用方式A即可)

# --- 2. 原有的插件源 ---
# Harbor File
rm -rf package/luci-app-harbor-file
git clone --depth=1 https://github.com/destan19/luci-app-harbor-file package/luci-app-harbor-file

# OpenAppFilter
rm -rf package/OpenAppFilter
git clone --depth 1 -b v6.1.8 https://github.com/destan19/OpenAppFilter package/OpenAppFilter

# iStore (LuCI app store)
rm -rf package/luci-app-store
git clone --depth=1 https://github.com/linkease/istore.git package/luci-app-store

# Gecoos AC (集客AC控制器)
rm -rf package/luci-app-gecoosac
git clone --depth=1 https://github.com/laipeng668/luci-app-gecoosac package/luci-app-gecoosac

# --- 3. 更新并安装插件源 ---
./scripts/feeds update -a
./scripts/feeds install -a

echo "============================================"
echo "  DIY Part 1 Complete!"
echo "  Athena LED Controller has been added."
echo "  Remember to select it in menuconfig:"
echo "    - Utilities  -> athena-led"
echo "    - LuCI -> Applications -> luci-app-athena-led"
echo "============================================"
