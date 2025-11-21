# Landing Page 代码生成提示词文档

**用途**: 用于v0.dev、Cursor、Claude等AI工具生成Landing Page代码

---

## 🎯 代码生成任务

基于设计稿，生成一个完整的、可部署的多语言Landing Page网站代码。

---

## 💻 技术栈要求

### 必须使用
```
前端框架: React 18+
框架: Next.js 14+ (App Router)
样式: TailwindCSS 3+
国际化: i18next + react-i18next
动画: Framer Motion
图标: Lucide React 或 React Icons
```

### 开发工具
```
包管理器: npm 或 pnpm
代码格式化: Prettier
代码检查: ESLint
TypeScript: 可选但推荐
```

---

## 📁 项目结构

```
landing-page/
├── public/
│   ├── locales/              # 19种语言翻译文件
│   │   ├── en/
│   │   │   └── translation.json
│   │   ├── zh_Hans/
│   │   │   └── translation.json
│   │   ├── ja/
│   │   │   └── translation.json
│   │   └── ... (其他16种语言)
│   ├── images/
│   │   ├── mockups/          # iPhone mockup图片
│   │   ├── screenshots/      # 应用截图
│   │   ├── scenes/           # 场景插画
│   │   └── icons/            # 图标
│   └── favicon.ico
├── src/
│   ├── app/
│   │   ├── layout.tsx        # 根布局
│   │   ├── page.tsx          # 主页面
│   │   └── globals.css       # 全局样式
│   ├── components/
│   │   ├── sections/         # 10个Section组件
│   │   │   ├── HeroSection.tsx
│   │   │   ├── FeaturesSection.tsx
│   │   │   ├── UseCasesSection.tsx
│   │   │   ├── InterfaceSection.tsx
│   │   │   ├── AdvantagesSection.tsx
│   │   │   ├── TestimonialsSection.tsx
│   │   │   ├── PricingSection.tsx
│   │   │   ├── FAQSection.tsx
│   │   │   ├── DownloadCTASection.tsx
│   │   │   └── Footer.tsx
│   │   ├── ui/               # UI组件
│   │   │   ├── Button.tsx
│   │   │   ├── Card.tsx
│   │   │   ├── Accordion.tsx
│   │   │   └── LanguageSwitcher.tsx
│   │   └── Navigation.tsx
│   ├── lib/
│   │   ├── i18n.ts           # i18next配置
│   │   └── utils.ts          # 工具函数
│   └── types/
│       └── index.ts          # TypeScript类型定义
├── tailwind.config.js
├── next.config.js
├── package.json
└── README.md
```

---

## 🌍 国际化实现

### 1. i18next配置

```typescript
// src/lib/i18n.ts
import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';
import LanguageDetector from 'i18next-browser-languagedetector';

// 支持的语言列表
const supportedLanguages = [
  'ar', 'de', 'en', 'es', 'fil', 'fr', 'id', 'it', 
  'ja', 'ko', 'pl', 'pt', 'ru', 'th', 'tr', 'vi', 
  'zh_Hans', 'zh_Hant'
];

i18n
  .use(LanguageDetector) // 自动检测浏览器语言
  .use(initReactI18next)
  .init({
    resources: {}, // 将动态加载
    fallbackLng: 'en', // 默认语言
    supportedLngs: supportedLanguages,
    interpolation: {
      escapeValue: false,
    },
    detection: {
      order: ['localStorage', 'navigator'],
      caches: ['localStorage'],
    },
  });

// 动态加载翻译文件
supportedLanguages.forEach((lang) => {
  import(`../../public/locales/${lang}/translation.json`).then((module) => {
    i18n.addResourceBundle(lang, 'translation', module.default);
  });
});

export default i18n;
```

### 2. 翻译文件结构示例

```json
// public/locales/en/translation.json
{
  "hero": {
    "title": "Professional Decibel Meter",
    "subtitle": "Precise · Reliable · Standards Compliant",
    "description": "Laboratory-grade noise measurement solution for environmental monitoring, occupational health, and acoustic research.",
    "cta_primary": "Download on App Store",
    "cta_secondary": "Watch Demo",
    "trust_badges": {
      "standard": "IEC 61672-1 Compliant",
      "support": "iOS 15.0+ Support",
      "rating": "4.8 Rating",
      "users": "30,000+ Users"
    }
  },
  "features": {
    "title": "Comprehensive Professional Features",
    "subtitle": "Everything you need for professional noise measurement",
    "cards": [
      {
        "title": "Five Frequency Weightings",
        "description": "dB-A/B/C/Z and ITU-R 468 standards for all measurement scenarios"
      },
      // ... 其他5个功能卡片
    ]
  },
  // ... 其他sections
}
```

