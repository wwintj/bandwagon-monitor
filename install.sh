#!/bin/bash

# ====================================================
# BandwagonHost (搬瓦工) 流量监控 Telegram 推送一键脚本
# ====================================================

echo "========================================================="
echo "欢迎使用 BandwagonHost 流量监控 Telegram 播报一键部署脚本"
echo "========================================================="
echo ""

# 1. 提示用户输入配置信息
read -p "请输入您的 搬瓦工 VEID: " VEID
read -p "请输入您的 搬瓦工 API KEY: " API_KEY
read -p "请输入您的 Telegram Bot Token: " TG_TOKEN
read -p "请输入您的 Telegram Chat ID: " CHAT_ID

echo ""
echo "--- 定时任务设置 ---"
read -p "请设置每天发送提醒的 [小时] (0-23, 例如早上9点输入 9): " CRON_HOUR
read -p "请设置每天发送提醒的 [分钟] (0-59, 例如半点输入 30): " CRON_MINUTE

echo ""
echo "--- 时区设置 ---"
echo "搬瓦工的流量重置通常以洛杉矶时间 (UTC-8) 为准。"
read -p "请输入时区偏移量 (直接回车默认使用 -8): " TZ_OFFSET
TZ_OFFSET=${TZ_OFFSET:--8}

# 2. 定义安装路径
INSTALL_DIR="/opt/bwg_monitor"
SCRIPT_PATH="${INSTALL_DIR}/bwg_monitor.py"

# 创建目录
mkdir -p ${INSTALL_DIR}

# 3. 生成 Python 脚本（已修复 403 拦截问题）
cat << EOF > ${SCRIPT_PATH}
import urllib.request
import urllib.parse
import json
from datetime import datetime, timezone, timedelta

# === 配置注入 ===
VEID = '${VEID}'
API_KEY = '${API_KEY}'
TG_TOKEN = '${TG_TOKEN}'
CHAT_ID = '${CHAT_ID}'
TZ_OFFSET = ${TZ_OFFSET}

def get_bwg_info():
    url = f"https://api.64clouds.com/v1/getServiceInfo?veid={VEID}&api_key={API_KEY}"
    try:
        # 加入 User-Agent 伪装，突破 403 拦截
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
        }
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode('utf-8'))
        
        # 将字节转换为 GB
        total_bw = data['plan_monthly_data'] / (1024**3)
        used_bw = data['data_counter'] / (1024**3)
        
        # 处理时区与重置日期
        tz = timezone(timedelta(hours=TZ_OFFSET))
        reset_day = datetime.fromtimestamp(data['data_next_reset'], tz).strftime('%Y-%m-%d')
        
        percentage = (used_bw / total_bw) * 100
        
        message = (
            f"📊 **VPS 流量监控报告**\n"
            f"--- \n"
            f"📈 当前用量: {used_bw:.2f} GB\n"
            f"🚩 总计流量: {total_bw:.0f} GB\n"
            f"🔄 使用比例: {percentage:.2f}%\n"
            f"🗓 重置日期: {reset_day} (UTC{TZ_OFFSET:+d})\n"
        )
        
        send_telegram(message)
    except Exception as e:
        print(f"获取数据失败: {e}")

def send_telegram(text):
    url = f"https://api.telegram.org/bot{TG_TOKEN}/sendMessage"
    data = urllib.parse.urlencode({
        "chat_id": CHAT_ID,
        "text": text,
        "parse_mode": "Markdown"
    }).encode('utf-8')
    
    try:
        # Telegram 请求同样加上 headers 更稳妥
        headers = {'User-Agent': 'Mozilla/5.0'}
        req = urllib.request.Request(url, data=data, headers=headers)
        with urllib.request.urlopen(req) as response:
            print("Telegram 消息推送成功！")
    except Exception as e:
        print(f"Telegram 推送失败: {e}")

if __name__ == "__main__":
    get_bwg_info()
EOF

# 赋予执行权限
chmod +x ${SCRIPT_PATH}

# 4. 设置 Crontab 定时任务
crontab -l 2>/dev/null | grep -v "${SCRIPT_PATH}" > /tmp/current_cron
echo "${CRON_MINUTE} ${CRON_HOUR} * * * /usr/bin/python3 ${SCRIPT_PATH} >> ${INSTALL_DIR}/cron.log 2>&1" >> /tmp/current_cron
crontab /tmp/current_cron
rm /tmp/current_cron

echo ""
echo "========================================================="
echo "✅ 部署完成！"
echo "👉 Python 脚本已保存至: ${SCRIPT_PATH}"
echo "👉 定时任务已设置: 每天 ${CRON_HOUR}:${CRON_MINUTE} 自动执行"
echo "========================================================="
echo "正在为您进行一次立即推送测试..."
/usr/bin/python3 ${SCRIPT_PATH}
