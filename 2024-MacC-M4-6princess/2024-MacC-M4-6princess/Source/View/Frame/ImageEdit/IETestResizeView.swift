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
    @State private var showingSavedAlert: Bool = false
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
                
                Image(uiImage: idolImg)
                    .resizable()
                    .scaledToFit()
                    .frame(width: baseWidth * imageScale, height: (baseWidth / imageAspectRatio) * imageScale)
                    .rotationEffect(rotationAngle)
                    .overlay(
                        Rectangle()
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1)
                            .frame(width: (baseWidth * imageScale) + 6, height: ((baseWidth / imageAspectRatio) * imageScale) + 6)
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
                
                VStack {
                    Spacer()
                    Button(action: {
                        saveHighQualityImage()
                    }) {
                        Text("저어장")
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
        }
        .alert(isPresented: $showingSavedAlert) {
            Alert(title: Text("성공"), message: Text("성공성공"), dismissButton: .default(Text("OK")))
        }
    }
    
    func saveHighQualityImage() {
        guard let backgroundCGImage = backgroundImg.cgImage else { return }
        
        let width = backgroundCGImage.width
        let height = backgroundCGImage.height
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        
        guard let context = CGContext(data: nil,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: 0,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo) else { return }
        
        // 배경 이미지 그리기
        context.draw(backgroundCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        // 현재 GeometryReader 크기를 고려한 스케일링
        let geometryWidthRatio = CGFloat(width) / UIScreen.main.bounds.width
        let geometryHeightRatio = CGFloat(height) / UIScreen.main.bounds.height
        
        // 아이돌 이미지 크기 계산
        let idolWidth = (baseWidth * imageScale) * geometryWidthRatio
        let idolHeight = idolWidth / imageAspectRatio
        
        // 아이돌 이미지의 좌표 계산 (GeometryReader 크기 기준)
        let idolX = (dragOffset.width * geometryWidthRatio) + CGFloat(width) / 2 - idolWidth / 2
        let idolY = (dragOffset.height * geometryHeightRatio) + CGFloat(height) / 2 - idolHeight / 2
        
        context.saveGState()
        context.translateBy(x: idolX + idolWidth / 2, y: idolY + idolHeight / 2)
        context.rotate(by: rotationAngle.radians)
        context.translateBy(x: -(idolX + idolWidth / 2), y: -(idolY + idolHeight / 2))
        
        if let idolCGImage = idolImg.cgImage {
            context.draw(idolCGImage, in: CGRect(x: idolX, y: idolY, width: idolWidth, height: idolHeight))
        }
        
        context.restoreGState()
        
        // 최종 이미지 생성 및 저장
        if let finalImage = context.makeImage() {
            let uiImage = UIImage(cgImage: finalImage)
            UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
            showingSavedAlert = true
        }
    }
    
}
