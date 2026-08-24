# 红米 AX6000 精简完整 OpenWrt 固件

此仓库构建的是红米 AX6000 的完整 `squashfs-sysupgrade.bin`。目标是保留日常家庭网络所需服务，并避免叠加多个代理和 DNS 服务。

## 包含内容

- OpenWrt 24.10.8、LuCI 中文界面、HTTPS、TTYD
- PPPoE、Wi-Fi 驱动、firewall4/nftables、dnsmasq-full
- PassWall2、Xray、Sing-box，强制选择 nftables 透明代理路径
- AdGuard Home（管理页默认可从 `http://路由器地址:3000` 初始化）
- UPnP 与 SQM

## 明确不包含

- OpenClash、旧版 PassWall、SSR Plus+
- SmartDNS、MosDNS 及其他重复 DNS 服务
- Docker、游戏加速、内网穿透、多拨、负载均衡等非日常必需组件

## 构建和下载

1. 在 GitHub 仓库顶部选择 **Actions**。
2. 选择 **Build AX6000 clean firmware**，点击 **Run workflow**。
3. 等待任务显示绿色成功标记。首次构建通常需要较长时间。
4. 打开该任务，在页面底部下载 `ax6000-openwrt-24.10-clean-sysupgrade`。

下载内容包含 `.bin`、软件清单 `.manifest` 和校验文件 `.sha256`。

## 刷写前的安全要求

- 本镜像使用 `xiaomi_redmi-router-ax6000-stock` 布局，只适用于普通官方分区布局的红米 AX6000。
- 不保留当前配置刷写；PPPoE、Wi-Fi、PassWall2 和 AdGuard Home 均应在新系统中重新设置。
- 刷写前先从 LuCI 导出当前配置备份，且保留可用的回退固件。
- 仅在 `.manifest` 同时包含 `luci-app-passwall2`、`adguardhome`、`dnsmasq-full`、`firewall4`、`sing-box` 和 `xray-core` 时才使用该构建产物。
