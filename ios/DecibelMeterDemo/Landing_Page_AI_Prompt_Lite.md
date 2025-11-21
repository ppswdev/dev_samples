# Landing Page AI生成提示词（精简版）

## 🎯 任务：为iOS专业分贝测量仪应用生成多语言Landing Page

---

## 🌍 国际化要求（重要！）

### 支持的语言

网页必须支持以下19种语言的完整国际化，所有文案、按钮、标题都需要翻译：

- **ar** - العربية (阿拉伯语)
- **de** - Deutsch (德语)
- **en** - English (英语) **[默认语言]**
- **es** - Español (西班牙语)
- **fil** - Filipino (菲律宾语)
- **fr** - Français (法语)
- **id** - Bahasa Indonesia (印尼语)
- **it** - Italiano (意大利语)
- **ja** - 日本語 (日语)
- **ko** - 한국어 (韩语)
- **pl** - Polski (波兰语)
- **pt** - Português (葡萄牙语)
- **ru** - Русский (俄语)
- **th** - ไทย (泰语)
- **tr** - Türkçe (土耳其语)
- **vi** - Tiếng Việt (越南语)
- **zh_Hans** - 简体中文
- **zh_Hant** - 繁體中文

### 国际化实现要求

1. **语言切换器**
   - 在页面右上角放置语言选择下拉菜单
   - 显示国旗图标 + 语言名称
   - 切换后立即更新页面所有文本
   - 记住用户选择（localStorage）

2. **默认语言**
   - 默认显示英语（en）
   - 根据浏览器语言自动检测并切换到对应语言（如果支持）
   - 如果浏览器语言不支持，回退到英语

3. **需要翻译的内容**
   - 所有标题和副标题
   - 所有按钮文案（CTA按钮）
   - 功能描述和卡片内容
   - 应用场景说明
   - FAQ问答
   - 用户评价
   - 定价方案内容
   - 页脚链接和版权信息

4. **技术实现建议**
   - 使用 i18next 或 react-intl 库
   - 或使用原生JavaScript对象存储翻译
   - JSON格式存储各语言翻译文件
   - 支持RTL布局（阿拉伯语）

5. **本地化注意事项**
   - 价格根据地区调整货币符号（¥/$/€等）
   - 日期格式根据地区调整
   - 职业健康标准根据地区突出相应标准
   - 用户评价使用对应语言的真实姓名

---

## 📱 应用信息

**应用名称**: Professional Decibel Meter / 专业分贝测量仪

**定位**: 符合IEC 61672-1国际标准的专业级iOS分贝计和噪音剂量计

**核心价值**: 为环境噪声监测、职业健康评估和声学研究提供精准测量解决方案

---

## 👥 目标用户

1. 职业健康与安全专家
2. 环境工程师  
3. 声学工程师
4. 科研人员
5. 工业检测人员
6. 普通用户（日常噪声监测）

---

## ✨ 核心功能（必须展示）

### 1. 多种频率权重

- **A/B/C/Z权重** + **ITU-R 468标准**
- 适配各种专业测量场景

### 2. 时间权重响应

- **Fast** (快速 - 125ms)
- **Slow** (慢速 - 1s)
- **Impulse** (脉冲 - 35ms)

### 3. 实时测量指标

- 实时dB值（精确到0.1dB）
- LEQ（等效连续声级）
- MIN/MAX/PEAK（最小/最大/峰值）

### 4. 四大专业图表

- **时间历程图** - 60秒实时分贝曲线
- **频谱分析** - 1/1和1/3倍频程
- **统计分布图** - L10/L50/L90百分位数
- **LEQ趋势图** - 累积等效声级趋势

### 5. 噪音剂量计（职业健康）

支持5种国际职业健康标准：

- 中国 GBZ 2.2 (85dB, 8h)
- OSHA (90dB, 8h)
- NIOSH (85dB, 8h)
- ISO 9612
- 欧盟 2003/10/EC (87dB, 8h)

功能包括：

