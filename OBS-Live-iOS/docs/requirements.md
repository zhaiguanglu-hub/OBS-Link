# iOS版OBS App软件开发需求文档

## 1. 项目概述

- 项目名称：OBS Live for iOS (暂定名)
- 项目简介：一款功能强大、界面简洁美观的iOS移动端直播推流应用，支持自定义RTMP推流。
- 目标用户：移动端内容创作者、游戏主播、生活分享者、企业用户。
- 开发工具：Xcode（主）、Cursor（辅）。
- 技术栈：Swift/SwiftUI + AVFoundation/CoreVideo + HaishinKit（RTMP）。

## 2. 功能需求

### 2.1 核心推流功能
- 输入源管理：前后摄像头切换、麦克风音频、（可扩展）屏幕录制（ReplayKit）。
- 推流设置：
  - 自定义RTMP URL
  - 视频配置：分辨率预设（720p/1080p/设备最高）、帧率（24/30/60fps）、码率（kbps，含自动）
  - 音频配置：采样率（44.1/48kHz）、码率
- 推流控制：开始/停止，状态显示（连接中/直播中/断开、时长、码率）。

### 2.2 设置与偏好
- 视频预设模板：保存多组（分辨率+帧率+码率）。
- 方向锁定：横/竖屏锁定。
- 基础美颜/滤镜（可选）。
- 应用设置：状态栏统计、触屏对焦。

### 2.3 监控与反馈
- 状态信息显示：实时分辨率、帧率、码率、网络状态。
- 简单统计：直播结束摘要（时长、平均码率）。

## 3. 非功能需求

### 3.1 性能需求
- 低延迟、低功耗、合理CPU/内存占用。

### 3.2 可用性
- 界面简洁、操作流畅、首次启动引导。

### 3.3 兼容性
- iOS 15+，适配全面屏iPhone机型。

## 4. UI/UX原则
- 现代简约风格，SF Symbols图标。
- 主界面：大预览 + 底部半透明控制栏（开始/切换/设置）。
- 设置界面：Form结构分组。
- Haptic反馈：开始/结束直播时震动反馈。

## 5. 实施建议（Cursor + Xcode）
1. 项目搭建（SwiftUI，配置权限）。
2. 依赖管理：SPM添加HaishinKit；如需FFmpeg可后续评估。
3. 模块划分：
   - StreamingManager.swift
   - SettingsViewModel.swift
   - CameraPreviewView.swift
   - StatsOverlayView.swift
4. 测试与调试：真机 + Instruments。
5. 部署：TestFlight 内测，App Store 上线。

## 6. 版本规划（Roadmap）
- V1.0：核心推流、可调画质、基础UI与状态。
- V1.5：预设模板、简单滤镜、历史记录。
- V2.0：屏幕采集（ReplayKit扩展）、多平台推流、高级音频。

本文档与 README 及 /docs/ROADMAP.md 同步维护。