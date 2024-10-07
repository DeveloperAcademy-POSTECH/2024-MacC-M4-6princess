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
    @State private var isSelected: Bool = false
    @State private var rotationAngle: Angle = .zero
    @State private var showingSavedAlert: Bool = false
    
    let backgroundImage: UIImage
    let idolImage: UIImage
    
    init() {
        // 고해상도 이미지를 로드합니다.
        guard let backgroundImg = UIImage(named: "6공주들")?.cgImage,
              let idolImg = UIImage(named: "필릭스디즈니누끼")?.cgImage else {
            fatalError("Failed to load images")
        }
        
        self.backgroundImage = UIImage(cgImage: backgroundImg, scale: 1.0, orientation: .up)
        self.idolImage = UIImage(cgImage: idolImg, scale: 1.0, orientation: .up)
    }
    
    var imageAspectRatio: CGFloat {
        return idolImage.size.width / idolImage.size.height
    }
    
    let baseWidth: CGFloat = 100
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image(uiImage: backgroundImage)
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
                
                Image(uiImage: idolImage)
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
                        Text("Save High Quality Image")
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
            Alert(title: Text("Success"), message: Text("High quality image saved successfully!"), dismissButton: .default(Text("OK")))
        }
    }
    
    func saveHighQualityImage() {
        guard let backgroundCGImage = backgroundImage.cgImage else { return }
        
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
        
        // 아이돌 이미지 그리기
        let idolWidth = CGFloat(width) * (baseWidth / backgroundImage.size.width) * imageScale
        let idolHeight = idolWidth / imageAspectRatio
        let idolX = CGFloat(width) * (dragOffset.width / backgroundImage.size.width) + CGFloat(width) / 2 - idolWidth / 2
        let idolY = CGFloat(height) * (dragOffset.height / backgroundImage.size.height) + CGFloat(height) / 2 - idolHeight / 2
        
        context.saveGState()
        context.translateBy(x: idolX + idolWidth / 2, y: idolY + idolHeight / 2)
        context.rotate(by: rotationAngle.radians)
        context.translateBy(x: -(idolX + idolWidth / 2), y: -(idolY + idolHeight / 2))
        
        if let idolCGImage = idolImage.cgImage {
            context.draw(idolCGImage, in: CGRect(x: idolX, y: idolY, width: idolWidth, height: idolHeight))
        }
        
        context.restoreGState()
        
        // 최종 이미지 생성
        if let finalImage = context.makeImage() {
            let uiImage = UIImage(cgImage: finalImage)
            UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
            showingSavedAlert = true
        }
    }
}
