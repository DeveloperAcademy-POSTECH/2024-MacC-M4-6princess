//
//  IETestResizeView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/9/24.
//
import SwiftUI

struct TestPositionView: View {
    @State private var imageScale: CGFloat = 1.0
    @State private var startScale: CGFloat = 1.0
    @State private var dragOffset: CGSize = .zero
    @State private var startOffset: CGSize = .zero
    @State private var isSelected: Bool = false
    @State private var rotationAngle: Angle = .zero
    @State private var showingSavedAlert: Bool = false
    var felix = "Felix"
    var princess = "6princess"
    
    var backgroundImg: UIImage
    var idolImg: UIImage
    
    init() {
        guard let backgroundCGImage = UIImage(named: princess)!.cgImage,
              let idolCGImage = UIImage(named: felix)!.cgImage else {
            fatalError("이미지 로드 실패")
        }
        
        self.backgroundImg = UIImage(cgImage: backgroundCGImage, scale: 1.0, orientation: .up)
        self.idolImg = UIImage(cgImage: idolCGImage, scale: 1.0, orientation: .up)
    }
    
    var imageAspectRatio: CGFloat {
        return idolImg.size.width / idolImg.size.height
    }
    
    let baseWidth: CGFloat = 100
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image(uiImage: backgroundImg)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        TapGesture()
                            .onEnded {
                                isSelected = false
                            }
                    )
                
                // 아이돌 이미지의 크기
                let idolWidth = baseWidth * imageScale
                let idolHeight = (baseWidth / imageAspectRatio) * imageScale
                
                // 배경 이미지의 실제 크기 계산
                let backgroundAspectRatio = backgroundImg.size.width / backgroundImg.size.height
                let backgroundHeight = min(geometry.size.height, geometry.size.width / backgroundAspectRatio)
                let backgroundWidth = backgroundHeight * backgroundAspectRatio
                
                // 배경 이미지의 오프셋 계산 (중앙 정렬을 위해)
                let backgroundOffsetX = (geometry.size.width - backgroundWidth) / 2
                let backgroundOffsetY = (geometry.size.height - backgroundHeight) / 2
                
                Image(uiImage: idolImg)
                    .resizable()
                    .scaledToFit()
                    .frame(width: idolWidth, height: idolHeight)
                    .rotationEffect(rotationAngle)
                    .overlay(
                        Rectangle()
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1)
                            .frame(width: idolWidth + 6, height: idolHeight + 6)
                    )
                    .gesture(
                        TapGesture()
                            .onEnded {
                                isSelected = true
                            }
                    )
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                if isSelected {
                                    imageScale = max(0.5, min(5, startScale + (value - 1) / 10))
                                }
                            }
                            .onEnded { _ in
                                startScale = imageScale
                            }
                    )
                    .gesture(
                        RotationGesture()
                            .onChanged { angle in
                                if isSelected {
                                    rotationAngle = angle
                                }
                            }
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
                
                // 현재 아이돌 이미지의 위치와 크기를 배경 기준으로 출력
                VStack {
                    Spacer()
                    // 아이돌 이미지의 최상단 왼쪽 모서리 위치 계산
                    let idolPositionX = (dragOffset.width + backgroundWidth / 2 - idolWidth / 2) / backgroundWidth
                    let idolPositionY = (dragOffset.height + backgroundHeight / 2 - idolHeight / 2) / backgroundHeight
                    Text("아이돌 위치: (x: \(idolPositionX, specifier: "%.2f"), y: \(idolPositionY, specifier: "%.2f"))")
                        .foregroundColor(.black)
                        .padding()
                    Text("아이돌 크기: (width: \(idolWidth, specifier: "%.2f"), height: \(idolHeight, specifier: "%.2f"))")
                        .foregroundColor(.black)
                        .padding()
                    Button(action: {
                        // 저장 액션
                    }) {
                        Text("저장")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.bottom, 20)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.white)
            .alert(isPresented: $showingSavedAlert) {
                Alert(title: Text("성공"), message: Text("성공성공"), dismissButton: .default(Text("OK")))
            }
        }
    }
}
