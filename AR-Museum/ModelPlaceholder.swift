//
//  ModelPlaceholder.swift
//  AR-Museum
//
//  Created for AR-Museum on 2023/10/25.
//

import Foundation
import RealityKit
import UIKit

/// Utility class for creating placeholder 3D models
class ModelPlaceholder {
    
    /// Creates a simple procedural model for the given artifact when no actual USDZ model is available
    /// - Parameter artifactName: The name/type of artifact to generate a placeholder for
    /// - Returns: A ModelEntity representing the artifact
    static func createPlaceholder(for artifactName: String) -> ModelEntity {
        
        switch artifactName.lowercased() {
        case "bronzevessel":
            return createBronzeVessel()
        case "tanghorse":
            return createTangHorse()
        case "jadeartifact":
            return createJadeArtifact()
        // 故宫文物模型占位
        case "成化款斗彩鸡缸杯", "chickencup":
            return createChickenCup()
        case "龙泉窑青釉凸雕缠枝莲纹瓶", "celadonvase":
            return createCeladonVase()
        case "斗彩海兽纹天字罐", "seacreaturejar":
            return createSeaCreatureJar()
        case "嘉靖款五彩鱼藻纹盖罐", "fishjar":
            return createFishJar()
        case "光绪款粉彩云蝠纹赏瓶", "batpatternvase":
            return createBatPatternVase()
        default:
            return createDefaultPlaceholder()
        }
    }
    
    /// Create a placeholder bronze vessel model
    /// - Returns: A ModelEntity shaped like a bronze vessel
    private static func createBronzeVessel() -> ModelEntity {
        // Base
        let baseMesh = MeshResource.generateCylinder(height: 0.05, radius: 0.1)
        let baseMaterial = SimpleMaterial(color: .init(red: 0.6, green: 0.4, blue: 0.2, alpha: 1.0), roughness: 0.3, isMetallic: true)
        let baseEntity = ModelEntity(mesh: baseMesh, materials: [baseMaterial])
        baseEntity.position.y = 0.025
        
        // Body
        let bodyMesh = MeshResource.generateCylinder(height: 0.2, radius: 0.12)
        let bodyMaterial = SimpleMaterial(color: .init(red: 0.6, green: 0.4, blue: 0.2, alpha: 1.0), roughness: 0.3, isMetallic: true)
        let bodyEntity = ModelEntity(mesh: bodyMesh, materials: [bodyMaterial])
        bodyEntity.position.y = 0.15
        
        // Top rim
        let topMesh = MeshResource.generateCylinder(height: 0.02, radius: 0.13)
        let topEntity = ModelEntity(mesh: topMesh, materials: [bodyMaterial])
        topEntity.position.y = 0.26
        
        // Handles
        let handleMesh = MeshResource.generateBox(size: [0.02, 0.08, 0.05])
        let leftHandleEntity = ModelEntity(mesh: handleMesh, materials: [bodyMaterial])
        leftHandleEntity.position = [0.12, 0.15, 0]
        let rightHandleEntity = ModelEntity(mesh: handleMesh, materials: [bodyMaterial])
        rightHandleEntity.position = [-0.12, 0.15, 0]
        
        // Parent entity
        let vessel = ModelEntity()
        vessel.addChild(baseEntity)
        vessel.addChild(bodyEntity)
        vessel.addChild(topEntity)
        vessel.addChild(leftHandleEntity)
        vessel.addChild(rightHandleEntity)
        
        return vessel
    }
    
