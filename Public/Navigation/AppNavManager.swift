//
//  AppNavManager.swift
//  AppNavStack
//
//  Created by 万孟超 on 2024/4/29.
//

import SwiftUI

fileprivate extension View {
    var feature: String {
        String(describing: Self.self)
    }
}

public class AppNavManager: ObservableObject {
    
    private var pathIndex = 0
    
    static let share = AppNavManager()
        
    @Published var navigationPath: [String] = []
    
    var navigationPathMap: [String: AnyView] = [:]
    
}

extension AppNavManager: AppNavRouterProtocol {
    
    public func push<Destination>(_ routeFeature: String?, view: Destination) where Destination: View {
        let feature = routeFeature ?? view.feature + "-\(pathIndex)"
        navigationPath.append(feature)
        navigationPathMap[feature] = AnyView(view)
        pathIndex += 1
    }
    
    public func push<Destination>(_ routeFeature: String?, view: () -> Destination) where Destination : View {
        push(routeFeature, view: view())
    }
    
    public func push<Destination>(_ view: Destination) where Destination: View {
        push(nil, view: view)
    }
    
    public func push<Destination>(view: () -> Destination) where Destination : View {
        push(nil, view: view())
    }
    
    public func pop() {
        if navigationPath.count >= 1 {
            let feature = navigationPath.removeLast()
            navigationPathMap[feature] = nil
        }
    }
    
    public func pop(_ routeFeature: String?) {
        if routeFeature == nil {
            pop()
        }else{
            if let index = navigationPath.lastIndex(where: { $0.contains(routeFeature!)}) {
                if index > 0 {
                    navigationPath = Array(navigationPath[0..<index])
                }else{
                    popRoot()
                }
            }
        }
    }
    
    public func popRoot() {
        navigationPath.removeAll()
        navigationPathMap = [:]
    }
}
