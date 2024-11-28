//
//  IEViewBuilder.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/11/24.
//

import SwiftUI

struct IEOutputImageView: View {
    var image: UIImage
    
    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
            
        }
        
    }
}

struct SliderView: View {
    @Binding var value: Float// 슬라이더 값
    var range: ClosedRange<Float> // 슬라이더 범위
    var step: Float // 슬라이더 단계
    
    var body: some View {
        HStack {
            Text(String(format: "%.0f", value * 100)) // 텍스트 (밝기 퍼센트)
                .foregroundColor(.white)
            
            // 슬라이더
            Slider(value: $value, in: range, step: Float.Stride(step))
                .padding()
                .foregroundColor(.pointPink) // 슬라이더 색상
                .background(Color.black.opacity(0.5)) // 배경색
        }
        .frame(height:40)
    }
}

struct CustomSliderView: View {
    @Binding var value: Float
    
    var range: ClosedRange<Float>
    var step: Float
    @StateObject var viewModel: IEViewModel
    var idx:Int
    // range의 중간값 계산
    var midValue: Float {
        (range.lowerBound + range.upperBound) / 2
    }
    
    // 0~100 사이로 변환하는 계산
    var displayValue: Float {
        // 실제 슬라이더 값의 범위를 0~100으로 변환
        let normalizedValue = (value - range.lowerBound) / (range.upperBound - range.lowerBound) * 100
        return normalizedValue
    }
    
    // 변환된 값을 원래 범위로 되돌리는 함수
    func valueFromDisplayValue(_ displayValue: Float) -> Float {
        // 0~100을 다시 원래의 range로 변환
        let normalizedValue = (displayValue / 100) * (range.upperBound - range.lowerBound) + range.lowerBound
        return normalizedValue
    }
    
    var body: some View {
        HStack {
            Text(String(format: "%.0f", displayValue)) // 변환된 텍스트 (밝기 퍼센트)
                .foregroundColor(.white)
                .frame(width: 30)
                .padding(.horizontal, 5)
            
            Slider(value: Binding(
                get: { value },
                set: { newValue in
                    // 슬라이더 값 업데이트 시 변환된 값으로 업데이트
                    let clampedValue = min(max(newValue, range.lowerBound), range.upperBound)
                    value = clampedValue
                }
            ), in: range, step: step, onEditingChanged: { editing in
                // 사용자가 슬라이더 조작을 종료했을 때
                if !editing {
                    viewModel.undoHistory.append(viewModel.recentPop)
                    viewModel.recentPop.sliderValues[idx] = value
                    if !viewModel.redoHistory.isEmpty{
                        viewModel.redoHistory = []
                    }
                }
            }
            )
            .tint(Color.pointPink)
            .padding(.horizontal)
        }
        .frame(width: viewModel.screenSize.width,height: 40)
        .background(Color.black.opacity(0.5)) // 배경색
    }
}

extension CGPoint {
    func printPoint() {
        print("x: \(self.x), y: \(self.y)")
    }
}
