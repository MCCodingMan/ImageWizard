//
//  IWFilter.swift
//  ImageWizard
//
//  Created by 万孟超 on 2024/4/11.
//

import Harbeth

enum IWFilterType {
    
    case none
    case auto
    case Luminance(Float)
    case Opacity(Float)
    case Hue(Float)
    case Exposure(Float)
    case Contrast(Float)
    case Saturation(Float)
    case ChannelRGBA(Float)
    case HighlightShadow(Float, Float)
    case WhiteBalance(Float)
    case Vibrance(Float)
    case Granularity(Float)
    case Vignette(Float, UIColor)
    case FalseColor
    case Crosshatch(Float)
    case Monochrome(Float)
    case ChromaKey(Float)
    case ReplaceColor(Float)
    case ZoomBlur(Float)
    case Pixellated(Float)
    case abao(Float)
    case ColorInvert
    case Color2Gray
    case Color2BGRA
    case Color2BRGA
    case Color2GBRA
    case Color2GRBA
    case Color2RBGA
    case Bulge(Float)
    case HueBlend(Float)
    case AlphaBlend(Float)
    case LuminosityBlend(Float)
    case Crop(C7Point2D)
    case Rotate(Float)
    case Flip(Bool)
    case Resize(CGSize)
    case MonochromeDilation(Int)
    case GlassSphere(Float)
    case Split(Float, Float)
    case Sobel(Float)
    case Pinch(Float)
    case PolkaDot(Float)
    case Posterize(Float)
    case Swirl(Float)
    case MotionBlur(Float, Float)
    case SoulOut(Float)
    case SplitScreen
    case Convolution3x3(Float)
    case Sharpen3x3(Float)
    case WaterRipple(Float)
    case ColorMatrix4x4(Float)
    case Levels(UIColor)
    case Transform(CGAffineTransform)
    case ShiftGlitch(Float)
    case EdgeGlow(Float)
    case VoronoiOverlay(Float)
    case MeanBlur(Float)
    case GaussianBlur(Float)
    case Storyboard(Float)
    case BilateralBlur(Float)
    case Sepia
    case ComicStrip
    case OilPainting
    case Sketch(Float)
    case CIHS(Float)
    case TextHEIC(Float)
    case MPSGaussian(Float)
    case CIGaussian(Float)
    case Grayed
    case ColorMonochrome
}

extension IWFilterType: CaseIterable {
    static var allCases: [IWFilterType] {
        [.none, .auto, .ColorInvert, .Color2BGRA, .Color2BRGA, .Color2GBRA, .Color2GRBA, .Color2RBGA, .Color2Gray, .Luminance(0.6), .Opacity(0.8), .abao(1.0), .ZoomBlur(10) ,.Pixellated(0.05), .HueBlend(1.0), .AlphaBlend(1.0), .LuminosityBlend(1.0), .Hue(30), .Bulge(0.2), .Contrast(1), .Saturation(1), .ChannelRGBA(1.0), .HighlightShadow(0.5, 0.5), .Monochrome(1.0), .ChromaKey(0.05), .ReplaceColor(0.1), .Rotate(90), .Flip(false), .Crosshatch(0.03), .WhiteBalance(4444), .MonochromeDilation(1), .Vibrance(0.6), .GlassSphere(0.25), .FalseColor, .Split(0.5, 0), .Sobel(1), .Pinch(0.25), .PolkaDot(0.05), .Posterize(2), .Swirl(0.25), .MotionBlur(45, 5), .SoulOut(0.5), .SplitScreen, .Sharpen3x3(1), .Granularity(0.3), .Vignette(0.3, .systemPink), .WaterRipple(0.3), .Levels(.purple), .Transform(CGAffineTransform(scaleX: 0.8, y: 1).rotated(by: .pi / 6)), .ShiftGlitch(0.5), .EdgeGlow(0.5), .VoronoiOverlay(0.5), .MeanBlur(1), .GaussianBlur(1), .Storyboard(2), .BilateralBlur(1), .Sepia, .ComicStrip, .OilPainting, .Sketch(0.3), .ColorMatrix4x4(1), .Convolution3x3(1.0), .CIHS(0.0), .TextHEIC(0.8), .MPSGaussian(10), .CIGaussian(10), .Grayed, .ColorMonochrome]
    }
    
}

