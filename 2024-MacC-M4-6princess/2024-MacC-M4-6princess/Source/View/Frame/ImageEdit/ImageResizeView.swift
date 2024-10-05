//
//  ImageResizeView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/4/24.
//
import SwiftUI

struct ImageResizeView: View {
    @State private var imageScale: CGFloat = 1.0
    @State private var startScale: CGFloat = 1.0
    @State private var dragOffset: CGSize = .zero
    @State private var startOffset: CGSize = .zero
    
    let image: UIImage = UIImage(named: "필릭스디즈니누끼")! // 이미지를 가져옴
    
    // 이미지 비율 계산
    var imageAspectRatio: CGFloat {
        return image.size.width / image.size.height
    }
    
    // 기본 이미지 크기 설정
    let baseWidth: CGFloat = 100
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 이미지 뷰와 Rectangle 오버레이를 함께 그룹화
                Group {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                    
                    Rectangle()
                        .stroke(Color.blue, lineWidth: 2)
                        .fill(Color.clear)
                }
                .frame(width: baseWidth, height: baseWidth / imageAspectRatio)
                .scaleEffect(imageScale)
                .offset(dragOffset)
                
                // 크기 조정 버튼
                Image(systemName: "chevron.forward.circle")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .position(x: (baseWidth * imageScale) - 15, y: ((baseWidth / imageAspectRatio) * imageScale) - 15)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let delta = value.translation.width + value.translation.height
                                imageScale = max(0.5, min(5, startScale + delta / 300)) // 크기 제한 추가
                            }
                            .onEnded { _ in
                                startScale = imageScale
                            }
                    )
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.white)
        }
    }
}
