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

## ✨ 修改telegram文字提示

1. 打开脚本进行编辑
在你的 VPS 终端中输入以下命令：

```bash
nano /opt/bwg_monitor/bwg_monitor.py
```

2. 找到修改信息的位置
使用键盘方向键往下滚动，找到代码里的 message = ( 这一块。你可以随意修改引号里面的中文、符号或者增加新的行。例如：

```bash
message = (
            f"🚀 **Tim 的专属 VPS 流量播报**\n"  # 比如修改了标题
            f"--- \n"
            f"📈 当前用量: {used_bw:.2f} GB\n"
            f"🚩 总计流量: {total_bw:.0f} GB\n"
            f"🔄 使用比例: {percentage:.2f}%\n"
            f"--- \n"
            f"🗓 下次重置: {reset_date.strftime('%Y-%m-%d')} ({reset_source})\n"
            f"⏳ 剩余时间: {days_left} 天\n"
            f"💡 记得去看看网站的 Google Search Console 数据！\n" # 比如增加了一行自定义提醒
        )
```

💡 小提示：在 Telegram 的 Markdown 语法中，\n 代表换行，用双星号包裹的 文字 代表加粗。

3. 保存并退出
修改满意后，依次按下快捷键：

按 Ctrl + O （保存文件）

按 Enter （确认当前文件名）

按 Ctrl + X （退出 nano 编辑器）

4. 手动运行测试
修改完成后，直接在终端里输入下面这行命令运行脚本：

```bash
python3 /opt/bwg_monitor/bwg_monitor.py
```
终端如果打印出 Telegram 消息推送成功！，你就可以立刻在手机上查看修改后的排版效果了。如果不满意，重复上面几个步骤继续改即可。

最棒的一点是：因为系统每天的定时任务（Crontab）就是直接运行这个 .py 文件，所以只要你修改并测试成功，明天以及以后的自动推送，就会自动采用你最新修改的格式，你不需要去动任何关于定时任务的设置！
