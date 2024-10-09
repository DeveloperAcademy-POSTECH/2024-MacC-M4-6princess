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
    var body: some View {
        ZStack {
            VStack {
                Button(action: {
                    showMagnifyGestureTestView.toggle()
                }) {
                    Text("IEMagnifyGestureTestView")
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
                    Text("IEWidthFixView")
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
            }
            .padding()
        }
        .fullScreenCover(isPresented: $showMagnifyGestureTestView) {
            IEMagnifyGestureTestView()
        }
        .fullScreenCover(isPresented: $showRatioChangeView) {
            IERatioChangeView()
        }
        .fullScreenCover(isPresented: $showWidthFixView) {
            IEWidthFixView()
        }
        .fullScreenCover(isPresented: $imageResizeView) {
            IEImageResizeView()
        }
    }
}

#Preview {
    IEDevelopView()
}