extension IWFilterType {
    var filterName : String {
        switch self {
            case .none: return "原片"
            case .auto: return "自动"
            case .Luminance: return "亮度"
            case .Opacity: return "透明度"
            case .Hue: return "色相角度"
            case .Exposure: return "曝光"
            case .Contrast: return "对比度"
            case .Saturation: return "饱和度"
            case .ChannelRGBA: return "RGBA通道"
            case .HighlightShadow: return "高光阴影"
            case .WhiteBalance: return "白平衡"
            case .Vibrance: return "自然饱和度"
            case .Granularity: return "颗粒感"
            case .Vignette: return "渐进效果"
            case .FalseColor: return "伪色彩"
            case .Crosshatch: return "绘制阴影线"
            case .Monochrome: return "黑白照片"
            case .ChromaKey: return "绿幕抠图"
            case .ReplaceColor: return "替换背景"
            case .ZoomBlur: return "缩放模糊"
            case .Pixellated: return "马赛克"
            case .abao: return "阿宝色"
            case .ColorInvert: return "颜色反转"
            case .Color2Gray: return "灰度图"
            case .Color2BGRA: return "BGRA"
            case .Color2BRGA: return "BRGA"
            case .Color2GBRA: return "GBRA"
            case .Color2GRBA: return "GRBA"
            case .Color2RBGA: return "RBGA"
            case .Bulge: return "大胸"
            case .HueBlend: return "色相融合"
            case .AlphaBlend: return "透明度融合"
            case .LuminosityBlend: return "亮度融合"
            case .Crop: return "图形延展补齐"
            case .Rotate: return "图形旋转"
            case .Flip: return "图形翻转"
            case .Resize: return "改变尺寸"
            case .MonochromeDilation: return "黑白模糊"
            case .GlassSphere: return "玻璃球"
            case .Split: return "分割滤镜"
            case .Sobel: return "Sobel算子特征"
            case .Pinch: return "波浪"
            case .PolkaDot: return "波点"
            case .Posterize: return "色调分离"
            case .Swirl: return "漩涡鸣人"
            case .MotionBlur: return "移动模糊"
            case .SoulOut: return "灵魂出窍"
            case .SplitScreen: return "分屏展示"
            case .Convolution3x3: return "3x3卷积"
            case .Sharpen3x3: return "锐化卷积"
            case .WaterRipple: return "水波效果"
            case .ColorMatrix4x4: return "4x4颜色"
            case .Levels: return "色阶"
            case .Transform: return "透视变形"
            case .ShiftGlitch: return "色彩转移"
            case .EdgeGlow: return "边缘发光"
            case .VoronoiOverlay: return "多边形叠加"
            case .MeanBlur: return "均值模糊"
            case .GaussianBlur: return "高斯模糊"
            case .Storyboard: return "分镜展示"
            case .BilateralBlur: return "双边模糊"
            case .Sepia: return "怀旧"
            case .ComicStrip: return "连环画"
            case .OilPainting: return "油画"
            case .Sketch: return "素描"
            case .CIHS: return "高光阴影"
            case .TextHEIC: return "HEIC"
            case .MPSGaussian: return "MPS高斯模糊"
            case .CIGaussian: return "CI高斯模糊"
            case .Grayed: return "灰度图像"
            case .ColorMonochrome: return "单色滤镜"
        }
    }
    
    var index: Int {
        switch self {
            case .none: return -1
            case .auto: return 0
            case .Luminance: return 1
            case .Opacity: return 2
            case .Hue: return 3
            case .Exposure: return 4
            case .Contrast: return 5
            case .Saturation: return 6
            case .ChannelRGBA: return 7
            case .HighlightShadow: return 8
            case .WhiteBalance: return 9
            case .Vibrance: return 10
            case .Granularity: return 11
            case .Vignette: return 12
            case .FalseColor: return 13
            case .Crosshatch: return 14
            case .Monochrome: return 15
            case .ChromaKey: return 16
            case .ReplaceColor: return 17
            case .ZoomBlur: return 18
            case .Pixellated: return 19
            case .abao: return 20
            case .ColorInvert: return 21
            case .Color2Gray: return 22
            case .Color2BGRA: return 23
            case .Color2BRGA: return 24
            case .Color2GBRA: return 25
            case .Color2GRBA: return 26
            case .Color2RBGA: return 27
            case .Bulge: return 28
            case .HueBlend: return 29
            case .AlphaBlend: return 30
            case .LuminosityBlend: return 31
            case .Crop: return 32
            case .Rotate: return 33
            case .Flip: return 34
            case .Resize: return 35
            case .MonochromeDilation: return 36
            case .GlassSphere: return 37
            case .Split: return 38
            case .Sobel: return 39
            case .Pinch: return 40
            case .PolkaDot: return 41
            case .Posterize: return 42
            case .Swirl: return 43
            case .MotionBlur: return 44
            case .SoulOut: return 45
            case .SplitScreen: return 46
            case .Convolution3x3: return 47
            case .Sharpen3x3: return 48
            case .WaterRipple: return 49
            case .ColorMatrix4x4: return 50
            case .Levels: return 51
            case .Transform: return 52
            case .ShiftGlitch: return 53
            case .EdgeGlow: return 54
            case .VoronoiOverlay: return 55
            case .MeanBlur: return 56
            case .GaussianBlur: return 57
            case .Storyboard: return 58
            case .BilateralBlur: return 59
            case .Sepia: return 60
            case .ComicStrip: return 61
            case .OilPainting: return 62
            case .Sketch: return 63
            case .CIHS: return 64
            case .TextHEIC: return 65
            case .MPSGaussian: return 66
            case .CIGaussian: return 67
            case .Grayed: return 68
            case .ColorMonochrome: return 69
        }
    }
    