- 噪声剂量百分比实时监测
- TWA（8小时时间加权平均）计算
- 允许暴露时长表
- 五级风险评估

### 6. 音频录制与回放

- 测量时同步录制环境音
- 录音与分贝数据完全同步
- 支持回放时查看原始测量数据

### 7. 精准校准

- 支持标准声源校准（94dB@1kHz）
- ±0.1dB精度调整
- 快速调整和精细滑块

---

## 🎨 应用场景（6个场景卡片）

### 🌳 1. 环境噪声监测

**描述**: 城市环境噪声评估、社区噪声投诉调查、公园绿地噪声监测  
**适用用户**: 环境工程师、城市规划师、物业管理  
**关键功能**: A权重测量、LEQ计算、长时间监测

### 🏭 2. 职业健康评估

**描述**: 工厂车间噪声监测、职业暴露评估、听力保护项目  
**适用用户**: 职业健康专家、安全工程师、企业EHS  
**关键功能**: 噪音剂量计、TWA计算、多标准支持

### 🏗️ 3. 建筑声学测试

**描述**: 建筑隔音性能测试、室内声学设计验证、HVAC噪声检测  
**适用用户**: 建筑声学工程师、室内设计师、建筑检测机构  
**关键功能**: 频谱分析、1/3倍频程、统计分布

### 🔧 4. 产品噪声测试

**描述**: 家电噪声检测、机械设备噪声评估、产品质量控制  
**适用用户**: 产品工程师、质量检测员、研发团队  
**关键功能**: PEAK测量、频谱分析、音频录制

### 🔬 5. 科学研究

**描述**: 声学实验、环境研究、教学演示  
**适用用户**: 科研人员、大学师生、实验室  
**关键功能**: 多标准支持、数据导出、精准校准

### 🏠 6. 日常生活

**描述**: 家居环境监测、听力保护、噪音投诉取证  
**适用用户**: 普通用户、家长、业主  
**关键功能**: 简单直观、实时显示、等级说明

---

## 🎨 设计风格

### 视觉关键词

Professional（专业）、Precise（精准）、Technical（技术）、Modern（现代）、Clean（简洁）、Trustworthy（可信赖）

### 颜色方案

**主色调**:

- 主色: `#007AFF` (iOS系统蓝) - 专业、科技、可信赖
- 辅助色: `#34C759` (绿色) - 安全、正常
- 警告色: `#FF9500` (橙色) - 注意、警告
- 危险色: `#FF3B30` (红色) - 危险、高风险

**分贝等级渐变色**:

- 0-50dB: `#34C759` (绿色) - 安静舒适
- 50-70dB: `#FFCC00` (黄色) - 正常环境
- 70-85dB: `#FF9500` (橙色) - 较大噪声
- 85-100dB: `#FF3B30` (红色) - 有害噪声
- 100+dB: `#AF52DE` (紫色) - 危险噪声

---

## 📐 Landing Page 结构（10个Section）

---

### 1️⃣ Hero Section（第一屏）

**主标题**: Professional Decibel Meter - Precise · Reliable · Standards Compliant  
（专业级分贝测量仪 - 精准·可靠·符合国际标准）

**副标题**: Laboratory-grade noise measurement solution for environmental monitoring, occupational health, and acoustic research.  
Support for multiple international standards | Real-time data analysis | Professional chart visualization  
（为环境监测、职业健康、声学研究提供实验室级别的噪声测量解决方案
支持多种国际标准 | 实时数据分析 | 专业图表可视化）

**CTA按钮**:

- 主按钮: "Download on App Store" / "免费下载 - App Store" (大号蓝色按钮)
- 次按钮: "Watch Demo" / "观看演示视频" (透明边框按钮)

**Hero图片**:

- iPhone 14 Pro mockup展示应用主界面
- 屏幕显示大号分贝值（例如：72.5 dB(A)F）
- 带有颜色鲜明的等级指示和波形曲线
- 背景：科技感蓝色渐变或粒子效果

**信任标识**（4个徽章横排）:

