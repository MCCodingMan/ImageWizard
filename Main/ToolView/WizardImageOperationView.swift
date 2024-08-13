//
//  IWImageOperationView.swift
//  ImageWizard
//
//  Created by 万孟超 on 2024/4/23.
//

import SwiftUI

struct WizardImageOperationView: View {
    @StateObject var viewModel = IWImageOperationViewModel()
    @StateObject var defaultOffsetModel = WizardOperationSlider.OffsetPublisher()
    var filterMapBlock: (BBMetalFilterTuple) -> ()
    var defaultFilterValue: [BBMetalFilterType : Float] = [:]
    
    init(filterDefaultValue: [BBMetalFilterType: Float] = [:],
         filterMapBlock: @escaping (BBMetalFilterTuple) -> Void) {
        self.defaultFilterValue = filterDefaultValue
        self.filterMapBlock = filterMapBlock
    }
    
    var body: some View {
        VStack(spacing: 15, content: {
            title
            VStack(spacing: 5, content: {
                filterListView
                WizardOperationSlider(offsetModel: defaultOffsetModel) { value in
                    viewModel.filterValue[viewModel.selectFilter] = round(Float(value))
                    filterMapBlock((viewModel.selectFilter, Float(value)))
                }
                .frame(height: 30)
            })
        })
        .background(Color.clear)
        .onAppear(perform: {
            viewModel.filterValue = defaultFilterValue
            defaultOffsetModel.defaultOffset = viewModel.currentFilterOffset
        })
        
    }
    
    var title: some View {
        Text(viewModel.selectFilter.rawValue)
            .foregroundStyle(.white)
            .padding(6)
            .background(Color.black)
            .cornerRadius(6.0)
    }
    
    var filterListView: some View {
        ScrollViewReader { proxy in
            GeometryReader { geometry in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        Spacer().frame(width: geometry.size.width / 2 - 65 / 2)
                        LazyHStack(spacing: 15, content: {
                            ForEach(viewModel.filterEnums, id: \.self) { filter in
                                OperateIteratorView(currentValue: Int(viewModel.filterValue[filter] ?? 0), imageName: filter.imageName)
                                    .frame(width: 65, height: 65)
                                    .onTapGesture {
                                        viewModel.selectFilter = filter
                                        defaultOffsetModel.defaultOffset = viewModel.currentFilterOffset
                                    }
                                    .id(filter.rawValue)
                            }
                        })
                        Spacer().frame(width: geometry.size.width / 2 - 65 / 2)
                    }
                }
                .onReceive(viewModel.$currentOperateID, perform: { _ in
                    withAnimation {
                        proxy.scrollTo(viewModel.currentOperateID, anchor: .center)
                    }
                })
            }
        }
        .frame(height: 65)
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
    }
    
}

extension WizardImageOperationView {
    struct OperateIteratorView: View {
                
        var currentValue: Int
        var imageName: String
        
        var body: some View {
            VStack(content: {
                ZStack(content: {
                    GeometryReader(content: { geometry in
                        Path { path in
                            path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2), radius: geometry.size.width / 2, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 360), clockwise: false)
                        }
                        .stroke(lineWidth: 3.0)
                        .fill(Color(uiColor: "AAAAAA".color(alpha: 0.6)))
                        Path { path in
                            path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2), radius: geometry.size.width / 2, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: Double(currentValue) * 90.0 / 25.0 - 90.0), clockwise: currentValue > 0 ? false : true)
                        }
                        .stroke(lineWidth: 3.0)
                        .fill(currentValue > 0 ? Color.yellow : Color.white)
                    })
                    .padding(.horizontal, 5)
                    if currentValue == 0 {
                        Image(systemName: imageName)
                            .font(.title2)
                            .foregroundStyle(.white)
                    }else{
                        Text("\(currentValue)")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                })
            })
            
        }
        
    }
    
    class IWImageOperationViewModel: ObservableObject {
        
        let filterEnums = BBMetalFilterType.allCases
        
        var filterValue: [BBMetalFilterType : Float] = [:]
        
        var selectFilter: BBMetalFilterType = .exposure {
            didSet {
                currentOperateID = selectFilter.rawValue
            }
        }
        
        var currentFilterOffset: Int {
            Int(filterValue[selectFilter] ?? 0)
        }
                
        @Published var currentOperateID: String = BBMetalFilterType.exposure.rawValue
        
    }
}

#Preview {
    VStack {
        Spacer()
        WizardImageOperationView { _, _ in
            
        }
    }
    .background(Color.black)
    
    
}
