//
//  ImageResizeView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/4/24.
//
import SwiftUI

struct IEImageResizeView: View {
    var felix = "Felix"
    var princess = "6princess"
    @ObservedObject var viewModel = IEViewModel()
    @State var backgroundImage = UIImage(named: "6princess")!
    @State var idolImage = UIImage(named: "Felix")!
    var body: some View {
        IETestResizeView(ievm: viewModel, bgImg: $backgroundImage, idolImg: $idolImage)
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
