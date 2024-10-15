//
//  ImageResizeView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/4/24.
//
import SwiftUI

struct TestResizeView: View {
    var felix = "Felix"
    var princess = "6princess"
    @ObservedObject var viewModel = IEViewModel()
    @State var backgroundImage = UIImage(named: "6princess")!
    @State var idolImage = UIImage(named: "Felix")!
    var body: some View {
        IECanvasView(viewModel: viewModel, bgImg: $backgroundImage, idolImg: $idolImage)
    }
    
    
    
}

//
//                VStack {
//                    Spacer()
//                    Button(action: {
//                        saveHighQualityImage()
//                    }) {
//                        Text("저어장")
//                            .padding()
//                            .background(Color.blue)
//                            .foregroundColor(.white)
//                            .cornerRadius(10)
//                    }
//                    .padding(.bottom, 20)
//                }
//func saveHighQualityImage() {
//    guard let backgroundCGImage = backgroundImg.cgImage else { return }
//    
//    let width = backgroundCGImage.width
//    let height = backgroundCGImage.height
//    
//    let colorSpace = CGColorSpaceCreateDeviceRGB()
//    let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
//    
//    guard let context = CGContext(data: nil,
//                                  width: width,
//                                  height: height,
//                                  bitsPerComponent: 8,
//                                  bytesPerRow: 0,
//                                  space: colorSpace,
//                                  bitmapInfo: bitmapInfo) else { return }
//    
//    // 배경 이미지 그리기
//    context.draw(backgroundCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))
//    
//    // 현재 GeometryReader 크기를 고려한 스케일링
//    let geometryWidthRatio = CGFloat(width) / UIScreen.main.bounds.width
//    let geometryHeightRatio = CGFloat(height) / UIScreen.main.bounds.height
//    
//    // 아이돌 이미지 크기 계산
//    let idolWidth = (baseWidth * imageScale) * geometryWidthRatio
//    let idolHeight = idolWidth / imageAspectRatio
//    
//    // 아이돌 이미지의 좌표 계산 (GeometryReader 크기 기준)
//    let idolX = (dragOffset.width * geometryWidthRatio) + CGFloat(width) / 2 - idolWidth / 2
//    let idolY = (dragOffset.height * geometryHeightRatio) + CGFloat(height) / 2 - idolHeight / 2
//    
//    context.saveGState()
//    context.translateBy(x: idolX + idolWidth / 2, y: idolY + idolHeight / 2)
//    context.rotate(by: rotationAngle.radians)
//    context.translateBy(x: -(idolX + idolWidth / 2), y: -(idolY + idolHeight / 2))
//    
//    if let idolCGImage = idolImg.cgImage {
//        context.draw(idolCGImage, in: CGRect(x: idolX, y: idolY, width: idolWidth, height: idolHeight))
//    }
//    
//    context.restoreGState()
//    
//    // 최종 이미지 생성 및 저장
//    if let finalImage = context.makeImage() {
//        let uiImage = UIImage(cgImage: finalImage)
//        UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
//        showingSavedAlert = true
//    }
//}

