//
//  IWCoreFilterListView.swift
//  ImageWizard
//
//  Created by 万孟超 on 2024/4/15.
//

import SwiftUI

struct WizardCoreFilterListView: View {
    
    let filterList = IWCoreImageFilter.logFilters()
    
    @Binding var filter: String?
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(alignment: .leading, content: {
                ForEach(filterList, id: \.self) { filterName in
                    Button {
                        filter = filterName
                    } label: {
                        Text(filterName)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .padding(.trailing)
                            .frame(height: 30)
                            .font(.title3)
                            .foregroundStyle(Color.black)
                            .padding(.leading)
                    }
                    Divider()
                        .frame(maxWidth: .infinity, maxHeight: 2)
                        .padding(.leading)
                }
            })
            .padding(.vertical)
        }
    }
}