- ✓ IEC 61672-1 Compliant / 符合 IEC 61672-1 标准
- ✓ iOS 15.0+ Support / iOS 15.0+ 支持
- ✓ ⭐⭐⭐⭐⭐ 4.8 Rating / 4.8分评分
- ✓ 30,000+ Users / 30,000+ 专业用户

**语言切换器**: 在右上角显示当前语言和下拉菜单

---

### 2️⃣ Features Section（核心功能区）

**标题**: Comprehensive Professional Features / 专业功能，一应俱全

**6个功能卡片（3x2网格或响应式调整）**:

#### 卡片1: 多标准支持

- 图标: ⚙️ 或设置齿轮图标
- 标题: Five Frequency Weightings / 五种频率权重
- 描述: dB-A/B/C/Z and ITU-R 468 standards for all measurement scenarios / dB-A/B/C/Z 和 ITU-R 468，适配各种测量场景

#### 卡片2: 实时精准测量

- 图标: 📊 或波形图标
- 标题: Real-time Precision Measurement / 实时高精度测量
- 描述: 0.1dB precision, Fast/Slow/Impulse response, comprehensive LEQ/MIN/MAX/PEAK metrics / 0.1dB精度，Fast/Slow/Impulse响应，LEQ/MIN/MAX/PEAK全指标

#### 卡片3: 专业图表分析

- 图标: 📈 或图表图标
- 标题: Four Professional Analysis Charts / 四种专业分析图表
- 描述: Time history, spectrum analysis, statistical distribution, LEQ trends for deep noise insights / 时间历程、频谱分析、统计分布、LEQ趋势，深度洞察噪声特征

#### 卡片4: 职业健康监测

- 图标: 🏭 或安全帽图标
- 标题: Noise Dosimeter / 噪音剂量计
- 描述: Support for 5 international occupational health standards, TWA calculation, exposure duration table, risk assessment / 支持5种国际职业健康标准，TWA计算，暴露时长表，风险评估

#### 卡片5: 音频录制

- 图标: 🎙️ 或麦克风图标
- 标题: Synchronized Audio Recording / 同步音频录制
- 描述: Record audio during measurement, playback analysis support, fully correlated data / 测量时同步录音，支持回放分析，数据完全关联

#### 卡片6: 精准校准

- 图标: 🎯 或靶心图标
- 标题: Professional Calibration / 专业校准功能
- 描述: Standard sound source calibration support, ±0.1dB precision adjustment, ensuring measurement accuracy / 支持标准声源校准，±0.1dB精度调整，确保测量准确性

**设计要求**:

- 卡片悬停时轻微上浮 + 阴影加深
- 图标使用统一风格
- 背景白色卡片，圆角设计

---

### 3️⃣ Use Cases Section（应用场景区）

**标题**: Wide Range of Applications / 广泛应用场景，满足多元需求

**6个场景卡片（左右交替布局或网格）**:

每个场景卡片包含：

- Emoji图标
- 场景标题（英文/中文）
- 描述（1-2句话）
- 适用用户类型
- 关键功能列表
- 配图或插画

展示上面定义的6个应用场景（环境噪声监测、职业健康评估、建筑声学测试、产品噪声测试、科学研究、日常生活）

**设计要求**:

- 场景插画采用扁平化2.5D风格
- 奇数项左图右文，偶数项左文右图（桌面端）
- 移动端堆叠布局

---

### 4️⃣ Interface Showcase（界面展示区）

**标题**: Professional Interface, Simple to Use / 专业界面，简洁易用

**5张界面截图（横向滚动卡片或网格）**:

1. **主测量界面**
   - 大号分贝显示（72.5 dB）
   - 等级描述（较大噪声/Loud Noise）
   - 统计数据卡片

2. **分贝计界面**
   - 实时曲线图
   - 频率权重选择
   - 完整统计信息

3. **噪音剂量计界面**
   - 剂量百分比圆环
   - TWA实时值
   - 风险等级评估