```json
// public/locales/zh_Hans/translation.json
{
  "hero": {
    "title": "专业级分贝测量仪",
    "subtitle": "精准·可靠·符合国际标准",
    "description": "为环境监测、职业健康、声学研究提供实验室级别的噪声测量解决方案。",
    "cta_primary": "App Store 免费下载",
    "cta_secondary": "观看演示视频",
    "trust_badges": {
      "standard": "符合 IEC 61672-1 标准",
      "support": "支持 iOS 15.0+",
      "rating": "4.8分评分",
      "users": "30,000+ 用户"
    }
  },
  // ... 其他内容
}
```

### 3. 语言切换器组件

```tsx
// src/components/ui/LanguageSwitcher.tsx
'use client';

import { useTranslation } from 'react-i18next';
import { useState } from 'react';
import { ChevronDown } from 'lucide-react';

const languages = [
  { code: 'ar', name: 'العربية', flag: '🇸🇦', dir: 'rtl' },
  { code: 'de', name: 'Deutsch', flag: '🇩🇪', dir: 'ltr' },
  { code: 'en', name: 'English', flag: '🇺🇸', dir: 'ltr' },
  { code: 'es', name: 'Español', flag: '🇪🇸', dir: 'ltr' },
  { code: 'fil', name: 'Filipino', flag: '🇵🇭', dir: 'ltr' },
  { code: 'fr', name: 'Français', flag: '🇫🇷', dir: 'ltr' },
  { code: 'id', name: 'Bahasa Indonesia', flag: '🇮🇩', dir: 'ltr' },
  { code: 'it', name: 'Italiano', flag: '🇮🇹', dir: 'ltr' },
  { code: 'ja', name: '日本語', flag: '🇯🇵', dir: 'ltr' },
  { code: 'ko', name: '한국어', flag: '🇰🇷', dir: 'ltr' },
  { code: 'pl', name: 'Polski', flag: '🇵🇱', dir: 'ltr' },
  { code: 'pt', name: 'Português', flag: '🇵🇹', dir: 'ltr' },
  { code: 'ru', name: 'Русский', flag: '🇷🇺', dir: 'ltr' },
  { code: 'th', name: 'ไทย', flag: '🇹🇭', dir: 'ltr' },
  { code: 'tr', name: 'Türkçe', flag: '🇹🇷', dir: 'ltr' },
  { code: 'vi', name: 'Tiếng Việt', flag: '🇻🇳', dir: 'ltr' },
  { code: 'zh_Hans', name: '简体中文', flag: '🇨🇳', dir: 'ltr' },
  { code: 'zh_Hant', name: '繁體中文', flag: '🇹🇼', dir: 'ltr' },
];

export default function LanguageSwitcher() {
  const { i18n } = useTranslation();
  const [isOpen, setIsOpen] = useState(false);
  
  const currentLang = languages.find(lang => lang.code === i18n.language) || languages[2];

  const changeLanguage = (langCode: string, dir: string) => {
    i18n.changeLanguage(langCode);
    document.documentElement.dir = dir;
    document.documentElement.lang = langCode;
    setIsOpen(false);
  };

  return (
    <div className="relative">
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="flex items-center gap-2 px-4 py-2 rounded-lg hover:bg-gray-100 transition-colors"
      >
        <span className="text-xl">{currentLang.flag}</span>
        <span className="hidden sm:inline">{currentLang.name}</span>
        <ChevronDown className={`w-4 h-4 transition-transform ${isOpen ? 'rotate-180' : ''}`} />
      </button>
      
      {isOpen && (
        <div className="absolute right-0 mt-2 w-64 bg-white rounded-lg shadow-xl border border-gray-200 py-2 z-50 max-h-96 overflow-y-auto">
          {languages.map((lang) => (
            <button
              key={lang.code}
              onClick={() => changeLanguage(lang.code, lang.dir)}
              className={`w-full flex items-center gap-3 px-4 py-2 hover:bg-gray-50 transition-colors ${
                currentLang.code === lang.code ? 'bg-blue-50' : ''
              }`}
            >
              <span className="text-xl">{lang.flag}</span>
              <span>{lang.name}</span>
            </button>
          ))}
        </div>
      )}
    </div>
  );
}
```

