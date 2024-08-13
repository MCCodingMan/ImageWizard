//
//  AppNavRouterProtocol.swift
//  AppNavStack
//
//  Created by 万孟超 on 2024/4/29.
//

import SwiftUI

public protocol AppNavRouterProtocol {
        
    func push<Destination>(_ routeFeature: String?, view: Destination) where Destination: View
    
    func push<Destination>(_ routeFeature: String?, @ViewBuilder view: () -> Destination) where Destination: View
    
    func push<Destination>(_ view: Destination) where Destination: View
    
    func push<Destination>(@ViewBuilder view: () -> Destination) where Destination: View
    
    func pop()
    
    func pop(_ routeFeature: String?)
    
    func popRoot()
}


extension View {
    
}
