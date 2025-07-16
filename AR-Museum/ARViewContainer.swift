//
//  ARViewContainer.swift
//  AR-Museum
//
//  Created for AR-Museum on 2023/10/25.
//

import SwiftUI
import RealityKit
import ARKit
import Combine

// AR View Container for displaying artifacts in AR
struct ARViewContainer: View {
    let artifact: Artifact
    @Environment(\.presentationMode) var presentationMode
    @State private var modelScale: Float = 0.01 // 保留缩放值用于模型大小调整
    @State private var isModelPlaced = false
    @State private var isRecording = false
    @State private var currentModelName: String
    
    init(artifact: Artifact) {
        self.artifact = artifact
        // 初始化当前模型名称
        _currentModelName = State(initialValue: artifact.modelName)
    }
    
    var body: some View {
        ZStack {
            // AR View
            ARModelView(modelName: currentModelName, scale: $modelScale, isPlaced: $isModelPlaced)
                .edgesIgnoringSafeArea(.all)
                .id(currentModelName) // 添加ID以强制在模型变化时重新创建视图
            
            // UI Elements
            VStack {
                // Top controls
                HStack {
                    // Back button
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .padding(.leading, 20)
                    
                    Spacer()
                    
                    // Record button
                    Button(action: {
                        isRecording.toggle()
                    }) {
                        Circle()
                            .fill(isRecording ? Color.red : Color.red.opacity(0.7))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Group {
                                    if isRecording {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.white)
                                            .frame(width: 16, height: 16)
                                    } else {
                                        Circle()
                                            .stroke(Color.white, lineWidth: 2)
                                            .frame(width: 30, height: 30)
                                    }
                                }
                            )
                    }
                    .padding(.trailing, 20)
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Instruction card
                if !isModelPlaced {
                    HStack {
                        Image(systemName: "arrow.up.and.down.and.arrow.left.and.right")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text("移动设备以扫描表面，然后点击放置按钮")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .padding(.bottom, 100)
                }
                
                // Bottom controls
                HStack(spacing: 20) {
                    // Reset button
                    Button(action: {
                        isModelPlaced = false
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    
                    // Place button
                    Button(action: {
                        withAnimation {
                            isModelPlaced = true
                        }
                    }) {
                        if isModelPlaced {
                            Image(systemName: "checkmark")
                                .font(.system(size: 24))
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.white)
                                .clipShape(Circle())
                                .frame(width: 70, height: 70)
                        } else {
                            Image(systemName: "plus")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .padding()
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                                .frame(width: 70, height: 70)
                        }
                    }
                    
                    // Share button
                    Button(action: {
                        // Share functionality would go here
                        shareARExperience()
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
                .padding(.bottom, 40)
            }
            
            // 移除了左侧的文物选择框和右侧的缩放滑块
        }
    }
    
    // Function to share the AR experience
    private func shareARExperience() {
        // In a real app, this would capture a screenshot or recording
        // and share it via the system share sheet
        print("Sharing AR experience")
    }
}

// AR View for displaying models in AR
struct ARModelView: UIViewRepresentable {
    let modelName: String
    @Binding var scale: Float
    @Binding var isPlaced: Bool
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // Configure AR session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        arView.session.run(config)
        
        // Set up coaching overlay
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.session = arView.session
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.goal = .horizontalPlane
        arView.addSubview(coachingOverlay)
        
        // Add tap gesture for placing model
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
        
        // Store arView in coordinator
        context.coordinator.arView = arView
        context.coordinator.modelName = modelName
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        context.coordinator.scale = scale
        
        // 检查模型名称是否已更改
        if context.coordinator.modelName != modelName {
            context.coordinator.modelName = modelName
            
            // 如果模型已放置，则重新加载新模型
            if isPlaced && context.coordinator.isPlaced {
                context.coordinator.resetPlacement()
                if isPlaced {
                    context.coordinator.placeModel()
                }
            }
        }
        
        // Update model scale if it exists
        if let modelEntity = context.coordinator.modelEntity {
            modelEntity.scale = [scale, scale, scale]
        }
        
        // Handle model placement state
        if isPlaced != context.coordinator.isPlaced {
            context.coordinator.isPlaced = isPlaced
            if isPlaced {
                context.coordinator.placeModel()
            } else {
                context.coordinator.resetPlacement()
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: ARModelView
        var arView: ARView?
        var modelEntity: ModelEntity?
        var placementAnchor: AnchorEntity?
        var modelName: String = ""
        var scale: Float = 1.0
        var isPlaced: Bool = false
        private var cancellables = Set<AnyCancellable>()
        
        init(_ parent: ARModelView) {
            self.parent = parent
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let arView = arView else { return }
            
            if !isPlaced {
                // Check if we hit a plane
                let location = gesture.location(in: arView)
                if let result = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal).first {
                    isPlaced = true
                    parent.isPlaced = true
                    
                    // 创建锚点并调整位置
                    let anchor = AnchorEntity(world: result.worldTransform)
                    
                    // 稍微调整高度，使模型放置在平面上方一点
                    var position = anchor.position
                    position.y += 0.01 // 增加一点高度，避免模型嵌入平面
                    anchor.position = position
                    
                    arView.scene.addAnchor(anchor)
                    
                    // Load and place model
                    placementAnchor = anchor
                    loadAndPlaceModel()
                }
            }
        }
        
        func placeModel() {
            guard !isPlaced else { return }
            
            // Find a plane to place the model on
            guard let arView = arView,
                  let query = arView.makeRaycastQuery(from: arView.center, 
                                                     allowing: .estimatedPlane, 
                                                     alignment: .horizontal),
                  let result = arView.session.raycast(query).first else {
                return
            }
            
            isPlaced = true
            
            // 创建锚点并调整位置
            let anchor = AnchorEntity(world: result.worldTransform)
            
            // 稍微调整高度，使模型放置在平面上方一点
            var position = anchor.position
            position.y += 0.01 // 增加一点高度，避免模型嵌入平面
            anchor.position = position
            
            arView.scene.addAnchor(anchor)
            
            // Load and place model
            placementAnchor = anchor
            loadAndPlaceModel()
        }
        
        func loadAndPlaceModel() {
            guard let anchor = placementAnchor else { return }
            
            // Use ModelLoader to load the model
            ModelLoader.shared.loadModel(named: modelName)
                .sink(receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        print("Failed to load model: \(error)")
                        self?.loadFallbackModel()
                    }
                }, receiveValue: { [weak self] model in
                    guard let self = self else { return }
                    
                    // 根据不同的文物模型设置不同的缩放比例
                    var baseScale: Float = 0.05 // 默认缩放比例更小
                    
                    switch self.modelName {
                    case "成化款斗彩鸡缸杯":
                        baseScale = 0.003 // 鸡缸杯较小
                    case "龙泉窑青釉凸雕缠枝莲纹瓶":
                        baseScale = 0.004 // 龙泉瓶中等大小
                    case "斗彩海兽纹天字罐":
                        baseScale = 0.0035 // 天字罐中等偏小
                    case "嘉靖款五彩鱼藻纹盖罐":
                        baseScale = 0.004 // 鱼藻罐中等大小
                    case "光绪款粉彩云蝠纹赏瓶":
                        baseScale = 0.0035 // 云蝠瓶中等偏小
                    default:
                        baseScale = 0.005
                    }
                    
                    // 应用用户设置的缩放比例
                    let finalScale = baseScale * self.scale
                    model.scale = [finalScale, finalScale, finalScale]
                    
                    // Add model to anchor
                    anchor.addChild(model)
                    self.modelEntity = model
                    
                    // Add continuous rotation if desired - uncomment to enable rotation in AR mode
                    // model.addRotationAnimation(axis: [0, 1, 0], period: 20.0, clockwise: true)
                })
                .store(in: &cancellables)
        }
        
        func loadFallbackModel() {
            // Create a placeholder model if loading fails
            guard let anchor = placementAnchor else { return }
            
            let fallbackModel = ModelLoader.shared.createPlaceholderModel()
            // 缩小占位模型的大小
            let baseScale: Float = 0.003
            let finalScale = baseScale * scale
            fallbackModel.scale = [finalScale, finalScale, finalScale]
            
            anchor.addChild(fallbackModel)
            self.modelEntity = fallbackModel
            
            // Optionally add rotation to the fallback model
            // fallbackModel.addRotationAnimation(axis: [0, 1, 0], period: 20.0, clockwise: true)
        }
        
        func resetPlacement() {
            // Remove the current model and anchor
            if let anchor = placementAnchor {
                arView?.scene.removeAnchor(anchor)
            }
            
            // If we have a model entity, stop its rotation animation
            if let entity = modelEntity {
                entity.stopRotationAnimation()
            }
            
            placementAnchor = nil
            modelEntity = nil
            isPlaced = false
        }
    }
} 