4. **图表分析界面**
   - 频谱分析柱状图
   - 统计分布图
   - LEQ趋势曲线

5. **设置/校准界面**
   - 校准控制
   - 参数配置
   - 标准选择

**设计要求**:

- 使用iPhone 14 Pro mockup（深空黑或银色）
- 截图清晰，界面元素可见
- 悬停时放大效果
- 可点击查看大图（lightbox）

---

### 5️⃣ Technical Advantages（技术优势区）

**标题**: Professional Technology, Reliable Assurance / 专业技术，可靠保障

**6个优势点（2列布局，每列3个）**:

#### 1. Standards Compliant ✓ / 符合国际标准 ✓

- IEC 61672-1:2013 Sound level meter standard
- ISO 1996-1:2016 Environmental noise measurement
- IEC 61260-1:2014 Octave-band filters
- ITU-R BS.468-4 Broadcast audio measurement

#### 2. Professional Algorithms 🧮 / 专业算法 🧮

- Precise frequency weighting filtering
- Standards-compliant time weighting response
- Accurate LEQ equivalent sound level calculation
- Professional FFT spectrum analysis

#### 3. Real-time Performance ⚡ / 实时性能 ⚡

- Millisecond-level response speed
- Smooth data visualization
- Low-latency audio processing
- 60fps chart refresh rate

#### 4. Data Reliability 🔒 / 数据可靠 🔒

- Local data storage
- Complete data recording
- JSON/CSV export support
- Privacy security protection

#### 5. Easy Calibration 🎯 / 易于校准 🎯

- Standard sound source support (94dB@1kHz)
- ±0.1dB precision adjustment
- Persistent calibration parameters
- Simple and intuitive calibration process

#### 6. User Friendly 💡 / 用户友好 💡

- Modern SwiftUI interface
- Intuitive operation logic
- Comprehensive help documentation
- Professional terminology explanations

---

### 6️⃣ Testimonials（用户评价区）

**标题**: Trusted by Professional Users / 专业用户的一致选择

**6条用户评价（3列网格或轮播）**:

#### 评价1 - 职业健康专家
>
> "As an occupational health engineer, this is the most professional mobile decibel meter I've used. Multi-standard support and dosimeter functions are very practical."  
> "作为职业健康工程师，这是我用过最专业的移动端分贝计。多标准支持和噪音剂量计功能非常实用。"
>
> **Zhang (Engineer)** - EHS Manager at Large Enterprise  
> **张工** - 某大型企业EHS经理  
> ⭐⭐⭐⭐⭐

#### 评价2 - 声学工程师
>
> "The spectrum analysis is powerful, 1/3 octave analysis is very helpful for architectural acoustics testing. Professional yet simple interface design, highly recommended!"  
> "频谱分析功能很强大，1/3倍频程分析对建筑声学测试非常有帮助。界面设计专业又不失简洁，推荐！"
>
> **Li (Engineer)** - Architectural Acoustics Engineer  
> **李工** - 建筑声学工程师  
> ⭐⭐⭐⭐⭐

#### 评价3 - 科研人员
>
> "We use it for environmental noise research in our lab. The data export function is very convenient. Calibration ensures measurement accuracy for research requirements."  
> "我们实验室用它做环境噪声研究，数据导出功能很方便。校准功能确保了测量精度，符合科研要求。"
>
> **Prof. Wang** - Acoustics Lab, University  
> **王教授** - 某大学声学实验室  
> ⭐⭐⭐⭐⭐

#### 评价4 - 普通用户
>
> "As a regular user, I use it to monitor noise in my home and office. The interface is very intuitive, level descriptions are clear, no professional knowledge needed."  
> "作为普通用户，我用它监测家里和办公室的噪声环境。界面很直观，等级说明很清楚，不需要专业知识也能看懂。"
>
> **Chen** - App Store Review  
> **用户Chen** - App Store评价  
> ⭐⭐⭐⭐⭐