//
//  IETestResizeView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/9/24.
//
//import SwiftUI
//
//struct TestPositionView: View {
//    @State private var imageScale: CGFloat = 1.0
//    @State private var startScale: CGFloat = 1.0
//    @State private var dragOffset: CGSize = .zero
//    @State private var startOffset: CGSize = .zero
//    @State private var isSelected: Bool = false
//    @State private var rotationAngle: Angle = .zero
//    @State private var showingSavedAlert: Bool = false
//    @State private var idolPositionX: CGFloat = 0.0 // 아이돌 위치 X
//    @State private var idolPositionY: CGFloat = 0.0 // 아이돌 위치 Y
//
//    var felix = "Felix"
//    var princess = "6princess"
//
//    var backgroundImg: UIImage
//    var idolImg: UIImage
//
//    init() {
//        guard let backgroundCGImage = UIImage(named: princess)!.cgImage,
//              let idolCGImage = UIImage(named: felix)!.cgImage else {
//            fatalError("이미지 로드 실패")
//        }
//
//        self.backgroundImg = UIImage(cgImage: backgroundCGImage, scale: 1.0, orientation: .up)
//        self.idolImg = UIImage(cgImage: idolCGImage, scale: 1.0, orientation: .up)
//    }
//
//    var imageAspectRatio: CGFloat {
//        return idolImg.size.width / idolImg.size.height
//    }
//
//    let baseWidth: CGFloat = 100
//
//    var body: some View {
//        GeometryReader { geometry in
//            ZStack {
//                Image(uiImage: backgroundImg)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: geometry.size.width, height: geometry.size.height)
//                    .clipped()
//
//                Color.clear
//                    .contentShape(Rectangle())
//                    .gesture(
//                        TapGesture()
//                            .onEnded {
//                                isSelected = false
//                            }
//                    )
//
//                let idolWidth = baseWidth * imageScale
//                let idolHeight = (baseWidth / imageAspectRatio) * imageScale
//
//                let backgroundAspectRatio = backgroundImg.size.width / backgroundImg.size.height
//                let backgroundHeight = min(geometry.size.height, geometry.size.width / backgroundAspectRatio)
//                let backgroundWidth = backgroundHeight * backgroundAspectRatio
//
//                Image(uiImage: idolImg)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: idolWidth, height: idolHeight)
//                    .rotationEffect(rotationAngle)
//                    .overlay(
//                        Rectangle()
//                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1)
//                            .frame(width: idolWidth + 6, height: idolHeight + 6)
//                    )
//                    .gesture(
//                        TapGesture()
//                            .onEnded {
//                                isSelected = true
//                            }
//                    )
//                    .gesture(
//                        MagnificationGesture()
//                            .onChanged { value in
//                                if isSelected {
//                                    imageScale = max(0.5, min(5, startScale + (value - 1) / 10))
//                                }
//                            }
//                            .onEnded { _ in
//                                startScale = imageScale
//                            }
//                    )
//                    .gesture(
//                        RotationGesture()
//                            .onChanged { angle in
//                                if isSelected {
//                                    rotationAngle = angle
//                                }
//                            }
//                    )
//                    .gesture(
//                        DragGesture(minimumDistance: 0)
//                            .onChanged { value in
//                                if isSelected {
//                                    withAnimation(.easeInOut(duration: 0.1)) {
//                                        dragOffset = CGSize(
//                                            width: startOffset.width + value.translation.width,
//                                            height: startOffset.height + value.translation.height
//                                        )
//                                    }
//                                }
//                            }
//                            .onEnded { _ in
//                                startOffset = dragOffset
//                            }
//                    )
//                    .scaleEffect(imageScale)
//                    .offset(dragOffset)
//                    .onAppear {
//                        // 아이돌 위치를 계산하여 State 변수에 저장
//                        idolPositionX = (dragOffset.width + backgroundWidth / 2 - idolWidth / 2) / backgroundWidth
//                        idolPositionY = (dragOffset.height + backgroundHeight / 2 - idolHeight / 2) / backgroundHeight
//                    }
//
//                VStack {
//                    Spacer()
//                    Text("아이돌 위치: (x: \(idolPositionX, specifier: "%.2f"), y: \(idolPositionY, specifier: "%.2f"))")
//                        .foregroundColor(.black)
//                        .padding()
//                    Text("아이돌 크기: (width: \(idolWidth, specifier: "%.2f"), height: \(idolHeight, specifier: "%.2f"))")
//                        .foregroundColor(.black)
//                        .padding()
//                    Button(action: {
//                        saveImage(geometry: geometry)
//                    }) {
//                        Text("저장")
//                            .padding()
//                            .background(Color.blue)
//                            .foregroundColor(.white)
//                            .cornerRadius(10)
//                    }
//                    .padding(.bottom, 20)
//                }
//            }
//            .frame(width: geometry.size.width, height: geometry.size.height)
//            .background(Color.white)
//            .alert(isPresented: $showingSavedAlert) {
//                Alert(title: Text("성공"), message: Text("이미지가 저장되었습니다."), dismissButton: .default(Text("OK")))
//            }
//        }
//    }
//
//    private func saveImage(geometry: GeometryProxy) {
//        // 배경 이미지 크기 가져오기
//        let backgroundSize = backgroundImg.size
//        UIGraphicsBeginImageContextWithOptions(backgroundSize, false, 0) //scale이 0이면 화면에 맞춤
//
//
//        guard let context = UIGraphicsGetCurrentContext() else {
//            UIGraphicsEndImageContext()
//            return
//        }
//
//        // 배경 이미지 그리기
//        backgroundImg.draw(in: CGRect(origin: .zero, size: backgroundSize))
//
//        // 아이돌 이미지 크기 및 위치 계산
//        let idolWidth = idolImg.size.width
//        let idolHeight = idolImg.size.height
//
//        // 아이돌 이미지의 최상단 왼쪽 모서리 위치 계산
//        let newIdolPositionX = (dragOffset.width + (backgroundSize.width / 2) - (idolWidth / 2))
//        let newIdolPositionY = (dragOffset.height + (backgroundSize.height / 2) - (idolHeight / 2))
//
//        // 아이돌 이미지 프레임
//        let idolFrame = CGRect(x: idolPositionX, y: idolPositionY, width: idolWidth, height: idolHeight)
//
//        // 회전 적용
//        context.saveGState()
//        context.translateBy(x: idolFrame.midX, y: idolFrame.midY)
//        context.rotate(by: CGFloat(rotationAngle.radians))
//        context.translateBy(x: -idolFrame.midX, y: -idolFrame.midY)
//
//        // 아이돌 이미지 그리기
//        idolImg.draw(in: idolFrame)
//        context.restoreGState()
//
//        // 이미지 가져오기
//        let renderedImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//
//        // 이미지 저장
//        if let imageToSave = renderedImage {
//            UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil)
//            showingSavedAlert = true
//        }
//    }
//}
//
//  IETestResizeView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/9/24.
//
//
//  IETestResizeView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/9/24.
//


