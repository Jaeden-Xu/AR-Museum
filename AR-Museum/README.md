# AR Museum Application

一个基于RealityKit和SwiftUI开发的AR博物馆应用，可以展示3D文物模型并提供AR交互体验。

## 功能特点

- 3D文物模型展示与交互
- 文物信息卡片展示
- 左右滑动切换不同文物
- AR模式，可在真实环境中放置和交互文物
- 玻璃态设计(Glassmorphism)效果
- 响应式交互

## 技术栈

- Swift
- SwiftUI
- RealityKit
- ARKit
- Combine

## 项目结构

```
AR-Museum/
├── AppDelegate.swift       # 应用入口
├── ContentView.swift       # 主内容视图
├── ARViewContainer.swift   # AR视图容器
├── ArtifactModel.swift     # 文物数据模型
├── ModelLoader.swift       # 3D模型加载器
├── RotationAnimation.swift # 旋转动画工具
├── ModelPlaceholder.swift  # 模型占位符生成工具
└── Assets.xcassets         # 资源文件
```

## 运行要求

- iOS 14.0+
- Xcode 13.0+
- 支持ARKit的iOS设备

## 使用说明

1. 主界面中可以通过左右滑动或点击箭头切换不同文物
2. 点击AR按钮可进入AR模式，在真实环境中放置文物
3. AR模式中可通过侧边滑块调整文物大小
4. AR模式中可选择不同文物进行展示

## 文物模型

应用中包含以下几种文物模型：

1. 青铜器 - 战国时期，展示了中国古代青铜铸造技术
2. 唐三彩马 - 唐代，展示了唐代的代表性陶瓷工艺
3. 玉器 - 新石器时代，展示了远古工匠的玉石雕刻技艺

## 未来计划

- 添加更多文物模型
- 实现文物标注功能
- 添加语音讲解
- 实现多人协作AR体验
- 集成更多互动元素 