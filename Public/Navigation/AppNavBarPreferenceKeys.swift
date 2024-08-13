//
//  AppNavBarPreferenceKeys.swift
//  ImageWizard
//
//  Created by 万孟超 on 2024/4/16.
//

import SwiftUI



struct AppNavPreferenceKeys {
    
    private init() { }
    
    enum PreferenceBuilder {
        case view(AnyView)
        case moreBlock((() -> ())?)
        case backBlock((() -> Bool)?)
    }
    
    struct AppNavTitlePreferenceKey: PreferenceKey {
        
        private init() { }
        
        static var defaultValue = ""
        
        static func reduce(value: inout String, nextValue: () -> String) {
            value = nextValue()
        }
    }
    
    struct AppNavBackItemHiddenPreferenceKey: PreferenceKey {
        
        private init() { }
        
        static var defaultValue = false
        
        static func reduce(value: inout Bool, nextValue: () -> Bool) {
            value = nextValue()
        }
    }
    
    struct AppNavHiddenPreferenceKey: PreferenceKey {
        
        private init() { }
        
        static var defaultValue = false
        
        static func reduce(value: inout Bool, nextValue: () -> Bool) {
            value = nextValue()
        }
    }
    
    struct AppNavBackgroundPreferenceKey: PreferenceKey {
        
        static var defaultValue: PreferenceBuilder? = nil
        
        static func reduce(value: inout PreferenceBuilder?, nextValue: () -> PreferenceBuilder?) {
            value = nextValue()
        }
        
        private init() { }
        
    }
    
    struct AppNavContentColorPreferenceKey: PreferenceKey {
        typealias Value = SwiftUI.Color
        
        static var defaultValue = SwiftUI.Color.black
        
        static func reduce(value: inout SwiftUI.Color, nextValue: () -> SwiftUI.Color) {
            value = nextValue()
        }
        
        private init() { }
        
    }
    
    struct AppNavLeftImagePreferenceKey: PreferenceKey {
        
        static var defaultValue: String? = nil
        
        static func reduce(value: inout String?, nextValue: () -> String?) {
            value = nextValue()
        }
        
        private init() { }
        
    }
    
    struct AppNavLeftSystemImagePreferenceKey: PreferenceKey {
        
        static var defaultValue: String? = "chevron.left"
        
        static func reduce(value: inout String?, nextValue: () -> String?) {
            value = nextValue()
        }
        
        private init() { }
        
    }
    
    struct AppNavBackActionPreferenceKey: PreferenceKey {
                
        static var defaultValue: PreferenceBuilder? = nil
        
        static func reduce(value: inout PreferenceBuilder?, nextValue: () -> PreferenceBuilder?) {
            value = nextValue()
        }
        
        private init() { }
        
    }
    
    struct AppNavMoreItemHiddenPreferenceKey: PreferenceKey {
        
        private init() { }
        
        static var defaultValue = false
        
        static func reduce(value: inout Bool, nextValue: () -> Bool) {
            value = nextValue()
        }
    }
    
    struct AppNavRightImagePreferenceKey: PreferenceKey {
        
        static var defaultValue: String? = nil
        
        static func reduce(value: inout String?, nextValue: () -> String?) {
            value = nextValue()
        }
        
        private init() { }
        
    }
    
    struct AppNavRightSystemImagePreferenceKey: PreferenceKey {
        
        static var defaultValue: String? = nil
        
        static func reduce(value: inout String?, nextValue: () -> String?) {
            value = nextValue()
        }
        
        private init() { }
        
    }
    
    struct AppNavMoreActionPreferenceKey: PreferenceKey {
        
        static var defaultValue: PreferenceBuilder? = nil
        
        static func reduce(value: inout PreferenceBuilder?, nextValue: () -> PreferenceBuilder?) {
            value = nextValue()
        }
        
        private init() { }
        
    }
    
    struct AppNavContentLeadingTopPreferenceKey: PreferenceKey {
        
        private init() { }
        
        static var defaultValue = false
        
        static func reduce(value: inout Bool, nextValue: () -> Bool) {
            value = nextValue()
        }
    }
}