#### 评价5 - 安全主管
>
> "Essential tool for factory noise monitoring! TWA calculation and exposure duration table help us protect employee hearing."  
> "工厂噪声监测必备工具！TWA计算和允许暴露时长表帮助我们做好员工听力保护工作。"
>
> **Liu (Manager)** - Safety Director, Manufacturing  
> **刘经理** - 制造业安全主管  
> ⭐⭐⭐⭐⭐

#### 评价6 - 环境检测工程师
>
> "Support for multiple frequency and time weightings is very professional, can handle various measurement scenarios. Audio recording feature is also thoughtful."  
> "多种频率权重和时间权重的支持很专业，可以应对各种测量场景。音频录制功能也很贴心。"
>
> **Zhao (Engineer)** - Environmental Testing Engineer  
> **赵工** - 环境检测工程师  
> ⭐⭐⭐⭐⭐

---

### 7️⃣ Pricing（定价方案区）

**标题**: Flexible Pricing Plans / 灵活订阅方案，满足不同需求

**3个定价卡片（3列布局）**:

#### 基础版 - FREE / 免费

**Features included**:

- ✓ Real-time decibel measurement / 实时分贝测量
- ✓ A-weighting and Z-weighting / A权重和Z权重
- ✓ Fast and Slow response / Fast和Slow响应
- ✓ Basic statistics (MIN/MAX) / 基础统计
- ✓ Time history chart / 时间历程图
- ✗ Advanced weightings (B/C/ITU-R 468) / 高级权重
- ✗ Spectrum analysis / 频谱分析
- ✗ Noise dosimeter / 噪音剂量计
- ✗ Audio recording / 音频录制
- ✗ Data export / 数据导出

**Button**: "Free Download" / "免费下载"

---

#### 专业版 - $9.99/year (¥68/年) **[RECOMMENDED / 推荐]**

**Features included**:

- ✓ All Basic features / 所有基础版功能
- ✓ All 5 frequency weightings / 全部5种频率权重
- ✓ Impulse response / Impulse脉冲响应
- ✓ Complete statistics (PEAK & LEQ) / 完整统计
- ✓ 1/1 octave spectrum analysis / 1/1倍频程频谱分析
- ✓ Statistical distribution & LEQ trend / 统计分布图和LEQ趋势图
- ✓ Audio recording & playback / 音频录制与回放
- ✓ PDF report export / PDF报告导出
- ✗ Noise dosimeter / 噪音剂量计
- ✗ 1/3 octave / 1/3倍频程

**Button**: "Start 7-Day Free Trial" / "开始7天免费试用"

**Badge**: "Most Popular" / "最受欢迎"

---

#### 企业版 - $29.99/year (¥198/年)

**Features included**:

- ✓ All Pro features / 所有专业版功能
- ✓ Noise dosimeter (5 standards) / 噪音剂量计（5种标准）
- ✓ 1/3 octave spectrum analysis / 1/3倍频程频谱分析
- ✓ Complete data export (JSON/CSV) / 完整数据导出
- ✓ Batch measurement management / 批量测量管理
- ✓ Cloud data sync / 云端数据同步
- ✓ Priority technical support / 优先技术支持
- ✓ Team sharing / 团队共享功能

**Button**: "Contact Us" / "联系我们"

---

**底部说明**:

- All plans include 7-day free trial / 所有方案均含7天免费试用
- Cancel anytime / 随时可取消
- Secure payment via App Store / 通过App Store安全支付

---

### 8️⃣ FAQ Section（常见问题区）

**标题**: Frequently Asked Questions / 常见问题解答

**8个FAQ（可折叠accordion或直接展示）**:

#### Q1: How accurate is the measurement? / 这个应用的测量精度如何？

**A**: This app uses professional acoustic measurement algorithms compliant with IEC 61672-1 international standards. With proper calibration, accuracy can reach ±1-2dB, fully meeting professional measurement needs. Note that measurement accuracy is also affected by device microphone quality.  
本应用采用专业的声学测量算法，符合IEC 61672-1国际标准。在正确校准的前提下，精度可达±1-2dB，完全满足专业测量需求。但需要注意，测量精度也受设备麦克风质量影响。

