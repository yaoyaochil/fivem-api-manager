# 🚀 FiveM API Service

<div align="center">

![Status](https://img.shields.io/badge/status-active-success.svg)
![FiveM](https://img.shields.io/badge/FiveM-Ready-brightgreen)
![QB-Core](https://img.shields.io/badge/QB--Core-Compatible-blue)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

</div>

---

## 📖 目录

- [项目简介](#-项目简介)
- [功能特性](#-功能特性)
- [依赖要求](#-依赖要求)
- [快速开始](#-快速开始)
- [配置说明](#-配置说明)
- [API 文档](#-api-文档)
- [常见问题](#-常见问题)
- [贡献指南](#-贡献指南)

## 🎯 项目简介

这是一个基于 FiveM 和 QB-CORE 框架的 HTTP API 插件包，旨在为服务器开发者提供便捷的接口服务，实现游戏内容的管理和对接。通过这个插件，你可以轻松地构建自己的服务器管理系统、网站后台或移动应用。

## 💫 功能特性

- ✨ 完整的 RESTful API 支持
- 🔒 安全的身份验证系统
- 🎮 游戏内容实时管理
- 📊 数据统计和监控
- 🛠 可扩展的插件架构
- 🌐 跨平台支持
- ⚡️ 高性能低延迟

## 📋 依赖要求

- 🎮 FiveM Server
- 💻 QB-Core Framework
- 🔧 MySQL/MariaDB (oxmysql)
- 📦 Node.js (可选，用于外部应用开发)

## 🚀 快速开始

1. **下载插件**

```bash
git clone git@github.com:yaoyaochil/fivem-api-manager.git
```

2. **将插件文件夹复制到 `resources` 目录下**

```bash
# 将插件文件夹复制到 resources 目录的 [api] 文件夹下
mv fivem-api-manager [api]
```

## 🔧 配置说明

1. **在 `server.cfg` 文件中添加插件**

```bash
ensure [api]
```

2. **在txAdmin中启动插件**

![image](https://github.com/user-attachments/assets/fcc864c9-559a-496e-a8f5-a146e35833e7)

## 📚 API 文档

### 示例
```lua
-- 引入 API 管理器
local API = exports['api']
-- 获取 Response 对象
local Response = exports['api'].getResponse()

-- 注册路由
RegisterRoute("GET", "/server/status", function(req)
    return Response.okWithData({
        status = "online",
        timestamp = os.time()
    }, "获取成功")
end, {
    auth_required = false
})
```

### 获取 Response 对象

```lua
local Response = exports['api'].getResponse()
```

### 注册路由

```lua
RegisterRoute("GET", "/server/status", function(req)
    return Response.okWithData({
        status = "online",
        timestamp = os.time()
    }, "获取成功")
end, {
    auth_required = false
})
```

### 返回数据

```lua

{
    "code": 0, -- 状态码 0 成功 7 失败
    "data": {}, -- 返回数据
    "msg": "获取成功" -- 返回消息
}
```

### 返回消息

```lua
-- 成功返回消息
Response.okWithMsg(msg)
-- 成功返回数据
Response.okWithData(data, msg)
-- 失败返回数据
Response.failWithData(data, msg)
-- 返回错误
Response.failWithMsg(msg)
```

## 🤝 贡献指南

我们欢迎所有贡献者为这个项目做出贡献。


## ☕️ 赞助

如果你觉得这个项目对你有帮助，可以请我喝杯咖啡。

<div align="center" style="margin-top: 20px; margin-bottom: 20px; ">

<img src="https://github.com/user-attachments/assets/91731d85-c8eb-47b8-95f9-4df2e23aee6b" width="300" alt="赞助二维码" />

</div>
