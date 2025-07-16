//
//  ContentView.swift
//  AR-Museum
//
//  Created by JaedenXu on 2025/7/15.
//

import SwiftUI
import RealityKit
import ARKit
import Combine

struct ContentView : View {
    @StateObject private var viewModel = ArtifactViewModel()
    @State private var selectedArtifactIndex = 0
    @State private var showARView = false
    @State private var isCardExpanded = false  // 添加状态跟踪卡片是否展开
    
    // 定义卡片高度的比例常量
    private let collapsedCardHeightRatio: CGFloat = 0.4
    private let expandedCardHeightRatio: CGFloat = 0.6  // 增大展开时的高度比例
    
    var body: some View {
        ZStack {
            // Background
            Color.black.edgesIgnoringSafeArea(.all)
            
            if viewModel.isLoading {
                // Loading view
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            } else if let errorMessage = viewModel.errorMessage {
                // Error view
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.yellow)
                        .padding()
                    
                    Text(errorMessage)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Button("重试") {
                        viewModel.fetchArtifacts()
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                }
                .padding()
            } else if viewModel.artifacts.isEmpty {
                // No artifacts view
                VStack {
                    Image(systemName: "tray")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                        .padding()
                    
                    Text("没有找到文物")
                        .foregroundColor(.white)
                        .padding()
                }
                .padding()
            } else {
                // Main content when we have artifacts
                ZStack(alignment: .bottom) {  // 使用ZStack并设置底部对齐
                    // Main content
                    ZStack {
                        // 3D Model View - 固定高度，可被卡片覆盖
                        ArtifactModelView(modelName: viewModel.artifacts[selectedArtifactIndex].modelName)
                            .edgesIgnoringSafeArea(.all)
                            .frame(height: UIScreen.main.bounds.height * 0.6)
                            .id(viewModel.artifacts[selectedArtifactIndex].modelName) // 添加ID以强制在模型变化时重新创建视图
                            .offset(y: -UIScreen.main.bounds.height * 0.25) // 向上移动模型，防止被卡片遮挡
                        
                        // AR Button
                        VStack {
                            HStack {
                                Spacer()
                                Button(action: {
                                    showARView = true
                                }) {
                                    Image(systemName: "arkit")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(.ultraThinMaterial)
                                        .clipShape(Circle())
                                }
                                .padding(.trailing, 20)
                            }
                            Spacer()
                        }
                        .padding(.top, 20)
                        .zIndex(3)  // 确保AR按钮始终在最顶层
                        .offset(y: -UIScreen.main.bounds.height * 0.15) // 与模型保持一致的偏移
                        
                        // Swipe indicators
                        HStack {
                            Button(action: {
                                withAnimation {
                                    selectedArtifactIndex = max(0, selectedArtifactIndex - 1)
                                    // 切换文物时折叠卡片
                                    isCardExpanded = false
                                }
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white.opacity(0.7))
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                            }
                            .opacity(selectedArtifactIndex > 0 ? 1 : 0.3)
                            
                            Spacer()
                            
                            Button(action: {
                                withAnimation {
                                    selectedArtifactIndex = min(viewModel.artifacts.count - 1, selectedArtifactIndex + 1)
                                    // 切换文物时折叠卡片
                                    isCardExpanded = false
                                }
                            }) {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white.opacity(0.7))
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                            }
                            .opacity(selectedArtifactIndex < viewModel.artifacts.count - 1 ? 1 : 0.3)
                        }
                        .padding(.horizontal)
                        .zIndex(3)  // 确保左右滑动按钮在最顶层
                        .offset(y: -UIScreen.main.bounds.height * 0.15) // 与模型保持一致的偏移
                    }
                    .zIndex(1)  // 设置模型区域的Z轴层级
                    .padding(.top, UIScreen.main.bounds.height * 0.1)  // 增加顶部间距，确保模型完全可见
                    
                    // Information card - 可拉伸覆盖部分
                    VStack(alignment: .leading, spacing: 15) {
                        // Handle bar - 添加拖动提示
                        HStack {
                            Spacer()
                            RoundedRectangle(cornerRadius: 2.5)
                                .fill(Color.white.opacity(0.3))
                                .frame(width: 40, height: 5)
                            Spacer()
                        }
                        .padding(.top, 5)
                        .padding(.bottom, 5)
                        .contentShape(Rectangle())  // 确保整个区域可点击
                        .onTapGesture {
                            withAnimation(.spring()) {
                                isCardExpanded.toggle()
                            }
                        }
                        
                        // Header
                        HStack(alignment: .top) {  // 设置为顶部对齐，处理多行情况
                            Text(viewModel.artifacts[selectedArtifactIndex].name)
                                .font(.title)
                                .fontWeight(.bold)
                                .lineLimit(isCardExpanded ? nil : 1)  // 折叠状态下只显示一行
                                .truncationMode(.tail)  // 超出部分用省略号
                                .frame(maxWidth: .infinity, alignment: .leading)  // 确保文本使用可用的最大宽度
                            
                            Text(viewModel.artifacts[selectedArtifactIndex].period)
                                .font(.subheadline)
                                .padding(8)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(8)
                                .fixedSize(horizontal: true, vertical: false)  // 保持朝代标签固定宽度
                        }
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: 15) {
                                // 文物描述
                                Text(viewModel.artifacts[selectedArtifactIndex].description)
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.8))
                                    .lineLimit(isCardExpanded ? nil : 5)  // 展开时不限制行数
                                
                                // Additional info - 确保信息完整显示
                                VStack(alignment: .leading, spacing: 10) {
                                    
                                    // Basic info
                                    HStack(spacing: 12) {
                                        Label("高度: \(viewModel.artifacts[selectedArtifactIndex].height)", systemImage: "ruler")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.7))
                                            .padding(8)
                                            .background(Color.white.opacity(0.1))
                                            .cornerRadius(8)
                                        
                                        if let material = viewModel.artifacts[selectedArtifactIndex].materialType {
                                            Label(material, systemImage: "circle.fill")
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.7))
                                                .padding(8)
                                                .background(Color.white.opacity(0.1))
                                                .cornerRadius(8)
                                        }
                                    }
                                    .padding(.vertical, 5)
                                    
                                    // Discovery info and Display location in one row
                                    HStack(spacing: 12) {
                                        if let location = viewModel.artifacts[selectedArtifactIndex].discoveryLocation {
                                            Label("出土地: \(location)", systemImage: "map")
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.7))
                                                .padding(8)
                                                .background(Color.white.opacity(0.1))
                                                .cornerRadius(8)
                                                .fixedSize(horizontal: false, vertical: true)  // 允许文本换行
                                        }
                                        
                                        if let displayLocation = viewModel.artifacts[selectedArtifactIndex].displayLocation {
                                            Label("展厅: \(displayLocation)", systemImage: "building.2")
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.7))
                                                .padding(8)
                                                .background(Color.white.opacity(0.1))
                                                .cornerRadius(8)
                                                .fixedSize(horizontal: false, vertical: true)  // 允许文本换行
                                        }
                                    }
                                    .padding(.vertical, 5)
                                }
                            }
                            .padding(.bottom, isCardExpanded ? 30 : 0)  // 展开状态添加底部间距
                        }
                        
                        // 删除提示箭头部分
                    }
                    .padding()
                    .frame(maxHeight: UIScreen.main.bounds.height * (isCardExpanded ? expandedCardHeightRatio : collapsedCardHeightRatio))
                    .background(.ultraThinMaterial)
                    .cornerRadius(30, corners: [.topLeft, .topRight])
                    .zIndex(2)  // 展开时可以覆盖在模型上方
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                // 仅处理向上拖动
                                if gesture.translation.height < 0 && !isCardExpanded {
                                    if gesture.translation.height < -30 {  // 拖动超过阈值才切换状态
                                        withAnimation(.spring()) {
                                            isCardExpanded = true
                                        }
                                    }
                                } else if gesture.translation.height > 0 && isCardExpanded {
                                    if gesture.translation.height > 30 {  // 拖动超过阈值才切换状态
                                        withAnimation(.spring()) {
                                            isCardExpanded = false
                                        }
                                    }
                                }
                            }
                    )
                    .animation(.spring(), value: isCardExpanded)  // 添加动画
                }
                
                .fullScreenCover(isPresented: $showARView) {
                    ARViewContainer(artifact: viewModel.artifacts[selectedArtifactIndex])
                }
                .gesture(
                    DragGesture(minimumDistance: 20, coordinateSpace: .global)
                        .onEnded { value in
                            let horizontalAmount = value.translation.width
                            let verticalAmount = value.translation.height
                            
                            // 只在卡片未展开时处理水平滑动
                            if !isCardExpanded && abs(horizontalAmount) > abs(verticalAmount) {
                                if horizontalAmount < -50 && selectedArtifactIndex < viewModel.artifacts.count - 1 {
                                    withAnimation {
                                        selectedArtifactIndex += 1
                                    }
                                } else if horizontalAmount > 50 && selectedArtifactIndex > 0 {
                                    withAnimation {
                                        selectedArtifactIndex -= 1
                                    }
                                }
                            }
                        }
                )
            }
        }
        .onAppear {
            // Load artifacts when the view appears
            viewModel.fetchArtifacts()
        }
    }
}

