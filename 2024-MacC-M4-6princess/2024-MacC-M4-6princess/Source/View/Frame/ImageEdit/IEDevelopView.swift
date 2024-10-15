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
                Button(action: {
                    showMagnifyGestureTestView.toggle()
                }) {
                    Text("사진위치")
                        .font(.title)
                        .padding()
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(10)
                }
                .padding()
                
                Button(action: {
                    showRatioChangeView.toggle()
                }) {
                    Text("IERatioChangeView")
                        .font(.title)
                        .padding()
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(10)
                }
                .padding()
                
                Button(action: {
                    showWidthFixView.toggle()
                }) {
                    Text("color")
                        .font(.title)
                        .padding()
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(10)
                }
                .padding()
                
                
                Button(action: {
                    imageResizeView.toggle()
                }) {
                    Text("resize")
                        .font(.title)
                        .padding()
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(10)
                }
                .padding()
        
                
                NavigationLink(destination:IEMainView()) {
                    Text("full")
                        .font(.title)
                        .padding()
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(10)
                }
                
                NavigationLink(destination:TestPositionView()) {
                    Text("position")
                        .font(.title)
                        .padding()
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .fullScreenCover(isPresented: $showMagnifyGestureTestView) {
            TestImagePositionView()
        }
        .fullScreenCover(isPresented: $showRatioChangeView) {
            TestDragView()
        }
        .fullScreenCover(isPresented: $showWidthFixView) {
            IEWidthFixView()
        }
        .fullScreenCover(isPresented: $imageResizeView) {
            TestRatioChangeTestView()
        }
        .fullScreenCover(isPresented: $edit) {
            IEMainView()
        }
    }
}