---

## 🎨 TailwindCSS配置

```javascript
// tailwind.config.js
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        primary: '#007AFF',
        'primary-dark': '#0051D5',
        success: '#34C759',
        warning: '#FF9500',
        danger: '#FF3B30',
        accent: '#AF52DE',
        'decibel-green': '#34C759',
        'decibel-yellow': '#FFCC00',
        'decibel-orange': '#FF9500',
        'decibel-red': '#FF3B30',
        'decibel-purple': '#AF52DE',
      },
      fontFamily: {
        sans: ['-apple-system', 'BlinkMacSystemFont', 'Segoe UI', 'Roboto', 'Helvetica Neue', 'Arial'],
        mono: ['SF Mono', 'Monaco', 'Consolas', 'monospace'],
      },
      boxShadow: {
        'card': '0 2px 12px rgba(0, 0, 0, 0.08)',
        'card-hover': '0 8px 24px rgba(0, 0, 0, 0.12)',
        'button': '0 4px 12px rgba(0, 122, 255, 0.3)',
        'button-hover': '0 6px 16px rgba(0, 122, 255, 0.4)',
      },
      animation: {
        'fade-in': 'fadeIn 0.6s ease-in-out',
        'slide-up': 'slideUp 0.6s ease-in-out',
        'slide-in-left': 'slideInLeft 0.8s ease-in-out',
        'slide-in-right': 'slideInRight 0.8s ease-in-out',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideUp: {
          '0%': { transform: 'translateY(20px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
        slideInLeft: {
          '0%': { transform: 'translateX(-50px)', opacity: '0' },
          '100%': { transform: 'translateX(0)', opacity: '1' },
        },
        slideInRight: {
          '0%': { transform: 'translateX(50px)', opacity: '0' },
          '100%': { transform: 'translateX(0)', opacity: '1' },
        },
      },
    },
  },
  plugins: [],
}
```

---

## 🧩 核心组件示例

### 1. Hero Section组件

```tsx
// src/components/sections/HeroSection.tsx
'use client';

import { useTranslation } from 'react-i18next';
import { motion } from 'framer-motion';
import { Download, Play } from 'lucide-react';
import Image from 'next/image';

export default function HeroSection() {
  const { t } = useTranslation();

  return (
    <section className="relative min-h-screen flex items-center bg-gradient-to-br from-primary to-primary-dark overflow-hidden">
      {/* 背景装饰 */}
      <div className="absolute inset-0 opacity-10">
        {/* 波形或网格效果 */}
      </div>

      <div className="container mx-auto px-6 lg:px-12 relative z-10">
        <div className="grid lg:grid-cols-2 gap-12 items-center">
          {/* 左侧内容 */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.2 }}
            className="text-white"
          >
            <h1 className="text-5xl lg:text-6xl font-bold mb-4 leading-tight">
              {t('hero.title')}
            </h1>
            <p className="text-xl lg:text-2xl mb-2 opacity-90">
              {t('hero.subtitle')}
            </p>
            <p className="text-lg mb-8 opacity-80 max-w-xl">
              {t('hero.description')}
            </p>

            {/* CTA按钮 */}
            <div className="flex flex-col sm:flex-row gap-4 mb-12">
              <a
                href="https://apps.apple.com/"
                className="flex items-center justify-center gap-2 bg-white text-primary px-8 py-4 rounded-xl font-semibold shadow-button hover:shadow-button-hover transform hover:-translate-y-1 transition-all"
              >
                <Download className="w-5 h-5" />
                {t('hero.cta_primary')}
              </a>
              <button className="flex items-center justify-center gap-2 border-2 border-white text-white px-8 py-4 rounded-xl font-semibold hover:bg-white/10 transition-all">
                <Play className="w-5 h-5" />
                {t('hero.cta_secondary')}
              </button>
            </div>

            {/* 信任徽章 */}
            <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
              {['standard', 'support', 'rating', 'users'].map((badge) => (
                <div key={badge} className="bg-white/10 backdrop-blur-sm rounded-lg px-4 py-3 text-center">
                  <p className="text-sm opacity-90">{t(`hero.trust_badges.${badge}`)}</p>
                </div>
              ))}
            </div>
          </motion.div>

          {/* 右侧 iPhone Mockup */}
          <motion.div
            initial={{ opacity: 0, x: 50 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.8, delay: 0.4 }}
            className="relative"
          >
            <div className="relative transform lg:rotate-6 hover:rotate-0 transition-transform duration-500">
              <Image
                src="/images/mockups/iphone-mockup.png"
                alt="App Screenshot"
                width={600}
                height={1200}
                className="drop-shadow-2xl"
              />
            </div>
          </motion.div>
        </div>
      </div>
    </section>
  );
}
```

