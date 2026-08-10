# 🔥 PDS-AX6600 OpenWrt 自动构建

> 基于 [LibWrt](https://github.com/LiBwrt/LibWrt) `25.12-nss` 分支，针对 **京东云雅典娜 AX6600 (JDCloud RE-CS-02)** 的 GitHub Actions 自动编译方案。

## ✨ 固件特性

| 功能 | 说明 |
|---|---|
| 🚀 NSS 硬件加速 | Qualcomm NSS 全栈加速，转发性能拉满 |
| 🌐 TurboACC | Fullcone NAT + BBR，游戏/下载友好 |
| 🏮 Athena LED | 京东云雅典娜 LED 灯效控制（农历/日出日落/MQTT/温度告警） |
| 📦 iStore | 应用商店，一键安装插件 |
| 💾 磁盘管理 | Samba4 + diskman + btrfs + smartmontools |
| 🔒 应用过滤 | OpenAppFilter 应用层管控 |
| 📡 ZeroTier | 内网穿透 |
| 🎮 集客 AC | Gecoos AC 控制器 |
| ⏰ 定时重启 | autoreboot 计划任务 |
| 🌡️ CPU 调频 | cpufreq 调度策略管理 |
| 📊 实时监控 | htop + ttyd 终端 |

## 📋 硬件信息

| 项目 | 参数 |
|---|---|
| 设备代号 | JDCloud RE-CS-02 (Athena / 雅典娜) |
| SoC | Qualcomm IPQ6018 (ARM Cortex-A53) |
| 架构 | aarch64_cortex-a53 |
| 无线 | 2.4G + 5G (ath11k) + IoT 2.4G |
| 闪存 | eMMC 8GB |
| 内存 | 1GB / 2GB DDR3 |
| 网口 | 1×2.5G + 3×1G |

## 🛠️ 使用方式

### 自动编译

1. **Fork 本仓库**
2. 修改 `.config` 调整你需要的功能（或直接用现有的）
3. 进入 **Actions → OpenWrt Builder**
4. 点击 **Run workflow**
5. 等待约 **1.5~2 小时**（首次）/ **25~40 分钟**（增量，ccache 命中）
6. 到 **Releases** 页面下载 `factory.bin` 或 `sysupgrade.bin`

### 手动清缓存

如果编译遇到诡异错误，可以强制清缓存重编：

1. 进入 **Actions → OpenWrt Builder**
2. 点击 **Run workflow**
3. 在 `cache_bust` 输入框填 `true`
4. 点击绿色按钮 → 全新编译（约 2 小时）

## 📥 刷机指南

### ⚠️ 刷机前必读

> **京东云雅典娜必须先刷大分区 GPT + U-Boot，否则无法启动第三方固件！**

### 刷机步骤

1. **开启 SSH**
   - 参考 [京东云雅典娜 SSH 开启教程](https://github.com/glk17/jdcloud-1)

2. **备份原厂分区**
   ```bash
   # 在路由器 SSH 里执行
   dd if=/dev/mmcblk0 of=/tmp/backup-emmc.img bs=1M
   # 下载 backup-emmc.img 到电脑保存
   ```

3. **刷入大分区 GPT**
   - 下载社区维护的 2GB rootfs GPT 镜像
   - 通过 U-Boot Web (192.168.1.1) 上传

4. **刷入 OpenWrt**
   - U-Boot 中选择 `*-factory.bin`
   - 等待自动重启

5. **首次启动**
   - 默认 IP: `192.168.100.1`
   - 默认无密码，请首次登录后立即设置

### 升级（已刷过 OpenWrt）

- 在 LuCI → 系统 → 备份/升级 中上传 `*-sysupgrade.bin`
- 勾选「保留配置」可保留现有设置

## 📁 仓库结构

```
pds-ax6600.Actions/
├── .github/
│   └── workflows/
│       └── openwrt-builder.yml    # GitHub Actions 工作流
├── files/                         # 自定义文件（会打包进固件）
├── prebuilt/                      # 预编译文件
├── .config                        # OpenWrt 编译配置
├── diy-part1.sh                   # DIY 脚本：添加插件源
├── diy-part2.sh                   # DIY 脚本：修改默认设置
├── LICENSE
└── README.md
```

## 🔧 自定义说明

### 添加/删除插件

编辑 `.config` 文件：
- 添加：`CONFIG_PACKAGE_插件名=y`
- 删除：`# CONFIG_PACKAGE_插件名 is not set`

### 修改默认设置

编辑 `diy-part2.sh`：
- 默认 IP、主题、主机名等都在这改

### 添加新插件源

编辑 `diy-part1.sh`：
- 在 `./scripts/feeds update -a` 之前加入 `git clone` 命令

## ⚙️ 技术细节

### ccache 缓存加速

- 缓存目录：`.ccache/`（2GB 上限）
- Cache Key：基于 `.config` 文件哈希
- 增量编译命中率通常 40%~70%
- 首次编译 ~2h → 后续增量 ~25-40min

### NSS 加速注意事项

以下模块**已禁用**（与 NSS 冲突，不要开启）：
- ❌ `kmod-shortcut-fe`
- ❌ `kmod-fast-classifier`
- ❌ `kmod-nft-offload`
- ❌ `kmod-ipt-fullconenat`

已启用（NSS 兼容）：
- ✅ `kmod-nft-fullcone`（Fullcone NAT）
- ✅ `kmod-tcp-bbr`（BBR 拥塞控制）
- ✅ `luci-app-turboacc`（TurboACC 界面）

## 📜 License

MIT License

## 🙏 致谢

- [LibWrt](https://github.com/LiBwrt/LibWrt) - NSS 分支源码
- [P3TERX/Actions-OpenWrt](https://github.com/P3TERX/Actions-OpenWrt) - 工作流模板
- [xiaren2/JDC-AX6600-Athena-LED-Controller](https://github.com/xiaren2/JDC-AX6600-Athena-LED-Controller) - LED 控制器
- [coolsnowwolf/lede](https://github.com/coolsnowwolf/lede) - 插件来源
- [Microsoft Azure](https://azure.microsoft.com/) - GitHub Actions 运行环境
