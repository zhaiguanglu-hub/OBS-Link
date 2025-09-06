# OBS Live for iOS

一款功能强大、界面简洁美观的iOS移动端直播推流应用，让用户能够轻松地以高质量的视频分辨率和帧率进行直播，并推送到自定义的RTMP服务器。

## 🚀 功能特性

### 核心功能
- **高质量视频推流**: 支持720p、1080p等多种分辨率
- **灵活帧率控制**: 支持24fps、30fps、60fps可调帧率
- **智能码率管理**: 自动或手动设置视频码率，优化推流质量
- **RTMP服务器支持**: 兼容Twitch、YouTube、Bilibili等主流平台
- **实时监控**: 显示推流状态、码率、网络速度等统计信息

### 用户体验
- **现代化UI**: 采用SwiftUI构建，符合iOS设计规范
- **直观操作**: 简洁的控制界面，一键开始/停止直播
- **预设管理**: 保存和快速切换不同场景的直播配置
- **状态反馈**: 实时显示连接状态和推流质量

### 设备兼容
- **iOS 15.0+**: 支持最新iOS系统特性
- **全面屏适配**: 完美适配iPhone X至iPhone 15系列
- **相机控制**: 前后摄像头切换，触摸对焦

## 🛠 技术架构

### 开发环境
- **Xcode**: iOS应用编译、调试和上架
- **Cursor**: Swift代码编写和AI辅助开发
- **Swift Package Manager**: 依赖管理

### 技术栈
- **Swift + SwiftUI**: 现代化iOS开发
- **HaishinKit**: 高性能RTMP推流库
- **AVFoundation**: 音视频处理
- **Combine**: 响应式编程

### 项目结构
```
OBSLive/
├── Managers/
│   └── StreamingManager.swift      # 核心推流管理
├── ViewModels/
│   └── SettingsViewModel.swift     # 设置数据管理
├── Views/
│   ├── ContentView.swift           # 主界面
│   ├── CameraPreviewView.swift     # 相机预览
│   ├── SettingsView.swift          # 设置界面
│   └── StatsOverlayView.swift      # 统计信息覆盖层
└── Assets.xcassets/                # 应用资源
```

## 📱 界面设计

### 主界面
- **全屏相机预览**: 实时显示摄像头画面
- **底部控制栏**: 包含开始直播、设置、切换摄像头按钮
- **状态指示器**: 显示连接状态和推流质量
- **统计信息**: 可展开的实时数据监控

### 设置界面
- **服务器配置**: RTMP URL输入和验证
- **视频设置**: 分辨率、帧率、码率配置
- **音频设置**: 采样率、音频码率调整
- **预设管理**: 保存和应用不同场景配置

## 🔧 配置说明

### RTMP服务器设置
支持标准RTMP协议的流媒体服务器：
- **Twitch**: `rtmp://live.twitch.tv/app/YOUR_STREAM_KEY`
- **YouTube**: `rtmp://a.rtmp.youtube.com/live2/YOUR_STREAM_KEY`
- **Bilibili**: `rtmp://live-push.bilivideo.com/live-bvc/YOUR_STREAM_KEY`
- **自定义服务器**: `rtmp://your-server.com/app/stream_key`

### 推荐设置
| 场景 | 分辨率 | 帧率 | 视频码率 | 音频码率 |
|------|--------|------|----------|----------|
| 高清流畅 | 720p | 30fps | 2500kbps | 128kbps |
| 超高清 | 1080p | 30fps | 5000kbps | 192kbps |
| 省流模式 | 480p | 24fps | 1000kbps | 64kbps |

## 🚀 快速开始

### 环境要求
- macOS 12.0+
- Xcode 14.0+
- iOS 15.0+ 设备

### 安装步骤
1. **克隆项目**
   ```bash
   git clone https://github.com/your-username/obs-live-ios.git
   cd obs-live-ios
   ```

2. **打开项目**
   ```bash
   open OBSLive.xcodeproj
   ```

3. **安装依赖**
   项目使用Swift Package Manager，Xcode会自动解析依赖

4. **配置开发者账号**
   - 在Xcode中设置您的Apple Developer账号
   - 修改Bundle Identifier为您的唯一标识符

5. **运行应用**
   - 选择目标设备（真机测试推荐）
   - 点击运行按钮开始调试

### 首次使用
1. **权限授权**: 应用启动时会请求相机和麦克风权限
2. **服务器配置**: 在设置中输入您的RTMP服务器地址
3. **参数调整**: 根据网络状况选择合适的分辨率和码率
4. **开始直播**: 点击主界面的直播按钮开始推流

## 🔒 隐私说明

### 权限使用
- **相机权限**: 用于视频采集和直播推流
- **麦克风权限**: 用于音频采集和直播推流
- **网络权限**: 用于RTMP推流和数据传输

### 数据处理
- 所有音视频数据仅用于实时推流，不进行本地存储
- 用户设置数据仅保存在设备本地，不上传至服务器
- 应用不收集用户个人信息或使用数据

## 🤝 贡献指南

欢迎提交Issue和Pull Request来帮助改进项目！

### 开发规范
- 使用Swift 5.0+语法
- 遵循iOS Human Interface Guidelines
- 编写清晰的代码注释
- 提交前进行充分测试

### 问题反馈
如果您遇到问题或有功能建议，请：
1. 查看现有Issues
2. 创建详细的Issue描述
3. 提供复现步骤和设备信息

## 📄 开源协议

本项目采用 MIT 协议开源，详见 [LICENSE](LICENSE) 文件。

## 🙏 致谢

- [HaishinKit](https://github.com/shogo4405/HaishinKit.swift) - 优秀的Swift RTMP推流库
- [SF Symbols](https://developer.apple.com/sf-symbols/) - Apple官方图标库
- iOS开发社区的支持和贡献

---

**OBS Live for iOS** - 让移动直播更简单、更专业 🎥✨