//
//  ThresholdProvider.swift
//  AppAccesibilidad
//
//  Created by Azuany Mila Cerón on 10/6/25.
//

import CoreML


class ThresholdProvider: MLFeatureProvider {
    open var values = [
        "iouThreshold": MLFeatureValue(double: UserDefaults.standard.double(forKey: "iouThreshold")),
        "confidenceThreshold": MLFeatureValue(double: UserDefaults.standard.double(forKey: "confidenceThreshold"))
        ]

    var featureNames: Set<String> {
        return Set(values.keys)
    }

    func featureValue(for featureName: String) -> MLFeatureValue? {
        return values[featureName]
    }
}
