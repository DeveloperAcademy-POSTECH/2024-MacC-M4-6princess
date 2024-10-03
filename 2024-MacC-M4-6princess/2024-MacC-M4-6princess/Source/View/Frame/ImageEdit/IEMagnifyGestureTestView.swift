//
//  IEMagnifyGestureView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/1/24.
//
import SwiftUI

struct IEMagnifyGestureTestView: View {
    @State private var scale = 3.0
    @State private var magnificationValue = 1.0 // Add this state for manual magnification
    @GestureState private var magnification = 1.0
    
    var magnificationGesture: some Gesture {
        MagnifyGesture()
            .updating($magnification) { value, gestureState, transaction in
                gestureState = value.magnification
            }
            .onEnded { value in
                self.scale *= value.magnification
            }
    }
    
    var body: some View {
        ZStack{
            Image("필릭스디즈니누끼")
                .resizable()
                .scaledToFit()
                .frame(width: 100)
                .scaleEffect(scale * magnification * magnificationValue) // Combine gesture and manual magnification
                .gesture(magnificationGesture)
            VStack{
                Spacer()
                HStack{
                    Spacer()
                    VStack {
                        Button(action: {
                            magnificationValue += 0.2 // Adjust magnification value for manual scaling
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .padding()
                        }
                        
                        Button(action: {
                            magnificationValue = max(0.5, magnificationValue * 0.8) // Adjust magnification with a minimum limit
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .padding()
                        }
                    }
                    .padding(.horizontal, 20)
                }
                Text("scale: \(String(format: "%.1f",magnificationValue))")
            }
        }
    }
}
