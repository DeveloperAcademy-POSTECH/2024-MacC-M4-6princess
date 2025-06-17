//
//  TextSizeSliderView.swift
//  2024-MacC-M4-6princess
//
//  Created by piri kim on 6/17/25.
//
import SwiftUI

struct TextSizeSliderView: View {
    var barSize: CGSize // ✅ 외부에서 지정하는 슬라이더 크기
    let handleSize: CGFloat = 40

    @State private var value: CGFloat = 0.5 // 핸들의 위치 (0.0 ~ 1.0)

    var body: some View {
        let barWidth = barSize.width
        let barHeight = barSize.height

        // 핸들이 이동 가능한 범위
        let minY = handleSize / 2
        let maxY = barHeight - handleSize / 2
        let clampedY = minY + (maxY - minY) * value

        GeometryReader { geometry in
            let xCenter = geometry.size.width / 2

            ZStack {
                // 슬라이드 바
                Image("textSizeBar")
                    .resizable()
                    .frame(width: barWidth, height: barHeight)
                    .position(x: xCenter, y: barHeight / 2)

                // 핸들
                Image("textSizeHandle")
                    .resizable()
                    .frame(width: handleSize, height: handleSize)
                    .position(x: xCenter, y: clampedY)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                let newY = min(max(gesture.location.y, minY), maxY)
                                value = (newY - minY) / (maxY - minY)
                            }
                    )
            }
            .frame(width: max(barWidth, handleSize), height: barHeight)
        }
        .frame(width: max(barWidth, handleSize), height: barHeight)
    }
}
#Preview {
    TextSizeSliderView(barSize: CGSize(width: 16, height: 200))
        .padding()
        .background(Color.gray)
}
