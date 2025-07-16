//
//  ModelLoader.swift
//  AR-Museum
//
//  Created for AR-Museum on 2023/10/25.
//

import Foundation
import RealityKit
import Combine

class ModelLoader {
    static let shared = ModelLoader()
    // 将cancellables改为internal，这样可以从扩展中访问
    var cancellables = Set<AnyCancellable>()
    
    // Model cache to avoid reloading the same model multiple times
    private var modelCache: [String: ModelEntity] = [:]
    
    private init() {}
    
    /// Loads a model from the app's bundle asynchronously
    /// - Parameter name: The name of the model file without extension
    /// - Returns: A publisher that delivers a ModelEntity when loaded
    func loadModel(named name: String) -> Future<ModelEntity, Error> {
        return Future<ModelEntity, Error> { promise in
            // If the model is in the cache, return it immediately
            if let cachedModel = self.modelCache[name] {
                promise(.success(cachedModel.clone(recursive: true)))
                return
            }
            
            // 对故宫文物模型进行特殊处理
            let processedName = self.processModelName(name)
            
            // Try to load the model from the bundle
            let modelName = processedName
            let modelExtension = "usdz"
            
            // 首先从Resources/Models目录中加载
            let modelPath = "Resources/Models/\(modelName)"
            
            if let modelURL = Bundle.main.url(forResource: modelPath, withExtension: modelExtension) {
                // For newer iOS versions use async/await pattern
                if #available(iOS 15.0, *) {
                    Task {
                        do {
                            let model = try await ModelEntity.loadModel(contentsOf: modelURL)
                            // Cache the loaded model
                            self.modelCache[name] = model
                            // Return a clone to avoid mutating the cached model
                            promise(.success(model.clone(recursive: true)))
                        } catch {
                            print("Failed to load model: \(error)")
                            // Use placeholder model instead
                            let placeholderModel = ModelPlaceholder.createPlaceholder(for: name)
                            self.modelCache[name] = placeholderModel
                            promise(.success(placeholderModel.clone(recursive: true)))
                        }
                    }
                } else {
                    // For iOS 14 and below, use the older API
                    do {
                        let modelEntity = try ModelEntity.load(contentsOf: modelURL)
                        if let entity = modelEntity as? ModelEntity {
                            // Cache the loaded model
                            self.modelCache[name] = entity
                            // Return a clone to avoid mutating the cached model
                            promise(.success(entity.clone(recursive: true)))
                        } else {
                            let placeholderModel = ModelPlaceholder.createPlaceholder(for: name)
                            self.modelCache[name] = placeholderModel
                            promise(.success(placeholderModel.clone(recursive: true)))
                        }
                    } catch {
                        print("Failed to load model: \(error)")
                        // Use placeholder model instead
                        let placeholderModel = ModelPlaceholder.createPlaceholder(for: name)
                        self.modelCache[name] = placeholderModel
                        promise(.success(placeholderModel.clone(recursive: true)))
                    }
                }
            } else {
                // 如果在Resources/Models目录下找不到，尝试从根目录加载
                if let rootModelURL = Bundle.main.url(forResource: modelName, withExtension: modelExtension) {
                    if #available(iOS 15.0, *) {
                        Task {
                            do {
                                let model = try await ModelEntity.loadModel(contentsOf: rootModelURL)
                                // Cache the loaded model
                                self.modelCache[name] = model
                                // Return a clone to avoid mutating the cached model
                                promise(.success(model.clone(recursive: true)))
                            } catch {
                                print("Failed to load model from root: \(error)")
                                // Use placeholder model instead
                                let placeholderModel = ModelPlaceholder.createPlaceholder(for: name)
                                self.modelCache[name] = placeholderModel
                                promise(.success(placeholderModel.clone(recursive: true)))
                            }
                        }
                    } else {
                        do {
                            let modelEntity = try ModelEntity.load(contentsOf: rootModelURL)
                            if let entity = modelEntity as? ModelEntity {
                                // Cache the loaded model
                                self.modelCache[name] = entity
                                // Return a clone to avoid mutating the cached model
                                promise(.success(entity.clone(recursive: true)))
                            } else {
                                let placeholderModel = ModelPlaceholder.createPlaceholder(for: name)
                                self.modelCache[name] = placeholderModel
                                promise(.success(placeholderModel.clone(recursive: true)))
                            }
                        } catch {
                            print("Failed to load model from root: \(error)")
                            // Use placeholder model instead
                            let placeholderModel = ModelPlaceholder.createPlaceholder(for: name)
                            self.modelCache[name] = placeholderModel
                            promise(.success(placeholderModel.clone(recursive: true)))
                        }
                    }
                } else {
                    // Model file not found, use placeholder
                    print("Model file not found, using placeholder for \(name)")
                    let placeholderModel = ModelPlaceholder.createPlaceholder(for: name)
                    self.modelCache[name] = placeholderModel
                    promise(.success(placeholderModel.clone(recursive: true)))
                }
            }
        }
    }
    
    /// Creates a placeholder model when the actual model fails to load
    /// - Returns: A simple box model entity
    func createPlaceholderModel() -> ModelEntity {
        return ModelPlaceholder.createDefaultPlaceholder()
    }
    
    /// Load model synchronously (for previews and simple cases)
    func loadModelSync(named name: String) -> ModelEntity {
        do {
            // 首先从Resources/Models目录中加载
            let modelPath = "Resources/Models/\(name)"
            
            if let modelURL = Bundle.main.url(forResource: modelPath, withExtension: "usdz") {
                if let modelEntity = try ModelEntity.load(contentsOf: modelURL) as? ModelEntity {
                    return modelEntity
                }
            }
            
            // 如果Resources/Models中找不到，尝试从根目录加载
            if let modelURL = Bundle.main.url(forResource: name, withExtension: "usdz") {
                // ModelEntity.load(contentsOf:) 实际返回的是Entity类型，需要进行安全类型转换
                if let modelEntity = try ModelEntity.load(contentsOf: modelURL) as? ModelEntity {
                    return modelEntity
                } else {
                    print("Failed to convert loaded entity to ModelEntity")
                    return ModelPlaceholder.createPlaceholder(for: name)
                }
            } else {
                return ModelPlaceholder.createPlaceholder(for: name)
            }
        } catch {
            print("Failed to load model: \(error)")
            return ModelPlaceholder.createPlaceholder(for: name)
        }
    }

    /// 处理模型名称，将中文名称转换为文件系统可用的名称
    private func processModelName(_ name: String) -> String {
        // 如果是已知的故宫文物名称，直接返回对应的文件名
        switch name {
        case "成化款斗彩鸡缸杯":
            return "成化款斗彩鸡缸杯"
        case "龙泉窑青釉凸雕缠枝莲纹瓶":
            return "龙泉窑青釉凸雕缠枝莲纹瓶"
        case "斗彩海兽纹天字罐":
            return "斗彩海兽纹天字罐"
        case "嘉靖款五彩鱼藻纹盖罐":
            return "嘉靖款五彩鱼藻纹盖罐"
        case "光绪款粉彩云蝠纹赏瓶":
            return "光绪款粉彩云蝠纹赏瓶"
        default:
            return name
        }
    }
}

/// Custom errors for model loading
enum ModelLoadingError: Error {
    case modelNotFound
    case loadingFailed
}

extension ModelEntity {
    /// Helper method to load a model by name
    /// - Parameter name: The name of the model file without extension
    /// - Returns: The loaded model entity
    static func loadModel(named name: String) async throws -> ModelEntity {
        return try await withCheckedThrowingContinuation { continuation in
            ModelLoader.shared.loadModel(named: name)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }, receiveValue: { model in
                    continuation.resume(returning: model)
                })
                .store(in: &ModelLoader.shared.cancellables)
        }
    }
} 