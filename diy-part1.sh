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
# 通用设置
# ============================================================
set -e

# 全局 Git 优化（防 CI clone 超时）
git config --global http.postBuffer 524288000
git config --global http.lowSpeedLimit 1000
git config --global http.lowSpeedTime 600

# ============================================================
# 1. JDC AX6600 Athena LED Controller
# 官方源: https://github.com/unraveloop/JDC-AX6600-Athena-LED-Controller
# 锁定版本: v2.4.0（官方已发布的稳定版，有预编译 Rust 二进制）
# 注意: main 分支已到 v2.5.0，但 release 尚未发布，直接编会 404
# ============================================================
echo "============================================"
echo " Adding JDC-AX6600 Athena LED Controller"
echo "============================================"

rm -rf package/JDC-AX6600-Athena-LED-Controller
git clone --depth=1 --branch v2.4.0 \
  https://github.com/unraveloop/JDC-AX6600-Athena-LED-Controller.git \
  package/JDC-AX6600-Athena-LED-Controller

# 验证版本号
if [ -f "package/JDC-AX6600-Athena-LED-Controller/athena-led/Makefile" ]; then
  PKG_VER=$(grep 'PKG_VERSION' \
    package/JDC-AX6600-Athena-LED-Controller/athena-led/Makefile \
    | head -1 | cut -d'=' -f2)
  echo "✅ athena-led Makefile PKG_VERSION=${PKG_VER}"
else
  echo "❌ athena-led Makefile not found! Abort."
  exit 1
fi

# ============================================================
# 2. Harbor File（文件管理器）
# ============================================================
echo "============================================"
echo " Adding luci-app-harbor-file"
echo "============================================"
rm -rf package/luci-app-harbor-file
git clone --depth=1 \
  https://github.com/destan19/luci-app-harbor-file \
  package/luci-app-harbor-file

# ============================================================
# 3. OpenAppFilter（应用过滤 / 家长控制）
# ============================================================
echo "============================================"
echo " Adding OpenAppFilter"
echo "============================================"
rm -rf package/OpenAppFilter
git clone --depth=1 --branch v6.1.8 \
  https://github.com/destan19/OpenAppFilter \
  package/OpenAppFilter

# ============================================================
# 4. iStore（软件中心）— 官方推荐 feeds 方式
# ============================================================
echo "============================================"
echo " Adding iStore (luci-app-store)"
echo "============================================"
if ! grep -q "istore" feeds.conf.default; then
  echo "" >> feeds.conf.default
  echo "src-git istore https://github.com/linkease/istore;main" >> feeds.conf.default
fi

# ============================================================
# 5. Gecoos AC（集客 AC 控制器）
# ============================================================
echo "============================================"
echo " Adding luci-app-gecoosac"
echo "============================================"
rm -rf package/luci-app-gecoosac
git clone --depth=1 \
  https://github.com/laipeng668/luci-app-gecoosac \
  package/luci-app-gecoosac

# ============================================================
# 6. PassWall（核心 + LuCI）— 官方推荐双 feeds
# 官方源: https://github.com/Openwrt-Passwall/openwrt-passwall
# ============================================================
echo "============================================"
echo " Adding PassWall feeds"
echo "============================================"

# 添加 PassWall 双 feeds（luci + 核心包分开维护）
if ! grep -q "openwrt-passwall" feeds.conf.default; then
  echo "" >> feeds.conf.default
  echo "src-git passwall https://github.com/Openwrt-Passwall/openwrt-passwall;main" >> feeds.conf.default
  echo "src-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages;main" >> feeds.conf.default
fi

# 删除 feeds 中过时的 luci-app-passwall（防止与自建 feed 冲突）
rm -rf feeds/luci/applications/luci-app-passwall

# ============================================================
# 7. OpenClash（Mihomo/Clash 客户端）
# 官方源: https://github.com/vernesong/OpenClash
# 锁定版本: v0.47.156（官方已发布 tag）
# ============================================================
echo "============================================"
echo " Adding OpenClash v0.47.156"
echo "============================================"

# 方式：精确锁定 v0.47.156 tag（你指定要这个版本）
rm -rf package/luci-app-openclash
git clone --depth=1 --branch v0.47.156 \
  https://github.com/vernesong/OpenClash.git \
  package/luci-app-openclash

# OpenClash 仓库根目录下真正可编译的包在 luci-app-openclash/ 子目录
# 把子目录内容提到顶层，并清理 .git，避免 feeds 混乱
mv package/luci-app-openclash/luci-app-openclash/* package/luci-app-openclash/ 2>/dev/null || true
rm -rf package/luci-app-openclash/.git

echo "✅ OpenClash v0.47.156 added"

# ============================================================
# 8. 更新并安装 feeds
# ============================================================
echo "============================================"
echo " Updating and installing feeds"
echo "============================================"
./scripts/feeds update -a

# 分层安装，避免一次性拉入不兼容包
./scripts/feeds install -a -p passwall
./scripts/feeds install -a -p passwall_packages
./scripts/feeds install -a -p istore

# 兜底安装关键包（防止漏选）
./scripts/feeds install luci-app-store
./scripts/feeds install luci-app-passwall
./scripts/feeds install luci-app-openclash

echo "============================================"
echo " DIY Part 1 Complete!"
echo "============================================"
echo " menuconfig 必选项："
echo " - Utilities -> athena-led"
echo " - LuCI -> Applications -> luci-app-athena-led"
echo " - LuCI -> Applications -> luci-app-store"
echo " - LuCI -> Applications -> luci-app-passwall"
echo " - LuCI -> Applications -> luci-app-openclash"
echo " - LuCI -> Applications -> luci-app-harbor-file"
echo " - LuCI -> Applications -> luci-app-gecoosac"
echo " - LuCI -> Applications -> luci-app-oaf"
echo " - Base system -> dnsmasq-full (替换 dnsmasq)"
echo " - Network -> Firewall -> ipset"
echo " - Kernel modules -> Network Support -> kmod-tun"
echo " - Kernel modules -> Netfilter Extensions -> kmod-nft-tproxy"
echo "============================================"
