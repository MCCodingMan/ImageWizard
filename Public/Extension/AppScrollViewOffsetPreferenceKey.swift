//
//  AppScrollViewOffsetPreferenceKey.swift
//  ImageWizard
//
//  Created by 万孟超 on 2024/4/22.
//

import SwiftUI

struct AppScrollViewPreferenceKeys {
    
    enum PreferenceBuilder {
        
    }
    
    struct AppScrollViewOffsetPreferenceKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
        
        private init() { }
    }
    
    struct AppScrollViewUpdateOffsetPreferenceKey: PreferenceKey {
        static var defaultValue: String = ""
        
        static func reduce(value: inout String, nextValue: () -> String) {
            value = nextValue()
        }
        
        private init() { }
    }
}

extension View {
    func onScrollViewOffsetXChanged(_ offsetAction: @escaping (_ offset: CGFloat) -> ()) -> some View {
        background(
            GeometryReader(content: { geometry in
                Spacer().preference(key: AppScrollViewPreferenceKeys.AppScrollViewOffsetPreferenceKey.self, value: geometry.frame(in: .global).minX)
            })
        )
        .onPreferenceChange(AppScrollViewPreferenceKeys.AppScrollViewOffsetPreferenceKey.self, perform: { value in
            offsetAction(value)
        })
    }
}

extension View {
    func scrollToDefault<ID: Hashable>(_ id: ID, anchor: UnitPoint?) -> some View {
        ScrollViewReader(content: { proxy in
            onAppear(perform: {
                proxy.scrollTo(id, anchor: anchor)
            })
        })
    }
    
}
