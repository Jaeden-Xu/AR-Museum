//
//  RotationAnimation.swift
//  AR-Museum
//
//  Created for AR-Museum on 2023/10/25.
//

import Foundation
import RealityKit
import Combine

/// 一个用于3D模型旋转的辅助工具类
class RotationAnimation {
    // 存储每个实体的定时器，以便在需要时停止动画
    private static var timers: [ModelEntity: Timer] = [:]
    
    /// 给实体添加持续旋转动画
    /// - Parameters:
    ///   - entity: 要添加动画的实体
    ///   - axis: 旋转轴，默认为Y轴
    ///   - period: 完成一圈旋转所需的时间（秒）
    ///   - clockwise: 是否顺时针旋转
    static func addRotation(to entity: ModelEntity, axis: SIMD3<Float> = [0, 1, 0], period: Float = 10.0, clockwise: Bool = true) {
        // 取消之前的动画如果有的话
        stopRotation(for: entity)
        
        // 确保轴向量已归一化
        let normalizedAxis = normalize(axis)
        
        // 计算每帧旋转的角度（假设60fps）
        let direction: Float = clockwise ? 1.0 : -1.0
        let framesPerSecond: Float = 60.0
        let totalFrames = Int(period * framesPerSecond)
        let anglePerFrame = (Float.pi * 2.0) / Float(totalFrames)
        
        // 创建一个定时器来逐帧旋转模型
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0/TimeInterval(framesPerSecond), repeats: true) { _ in
            // 创建围绕指定轴的旋转
            let rotation = simd_quatf(angle: anglePerFrame * direction, axis: normalizedAxis)
            
            // 将此旋转应用到实体的当前旋转上
            entity.transform.rotation = rotation * entity.transform.rotation
        }
        
        // 存储定时器以便以后可以停止它
        timers[entity] = timer
    }
    
    /// 停止指定实体的旋转动画
    /// - Parameter entity: 要停止动画的实体
    static func stopRotation(for entity: ModelEntity) {
        if let timer = timers[entity] {
            timer.invalidate()
            timers.removeValue(forKey: entity)
        }
    }
    
    /// 停止所有实体的旋转动画
    static func stopAllRotations() {
        for (_, timer) in timers {
            timer.invalidate()
        }
        timers.removeAll()
    }
}

extension ModelEntity {
    /// 给实体添加连续旋转动画的便捷方法
    /// - Parameters:
    ///   - axis: 旋转轴，默认为Y轴 [0, 1, 0]
    ///   - period: 完成一圈旋转所需的时间（秒），默认为10秒
    ///   - clockwise: 是否顺时针旋转，默认为是
    func addRotationAnimation(axis: SIMD3<Float> = [0, 1, 0], period: Float = 10.0, clockwise: Bool = true) {
        RotationAnimation.addRotation(to: self, axis: axis, period: period, clockwise: clockwise)
    }
    
    /// 停止实体的旋转动画
    func stopRotationAnimation() {
        RotationAnimation.stopRotation(for: self)
    }
} 