//
//  CustomFilter.swift
//  ImageWizard
//
//  Created by 万孟超 on 2024/5/20.
//

import Harbeth

class CustomSmoothFilter: C7FilterProtocol {
    
    @ZeroOneRange public var intensity: Float = R.iRange.value
    
    public var smoothDegree: Float = 0.0
    
    public var modifier: Modifier {
        return .compute(kernel: "C7CombinationBeautiful")
    }
    
    public var factors: [Float] {
        return [intensity, smoothDegree]
    }
    
    public init(smoothDegree: Float = 0.0) {
        self.smoothDegree = smoothDegree
    }
    
}
