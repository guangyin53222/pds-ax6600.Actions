========================================================
  athena-led 编译 404 问题修复说明
========================================================

【问题根因】
  athena-led/Makefile 和 luci-app-athena-led/Makefile 里
  写的是 PKG_VERSION:=2.5.0
  
  但 unraveloop 官方 GitHub Releases 从未发布过 v2.5.0！
  真实最新版本是 v2.4.0（2026-07-07 发布）

  所以构建系统去下载：
    athena-led-aarch64-unknown-linux-musl-v2.5.0.tar.gz
  全部返回 404 → 编译失败

【修复方法】
  diy-part1.sh 在克隆仓库后，自动用 sed 把：
    PKG_VERSION:=2.5.0  →  PKG_VERSION:=2.4.0
  
  同时提前 curl 下载 v2.4.0 的 tar.gz 到 dl/ 目录做双重保险

【v2.4.0 真实存在的文件】
  ✅ athena-led-aarch64-unknown-linux-musl-v2.4.0.tar.gz (1.95MB)
  ✅ athena-led-aarch64-unknown-linux-musl-v2.4.0.tar.gz.sha256
  ✅ athena-led-2.4.0-r1.apk
  ✅ athena-led_2.4.0-1_aarch64_cortex-a53.ipk
  ✅ luci-app-athena-led-2.4.0-r1.apk
  ✅ luci-app-athena-led_2.4.0-1_all.ipk

【使用方法】
  1. 用本目录的 diy-part1.sh 替换你仓库根目录的同名文件
  2. git add . && git commit -m "fix: athena-led 版本号 2.5.0→2.4.0" && git push
  3. GitHub Actions → OpenWrt Builder → Run workflow

【v2.4.0 新增功能（比旧版好很多）】
  🏮 农历显示（L:五月初七）
  🌅 日出日落时间
  📨 MQTT 消息推送
  🔥 温度告警插播
  🎛️ 运行时控制接口（nc 127.0.0.1 8377）
  👆 按键双击回到频道1
  天气/网速/动画等全部模块优化

【注意事项】
  - 不要改成 1.0.5！那个是老版本，天气等功能有 bug
  - v2.4.0 是目前最新最稳定版本
  - PKG_HASH:=skip 保持不变即可，不需要改
