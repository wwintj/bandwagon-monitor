# BandwagonHost (搬瓦工) 流量监控与 Telegram 推送

这是一个轻量级的一键部署脚本，用于自动获取搬瓦工 VPS 的流量使用情况，并通过 Telegram 机器人定时推送提醒。

## ✨ 特性

- **零依赖**：仅使用 Python3 原生库，无需安装 `pip` 或任何第三方包（如 `requests`）。
- **时区智能转换**：自动处理搬瓦工 API 的时间戳，可自定义时区，重置日期显示更准确。
- **一键自动化**：交互式配置，自动生成执行脚本并配置 Linux Crontab 定时任务。

## 🛠️ 准备工作

在运行脚本之前，请准备好以下 4 个参数：
1. **VEID**: 搬瓦工 KiwiVM 面板获取。
2. **API KEY**: 搬瓦工 KiwiVM 面板获取。
3. **Telegram Bot Token**: 通过 `@BotFather` 获取。
4. **Telegram Chat ID**: 通过 `@userinfobot` 获取。

## 🚀 一键安装

使用 root 用户登录你的任意一台 Linux 服务器（不限制必须是搬瓦工本机），运行以下命令：

```bash
wget -O bwg-monitor.sh https://raw.githubusercontent.com/wwintj/bandwagon-monitor/main/bwg-monitor.sh && bash bwg-monitor.sh
```

运行后，根据终端提示输入上述的 4 个参数以及你期望的定时推送时间即可。

## 🗑️ 一键卸载

如果你想移除该监控脚本及相关的定时任务，请在服务器上运行以下命令：

```bash
rm -rf /opt/bwg_monitor && crontab -l | grep -v "/opt/bwg_monitor/bwg_monitor.py" | crontab - && rm -f bwg-monitor.sh
```
