//
//  AppViewExtension.swift
//  ImageWizard
//
//  Created by 万孟超 on 2024/4/24.
//

import SwiftUI

extension View {
    func onValueChange<T>(of property: T, perform: @escaping (_ value: T) -> ()) -> some View where T: Equatable {
        if #available(iOS 17.0, *) {
            return onChange(of: property) { oldValue, newValue in
                perform(newValue)
            }
        } else {
           return onChange(of: property, perform: { value in
                perform(value)
            })
        }
    }
    
    func customCornerRadius(_ radius: CGFloat = 8, rectCorner: UIRectCorner = .allCorners, fillColor: Color? = nil) -> some View {
        clipShape(AppCornerRadiusStyle(radius: radius, corners: rectCorner))
    }
    
    func viewOrientationRotation(_ orientation: UIDeviceOrientation) -> some View {
        rotationEffect(Angle(degrees: orientation == .landscapeLeft ? 90 : ( orientation == .landscapeRight ? -90 : (orientation == .portraitUpsideDown ? 180 : 0))))
            .animation(.linear, value: orientation)
    }
}

struct AppCornerRadiusStyle: Shape {
    var radius: CGFloat = 8
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

protocol SwiftUIViewToUIViewProtocol {
    static func viewToUIView() -> Self
}