extension AppNavPreferenceKeys.PreferenceBuilder: Equatable {
    static func == (lhs: AppNavPreferenceKeys.PreferenceBuilder, rhs: AppNavPreferenceKeys.PreferenceBuilder) -> Bool {
        false
    }
}

public extension View {
    func customNavigationTitle(_ title: String) -> some View {
        preference(key: AppNavPreferenceKeys.AppNavTitlePreferenceKey.self, value: title)
    }

    func customNavigationBackground<BackgroundView>(_ background: BackgroundView) -> some View where BackgroundView : View {
        preference(key: AppNavPreferenceKeys.AppNavBackgroundPreferenceKey.self, value: .view(AnyView(background)))
    }
    
    func customNavigationBarHidden(_ isHidden: Bool) -> some View {
        preference(key: AppNavPreferenceKeys.AppNavHiddenPreferenceKey.self, value: isHidden)
    }
    
    func customNavigationContentColor(_ color: SwiftUI.Color) -> some View {
        preference(key: AppNavPreferenceKeys.AppNavContentColorPreferenceKey.self, value: color)
    }
    
    func customNavigationBackItemHidden(_ isHidden: Bool) -> some View {
        preference(key: AppNavPreferenceKeys.AppNavBackItemHiddenPreferenceKey.self, value: isHidden)
    }
    
    func customNavigationBackImage(_ backImage: String?) -> some View {
        preference(key: AppNavPreferenceKeys.AppNavLeftImagePreferenceKey.self, value: backImage)
    }
    
    func customNavigationBackSystemImage(_ backSystemImage: String?) -> some View {
        preference(key: AppNavPreferenceKeys.AppNavLeftSystemImagePreferenceKey.self, value: backSystemImage)
    }
    
    func customNavigationBackAction(_ action: (() -> Bool)?) -> some View {
        preference(key: AppNavPreferenceKeys.AppNavBackActionPreferenceKey.self, value: .backBlock(action))
    }
    
    func customNavigationMoreItemHidden(_ isHidden: Bool) -> some View {
        preference(key: AppNavPreferenceKeys.AppNavMoreItemHiddenPreferenceKey.self, value: isHidden)
    }
    
    func customNavigationMoreImage(_ moreImage: String?) -> some View {
        preference(key: AppNavPreferenceKeys.AppNavRightImagePreferenceKey.self, value: moreImage)
    }
    
    func customNavigationMoreSystemImage(_ moreSystemImage: String?) -> some View {
        preference(key: AppNavPreferenceKeys.AppNavRightSystemImagePreferenceKey.self, value: moreSystemImage)
    }
    
    func customNavigationMoreAction(_ action: (() -> ())?) -> some View {
        preference(key: AppNavPreferenceKeys.AppNavMoreActionPreferenceKey.self, value: .moreBlock(action))
    }
    
    func customNavigationContentIsLeadingTop(_ isLeading: Bool, isClearBackground: Bool = true) -> some View {
        Group {
            if isClearBackground {
                preference(key: AppNavPreferenceKeys.AppNavBackgroundPreferenceKey.self, value: .view(AnyView(Color.clear)))
            }else{
                self
            }
        }
        .preference(key: AppNavPreferenceKeys.AppNavContentLeadingTopPreferenceKey.self, value: isLeading)
    }
    
    func customAlertContent<TitleContent, MessageContent, SureContent, CancelContent>(isShow: Binding<Bool>,
                                                                                      titleContent: (() -> TitleContent)? = nil,
                                                                                      messageContent: () -> MessageContent,
                                                                                      cancelContent: (() -> CancelContent)? = nil,
                                                                                      cancelAction: (() -> ())? = nil,
                                                                                      sureContent: (() -> SureContent)? = nil,
                                                                                      sureAction: (() -> ())? = nil) -> some View where TitleContent: View, MessageContent: View, SureContent: View, CancelContent: View {
        overlay {
            isShow.wrappedValue ? AppAlertView(isShow: isShow, 
                                               alignment: .horizontal,
                                               cancelAction: .custom(cancelContent, action: cancelAction),
                                               sureAction: .custom(sureContent, action: sureAction),
                                               titleContent: titleContent, messageContent: messageContent) : nil
        }
    }
}
