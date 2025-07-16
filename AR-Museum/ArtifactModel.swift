//
//  ArtifactModel.swift
//  AR-Museum
//
//  Created for AR-Museum on 2023/10/25.
//

import Foundation
import SwiftUI
import Combine

// Model representation for museum artifacts
struct Artifact: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let period: String
    let height: String
    let modelName: String
    
    // Additional properties can be added as needed
    let discoveryLocation: String?
    let materialType: String?
    let displayLocation: String?
}

// View model for artifacts
class ArtifactViewModel: ObservableObject {
    @Published var artifacts: [Artifact] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // 初始化时不预加载数据
    }
    
    // 这个方法不再使用，但保留作为参考
    private func loadSampleArtifacts() {
        self.artifacts = [
            Artifact(
                id: "1", 
                name: "青铜器", 
                description: "战国时期的青铜礼器，具有精美的纹饰和历史价值。这件文物代表了中国古代青铜铸造技术的巅峰。青铜器表面的纹饰反映了当时人们的审美观念和宗教信仰。", 
                period: "战国时期", 
                height: "32厘米", 
                modelName: "bronzeVessel",
                discoveryLocation: "河南安阳",
                materialType: "青铜",
                displayLocation: "一号展厅"
            ),
            Artifact(
                id: "2", 
                name: "唐三彩马", 
                description: "唐代三彩陶瓷艺术品，色彩艳丽，造型生动。这种多彩釉陶是唐代的代表性艺术。唐三彩以其鲜艳的色彩和精湛的工艺在中国陶瓷史上占有重要地位。", 
                period: "唐代", 
                height: "28厘米", 
                modelName: "tangHorse",
                discoveryLocation: "陕西西安",
                materialType: "陶瓷",
                displayLocation: "二号展厅"
            ),
            Artifact(
                id: "3", 
                name: "玉器", 
                description: "新石器时期的精美玉雕，展示了远古工匠高超的雕刻技艺。玉在中国文化中象征美德与权力。这件玉器的造型简约而富有表现力，反映了新石器时代人们的审美观。", 
                period: "新石器时代", 
                height: "15厘米", 
                modelName: "jadeArtifact",
                discoveryLocation: "浙江余杭",
                materialType: "和田玉",
                displayLocation: "三号展厅"
            )
        ]
    }
    
    // Method to fetch artifacts from a remote API
    func fetchArtifacts() {
        isLoading = true
        errorMessage = nil
        
        // 清空现有数据，避免重复
        self.artifacts = []
        
        // 只加载故宫文物数据
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.loadPalaceMuseumArtifacts()
            self.isLoading = false
        }
    }
    
    // Method to get a specific artifact by ID
    func getArtifact(byId id: String) -> Artifact? {
        return artifacts.first { $0.id == id }
    }
} 