//private func saveImage(geometry: GeometryProxy) {
//    // 배경 이미지 크기 가져오기
//    let backgroundSize = backgroundImg.size
//    UIGraphicsBeginImageContextWithOptions(backgroundSize, false, 0) //scale이 0이면 화면에 맞춤
//
//
//    guard let context = UIGraphicsGetCurrentContext() else {
//        UIGraphicsEndImageContext()
//        return
//    }
//
//    // 배경 이미지 그리기
//    backgroundImg.draw(in: CGRect(origin: .zero, size: backgroundSize))
//
//    // 아이돌 이미지 크기 및 위치 계산
//    let idolWidth = idolImg.size.width
//    let idolHeight = idolImg.size.height
//
//    // 아이돌 이미지의 최상단 왼쪽 모서리 위치 계산
//    let newIdolPositionX = (dragOffset.width + (backgroundSize.width / 2) - (idolWidth / 2))
//    let newIdolPositionY = (dragOffset.height + (backgroundSize.height / 2) - (idolHeight / 2))
//
//    // 아이돌 이미지 프레임
//    let idolFrame = idolPosition
//
//    // 회전 적용
//    context.saveGState()
//    context.translateBy(x: idolFrame.midX, y: idolFrame.midY)
//    context.rotate(by: CGFloat(rotationAngle.radians))
//    context.translateBy(x: -idolFrame.midX, y: -idolFrame.midY)
//
//    // 아이돌 이미지 그리기
//    idolImg.draw(in: idolFrame)
//    context.restoreGState()
//
//    // 이미지 가져오기
//    let renderedImage = UIGraphicsGetImageFromCurrentImageContext()
//    UIGraphicsEndImageContext()
//
//    // 이미지 저장
//    if let imageToSave = renderedImage {
//        UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil)
//        showingSavedAlert = true
//    }
//}