### 2. 功能卡片组件

```tsx
// src/components/sections/FeaturesSection.tsx
'use client';

import { useTranslation } from 'react-i18next';
import { motion } from 'framer-motion';
import { Settings, Activity, BarChart3, Factory, Mic, Target } from 'lucide-react';

const icons = [Settings, Activity, BarChart3, Factory, Mic, Target];

export default function FeaturesSection() {
  const { t } = useTranslation();
  const features = t('features.cards', { returnObjects: true }) as Array<{title: string, description: string}>;

  return (
    <section className="py-20 lg:py-32 bg-white">
      <div className="container mx-auto px-6 lg:px-12">
        {/* 标题 */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          className="text-center mb-16"
        >
          <h2 className="text-4xl lg:text-5xl font-bold mb-4">
            {t('features.title')}
          </h2>
          <p className="text-xl text-gray-600 max-w-2xl mx-auto">
            {t('features.subtitle')}
          </p>
        </motion.div>

        {/* 功能卡片网格 */}
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
          {features.map((feature, index) => {
            const Icon = icons[index];
            return (
              <motion.div
                key={index}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ delay: index * 0.1 }}
                className="bg-white rounded-2xl p-8 shadow-card hover:shadow-card-hover transform hover:-translate-y-2 transition-all duration-300"
              >
                {/* 图标 */}
                <div className="w-20 h-20 bg-primary/10 rounded-full flex items-center justify-center mb-6">
                  <Icon className="w-10 h-10 text-primary" />
                </div>
                
                {/* 标题 */}
                <h3 className="text-2xl font-semibold mb-3">
                  {feature.title}
                </h3>
                
                {/* 描述 */}
                <p className="text-gray-600 leading-relaxed">
                  {feature.description}
                </p>
              </motion.div>
            );
          })}
        </div>
      </div>
    </section>
  );
}
```

### 3. FAQ Accordion组件

```tsx
// src/components/ui/Accordion.tsx
'use client';

import { useState } from 'react';
import { ChevronDown } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';

interface AccordionProps {
  question: string;
  answer: string;
}

export default function Accordion({ question, answer }: AccordionProps) {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <div className="border-b border-gray-200">
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="w-full flex items-center justify-between py-6 text-left hover:text-primary transition-colors"
      >
        <span className="text-lg font-semibold pr-8">{question}</span>
        <ChevronDown
          className={`w-5 h-5 flex-shrink-0 transition-transform ${
            isOpen ? 'rotate-180' : ''
          }`}
        />
      </button>
      
      <AnimatePresence>
        {isOpen && (
          <motion.div
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: 'auto', opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            transition={{ duration: 0.3 }}
            className="overflow-hidden"
          >
            <p className="pb-6 text-gray-600 leading-relaxed">
              {answer}
            </p>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
```

### 4. 导航栏组件

