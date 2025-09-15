# dev_samples

开发学习示例

## 项目清理

``` json
"scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "lint": "eslint . --fix",
    "format": "prettier --write src/",
    "clean": "rm -rf node_modules pnpm-lock.yaml && pnpm store prune && pnpm install"
  },

```

运行命令：`pnpm run clean`
