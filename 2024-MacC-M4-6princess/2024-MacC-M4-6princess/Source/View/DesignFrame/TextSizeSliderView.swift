//
//  TextSizeSliderView.swift
//  2024-MacC-M4-6princess
//
//  Created by piri kim on 6/17/25.
//
import SwiftUI
import UIKit

struct TextSizeSliderView: View {
    var barSize: CGSize
    let handleSize: CGFloat = 40
    let minFontSize: Double
    let maxFontSize: Double
    
    @Binding var fontSize: Double
    
    @State private var lastFeedbackFontSize: Int = -1 // 햅틱 마지막 트리거 시점
    
    var body: some View {
        let barWidth = barSize.width
        let barHeight = barSize.height
        
        let minY = handleSize / 2
        let maxY = barHeight - handleSize / 2
        
        let value = CGFloat(1.0 - (fontSize - minFontSize) / (maxFontSize - minFontSize))
        let clampedY = minY + (maxY - minY) * value
        
        GeometryReader { geometry in
            let xCenter = geometry.size.width / 2
            
            ZStack {
                Image("textSizeBar")
                    .resizable()
                    .frame(width: barWidth, height: barHeight)
                    .position(x: xCenter, y: barHeight / 2)
                
                Image("textSizeHandle")
                    .resizable()
                    .frame(width: handleSize, height: handleSize)
                    .position(x: xCenter, y: clampedY)
                    .animation(.easeInOut(duration: 0.2), value: clampedY)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                let newY = min(max(gesture.location.y, minY), maxY)
                                let newValue = 1.0 - (newY - minY) / (maxY - minY)
                                let newFontSize = minFontSize + Double(newValue) * (maxFontSize - minFontSize)
                                
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    fontSize = newFontSize
                                }
                                
                                // 햅틱 트리거: 폰트가 정수 단위로 바뀔 때마다
                                let currentIntSize = Int(newFontSize.rounded())
                                if currentIntSize != lastFeedbackFontSize {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    lastFeedbackFontSize = currentIntSize
                                }
                            }
                    )
            }
            .frame(width: max(barWidth, handleSize), height: barHeight)
        }
        .frame(width: max(barWidth, handleSize), height: barHeight)
        .onAppear{
//            fontSize = (minFontSize+maxFontSize) / 2
        }
    }
    
}