#### Q2: Do I need to purchase additional hardware? / 需要额外购买硬件设备吗？

**A**: No. This app uses the built-in microphone of iPhone/iPad for measurement. For higher precision requirements, professional external microphones (such as Rode, Shure iOS-compatible microphones) are recommended.  
不需要。本应用使用iPhone/iPad内置麦克风进行测量。对于更高精度要求，建议使用专业外接麦克风（如Rode、Shure等品牌的iOS兼容麦克风）。

#### Q3: How to calibrate? / 如何进行校准？

**A**: We recommend using a standard sound source calibrator (94dB @ 1kHz). In settings, enter the "Calibration" page, place the calibrator in front of the microphone, and adjust the offset to make the reading 94.0dB. You can also compare with a professional sound level meter for calibration.  
推荐使用标准声源校准器（94dB @ 1kHz）进行校准。在设置中进入"校准"页面，将校准器置于麦克风前，调整偏移值使读数为94.0dB。也可以参考专业声级计进行对比校准。

#### Q4: What scenarios is the noise dosimeter suitable for? / 噪音剂量计功能适用于哪些场景？

**A**: The noise dosimeter is designed for occupational health monitoring and is suitable for high-noise work environments such as factories, construction sites, and entertainment venues. It supports occupational health standards from China, the United States, the European Union, and other countries and regions.  
噪音剂量计专为职业健康监测设计，适用于工厂、建筑工地、娱乐场所等高噪声工作环境。支持中国、美国、欧盟等多个国家和地区的职业健康标准。

#### Q5: Can it measure continuously in the background? / 可以在后台持续测量吗？

**A**: Due to iOS system limitations, background running time is limited (usually 3-10 minutes). The app will display remaining time when entering the background. It is recommended to keep the screen on to ensure continuous measurement.  
由于iOS系统限制，后台运行时间有限（通常3-10分钟）。应用会在进入后台时显示剩余时间。建议保持屏幕常亮以确保连续测量。

#### Q6: Can measurement data be exported? / 测量数据可以导出吗？

**A**: Pro and Enterprise versions support data export. You can export JSON format raw data, CSV format statistical reports, and PDF format professional reports. Export files can be shared via email, AirDrop, or cloud storage.  
专业版和企业版支持数据导出。可以导出JSON格式的原始数据、CSV格式的统计报表，以及PDF格式的专业报告。导出文件可通过邮件、AirDrop或云存储分享。

#### Q7: What's the difference between frequency weightings? / 不同频率权重有什么区别？

**A**:  

- **A-weighting**: Simulates human ear sensitivity to different frequencies, suitable for environmental noise assessment  
- **C-weighting**: More suitable for high-level noise and peak measurements  
- **Z-weighting**: No weighting (linear), true sound pressure level  
- **ITU-R 468**: Dedicated standard for broadcasting and audio equipment measurement

- **A权重**：模拟人耳对不同频率的敏感度，适用于环境噪声评估
- **C权重**：更适合高响度噪声和峰值测量
- **Z权重**：无权重（线性），真实声压级
- **ITU-R 468**：广播和音频设备测量专用标准

#### Q8: Is this app suitable for non-professional users? / 这个应用适合非专业用户使用吗？

**A**: Absolutely! Although the functions are professional, the interface design is simple and intuitive. Basic measurement functions are very easy to use, and each decibel level has clear text descriptions (such as "Quiet and Comfortable", "Normal Conversation", etc.), understandable without professional knowledge.  
完全可以！虽然功能专业，但界面设计简洁直观。基础测量功能非常易用，每个分贝等级都有清晰的文字说明（如"安静舒适"、"正常交谈"等），无需专业知识也能理解。

---

### 9️⃣ Download CTA Section（下载引导区）

**大标题**: Start Professional Noise Measurement Now / 立即开始专业噪声测量

**副标题**:  
Free download, enjoy basic features instantly  
Pro version with 7-day free trial, cancel anytime  