    /// Create a placeholder Tang dynasty horse model
    /// - Returns: A ModelEntity shaped like a horse
    private static func createTangHorse() -> ModelEntity {
        // Body
        let bodyMesh = MeshResource.generateBox(size: [0.2, 0.1, 0.3])
        let bodyMaterial = SimpleMaterial(color: .init(red: 0.8, green: 0.7, blue: 0.6, alpha: 1.0), roughness: 0.5, isMetallic: false)
        let bodyEntity = ModelEntity(mesh: bodyMesh, materials: [bodyMaterial])
        bodyEntity.position.y = 0.15
        
        // Head
        let headMesh = MeshResource.generateBox(size: [0.05, 0.1, 0.12])
        let headEntity = ModelEntity(mesh: headMesh, materials: [bodyMaterial])
        headEntity.position = [0, 0.25, 0.18]
        
        // Legs
        let legMesh = MeshResource.generateBox(size: [0.03, 0.15, 0.03])
        
        let frontLeftLegEntity = ModelEntity(mesh: legMesh, materials: [bodyMaterial])
        frontLeftLegEntity.position = [0.07, -0.05, 0.1]
        
        let frontRightLegEntity = ModelEntity(mesh: legMesh, materials: [bodyMaterial])
        frontRightLegEntity.position = [-0.07, -0.05, 0.1]
        
        let backLeftLegEntity = ModelEntity(mesh: legMesh, materials: [bodyMaterial])
        backLeftLegEntity.position = [0.07, -0.05, -0.1]
        
        let backRightLegEntity = ModelEntity(mesh: legMesh, materials: [bodyMaterial])
        backRightLegEntity.position = [-0.07, -0.05, -0.1]
        
        // Tail
        let tailMesh = MeshResource.generateBox(size: [0.02, 0.08, 0.02])
        let tailEntity = ModelEntity(mesh: tailMesh, materials: [bodyMaterial])
        tailEntity.position = [0, 0.15, -0.16]
        
        // Parent entity
        let horse = ModelEntity()
        horse.addChild(bodyEntity)
        horse.addChild(headEntity)
        horse.addChild(frontLeftLegEntity)
        horse.addChild(frontRightLegEntity)
        horse.addChild(backLeftLegEntity)
        horse.addChild(backRightLegEntity)
        horse.addChild(tailEntity)
        
        return horse
    }
    
    /// Create a placeholder jade artifact model
    /// - Returns: A ModelEntity shaped like a jade artifact
    private static func createJadeArtifact() -> ModelEntity {
        // Base
        let baseMesh = MeshResource.generateSphere(radius: 0.08)
        let baseMaterial = SimpleMaterial(color: .init(red: 0.6, green: 0.8, blue: 0.6, alpha: 1.0), roughness: 0.2, isMetallic: false)
        let baseEntity = ModelEntity(mesh: baseMesh, materials: [baseMaterial])
        
        // Decoration elements
        let decorMesh = MeshResource.generateSphere(radius: 0.015)
        
        for i in 0..<8 {
            let angle = Float(i) * (Float.pi / 4)
            let x = 0.08 * cos(angle)
            let z = 0.08 * sin(angle)
            
            let decorEntity = ModelEntity(mesh: decorMesh, materials: [baseMaterial])
            decorEntity.position = [x, 0, z]
            baseEntity.addChild(decorEntity)
        }
        
        // Top element
        let topMesh = MeshResource.generateSphere(radius: 0.02)
        let topEntity = ModelEntity(mesh: topMesh, materials: [baseMaterial])
        topEntity.position.y = 0.08
        baseEntity.addChild(topEntity)
        
        return baseEntity
    }
    
    /// Create a default placeholder for unknown artifacts
    /// - Returns: A simple placeholder ModelEntity
    static func createDefaultPlaceholder() -> ModelEntity {
        let mesh = MeshResource.generateBox(size: 0.15)
        let material = SimpleMaterial(color: .gray, roughness: 0.5, isMetallic: false)
        return ModelEntity(mesh: mesh, materials: [material])
    }
    
    /// 创建成化斗彩鸡缸杯模型
    private static func createChickenCup() -> ModelEntity {
        // 创建杯体
        let cupMesh = MeshResource.generateCylinder(height: 0.035, radius: 0.04)
        let cupMaterial = SimpleMaterial(color: .white, roughness: 0.1, isMetallic: false)
        let cup = ModelEntity(mesh: cupMesh, materials: [cupMaterial])
        
        // 创建杯底
        let baseMesh = MeshResource.generateCylinder(height: 0.01, radius: 0.02)
        let base = ModelEntity(mesh: baseMesh, materials: [cupMaterial])
        base.position.y = -0.0175
        
        // 创建鸡纹样（简化表示）
        let patternMesh = MeshResource.generateBox(size: [0.01, 0.02, 0.01])
        let redMaterial = SimpleMaterial(color: .red, roughness: 0.3, isMetallic: false)
        
        // 添加几个装饰点表示图案
        for i in 0..<8 {
            let angle = Float(i) * (Float.pi / 4)
            let x = 0.039 * cos(angle)
            let z = 0.039 * sin(angle)
            let patternPart = ModelEntity(mesh: patternMesh, materials: [redMaterial])
            patternPart.position = [x, 0, z]
            cup.addChild(patternPart)
        }
        
        // 创建组合实体
        let entity = ModelEntity()
        entity.addChild(cup)
        entity.addChild(base)
        
        return entity
    }
    