    private var overTexture: MTLTexture? {
        let color = UIColor.green.withAlphaComponent(0.5)
        guard let texture = try? TextureLoader.emptyTexture(width: 480, height: 270) else {
            return nil
        }
        let filter = C7SolidColor.init(color: color)
        let dest = HarbethIO(element: texture, filter: filter)
        return try? dest.output()
    }
}

extension IWFilterType {
    func filter() -> C7FilterProtocol {
        switch self {
            case .none, .auto: 
                var filter = C7Luminance()
                filter.luminance = 1.0
                return filter
            case .ColorInvert: return C7ColorConvert(with: .invert)
            case .Color2BGRA:
                return C7ColorConvert(with: .bgra)
            case .Color2BRGA:
                return C7ColorConvert(with: .brga)
            case .Color2GBRA:
                return C7ColorConvert(with: .gbra)
            case .Color2GRBA:
                return C7ColorConvert(with: .grba)
            case .Color2RBGA:
                return C7ColorConvert(with: .rbga)
            case .Color2Gray:
                return C7ColorConvert(with: .gray)
            case .Luminance(let value):
                var filter = C7Luminance()
                filter.luminance = value
                return filter
            case .Opacity(let value):
                var filter = C7Opacity()
                filter.opacity = value
                return filter
            case .Exposure(let value):
                var filter = C7Exposure()
                filter.exposure = value
                return filter
            case .abao(let value):
                var filter = C7LookupTable(image: R.image("lut_abao"))
                filter.intensity = value
                return filter
            case .ZoomBlur(let value):
                var filter = C7ZoomBlur()
                filter.radius = value
                return filter
            case .Pixellated(let value):
                var filter = C7Pixellated()
                filter.scale = value
                return filter
            case .HueBlend(let value):
                var filter = C7Blend(with: .hue, blendTexture: overTexture)
                filter.intensity = value
                return filter
            case .AlphaBlend(let value):
                var filter = C7Blend(with: .alpha, blendTexture: overTexture)
                filter.intensity = value
                return filter
            case .LuminosityBlend(let value):
                var filter = C7Blend(with: .luminosity, blendTexture: overTexture)
                filter.intensity = value
                return filter
            case .Hue(let value):
                var filter = C7Hue()
                filter.hue = value
                return filter
            case .Bulge(let value):
                var filter = C7Bulge()
                filter.scale = value
                return filter
            case .Contrast(let value):
                var filter = C7Contrast()
                filter.contrast = value
                return filter
            case .Saturation(let value):
                var filter = C7Saturation()
                filter.saturation = value
                return filter
            case .ChannelRGBA(let value):
                var filter = C7ColorRGBA(color: .red)
                filter.intensity = value
                return filter
            case .HighlightShadow(let value1, let value2):
                var filter = C7HighlightShadow()
                filter.highlights = value1
                filter.shadows = value2
                return filter
            case .Monochrome(let value):
                var filter = C7Monochrome()
                filter.intensity = value
                return filter
            case .ChromaKey(let value):
                let filter = C7ChromaKey(smoothing: value, chroma: .red)
                return filter
            case .ReplaceColor(let value):
                let filter = C7ChromaKey(smoothing: value, chroma: .red, replace: .purple)
                return filter
            case .Crop(let value):
                let filter = C7Crop(origin: value, width: 0, height: 1080)
                return filter
            case .Rotate(let value):
                var filter = C7Rotate()
                filter.angle = value
                return filter
            case .Flip(let value):
                var filter = C7Flip()
                filter.vertical = value
                return filter
            case .Crosshatch(let value):
                var filter = C7Crosshatch()
                filter.crosshatchSpacing = value
                return filter
            case .WhiteBalance(let value):
                var filter = C7WhiteBalance()
                filter.temperature = value
                return filter
            case .Resize(let value):
                let filter = C7Resize(width: Float(value.width), height: Float(value.height))
                return filter
            case .MonochromeDilation(let value):
                var filter = C7RedMonochromeBlur()
                filter.pixelRadius = value
                return filter
            case .Vibrance(let value):
                var filter = C7Vibrance()
                filter.vibrance = value
                return filter
            case .GlassSphere(let value):
                var filter = C7GlassSphere()
                filter.radius = value
                return filter
            case .FalseColor:
                var filter = C7FalseColor()
                filter.fristColor = UIColor.black
                filter.secondColor = UIColor.systemPink
                return filter
            case .Split(let value1, let value2):
                var filter = C7LookupSplit(UIImage(named: "lut_abao")!, lookupImage2: UIImage(named: "ll")!)
                filter.progress = value1
                filter.intensity = value2
                return filter
            case .Sobel(let value):
                var filter = C7Sobel()
                filter.edgeStrength = value
                return filter
            case .Pinch(let value):
                var filter = C7Pinch()
                filter.radius = value
                return filter
            case .PolkaDot(let value):
                var filter = C7PolkaDot()
                filter.fractionalWidth = value
                return filter
            case .Posterize(let value):
                var filter = C7Posterize()
                filter.colorLevels = value
                return filter
            case .Swirl(let value):
                var filter = C7Swirl()
                filter.radius = value
                return filter
            case .MotionBlur(let value1, let value2):
                var filter = C7MotionBlur()
                filter.blurAngle = value1
                filter.radius = value2
                return filter
            case .SoulOut(let value):
                var filter = C7SoulOut()
                filter.soul = value
                filter.maxScale = 1.5
                return filter
            case .SplitScreen:
                let filter = C7SplitScreen()
                return filter
            case .Sharpen3x3(let value):
                let filter = C7ConvolutionMatrix3x3(convolutionType: .sharpen(iterations: value))
                return filter
            case .Granularity(let value):
                var filter = C7Granularity()
                filter.grain = value
                return filter
            case .Vignette(let value, let color):
                var filter = C7Vignette()
                filter.color = color
                filter.start = value
                return filter
            case .WaterRipple(let value):
                var filter = C7WaterRipple()
                filter.ripple = value
                return filter
            case .Levels(let value):
                var filter = C7Levels()
                filter.minimum = value
                return filter
            case .Transform(let transform):
                let filter = C7Transform(transform: transform)
                return filter
            case .ShiftGlitch(let value):
                var filter = C7ShiftGlitch()
                filter.time = value
                return filter
            case .EdgeGlow(let value):
                var filter = C7EdgeGlow()
                filter.time = value
                return filter
            case .VoronoiOverlay(let value):
                var filter = C7VoronoiOverlay()
                filter.time = value
                return filter
            case .MeanBlur(let value):
                var filter = C7MeanBlur()
                filter.radius = value
                return filter
            case .GaussianBlur(let value):
                var filter = C7GaussianBlur()
                filter.radius = value
                return filter
            case .Storyboard(let value):
                var filter = C7Storyboard()
                filter.ranks = Int(ceil(value))
                return filter
            case .BilateralBlur(let value):
                var filter = C7BilateralBlur()
                filter.radius = value
                return filter
            case .Sepia:
                let filter = C7Sepia()
                return filter
            case .ComicStrip:
                let filter = C7ComicStrip()
                return filter
            case .OilPainting:
                let filter = C7OilPainting()
                return filter
            case .Sketch(let value):
                var filter = C7Sketch()
                filter.edgeStrength = value
                return filter
            case .ColorMatrix4x4(let value):
                var filter = C7ColorMatrix4x4(matrix: Matrix4x4.Color.replaced_red_green)
                filter.intensity = value
                return filter
            case .Convolution3x3(let value):
                var filter = C7ConvolutionMatrix3x3(convolutionType: .embossment)
                filter.intensity = value
                return filter
            case .CIHS(let value):
                var filter = CIHighlight()
                filter.highlight = value
                return filter
            case .TextHEIC(let value):
                var filter = C7Granularity()
                filter.grain = value
                return filter
            case .MPSGaussian(let value):
                var filter = MPSGaussianBlur()
                filter.radius = value
                return filter
            case .CIGaussian(let value):
                var filter = CIGaussianBlur()
                filter.radius = value
                return filter
            case .Grayed:
                let filter = C7Grayed(with: .desaturation)
                return filter
            case .ColorMonochrome:
                let filter = CIColorMonochrome(color: .random)
                return filter
        }
    }
}
