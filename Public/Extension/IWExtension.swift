//
//  IWExtension.swift
//  ImageWizard
//
//  Created by 万孟超 on 2024/4/7.
//

import UIKit
import SwiftUI

extension UIImage {
    func imageByCropToRect(rect:CGRect, scale:Bool) -> UIImage {
        var rect = rect
        var scaleFactor: CGFloat = 1.0
        if scale  {
            scaleFactor = self.scale
            rect.origin.x *= scaleFactor
            rect.origin.y *= scaleFactor
            rect.size.width *= scaleFactor
            rect.size.height *= scaleFactor
        }

        var image: UIImage? = nil;
        if rect.size.width > 0 && rect.size.height > 0 {
            let imageRef = self.cgImage!.cropping(to: rect)
            image = UIImage(cgImage: imageRef!, scale: scaleFactor, orientation: imageOrientation)
        }

        return image!
    }
}

extension Color {
    static func hex(_ string: String) -> Color {
        return Color(uiColor: string.color())
    }
}

extension String {
    /// 十六进制字符串颜色转为UIColor
    /// - Parameter alpha: 透明度
    func color(alpha: CGFloat = 1.0) -> UIColor {
        // 存储转换后的数值
        var red: UInt64 = 0, green: UInt64 = 0, blue: UInt64 = 0
        var hex = self
        // 如果传入的十六进制颜色有前缀，去掉前缀
        if hex.hasPrefix("0x") || hex.hasPrefix("0X") {
            hex = String(hex[hex.index(hex.startIndex, offsetBy: 2)...])
        } else if hex.hasPrefix("#") {
            hex = String(hex[hex.index(hex.startIndex, offsetBy: 1)...])
        }
        // 如果传入的字符数量不足6位按照后边都为0处理，当然你也可以进行其它操作
        if hex.count < 6 {
            for _ in 0..<6-hex.count {
                hex += "0"
            }
        }
        // 分别进行转换
        // 红
        Scanner(string: String(hex[..<hex.index(hex.startIndex, offsetBy: 2)])).scanHexInt64(&red)
        // 绿
        Scanner(string: String(hex[hex.index(hex.startIndex, offsetBy: 2)..<hex.index(hex.startIndex, offsetBy: 4)])).scanHexInt64(&green)
        // 蓝
        Scanner(string: String(hex[hex.index(startIndex, offsetBy: 4)...])).scanHexInt64(&blue)
        return UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: alpha)
    }
    
    func iiColor(alpha: CGFloat = 1.0) -> Color {
        return Color(uiColor:color(alpha: alpha))
    }
}

extension Date {
    
    /// 时间转换成字符串
    /// - Parameter format: 转换格式
    /// - Returns: 字符串
    func toString(format: String = "yyyy-MM-dd") -> String {
        let df = DateFormatter()
        df.dateFormat = format
        return df.string(from: self)
    }
}

extension UIColor {
    static func randomColor(alpha : CGFloat? = 1) -> UIColor {
        return randomAplhaColor(alpha!)
    }
    
    static func randomAplhaColor(_ alpha : CGFloat? = .random(in: 0...1)) -> UIColor {
        return UIColor(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), alpha: alpha!)
    }
}

@propertyWrapper public struct NumClamping<Value: Comparable> {
    private var value: Value
    private let range: ClosedRange<Value>
    
    public var wrappedValue: Value {
        get { value }
        set { value = min(max(newValue, range.lowerBound), range.upperBound) }
    }
    
    public init(wrappedValue: Value, _ range: ClosedRange<Value>) {
        self.value = min(max(wrappedValue, range.lowerBound), range.upperBound)
        self.range = range
    }
}

@inlinable func string(with bytes: Int) -> String {
   if bytes < 1024 {
       return "0KB"
   }
   if bytes >= 1024 && bytes < 1024 * 1024 {
       return String(format: "%.1fKB", Double(bytes) / 1024.0)
   }
   if bytes >= 1024 * 1024 && bytes < 1024 * 1024 * 1024 {
       return String(format: "%.2fMB", Double(bytes) / 1024.0 / 1024.0)
   }
   if bytes >= 1024 * 1024 * 1024 {
       return String(format: "%.2fGB", Double(bytes) / 1024.0 / 1024.0 / 1024.0)
   }
   return "0KB"
}
