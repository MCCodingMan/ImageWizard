//
//  AppAlertView.swift
//  ImageWizard
//
//  Created by 万孟超 on 2024/5/7.
//

import SwiftUI

struct AppAlertView<TitleContent: View, MessageContent: View, CancelActionContent: View, SureActionContent: View>: View {
    
    @Binding var isShow: Bool
    var alertTitle: String = ""
    var alertMessage: String = ""
    var alertAlignment: Alignment
    
    var cancelAction: AppAlertView.Button<CancelActionContent>?
    var sureAction: AppAlertView.Button<SureActionContent>?
    
    var titleContent: TitleContent?
    var messageContent: MessageContent?
    
    init(isShow: Binding<Bool>, 
         alignment: Alignment = .horizontal,
         alertTitle: String,
         alertMessage: String,
         cancelAction: AppAlertView.Button<CancelActionContent>,
         sureAction: AppAlertView.Button<SureActionContent> ) {
        self._isShow = isShow
        self.alertAlignment = alignment
        self.alertTitle = alertTitle
        self.alertMessage = alertMessage
        self.cancelAction = cancelAction
        self.sureAction = sureAction
    }
    
    init(isShow: Binding<Bool>,
         alignment: Alignment = .horizontal,
         cancelAction: AppAlertView.Button<CancelActionContent>,
         sureAction: AppAlertView.Button<SureActionContent>,
         titleContent: (() -> TitleContent)? = nil,
         @ViewBuilder messageContent: () -> MessageContent) {
        self._isShow = isShow
        self.alertAlignment = alignment
        self.cancelAction = cancelAction
        self.sureAction = sureAction
        self.titleContent = titleContent?()
        self.messageContent = messageContent()
    }
    
    var body: some View {
        VStack {
            Spacer()
            // 弹窗内容
            ZStack(alignment: .top, content: {
                VStack {
                    if !alertTitle.isEmpty {
                        Text(alertTitle)
                            .font(.headline)
                            .padding(.top, 23)
                    }else if titleContent != nil {
                        titleContent
                            .padding(.top, 23)
                    }
                    
                    Group {
                        if !alertMessage.isEmpty {
                            Text(alertMessage)
                                .multilineTextAlignment(.center)
                        }else if messageContent != nil {
                            messageContent
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 6)
                    .padding(.bottom, 12)
                    if alertAlignment == .horizontal {
                        HStack {
                            Spacer()
                            cancelAction?.content
                                .onTapGesture {
                                    withAnimation {
                                        isShow = false
                                    }
                                    cancelAction?.action?()
                                }
                            Spacer()
                            sureAction?.content
                                .onTapGesture {
                                    withAnimation {
                                        isShow = false
                                    }
                                    sureAction?.action?()
                                }
                            Spacer()
                        }
                        .frame(height: 44)
                    }else{
                        VStack {
                            cancelAction?.content
                                .frame(height: 35)
                                .frame(maxWidth: .infinity)
                                .background(LinearGradient(colors: [Color(uiColor: UIColor.randomColor()), Color(uiColor: UIColor.randomColor())], startPoint: .leading, endPoint: .trailing))
                                .clipShape(RoundedRectangle(cornerRadius: 17.5))
                                .onTapGesture {
                                    withAnimation {
                                        isShow = false
                                    }
                                    cancelAction?.action?()
                                }
                            Spacer()
                            sureAction?.content
                                .frame(height: 35)
                                .frame(maxWidth: .infinity)
                                .background(LinearGradient(colors: [Color(uiColor: UIColor.randomColor()), Color(uiColor: UIColor.randomColor())], startPoint: .leading, endPoint: .trailing))
                                .clipShape(RoundedRectangle(cornerRadius: 17.5))
                                .onTapGesture {
                                    withAnimation {
                                        isShow = false
                                    }
                                    sureAction?.action?()
                                }
                        }
                        .padding(.horizontal)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 0)
                .background(Color.white)
                .cornerRadius(8)
                .shadow(radius: 5)
                .padding(.horizontal, 50)
                                
                Image(uiImage: UIImage(named: "icon_alert")!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 34, height: 34)
                    .background(Color(uiColor: "F2F2F7".color()))
                    .clipShape(Circle())
                    .offset(y: -17)
            })
            Spacer()
        }
        .background(
            // 背景遮罩
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        isShow = false
                    }
                }
        )
    }
}

extension AppAlertView {
    
    struct Button<Content: View> {
        
        var content: Content?
        
        var action: (() -> ())? = nil
        
        static func custom(_ content: (() -> Content)? = nil, action: (() -> ())? = nil) -> AppAlertView.Button<Content> {
            AppAlertView.Button(content: content?(), action: action)
        }
    }
    
    enum Alignment {
        case horizontal, vertical
    }
}

#Preview {
    AppAlertView(isShow: .constant(true), cancelAction: .custom({
        Text("取消")
    }), sureAction: .custom({
        Text("确认")
    })) {
        Text("")
    } messageContent: {
        Text("确认")
    }


}
