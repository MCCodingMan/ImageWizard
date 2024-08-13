//
//  BBMetalCustomBeautyFilter.swift
//  ImageWizard
//
//  Created by 万孟超 on 2024/5/16.
//

import BBMetalImage

class BBMetalCustomBeautyFilter: BBMetalBaseFilterGroup {
    public var distanceNormalizationFactor: Float {
        get { return blurFilter.distanceNormalizationFactor }
        set { blurFilter.distanceNormalizationFactor = newValue }
    }
    
    public var stepOffset: Float {
        get { return blurFilter.stepOffset }
        set { blurFilter.stepOffset = newValue }
    }
    
    public var edgeStrength: Float {
        get { return edgeDetectionFilter.edgeStrength }
        set { edgeDetectionFilter.edgeStrength = newValue }
    }
    
    public var smoothDegree: Float {
        get { return combinationFilter.smoothDegree }
        set { combinationFilter.smoothDegree = newValue }
    }
    
    public var sharpeness: Float {
        get { _sharpeness }
        set { _sharpeness = newValue }
    }
    
    private var _sharpeness: Float = 1.0 {
        didSet {
            sharpenessFilter.sharpeness = _sharpeness
        }
    }
    
    public var brightness: Float {
        get { _brightness }
        set { _brightness = newValue }
    }
    
    private var _brightness: Float = 1.0 {
        didSet {
            hsbFilter.adjustBrightness(_brightness)
        }
    }
    
    public var hue: Float {
        get { _hue }
        set { _hue = newValue }
    }
    
    private var _hue: Float = 0 {
        didSet {
            hsbFilter.rotateHue(_hue)
        }
    }
    
    public var saturation: Float {
        get { _saturation }
        set { _saturation = newValue }
    }
    
    private var _saturation: Float = 1.0 {
        didSet {
            hsbFilter.adjustSaturation(_saturation)
        }
    }
    
    private let blurFilter: BBMetalBilateralBlurFilter
    private let edgeDetectionFilter: BBMetalSobelEdgeDetectionFilter
    private let hsbFilter: BBMetalHSBFilter
    private let sharpenessFilter: BBMetalSharpenFilter
    private let combinationFilter: _BBMetalCustomBeautyCombinationFilter
    
    public init(distanceNormalizationFactor: Float = 4, 
                stepOffset: Float = 4,
                edgeStrength: Float = 1,
                smoothDegree: Float = 0.5,
                sharpeness: Float = 0.5,
                brightness: Float = 1.0,
                saturation: Float = 1.0,
                hue: Float = 0) {
        blurFilter = BBMetalBilateralBlurFilter(distanceNormalizationFactor: distanceNormalizationFactor, stepOffset: stepOffset)
        edgeDetectionFilter = BBMetalSobelEdgeDetectionFilter(edgeStrength: edgeStrength)
        hsbFilter = BBMetalHSBFilter()
        sharpenessFilter = BBMetalSharpenFilter(sharpeness: sharpeness)
        combinationFilter = _BBMetalCustomBeautyCombinationFilter(smoothDegree: smoothDegree)
        
        blurFilter.add(consumer: combinationFilter)
        edgeDetectionFilter.add(consumer: combinationFilter)
        hsbFilter.add(consumer: combinationFilter)
        super.init(kernelFunctionName: "")
        
        hsbFilter.adjustBrightness(brightness)
        hsbFilter.adjustSaturation(saturation)
        hsbFilter.rotateHue(hue)
        _sharpeness = sharpeness
        _brightness = brightness
        _saturation = saturation
        _hue = hue
        initialFilters = [blurFilter, edgeDetectionFilter, hsbFilter, combinationFilter]
        terminalFilter = combinationFilter
    }
}

fileprivate class _BBMetalCustomBeautyCombinationFilter: BBMetalBaseFilter {
    fileprivate var smoothDegree: Float
    
    fileprivate init(smoothDegree: Float = 0.5) {
        self.smoothDegree = smoothDegree
        super.init(kernelFunctionName: "beautyCombinationKernel")
    }
    
    override func updateParameters(for encoder: MTLComputeCommandEncoder, texture: BBMetalTexture) {
        encoder.setBytes(&smoothDegree, length: MemoryLayout<Float>.size, index: 0)
    }
}
