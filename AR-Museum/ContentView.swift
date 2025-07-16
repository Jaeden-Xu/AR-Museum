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
                VStack(spacing: 0) {
                    // Main content
                    ZStack {
                        // 3D Model View
                        ArtifactModelView(modelName: viewModel.artifacts[selectedArtifactIndex].modelName)
                            .edgesIgnoringSafeArea(.all)
                            .frame(height: UIScreen.main.bounds.height * 0.6)
                            .id(viewModel.artifacts[selectedArtifactIndex].modelName) // 添加ID以强制在模型变化时重新创建视图
                        
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
                        
                        // Swipe indicators
                        HStack {
                            Button(action: {
                                withAnimation {
                                    selectedArtifactIndex = max(0, selectedArtifactIndex - 1)
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
                        
                        // Artifact dots (navigation)
                        VStack {
                            Spacer()
                            HStack(spacing: 8) {
                                ForEach(0..<viewModel.artifacts.count, id: \.self) { index in
                                    Circle()
                                        .fill(index == selectedArtifactIndex ? Color.white : Color.white.opacity(0.3))
                                        .frame(width: 8, height: 8)
                                        .scaleEffect(index == selectedArtifactIndex ? 1.2 : 1.0)
                                }
                            }
                            .padding(.bottom, 20)
                        }
                    }
                    
                    // Information card
                    VStack(alignment: .leading, spacing: 15) {
                        // Handle bar
                        HStack {
                            Spacer()
                            RoundedRectangle(cornerRadius: 2.5)
                                .fill(Color.white.opacity(0.3))
                                .frame(width: 40, height: 5)
                            Spacer()
                        }
                        .padding(.top, 5)
                        
                        // Header
                        HStack {
                            Text(viewModel.artifacts[selectedArtifactIndex].name)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Text(viewModel.artifacts[selectedArtifactIndex].period)
                                .font(.subheadline)
                                .padding(8)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(8)
                        }
                        
                        // Details
                        Text(viewModel.artifacts[selectedArtifactIndex].description)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                        
                        // Additional info
                        VStack(alignment: .leading, spacing: 10) {
                            // Basic info
                            HStack {
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
                            
                            // Discovery info
                            if let location = viewModel.artifacts[selectedArtifactIndex].discoveryLocation {
                                Label("出土地: \(location)", systemImage: "map")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                                    .padding(8)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            
                            // Display location
                            if let displayLocation = viewModel.artifacts[selectedArtifactIndex].displayLocation {
                                Label("展厅: \(displayLocation)", systemImage: "building.2")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                                    .padding(8)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .frame(maxHeight: UIScreen.main.bounds.height * 0.4)
                    .background(.ultraThinMaterial)
                    .cornerRadius(30, corners: [.topLeft, .topRight])
                }
                
                .fullScreenCover(isPresented: $showARView) {
                    ARViewContainer(artifact: viewModel.artifacts[selectedArtifactIndex])
                }
                .gesture(
                    DragGesture(minimumDistance: 20, coordinateSpace: .global)
                        .onEnded { value in
                            let horizontalAmount = value.translation.width
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
