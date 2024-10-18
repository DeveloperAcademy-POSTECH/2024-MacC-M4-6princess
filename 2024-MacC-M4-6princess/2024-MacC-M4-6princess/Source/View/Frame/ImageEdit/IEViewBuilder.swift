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

// 편집 옵션 데이터 구조체 정의
struct EditingOption {
    let name: String
    let icon: String
    let range: ClosedRange<Float>
    var step: Float
}