免费下载，立享基础功能  
专业版7天免费试用，随时可取消

**主CTA**:

- 大号按钮: "Download on App Store" / "App Store 免费下载"
  - 带App Store黑色图标
  - 蓝色渐变背景
  - 悬停发光效果
  
**二维码**: 扫码下载（显示App Store下载二维码）

**次要信息**（图标 + 文字）:

- 📱 iOS 15.0+ | Compatible with iPhone & iPad / 支持 iOS 15.0+ | 兼容 iPhone 和 iPad
- ⭐ 4.8/5.0 Rating (3,200+ reviews) / ⭐ 4.8分 (3,200评价)
- 👥 30,000+ Professional Users / 👥 30,000+ 专业用户
- 📦 ~25MB Download Size / 📦 仅需 25MB 存储空间

**背景设计**: 蓝色渐变背景 + 波形装饰元素

---

### 🔟 Footer（页脚）

**4列布局（响应式在移动端堆叠）**:

#### 第一列: About / 关于

- Company / 公司介绍
- Team / 团队介绍  
- Philosophy / 产品理念
- News / 新闻动态

#### 第二列: Product / 产品

- Features / 功能特性
- Specifications / 技术规格
- Updates / 更新日志
- Roadmap / 路线图

#### 第三列: Support / 支持

- Help Center / 帮助中心
- Documentation / 使用文档
- Video Tutorials / 视频教程
- Contact Us / 联系我们
- Email: <support@decibelmeter.app>

#### 第四列: Legal / 法律

- Terms of Service / 用户协议
- Privacy Policy / 隐私政策
- Subscription Terms / 订阅条款
- Cookie Policy / Cookie政策

---

**底部信息**:

- Copyright © 2025 Professional Decibel Meter. All rights reserved.
- Compliant with IEC, ISO, OSHA international standards
- Made with ❤️ for acoustic professionals

**社交媒体链接图标**: Twitter, Facebook, YouTube, LinkedIn

---

## 🎨 设计要求

### 1. 响应式设计

- **桌面端 (1200px+)**: 多列布局，3-4列网格
- **平板端 (768-1199px)**: 2列布局
- **移动端 (<768px)**: 单列堆叠，汉堡菜单

### 2. 视觉风格

- 扁平化现代设计
- 大量留白，不拥挤
- 清晰的信息层级
- 圆角卡片设计（border-radius: 12-16px）
- 柔和阴影（box-shadow）

### 3. 动效要求

- **页面加载**: 首屏元素从下到上淡入
- **滚动触发**:
  - 功能卡片滚动到视口时从下滑入
  - 数字统计从0计数到目标值
  - 图表动画绘制
- **鼠标悬停**:
  - 卡片轻微上浮（transform: translateY(-8px)）
  - 阴影加深
  - CTA按钮颜色加深或发光
- **过渡**: 所有过渡使用 ease-in-out，持续时间 0.3s

### 4. 字体

- **标题**: Sans-serif，加粗（font-weight: 700）
- **正文**: Sans-serif，regular（font-weight: 400）
- **数字**: Monospace字体（等宽）
- 支持多语言字体回退

### 5. 图标

- 使用统一风格的图标库（如Font Awesome、Feather Icons）
- 或使用emoji图标
- 图标大小一致，颜色与主题配色

### 6. 图片

- 使用高质量的iPhone mockup
- 截图清晰，2x或3x分辨率
- 图片懒加载优化性能
- 使用WebP格式（回退到PNG）

---

## 💻 技术实现建议

### 推荐技术栈

**选项1: React + Next.js + TailwindCSS + i18next**

```javascript
// 国际化配置示例
import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';

i18n
  .use(initReactI18next)
  .init({
    resources: {
      en: { translation: require('./locales/en.json') },
      zh_Hans: { translation: require('./locales/zh_Hans.json') },
      ja: { translation: require('./locales/ja.json') },
      // ... 其他语言
    },
    lng: 'en', // 默认语言
    fallbackLng: 'en',
    interpolation: { escapeValue: false }
  });
```

