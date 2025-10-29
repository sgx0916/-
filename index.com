html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>雯雯小助手</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Microsoft YaHei', sans-serif;
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            min-height: 100vh;
            padding: 20px;
            display: flex;
            flex-direction: column;
            align-items: center;
            overflow: hidden;
        }
        
        .container {
            max-width: 500px;
            width: 100%;
            text-align: center;
        }
        
        h1 {
            color: #ff6b6b;
            margin-bottom: 20px;
            font-size: 1.8rem;
        }
        
        .info {
            background: white;
            padding: 20px;
            border-radius: 15px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
        
        .tip-window {
            position: fixed;
            width: 250px;
            min-height: 70px;
            border-radius: 12px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.15);
            display: flex;
            align-items: center;
            justify-content: center;
            text-align: center;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            transition: opacity 0.3s;
            z-index: 1000;
            opacity: 0.95;
            padding: 15px;
            animation: popIn 0.3s forwards;
        }
      @keyframes popIn {
            from { transform: scale(0.8); opacity: 0; }
            to { transform: scale(1); opacity: 0.95; }
        }
        
        .status {
            margin-top: 20px;
            padding: 15px;
            background: white;
            border-radius: 15px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            width: 100%;
        }
        
        .stats {
            display: flex;
            justify-content: space-around;
        }
        
        .stat-item {
            background: #f8f9fa;
            padding: 10px 15px;
            border-radius: 8px;
        }
        
        .stat-value {
            font-size: 24px;
            font-weight: bold;
            color: #007bff;
        }
        
        .footer {
            margin-top: 20px;
            color: #666;
            font-size: 0.9rem;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>💖 认错反思(雯雯版) 💖</h1>
        
        <div class="info">
            <p>雯雯，点击弹窗可提前关闭</p>
            <p>爱你小雯雯</p>
        </div>
        
        <div class="status">
            <div class="stats">
                <div class="stat-item">
                    <div>已显示</div>
                    <div id="shownCount" class="stat-value">0</div>
                </div>
                <div class="stat-item">
                    <div>当前活跃</div>
                    <div id="activeCount"
                      class="stat-value">0</div>
                </div>
            </div>
        </div>
        
        <div class="footer">
            <p>我这一次深刻意识到了自己的错误</p>
        </div>
    </div>

    <script>
        const tips = [
            '多喝水哦~', '我爱你😘', '每天都要元气满满', '记得把我拉出来哟', '保持好心情',
            '这次说话太愚蠢了', '我想你了雯雯', '保持微笑呀~', '期待下一次见面', '顺顺利利',
            '早点休息雯雯', '愿雯雯所有烦恼都消失', '别熬夜雯雯', '今天过得开心嘛雯雯', '天冷了多穿衣服雯雯',
            '记得按时吃饭雯雯', '你真的很棒雯雯', '保持乐观心态雯雯', '适当运动一下雯雯', '记得休息眼睛雯雯',
            '请给我一次机会嘛雯雯', '一切都会好起来的', '对自己好一点雯雯', '深呼吸，放松', '😜😜😜'
        ];
        
        const bgColors = [
            '#FFB6C1', '#87CEEB', '#98FB98', '#E6E6FA', '#FFFACD',
            '#DDA0DD', '#FF7F50', '#FFE4C4', '#7FFFD4', '#FFE4E1',
            '#E0FFFF', '#FFDAB9', '#D8BFD8', '#F5DEB3', '#F0FFF0'
        ];
      let activeWindows = 0;
        let totalShown = 0;
        let maxWindows = 5;
        let intervalTime = 150;
        let duration = 300;
        let timer = null;
        
        // 页面加载后自动启动
        window.addEventListener('load', startTips);
        
        // 页面关闭前清理资源
        window.addEventListener('beforeunload', stopTips);
        
        function startTips() {
            // 立即创建第一个弹窗
            createTipWindow();
            
            // 设置定时器持续创建弹窗
            timer = setInterval(() => {
                // 如果活跃窗口数量小于最大限制，创建新窗口
                if (activeWindows < maxWindows) {
                    createTipWindow();
                }
            }, intervalTime);
        }
        
        function stopTips() {
            if (timer) {
                clearInterval(timer);
                timer = null;
            }
            
            // 清除所有弹窗
            document.querySelectorAll('.tip-window').forEach(window => {
                window.remove();
            });
        }
        
        function createTipWindow() {
            const screenWidth = window.innerWidth;
            const screenHeight = window.innerHeight;
            const winWidth = 250;
            const winHeight = 80;
            
            // 随机位置，确保不会超出屏幕
            const x = Math.max(10, Math.random() * (screenWidth - winWidth - 20));
            const y = Math.max(10, Math.random() * (screenHeight - winHeight - 20));
            
            // 创建提示窗口元素
            const tipWindow = document.createElement('div');
            tipWindow.className = 'tip-window';
            tipWindow.style.left = `${x}px`;
            tipWindow.style.top = `${y}px`;
            tipWindow.style.backgroundColor = bgColors[Math.floor(Math.random() * bgColors.length)];
            
            // 随机选择提示语
            const tipText = tips[Math.floor(Math.random() * tips.length)];
            tipWindow.textContent = tipText;
            
            // 添加到页面
            document.body.appendChild(tipWindow);
            
            activeWindows++;
            totalShown++;
            updateStats();
            
            // 点击关闭
            tipWindow.addEventListener('click', () => {
                removeTipWindow(tipWindow);
            });
          // 自动关闭
            setTimeout(() => {
                if (tipWindow.parentNode) {
                    removeTipWindow(tipWindow);
                }
            }, duration);
        }
        
        function removeTipWindow(tipWindow) {
            tipWindow.style.opacity = '0';
            setTimeout(() => {
                if (tipWindow.parentNode) {
                    document.body.removeChild(tipWindow);
                    activeWindows--;
                    updateStats();
                }
            }, 300);
        }
        
        function updateStats() {
            document.getElementById('shownCount').textContent = totalShown;
            document.getElementById('activeCount').textContent = activeWindows;
        }
    </script>
</body>
</html>