// Extension for rounded corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// View for displaying 3D models
struct ArtifactModelView: View {
    let modelName: String
    @State private var isLoading = true
    @State private var loadError: Error?
    
    var body: some View {
        // Display the 3D model using RealityKit
        ZStack {
            // Here we'll display a rotating 3D model
            RealityView { content in
                // Create a container anchor for our model
                let anchor = AnchorEntity()
                
                // Try to load the model from ModelLoader
                Task {
                    do {
                        let modelEntity = try await ModelEntity.loadModel(named: modelName)
                        
                        // 根据不同的文物调整缩放比例
                        switch modelName {
                        case "成化款斗彩鸡缸杯":
                            modelEntity.scale = [0.1, 0.1, 0.1]
                        case "龙泉窑青釉凸雕缠枝莲纹瓶":
                            modelEntity.scale = [0.1, 0.1, 0.1]
                        case "斗彩海兽纹天字罐":
                            modelEntity.scale = [0.08, 0.08, 0.08]
                        case "嘉靖款五彩鱼藻纹盖罐":
                            modelEntity.scale = [0.1, 0.1, 0.1]
                        case "光绪款粉彩云蝠纹赏瓶":
                            modelEntity.scale = [0.1, 0.1, 0.1]
                        default:
                            modelEntity.scale = [0.1, 0.1, 0.1]
                        }
                        
                        // Add the model to the anchor
                        anchor.addChild(modelEntity)
                        
                        // Add a rotation animation using our improved RotationAnimation class
                        modelEntity.addRotationAnimation(axis: [0, 1, 0], period: 10.0, clockwise: true)
                        
                        // 更新UI状态
                        await MainActor.run {
                            isLoading = false
                        }
                        
                    } catch {
                        // If loading fails, create a placeholder
                        print("Failed to load model \(modelName): \(error)")
                        let box = ModelLoader.shared.createPlaceholderModel()
                        box.scale = [0.1, 0.1, 0.1]
                        anchor.addChild(box)
                        
                        // Add rotation to placeholder as well
                        box.addRotationAnimation(axis: [0, 1, 0], period: 10.0, clockwise: true)
                        
                        // 更新UI状态
                        await MainActor.run {
                            isLoading = false
                            loadError = error
                        }
                    }
                }
                
                // Position the anchor in front of the camera
                anchor.position = [0, 0, -0.5]
                content.add(anchor)
            }
            
            // 显示加载状态
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
            
            // 显示错误信息
            if let error = loadError {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 30))
                        .foregroundColor(.yellow)
                    Text("无法加载模型")
                        .foregroundColor(.white)
                        .padding(.top, 8)
                    Text(error.localizedDescription)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
            }
        }
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
