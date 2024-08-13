//
//  IWCoreImageFilter.swift
//  ImageWizard
//
//  Created by 万孟超 on 2024/4/15.
//

import Foundation
import CoreImage

class IWCoreImageFilter {
    static func logFilters() -> [String] {
        let properties = CIFilter.filterNames(inCategories: nil)
        for filterName in properties {
            print(filterName)
        }
        return properties
    }
    
    static func createCIFilter(with filterName: String) -> CIFilter? {
        let filter = CIFilter(name: filterName)
        return filter
    }
}

//import Foundation
//
//// 定义一个模型协议，用于支持结构体和类
//protocol ModelProtocol: Codable {
//    typealias ModelType = Self
//}
//
//// 定义一个JSON转模型的通用函数
//func decode<T: ModelProtocol>(_ jsonData: Data) -> T? {
//    let decoder = JSONDecoder()
//    do {
//        return try decoder.decode(T.self, from: jsonData)
//    } catch {
//        print("Error decoding JSON: \(error)")
//        return nil
//    }
//}
//
//// 定义一个模型转JSON字符串的通用函数
//func encode<T: ModelProtocol>(_ model: T) -> String? {
//    let encoder = JSONEncoder()
//    do {
//        let jsonData = try encoder.encode(model)
//        return String(data: jsonData, encoding: .utf8)
//    } catch {
//        print("Error encoding JSON: \(error)")
//        return nil
//    }
//}
//
//// 定义一个模型转字典的通用函数
//func toDictionary<T: ModelProtocol>(_ model: T) -> [String: Any]? {
//    guard let jsonData = try? JSONEncoder().encode(model) else {
//        return nil
//    }
//    guard let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []) else {
//        return nil
//    }
//    return jsonObject as? [String: Any]
//}
//
//// 定义一个模型数组转字典数组的通用函数
//func toDictionaryArray<T: ModelProtocol>(_ models: [T]) -> [[String: Any]]? {
//    return models.compactMap { toDictionary($0) }
//}
//
//// 定义一个使用dynamicCallable的类，用于处理JSON转换
//@dynamicCallable
//struct JSONDecoder {
//    func dynamicallyCall<T: ModelProtocol>(withArguments args: [Any]) -> T? {
//        if let jsonString = args.first as? String {
//            return decode(jsonString.data(using: .utf8) ?? Data())
//        } else if let model = args.first as? T {
//            return model
//        } else {
//            fatalError("Invalid argument type. Expected String or \(T.self).")
//        }
//    }
//}
//
//// 定义一个使用dynamicCallable的类，用于处理JSON转换
//@dynamicCallable
//struct JSONEncoder<T: ModelProtocol> {
//    func dynamicallyCall(withArguments args: [Any]) -> String? {
//        if let model = args.first as? T {
//            return encode(model)
//        } else {
//            fatalError("Invalid argument type. Expected \(T.self).")
//        }
//    }
//    
//    func dynamicallyCall(withArguments args: [Any]) -> [String: Any]? {
//        if let model = args.first as? T {
//            return toDictionary(model)
//        } else {
//            fatalError("Invalid argument type. Expected \(T.self).")
//        }
//    }
//    
//    func dynamicallyCall(withArguments args: [Any]) -> [[String: Any]]? {
//        if let models = args.first as? [ModelProtocol] {
//            return toDictionaryArray(models)
//        } else {
//            fatalError("Invalid argument type. Expected [\(T.self)].")
//        }
//    }
//}
