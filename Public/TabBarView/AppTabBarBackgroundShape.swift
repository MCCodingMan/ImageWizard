//
//  AppTabBarBackgroundShape.swift
//  ImageWizard
//
//  Created by 万孟超 on 2024/4/17.
//

import SwiftUI

struct AppTabBarBackgroundLeftShape: Shape {
    
    var cornerRatio = 10.0
    
    init(cornerRatio: Double = 10.0) {
        self.cornerRatio = cornerRatio
    }
    
    func path(in rect: CGRect) -> Path {
        Path({ path in
            path.move(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.minX, y: cornerRatio))
            path.addArc(center: CGPoint(x: cornerRatio, y: cornerRatio),
                        radius: cornerRatio,
                        startAngle: Angle(degrees: -180),
                        endAngle: Angle(degrees: -90),
                        clockwise: false)
            path.addLine(to: CGPoint(x: rect.maxX - rect.size.height / 4, y: 0))
            let topEndPoitx = rect.maxX - rect.size.height / 4
            let topEndPoity = rect.size.height / 2 - rect.size.height / 4 * sqrt(3.0)
            path.addQuadCurve(to: CGPoint(x: topEndPoitx, y: topEndPoity), 
                              control: CGPoint(x: rect.maxX - rect.size.height / 4 * 3 / 4 , y: topEndPoity / 2 - 1))
            
            path.addArc(center: CGPoint(x: rect.maxX, y: rect.midY),
                        radius: rect.size.height / 2,
                        startAngle: Angle(degrees: -120),
                        endAngle: Angle(degrees: 120),
                        clockwise: true)
            
            let endPoitx = rect.maxX - rect.size.height / 4
            
            path.addQuadCurve(to: CGPoint(x: endPoitx, y: rect.maxY),
                              control: CGPoint(x: rect.maxX - rect.size.height / 4 * 3 / 4 , y: rect.maxY - (topEndPoity / 2 - 1)))
            
            path.addLine(to: CGPoint(x: cornerRatio, y: rect.maxY))
            path.addArc(center: CGPoint(x: cornerRatio, y: rect.maxY - cornerRatio),
                        radius: cornerRatio,
                        startAngle: Angle(degrees: -90),
                        endAngle: Angle(degrees: -180),
                        clockwise: false)
            path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        })
    }
}


struct AppTabBarBackgroundRightShape: Shape {
    var cornerRatio = 10.0
    
    init(cornerRatio: Double = 10.0) {
        self.cornerRatio = cornerRatio
    }
    
    func path(in rect: CGRect) -> Path {
        Path({ path in
            path.move(to: CGPoint(x: rect.maxX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX, y: cornerRatio))
            path.addArc(center: CGPoint(x: rect.maxX - cornerRatio, y: cornerRatio),
                        radius: cornerRatio,
                        startAngle: Angle(degrees: 0),
                        endAngle: Angle(degrees: -90),
                        clockwise: true)
            path.addLine(to: CGPoint(x: rect.size.height / 4, y: 0))
            let topEndPoitx = rect.size.height / 4
            let topEndPoity = rect.size.height / 2 - rect.size.height / 4 * sqrt(3.0)
            
            path.addQuadCurve(to: CGPoint(x: topEndPoitx, y: topEndPoity),
                              control: CGPoint(x: rect.size.height / 4 * 3 / 4 , y: topEndPoity / 2 - 1))
            
            path.addArc(center: CGPoint(x: 0, y: rect.midY),
                        radius: rect.size.height / 2,
                        startAngle: Angle(degrees: -60),
                        endAngle: Angle(degrees: 60),
                        clockwise: false)
            
            let endPoitx = rect.size.height / 4
            path.addQuadCurve(to: CGPoint(x: endPoitx, y: rect.maxY),
                              control: CGPoint(x: rect.size.height / 4 * 3 / 4 , y: rect.maxY - (topEndPoity / 2 - 1)))
            
            path.addLine(to: CGPoint(x: rect.maxX - 10, y: rect.maxY))
            path.addArc(center: CGPoint(x: rect.maxX - 10, y: rect.maxY - 10),
                        radius: 10,
                        startAngle: Angle(degrees: 90),
                        endAngle: Angle(degrees: 0),
                        clockwise: true)
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        })
    }
}

#Preview(body: {
    ZStack(content: {
        HStack(spacing: 0, content: {
            AppTabBarBackgroundLeftShape()
                .frame(width: UIScreen.main.bounds.width / 2 - 26, height: 80)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0.0, y: -1.0)
            
            AppTabBarBackgroundRightShape()
                .frame(width: UIScreen.main.bounds.width / 2 - 26, height: 80)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0.0, y: -1.0)
        })
        .padding(.horizontal, 6)
        Circle()
            .frame(width: 70, height: 70)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0.0, y: -1.0)
    })
    
})