    /// 创建龙泉窑青釉凸雕缠枝莲纹瓶模型
    private static func createCeladonVase() -> ModelEntity {
        // 创建瓶身
        let vaseMesh = MeshResource.generateCylinder(height: 0.3, radius: 0.1)
        let vaseMaterial = SimpleMaterial(color: .init(red: 0.6, green: 0.8, blue: 0.7, alpha: 1.0), roughness: 0.2, isMetallic: false)
        let vase = ModelEntity(mesh: vaseMesh, materials: [vaseMaterial])
        
        // 创建瓶颈
        let neckMesh = MeshResource.generateCylinder(height: 0.1, radius: 0.05)
        let neck = ModelEntity(mesh: neckMesh, materials: [vaseMaterial])
        neck.position.y = 0.2
        
        // 创建瓶口
        let mouthMesh = MeshResource.generateCylinder(height: 0.02, radius: 0.06)
        let mouth = ModelEntity(mesh: mouthMesh, materials: [vaseMaterial])
        mouth.position.y = 0.26
        
        // 创建瓶底
        let baseMesh = MeshResource.generateCylinder(height: 0.02, radius: 0.1)
        let base = ModelEntity(mesh: baseMesh, materials: [vaseMaterial])
        base.position.y = -0.15
        
        // 创建组合实体
        let entity = ModelEntity()
        entity.addChild(vase)
        entity.addChild(neck)
        entity.addChild(mouth)
        entity.addChild(base)
        
        return entity
    }
    
    /// 创建斗彩海兽纹天字罐模型
    private static func createSeaCreatureJar() -> ModelEntity {
        // 创建罐身
        let jarMesh = MeshResource.generateCylinder(height: 0.13, radius: 0.07)
        let jarMaterial = SimpleMaterial(color: .white, roughness: 0.3, isMetallic: false)
        let jar = ModelEntity(mesh: jarMesh, materials: [jarMaterial])
        
        // 创建罐口
        let mouthMesh = MeshResource.generateCylinder(height: 0.02, radius: 0.067)
        let mouth = ModelEntity(mesh: mouthMesh, materials: [jarMaterial])
        mouth.position.y = 0.075
        
        // 创建罐底
        let baseMesh = MeshResource.generateCylinder(height: 0.01, radius: 0.077)
        let base = ModelEntity(mesh: baseMesh, materials: [jarMaterial])
        base.position.y = -0.07
        
        // 创建装饰（简化的海兽纹）
        let decorationMesh = MeshResource.generateSphere(radius: 0.01)
        let blueMaterial = SimpleMaterial(color: .blue, roughness: 0.3, isMetallic: false)
        let redMaterial = SimpleMaterial(color: .red, roughness: 0.3, isMetallic: false)
        
        // 添加一些装饰点
        for i in 0..<12 {
            let angle = Float(i) * (Float.pi / 6)
            let x = 0.069 * cos(angle)
            let z = 0.069 * sin(angle)
            let y = Float.random(in: -0.06...0.06)
            let patternPart = ModelEntity(mesh: decorationMesh, materials: [i % 2 == 0 ? blueMaterial : redMaterial])
            patternPart.position = [x, y, z]
            jar.addChild(patternPart)
        }
        
        // 创建组合实体
        let entity = ModelEntity()
        entity.addChild(jar)
        entity.addChild(mouth)
        entity.addChild(base)
        
        return entity
    }
    
