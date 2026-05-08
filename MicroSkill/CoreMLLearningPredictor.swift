import CoreML
import Foundation

struct LearningPredictionFeatures {
    let completedLessons: Int
    let totalLessons: Int
    let streak: Int
    let activeDays: Int
    let goalCategoryIndex: Int
    let fallbackOptimalHour: Int
}

/// Optional Core ML bridge for personalization.
///
/// Add a compiled model named `MicroSkillLearningModel.mlmodelc` to the app target
/// to enable model-backed recommendations. Until then, the app keeps using the
/// existing rule-based learning logic.
final class CoreMLLearningPredictor {
    static let shared = CoreMLLearningPredictor()

    private let model: MLModel?

    var isModelAvailable: Bool {
        model != nil
    }

    private init() {
        guard let modelURL = Bundle.main.url(forResource: "MicroSkillLearningModel", withExtension: "mlmodelc") else {
            model = nil
            return
        }

        do {
            let configuration = MLModelConfiguration()
            configuration.computeUnits = .all
            model = try MLModel(contentsOf: modelURL, configuration: configuration)
        } catch {
            print("Failed to load Core ML model: \(error)")
            model = nil
        }
    }

    func predictedOptimalHour(fallback: Int, features: LearningPredictionFeatures) -> Int {
        guard let value = predictionValue(for: features, outputKeys: ["optimalHour", "predictedHour", "hour"]) else {
            return fallback
        }

        let hour = Int(value)
        return (0...23).contains(hour) ? hour : fallback
    }

    func recommendedCategory(fallback: String, features: LearningPredictionFeatures) -> String {
        guard let output = prediction(for: features) else {
            return fallback
        }

        if let categoryValue = output.featureValue(for: "recommendedCategory")?.stringValue {
            return normalizedCategory(categoryValue, fallback: fallback)
        }

        if let categoryValue = output.featureValue(for: "category")?.stringValue {
            return normalizedCategory(categoryValue, fallback: fallback)
        }

        if let categoryIndex = predictionValue(from: output, outputKeys: ["categoryIndex", "recommendedCategoryIndex"]) {
            return category(for: Int(categoryIndex), fallback: fallback)
        }

        return fallback
    }

    func readinessScore(fallback: Double, features: LearningPredictionFeatures) -> Double {
        guard let value = predictionValue(for: features, outputKeys: ["readinessScore", "advancedReadiness", "score"]) else {
            return fallback
        }

        return min(max(value, 0), 1)
    }

    private func predictionValue(for features: LearningPredictionFeatures, outputKeys: [String]) -> Double? {
        guard let output = prediction(for: features) else {
            return nil
        }

        return predictionValue(from: output, outputKeys: outputKeys)
    }

    private func prediction(for features: LearningPredictionFeatures) -> MLFeatureProvider? {
        guard let model else {
            return nil
        }

        do {
            let provider = try MLDictionaryFeatureProvider(dictionary: [
                "completedLessons": features.completedLessons,
                "totalLessons": features.totalLessons,
                "streak": features.streak,
                "activeDays": features.activeDays,
                "goalCategoryIndex": features.goalCategoryIndex,
                "fallbackOptimalHour": features.fallbackOptimalHour
            ])

            return try model.prediction(from: provider)
        } catch {
            print("Core ML prediction failed: \(error)")
            return nil
        }
    }

    private func predictionValue(from output: MLFeatureProvider, outputKeys: [String]) -> Double? {
        for key in outputKeys {
            guard let value = output.featureValue(for: key) else { continue }

            switch value.type {
            case .double:
                return value.doubleValue
            case .int64:
                return Double(value.int64Value)
            default:
                continue
            }
        }

        return nil
    }

    private func normalizedCategory(_ value: String, fallback: String) -> String {
        let categories = ["Tech", "Productivity", "General Knowledge"]
        return categories.first { $0.caseInsensitiveCompare(value) == .orderedSame } ?? fallback
    }

    private func category(for index: Int, fallback: String) -> String {
        switch index {
        case 0: return "Tech"
        case 1: return "Productivity"
        case 2: return "General Knowledge"
        default: return fallback
        }
    }
}
