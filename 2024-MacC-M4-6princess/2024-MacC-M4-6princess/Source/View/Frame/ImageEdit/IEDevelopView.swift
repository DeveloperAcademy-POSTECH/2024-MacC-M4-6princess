//
//  IEDevelopView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/3/24.
//

import SwiftUI

struct IEDevelopView: View {
    @State private var showMagnifyGestureTestView = false
    @State private var showRatioChangeView = false
    @State private var showWidthFixView = false
    @State private var imageResizeView = false
    @State private var edit = false
    var body: some View {
        
        NavigationStack {
            VStack {
                NavigationLink(destination:IEMainView()) {
                    Text("full")
                        .font(.title)
                        .padding()
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(10)
                }
            }
            .padding()
        }
      
       
       
    }
}