```tsx
// src/components/Navigation.tsx
'use client';

import { useState, useEffect } from 'react';
import { useTranslation } from 'react-i18next';
import { Menu, X } from 'lucide-react';
import LanguageSwitcher from './ui/LanguageSwitcher';

export default function Navigation() {
  const { t } = useTranslation();
  const [isScrolled, setIsScrolled] = useState(false);
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 50);
    };
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  const navLinks = ['features', 'pricing', 'faq', 'download'];

  return (
    <nav
      className={`fixed top-0 w-full z-50 transition-all duration-300 ${
        isScrolled
          ? 'bg-white/90 backdrop-blur-md shadow-lg'
          : 'bg-transparent'
      }`}
    >
      <div className="container mx-auto px-6 lg:px-12">
        <div className="flex items-center justify-between h-20">
          {/* Logo */}
          <div className="flex items-center gap-2">
            <div className="w-10 h-10 bg-primary rounded-lg"></div>
            <span className={`font-bold text-xl ${isScrolled ? 'text-gray-900' : 'text-white'}`}>
              DecibelMeter
            </span>
          </div>

          {/* 桌面导航 */}
          <div className="hidden lg:flex items-center gap-8">
            {navLinks.map((link) => (
              <a
                key={link}
                href={`#${link}`}
                className={`font-medium hover:text-primary transition-colors ${
                  isScrolled ? 'text-gray-700' : 'text-white'
                }`}
              >
                {t(`nav.${link}`)}
              </a>
            ))}
            <LanguageSwitcher />
          </div>

          {/* 移动端菜单按钮 */}
          <button
            onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
            className="lg:hidden"
          >
            {isMobileMenuOpen ? (
              <X className={`w-6 h-6 ${isScrolled ? 'text-gray-900' : 'text-white'}`} />
            ) : (
              <Menu className={`w-6 h-6 ${isScrolled ? 'text-gray-900' : 'text-white'}`} />
            )}
          </button>
        </div>
      </div>

      {/* 移动端菜单 */}
      {isMobileMenuOpen && (
        <div className="lg:hidden bg-white border-t">
          <div className="container mx-auto px-6 py-4 space-y-4">
            {navLinks.map((link) => (
              <a
                key={link}
                href={`#${link}`}
                className="block py-2 text-gray-700 hover:text-primary transition-colors"
                onClick={() => setIsMobileMenuOpen(false)}
              >
                {t(`nav.${link}`)}
              </a>
            ))}
            <div className="pt-4 border-t">
              <LanguageSwitcher />
            </div>
          </div>
        </div>
      )}
    </nav>
  );
}
```

---

## 📱 响应式设计实现

### 使用TailwindCSS断点

```tsx
// 示例：响应式网格
<div className="
  grid 
  grid-cols-1          /* 移动端: 1列 */
  md:grid-cols-2       /* 平板: 2列 */
  lg:grid-cols-3       /* 桌面: 3列 */
  gap-6                /* 间距 */
">
  {/* 内容 */}
</div>

// 示例：响应式文字大小
<h1 className="
  text-3xl             /* 移动端 */
  md:text-4xl          /* 平板 */
  lg:text-5xl          /* 桌面 */
  font-bold
">
  {title}
</h1>

// 示例：响应式显示/隐藏
<div className="hidden lg:block">   {/* 仅桌面显示 */}
<div className="lg:hidden">         {/* 仅移动端显示 */}
```

---

## 🎬 动画实现

### 使用Framer Motion

```tsx
import { motion } from 'framer-motion';

// 淡入动画
<motion.div
  initial={{ opacity: 0 }}
  animate={{ opacity: 1 }}
  transition={{ duration: 0.6 }}
>
  {content}
</motion.div>

// 滚动触发动画
<motion.div
  initial={{ opacity: 0, y: 20 }}
  whileInView={{ opacity: 1, y: 0 }}
  viewport={{ once: true }}
  transition={{ duration: 0.6 }}
>
  {content}
</motion.div>

// 悬停动画
<motion.div
  whileHover={{ scale: 1.05, y: -8 }}
  transition={{ duration: 0.3 }}
>
  {content}
</motion.div>

// 列表项逐个动画
{items.map((item, index) => (
  <motion.div
    key={index}
    initial={{ opacity: 0, y: 20 }}
    whileInView={{ opacity: 1, y: 0 }}
    viewport={{ once: true }}
    transition={{ delay: index * 0.1 }}
  >
    {item}
  </motion.div>
))}
```

---

## ⚡ 性能优化

### 1. 图片优化

```tsx
import Image from 'next/image';

// 使用Next.js Image组件自动优化
<Image
  src="/images/mockup.png"
  alt="Description"
  width={600}
  height={1200}
  quality={85}
  loading="lazy"  // 懒加载
  placeholder="blur"  // 模糊占位符
/>
```

### 2. 代码分割

```tsx
// 动态导入组件
import dynamic from 'next/dynamic';

const HeavyComponent = dynamic(() => import('./HeavyComponent'), {
  loading: () => <p>Loading...</p>,
  ssr: false,  // 禁用服务端渲染（如果不需要SEO）
});
```

### 3. 字体优化

```typescript
// src/app/layout.tsx
import { Inter } from 'next/font/google';

const inter = Inter({ 
  subsets: ['latin'],
  display: 'swap',
});

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className={inter.className}>
      <body>{children}</body>
    </html>
  );
}
```

---

## 🚀 部署配置

### Next.js配置

```javascript
// next.config.js
/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'export', // 如果需要静态导出
  images: {
    unoptimized: true, // 静态导出时需要
  },
  i18n: {
    locales: ['en', 'zh_Hans', 'ja', 'ko', 'ar', 'de', 'es', 'fil', 'fr', 'id', 'it', 'pl', 'pt', 'ru', 'th', 'tr', 'vi', 'zh_Hant'],
    defaultLocale: 'en',
  },
}