**选项2: Vue.js + Nuxt + TailwindCSS + Vue I18n**

**选项3: 原生HTML + CSS + JavaScript + 自定义国际化**

### 国际化实现示例

```javascript
// 简单的国际化实现
const translations = {
  en: {
    hero_title: "Professional Decibel Meter",
    hero_subtitle: "Precise · Reliable · Standards Compliant",
    download_button: "Download on App Store"
  },
  zh_Hans: {
    hero_title: "专业级分贝测量仪",
    hero_subtitle: "精准·可靠·符合国际标准",
    download_button: "免费下载 - App Store"
  },
  ja: {
    hero_title: "プロフェッショナルデシベルメーター",
    hero_subtitle: "正確・信頼性・標準準拠",
    download_button: "App Storeでダウンロード"
  }
  // ... 其他语言
};

// 语言切换函数
function changeLanguage(lang) {
  currentLang = lang;
  document.querySelectorAll('[data-i18n]').forEach(el => {
    const key = el.getAttribute('data-i18n');
    el.textContent = translations[lang][key];
  });
  localStorage.setItem('preferred_language', lang);
}

// 自动检测浏览器语言
const browserLang = navigator.language.split('-')[0];
const defaultLang = translations[browserLang] ? browserLang : 'en';
changeLanguage(defaultLang);
```

### 语言切换器UI组件

```jsx
// React示例
function LanguageSwitcher() {
  const { i18n } = useTranslation();
  
  const languages = [
    { code: 'en', name: 'English', flag: '🇺🇸' },
    { code: 'zh_Hans', name: '简体中文', flag: '🇨🇳' },
    { code: 'ja', name: '日本語', flag: '🇯🇵' },
    // ... 其他语言
  ];
  
  return (
    <select onChange={(e) => i18n.changeLanguage(e.target.value)}>
      {languages.map(lang => (
        <option value={lang.code}>
          {lang.flag} {lang.name}
        </option>
      ))}
    </select>
  );
}
```

### RTL支持（阿拉伯语）

```css
/* RTL语言支持 */
[dir="rtl"] {
  direction: rtl;
  text-align: right;
}

[dir="rtl"] .hero-content {
  padding-left: 0;
  padding-right: 2rem;
}
```

---

## 📊 性能优化

1. **图片优化**: 使用WebP格式，懒加载
2. **代码分割**: 按路由或组件分割代码
3. **CDN加速**: 静态资源使用CDN
4. **缓存策略**: 合理设置浏览器缓存
5. **压缩**: Gzip/Brotli压缩
6. **首屏优化**: 关键CSS内联，非关键资源延迟加载

---

## ✅ 输出清单

生成的Landing Page必须包含：

- [x] 19种语言的完整国际化支持
- [x] 语言切换器（右上角）
- [x] 10个完整的section
- [x] 所有功能描述和卡片
- [x] 6个应用场景
- [x] 5张界面截图展示
- [x] 6条用户评价
- [x] 3个定价方案
- [x] 8个FAQ
- [x] 响应式设计（桌面/平板/移动）
- [x] 动效和交互效果
- [x] CTA按钮（至少5处）
- [x] App Store下载链接
- [x] 完整的页脚
- [x] RTL布局支持（阿拉伯语）

---

## 🚀 使用说明

1. **直接输入AI工具**: 将本文档完整内容复制粘贴给v0.dev、Cursor、Claude等AI工具
2. **分section生成**: 如果一次处理不了，可以按section分别生成，然后组合
3. **自定义修改**: 根据实际需求调整文案、颜色、布局等
4. **测试**: 生成后在多种设备和浏览器测试
5. **本地化**: 确保所有19种语言的翻译准确完整

---

**文档版本**: v2.0 Lite  
**创建日期**: 2025年11月21日  
**用途**: 直接输入AI工具生成多语言Landing Page  
**目标输出**: 完整可部署的响应式多语言Landing Page代码
