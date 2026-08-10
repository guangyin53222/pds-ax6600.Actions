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

# === 关键修复：Makefile 里 PKG_VERSION 写的是 2.5.0，但 unraveloop 从未发布过 v2.5.0 ===
# === 真实最新版本是 v2.4.0，对应的 tar.gz 文件真实存在 ===
# === 用 sed 把两个 Makefile 的版本号从 2.5.0 改成 2.4.0 ===

echo "============================================"
echo " Patching athena-led Makefile: 2.5.0 -> 2.4.0"
echo "============================================"

# 修复 athena-led 核心包
sed -i 's/^PKG_VERSION:=2.5.0/PKG_VERSION:=2.4.0/' \
    package/JDC-AX6600-Athena-LED-Controller/athena-led/Makefile

# 修复 luci-app-athena-led 界面包
sed -i 's/^PKG_VERSION:=2.5.0/PKG_VERSION:=2.4.0/' \
    package/JDC-AX6600-Athena-LED-Controller/luci-app-athena-led/Makefile

# 确认修改结果
echo "--- athena-led/Makefile ---"
grep '^PKG_VERSION' package/JDC-AX6600-Athena-LED-Controller/athena-led/Makefile
echo "--- luci-app-athena-led/Makefile ---"
grep '^PKG_VERSION' package/JDC-AX6600-Athena-LED-Controller/luci-app-athena-led/Makefile

# === 双重保险：提前下载 v2.4.0 的 tar.gz 到 dl/ 目录 ===
# 这样即使 Makefile 的 PKG_SOURCE_URL 访问不稳定，dl/ 里已有文件就不会再下载
echo "============================================"
echo " Pre-downloading athena-led tarball to dl/"
echo "============================================"

mkdir -p dl
TARBALL="athena-led-aarch64-unknown-linux-musl-v2.4.0.tar.gz"
TARBALL_URL="https://github.com/unraveloop/JDC-AX6600-Athena-LED-Controller/releases/download/v2.4.0/${TARBALL}"

# 用 curl 下载（和 OpenWrt 构建系统一致），带重试和超时
curl -L --retry 5 --retry-delay 3 --connect-timeout 30 \
     -o "dl/${TARBALL}" "${TARBALL_URL}"

# 检查下载是否成功
if [ -f "dl/${TARBALL}" ] && [ -s "dl/${TARBALL}" ]; then
    FILESIZE=$(stat -c%s "dl/${TARBALL}" 2>/dev/null || stat -f%z "dl/${TARBALL}")
    echo "✅ Download OK: dl/${TARBALL} (${FILESIZE} bytes)"
    # 验证是有效的 gzip 文件
    if gzip -t "dl/${TARBALL}" 2>/dev/null; then
        echo "✅ File is valid gzip archive"
    else
        echo "⚠️ Warning: file may not be a valid gzip archive"
    fi
else
    echo "❌ Failed to download ${TARBALL}"
    echo "   Build will try PKG_SOURCE_URL at compile time as fallback"
fi

# --- 2. TurboACC Luci 前端（仅 fullcone/BBR 开关，不启 SFE，不覆盖 firewall4/nftables）---
rm -rf package/luci-app-turboacc
git clone --depth=1 https://github.com/mufeng05/turboacc package/turboacc-src
mkdir -p package/luci-app-turboacc
# mufeng05/turboacc 根目录下直接有 luci-app-turboacc/ 子目录
cp -r package/turboacc-src/luci-app-turboacc/* package/luci-app-turboacc/
rm -rf package/turboacc-src

# --- 3. 其余插件源 ---
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

# --- 4. 更新并安装插件源 ---
./scripts/feeds update -a
./scripts/feeds install -a