module.exports = nextConfig
```

### 部署到Vercel

```bash
# 1. 推送代码到GitHub

# 2. 在Vercel导入项目
# https://vercel.com/new

# 3. 环境变量设置（如果需要）
# NEXT_PUBLIC_API_URL=xxx

# 4. 自动部署完成
```

---

## 📦 Package.json

```json
{
  "name": "decibel-meter-landing",
  "version": "1.0.0",
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "next": "^14.0.0",
    "i18next": "^23.7.0",
    "react-i18next": "^13.5.0",
    "i18next-browser-languagedetector": "^7.2.0",
    "framer-motion": "^10.16.0",
    "lucide-react": "^0.294.0"
  },
  "devDependencies": {
    "@types/node": "^20",
    "@types/react": "^18",
    "@types/react-dom": "^18",
    "typescript": "^5",
    "tailwindcss": "^3.3.0",
    "postcss": "^8",
    "autoprefixer": "^10",
    "eslint": "^8",
    "eslint-config-next": "^14.0.0"
  }
}
```

---

## ✅ 代码生成清单

生成的代码必须包含：

### 结构完整性
- [ ] 10个完整的Section组件
- [ ] Navigation组件（桌面+移动端）
- [ ] Footer组件
- [ ] 所有UI组件（Button, Card, Accordion等）
- [ ] 语言切换器组件

### 国际化
- [ ] i18next完整配置
- [ ] 19种语言的翻译文件（至少包含所有key）
- [ ] 语言切换功能正常工作
- [ ] RTL布局支持（阿拉伯语）
- [ ] 语言选择持久化（localStorage）

### 样式和动画
- [ ] TailwindCSS配置完整
- [ ] 响应式设计（3个断点都测试）
- [ ] 所有动画效果实现
- [ ] 悬停状态正常工作
- [ ] 过渡效果流畅

### 性能
- [ ] 使用Next.js Image优化
- [ ] 代码分割合理
- [ ] 懒加载实现
- [ ] 字体优化

### 功能
- [ ] 导航锚点跳转正常
- [ ] FAQ手风琴展开/收起
- [ ] 移动端菜单正常工作
- [ ] App Store链接正确
- [ ] 所有CTA按钮可点击

### 部署就绪
- [ ] next.config.js配置正确
- [ ] package.json依赖完整
- [ ] README.md包含运行说明
- [ ] 可以成功build
- [ ] 可以部署到Vercel

---

## 🔧 开发和部署流程

### 1. 本地开发

```bash
# 安装依赖
npm install

# 启动开发服务器
npm run dev

# 访问 http://localhost:3000
```

### 2. 构建生产版本

```bash
# 构建
npm run build

# 本地预览生产版本
npm run start
```

### 3. 部署到Vercel

```bash
# 方式1: 推送到GitHub，Vercel自动部署

# 方式2: 使用Vercel CLI
npm i -g vercel
vercel
```

---

## 💡 代码质量要求

1. **代码风格**
   - 使用TypeScript（可选但推荐）
   - 遵循ESLint规则
   - 使用Prettier格式化

2. **组件设计**
   - 每个Section独立组件
   - UI组件可复用
   - Props类型定义清晰

3. **性能优化**
   - 避免不必要的re-render
   - 使用React.memo（如需要）
   - 图片和资源优化

4. **可维护性**
   - 代码注释清晰
   - 文件结构合理
   - 命名规范统一

---

## 🐛 常见问题解决

### 国际化不工作
```typescript
// 确保在客户端组件使用
'use client';

// 确保i18n已初始化
import '../lib/i18n';
```

### 图片不显示
```bash
# 确保图片放在public目录
# 使用绝对路径: /images/xxx.png
```

### RTL布局问题
```typescript
// 确保设置dir属性
document.documentElement.dir = 'rtl';

// Tailwind配置
// tailwind.config.js
plugins: [require('@tailwindcss/rtl')],
```

---

**文档版本**: v1.0  
**创建日期**: 2025年11月21日  
**用途**: 用于AI工具生成可部署的Landing Page代码  
**技术栈**: React + Next.js + TailwindCSS + i18next  
**目标输出**: 完整的、可部署的多语言网站代码

