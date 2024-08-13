//
//  WizardClockView.swift
//  ImageWizard
//
//  Created by zjkj on 2024/6/22.
//
import SwiftUI

struct WizardClockView: View {
    @State private var currentTime = Time(hour: 0, minute: 0, second: 0)
    @State private var totalSeconds: Double = 0
    @State private var dayOfWeek: String = ""

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 刻度
                ForEach(0..<60) { tick in
                    Rectangle()
                        .foregroundColor(tick % 5 == 0 ? .black : "555555".iiColor())
                        .frame(width: 2, height: tick % 5 == 0 ? 10 : 5)
                        .offset(y: -geometry.size.width / 2 + 10)
                        .rotationEffect(.degrees(Double(tick) * 6))
                }
                
                // 数字刻度
                ForEach(1...12, id: \.self) { number in
                    Text("\(number)")
                        .font(.system(size: 12))
                        .fontWeight(.bold)
                        .foregroundStyle(.black)
                        .position(x: geometry.size.width / 2 + cos(CGFloat(number) * CGFloat.pi / 6 - CGFloat.pi / 2) * (geometry.size.width / 2 - 25),
                                  y: geometry.size.width / 2 + sin(CGFloat(number) * CGFloat.pi / 6 - CGFloat.pi / 2) * (geometry.size.width / 2 - 25))
                }
                // 星期显示
                Text(dayOfWeek)
                    .font(.system(size: 12))
                    .fontWeight(.bold)
                    .position(x: geometry.size.width / 2, y: geometry.size.width / 2.5)
                // 时针
                ClockHand(length: geometry.size.width / 2 - 40, thickness: 4, rotationAngle: hourAngle, color: "222222".iiColor())
                
                // 分针
                ClockHand(length: geometry.size.width / 2 - 20, thickness: 3, rotationAngle: minuteAngle, color: "333333".iiColor())
                
                // 秒针
                ClockHand(length: geometry.size.width / 2 - 10, thickness: 2, rotationAngle: secondAngle, color: "DDDDDD".iiColor())
                
            }
            .frame(width: geometry.size.width, height: geometry.size.width)
            .onAppear(perform: startClock)
        }
        .background(.gray)
        .clipped()
        .clipShape(Circle())
    }
    
    var secondAngle: Angle {
        .degrees(totalSeconds * 6)
    }
    
    var minuteAngle: Angle {
        .degrees((Double(currentTime.minute) / 60 * 360) + (Double(currentTime.second) / 60 * 6))
    }
    
    var hourAngle: Angle {
        .degrees((Double(currentTime.hour) / 12 * 360) + (Double(currentTime.minute) / 60 * 30))
    }
    
    func startClock() {
        let calendar = Calendar.current
        let date = Date()
        
        currentTime.second = calendar.component(.second, from: date)
        currentTime.minute = calendar.component(.minute, from: date)
        currentTime.hour = calendar.component(.hour, from: date)
        
        totalSeconds = Double(currentTime.second)
        
        let dateFormatter = DateFormatter()        
        dateFormatter.locale = Locale(identifier: "zh_CN")

        dateFormatter.dateFormat = "EEEE"
        dayOfWeek = dateFormatter.string(from: date)
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            withAnimation(.linear(duration: 1.0)) {
                let date = Date()
                
                currentTime.second = calendar.component(.second, from: date)
                currentTime.minute = calendar.component(.minute, from: date)
                currentTime.hour = calendar.component(.hour, from: date)
                
                totalSeconds += 1
                dayOfWeek = dateFormatter.string(from: date)
            }
        }
    }
    
    struct ClockHand: View {
        var length: CGFloat
        var thickness: CGFloat
        var rotationAngle: Angle
        var color: Color = .black
        
        var body: some View {
            RoundedRectangle(cornerRadius: length / 2)
                .fill(color)
                .frame(width: thickness, height: length)
                .offset(y: -length / 2)
                .rotationEffect(rotationAngle)
        }
    }

    struct Time {
        var hour: Int
        var minute: Int
        var second: Int
    }
}


struct ClockView_Previews: PreviewProvider {
    static var previews: some View {
        WizardClockView()
            .frame(width: 300, height: 300)
    }
}