    /// 创建嘉靖款五彩鱼藻纹盖罐模型
    private static func createFishJar() -> ModelEntity {
        // 创建罐身
        let jarMesh = MeshResource.generateCylinder(height: 0.3, radius: 0.12)
        let jarMaterial = SimpleMaterial(color: .white, roughness: 0.3, isMetallic: false)
        let jar = ModelEntity(mesh: jarMesh, materials: [jarMaterial])
        
        // 创建罐盖
        let lidBaseMesh = MeshResource.generateCylinder(height: 0.02, radius: 0.12)
        let lidBase = ModelEntity(mesh: lidBaseMesh, materials: [jarMaterial])
        lidBase.position.y = 0.16
        
        let lidTopMesh = MeshResource.generateCylinder(height: 0.05, radius: 0.08)
        let lidTop = ModelEntity(mesh: lidTopMesh, materials: [jarMaterial])
        lidTop.position.y = 0.195
        
        let knobMesh = MeshResource.generateSphere(radius: 0.02)
        let knob = ModelEntity(mesh: knobMesh, materials: [jarMaterial])
        knob.position.y = 0.23
        
        // 创建装饰（简化的鱼纹）
        let decorationMeshFish = MeshResource.generateBox(size: [0.03, 0.01, 0.01])
        let decorationMeshPlant = MeshResource.generateBox(size: [0.01, 0.04, 0.01])
        
        let greenMaterial = SimpleMaterial(color: .green, roughness: 0.3, isMetallic: false)
        let blueMaterial = SimpleMaterial(color: .blue, roughness: 0.3, isMetallic: false)
        
        // 添加鱼和藻装饰
        for i in 0..<8 {
            let angle = Float(i) * (Float.pi / 4)
            let x = 0.119 * cos(angle)
            let z = 0.119 * sin(angle)
            let y = Float.random(in: -0.1...0.1)
            
            if i % 2 == 0 {
                // 鱼
                let fish = ModelEntity(mesh: decorationMeshFish, materials: [blueMaterial])
                fish.position = [x, y, z]
                fish.orientation = simd_quatf(angle: angle, axis: [0, 1, 0])
                jar.addChild(fish)
            } else {
                // 藻
                let plant = ModelEntity(mesh: decorationMeshPlant, materials: [greenMaterial])
                plant.position = [x, y, z]
                jar.addChild(plant)
            }
        }
        
        // 创建组合实体
        let entity = ModelEntity()
        entity.addChild(jar)
        entity.addChild(lidBase)
        entity.addChild(lidTop)
        entity.addChild(knob)
        
        return entity
    }
    
    /// 创建光绪款粉彩云蝠纹赏瓶模型
    private static func createBatPatternVase() -> ModelEntity {
        // 创建瓶身
        let vaseMesh = MeshResource.generateCylinder(height: 0.3, radius: 0.08)
        let vaseMaterial = SimpleMaterial(color: .init(red: 1.0, green: 0.9, blue: 0.9, alpha: 1.0), roughness: 0.2, isMetallic: false)
        let vase = ModelEntity(mesh: vaseMesh, materials: [vaseMaterial])
        
        // 创建瓶颈
        let neckMesh = MeshResource.generateCylinder(height: 0.1, radius: 0.04)
        let neck = ModelEntity(mesh: neckMesh, materials: [vaseMaterial])
        neck.position.y = 0.2
        
        // 创建瓶口
        let mouthMesh = MeshResource.generateCylinder(height: 0.02, radius: 0.05)
        let mouth = ModelEntity(mesh: mouthMesh, materials: [vaseMaterial])
        mouth.position.y = 0.26
        
        // 创建瓶底
        let baseMesh = MeshResource.generateCylinder(height: 0.02, radius: 0.08)
        let base = ModelEntity(mesh: baseMesh, materials: [vaseMaterial])
        base.position.y = -0.15
        
        // 创建装饰（简化的云蝠纹）
        let batMesh = MeshResource.generateBox(size: [0.04, 0.02, 0.01])
        let cloudMesh = MeshResource.generateSphere(radius: 0.02)
        
        let purpleMaterial = SimpleMaterial(color: .init(red: 0.8, green: 0.3, blue: 0.8, alpha: 1.0), roughness: 0.3, isMetallic: false)
        let blueMaterial = SimpleMaterial(color: .init(red: 0.6, green: 0.6, blue: 0.9, alpha: 1.0), roughness: 0.3, isMetallic: false)
        
        // 添加装饰
        for i in 0..<6 {
            let angle = Float(i) * (Float.pi / 3)
            let x = 0.079 * cos(angle)
            let z = 0.079 * sin(angle)
            let y = Float.random(in: -0.1...0.1)
            
            if i % 2 == 0 {
                // 蝠
                let bat = ModelEntity(mesh: batMesh, materials: [purpleMaterial])
                bat.position = [x, y, z]
                bat.orientation = simd_quatf(angle: angle, axis: [0, 1, 0])
                vase.addChild(bat)
            } else {
                // 云
                let cloud = ModelEntity(mesh: cloudMesh, materials: [blueMaterial])
                cloud.position = [x, y, z]
                vase.addChild(cloud)
            }
        }
        
        // 创建组合实体
        let entity = ModelEntity()
        entity.addChild(vase)
        entity.addChild(neck)
        entity.addChild(mouth)
        entity.addChild(base)
        
        return entity
    }
} 