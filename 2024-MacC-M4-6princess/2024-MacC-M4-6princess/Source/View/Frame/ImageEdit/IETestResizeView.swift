//
//  IETestResizeView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/9/24.
//


import SwiftUI

struct IETestResizeView: View {
    @State private var imageScale: CGFloat = 1.0
    @State private var startScale: CGFloat = 1.0
    @State private var dragOffset: CGSize = .zero
    @State private var startOffset: CGSize = .zero
    @State private var isSelected: Bool = false
    @State private var rotationAngle: Angle = .zero
    var felix = "Felix"
    var princess = "6princess"
    
    var backgroundImg: UIImage
    var idolImg: UIImage
    
    init(backgroundImage: UIImage, idolImage: UIImage) {
        // 고해상도 이미지를 UIImage -> CGImage -> 다시 UIImage로 변환하는 과정 유지
        guard let backgroundCGImage = backgroundImage.cgImage,
              let idolCGImage = idolImage.cgImage else {
            fatalError("이미지 로드 실패")
        }
        
        // CGImage를 사용하여 새로운 UIImage를 생성
        self.backgroundImg = UIImage(cgImage: backgroundCGImage, scale: 1.0, orientation: .up)
        self.idolImg = UIImage(cgImage: idolCGImage, scale: 1.0, orientation: .up)
        
    }
    
    var imageAspectRatio: CGFloat {
        return idolImg.size.width / idolImg.size.height
    }
    
    let baseWidth: CGFloat = 100
    
    var body: some View {
        
        ZStack {
            Image(uiImage: backgroundImg)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
            
            Color.clear
                .contentShape(Rectangle())
                .gesture(
                    TapGesture()
                        .onEnded {
                            isSelected = false
                        }
                )
            Image(uiImage: idolImg)
                .resizable()
                .scaledToFit()
                .frame(width: baseWidth * imageScale, height: (baseWidth / imageAspectRatio) * imageScale)
                .rotationEffect(rotationAngle) // 이미지 회전 적용
                .overlay(
                    Rectangle()
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1)
                        .frame(width: (baseWidth * imageScale) + 6, height: ((baseWidth / imageAspectRatio) * imageScale) + 6)
                        .rotationEffect(rotationAngle) // 오버레이 회전 적용
                )
                .gesture(
                    TapGesture()
                        .onEnded {
                            isSelected = true
                        }
                )
                .gesture(
                    SimultaneousGesture(
                        MagnificationGesture()
                            .onChanged { value in
                                if isSelected {
                                    imageScale = max(0.5, min(5, startScale + (value - 1) / 10))
                                }
                            }
                            .onEnded { _ in
                                startScale = imageScale
                            },
                        RotationGesture()
                            .onChanged { angle in
                                if isSelected {
                                    rotationAngle = angle
                                }
                            }
                    )
                )
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            if isSelected {
                                withAnimation(.easeInOut(duration: 0.1)) {
                                    dragOffset = CGSize(
                                        width: startOffset.width + value.translation.width,
                                        height: startOffset.height + value.translation.height
                                    )
                                }
                            }
                        }
                        .onEnded { _ in
                            startOffset = dragOffset
                        }
                )
                .scaleEffect(imageScale)
                .offset(dragOffset)

        }
        
    }
    
}
