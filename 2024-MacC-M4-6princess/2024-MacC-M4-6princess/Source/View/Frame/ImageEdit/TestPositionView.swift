
import SwiftUI
import Photos

struct TestPositionView: View {
    @State private var imageScale: CGFloat = 1.0
    @State private var startScale: CGFloat = 1.0
    @State private var dragOffset: CGSize = .zero
    @State private var startOffset: CGSize = .zero
    @State private var isSelected: Bool = false
    @State private var rotationAngle: Angle = .zero
    @State private var showingSavedAlert: Bool = false
    @State private var saveError: Bool = false
    @State private var bgCornerPositions: [CGPoint] = [CGPoint](repeating: .zero, count: 4)
    @State private var idolCornerPositions: [CGPoint] = [CGPoint](repeating: .zero, count: 4)
    @State private var idolPosition: CGPoint = .zero
    @State private var bgImgRect: CGRect = .zero
    @State private var location: CGPoint = CGPoint(x: 0, y: 324)
    
    var felix = "Felix"
    var princess = "6princess"
    
    var backgroundImg: UIImage
    var idolImg: UIImage
    
    init() {
        guard let backgroundCGImage = UIImage(named: princess)?.cgImage,
              let idolCGImage = UIImage(named: felix)?.cgImage else {
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
                let backgroundAspectRatio = backgroundImg.size.width / backgroundImg.size.height
                let backgroundHeight = min(geometry.size.height, geometry.size.width / backgroundAspectRatio)
                let backgroundWidth = backgroundHeight * backgroundAspectRatio
                let backgroundOffsetX = (geometry.size.width - backgroundWidth) / 2
                let backgroundOffsetY = (geometry.size.height - backgroundHeight) / 2
                
                Image(uiImage: backgroundImg)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .onAppear {
                        bgCornerPositions[0] = CGPoint(x: backgroundOffsetX, y: backgroundOffsetY)
                        bgCornerPositions[1] = CGPoint(x: backgroundOffsetX + backgroundWidth, y: backgroundOffsetY)
                        bgCornerPositions[2] = CGPoint(x: backgroundOffsetX, y: backgroundOffsetY + backgroundHeight)
                        bgCornerPositions[3] = CGPoint(x: backgroundOffsetX + backgroundWidth, y: backgroundOffsetY + backgroundHeight)
                        
                        // backgroundRect 업데이트
                        bgImgRect = CGRect(x: backgroundOffsetX, y: backgroundOffsetY, width: backgroundWidth, height: backgroundHeight)
                    }
                
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        TapGesture()
                            .onEnded {
                                isSelected = false
                            }
                    )
                
                let idolWidth = baseWidth * imageScale
                let idolHeight = (baseWidth / imageAspectRatio) * imageScale
                
                Image(uiImage: idolImg)
                    .resizable()
                    .scaledToFit()
                    .frame(width: idolWidth, height: idolHeight)
                    .rotationEffect(rotationAngle)
                    .position(location)
                    .overlay(
                        Rectangle()
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1)
                            .frame(width: idolWidth , height: idolHeight)
                            .position(location)
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
//                                    withAnimation(.easeInOut(duration: 0.1)) {
//                                        dragOffset = CGSize(
//                                            width: startOffset.width + value.translation.width,
//                                            height: startOffset.height + value.translation.height
//                                        )
//                                    }
                                    self.location = value.location
                                }
                            }
                            .onEnded { _ in
                                startOffset = dragOffset
                            }
                    )
//                    .scaleEffect(imageScale)
//                    .offset(dragOffset)
                    .onChange(of: dragOffset) {
                        updateIdolCornerPositions(idolWidth: idolWidth, idolHeight: idolHeight, geometry: geometry)
                    }
                    .onChange(of: imageScale) {
                        updateIdolCornerPositions(idolWidth: idolWidth, idolHeight: idolHeight, geometry: geometry)
                    }
                    .onChange(of: rotationAngle) {
                        updateIdolCornerPositions(idolWidth: idolWidth, idolHeight: idolHeight, geometry: geometry)
                    }
                
                VStack {
                    Spacer()
                    
                    Text("아이돌 위치: (x: \(idolPosition.x, specifier: "%.2f"), y: \(idolPosition.y, specifier: "%.2f"))")
                        .foregroundColor(.black)
                        .padding()
                    
                    //                    Text("아이돌 크기: (width: \(idolWidth, specifier: "%.2f"), height: \(idolHeight, specifier: "%.2f"))")
                    //                        .foregroundColor(.black)
                    //                        .padding()
                    //
                    Text("Top-left: \(bgCornerPositions[0])")
                    //                    Text("Top-right: \(idolCornerPositions[1])")
                    //                    Text("Bottom-left: \(idolCornerPositions[2])")
                    //                    Text("Bottom-right: \(idolCornerPositions[3])")
                    
                    //                    Text("중심:(\(bgImgRect.origin.x, specifier: "%.2f"),\(bgImgRect.origin.y, specifier: "%.2f")")
                    //                    Text("w:\(bgImgRect.width),h:\(bgImgRect.height)")
                    Button(action: {
                        saveCompositeImage()
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
            .onAppear {
                updateIdolCornerPositions(idolWidth: baseWidth * imageScale, idolHeight: (baseWidth / imageAspectRatio) * imageScale, geometry: geometry)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.white)
            .alert(isPresented: $showingSavedAlert) {
                Alert(title: Text("성공"), message: Text("성공성공"), dismissButton: .default(Text("OK")))
            }
            .alert(isPresented: $saveError) {
                Alert(title: Text("에러"), message: Text("이미지 저장에 실패했습니다."), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func updateIdolCornerPositions(idolWidth: CGFloat, idolHeight: CGFloat, geometry: GeometryProxy) {
        let halfWidth = idolWidth / 2
        let halfHeight = idolHeight / 2
        
        // 회전 적용한 좌표 계산
        let transform = CGAffineTransform(rotationAngle: CGFloat(rotationAngle.radians))
        
        let topLeft = CGPoint(x: -halfWidth, y: -halfHeight).applying(transform)
        let topRight = CGPoint(x: halfWidth, y: -halfHeight).applying(transform)
        let bottomLeft = CGPoint(x: -halfWidth, y: halfHeight).applying(transform)
        let bottomRight = CGPoint(x: halfWidth, y: halfHeight).applying(transform)
        
        // 드래그 오프셋 추가하여 최종 위치 계산
        idolCornerPositions[0] = CGPoint(x: topLeft.x + dragOffset.width + geometry.size.width / 2,
                                         y: topLeft.y + dragOffset.height + geometry.size.height / 2)
        idolCornerPositions[1] = CGPoint(x: topRight.x + dragOffset.width + geometry.size.width / 2,
                                         y: topRight.y + dragOffset.height + geometry.size.height / 2)
        idolCornerPositions[2] = CGPoint(x: bottomLeft.x + dragOffset.width + geometry.size.width / 2,
                                         y: bottomLeft.y + dragOffset.height + geometry.size.height / 2)
        idolCornerPositions[3] = CGPoint(x: bottomRight.x + dragOffset.width + geometry.size.width / 2,
                                         y: bottomRight.y + dragOffset.height + geometry.size.height / 2)
        
        // 아이돌 이미지의 중심 좌표 업데이트
        idolPosition = CGPoint(x: idolCornerPositions[0].x,
                               y: idolCornerPositions[0].y)
//        CGPoint(x: dragOffset.width + geometry.size.width / 2,
//                               y: dragOffset.height + geometry.size.height / 2)
    }
    @MainActor
    func saveCompositeImage() {
        // 원본 크기를 가져옴
        let rawBGWidth = backgroundImg.size.width
        let rawBGHeight = backgroundImg.size.height
        
        // 배경 이미지 비율 계산
        
        let newBackgroundWidth = bgImgRect.width
        let scaleRatio = rawBGWidth / newBackgroundWidth
        //            newBackgroundWidth/rawBackgroundWidth
        print("raw비율:\(rawBGWidth)")
        print("new비율:\(newBackgroundWidth)")
        print("확대비율:\(scaleRatio)")
        
        
        
        // 비트맵 그래픽 컨텍스트 생성
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: rawBGWidth, height: rawBGHeight))
        
        let compositeImage = renderer.image { context in
            
            // 배경 이미지 그리기
            backgroundImg.draw(in: CGRect(x: 0, y: 0, width: rawBGWidth, height: rawBGHeight))
            
            // 아이돌 이미지 크기 계산
            let idolWidth = baseWidth * imageScale
            let idolHeight = (baseWidth / imageAspectRatio) * imageScale
            
            // 아이돌 이미지 그리기 위치 계산
            let idolX = idolPosition.x - bgCornerPositions[0].x
            let idolY = (bgCornerPositions[0].y - idolPosition.y) * (-1)
            
            // 현재 회전을 적용하여 아이돌 이미지를 그립니다.
            context.cgContext.saveGState()
            //이게 왜 있을까?
//            context.cgContext.translateBy(x: (idolX + (idolWidth / 2))*scaleRatio, y: (idolY + (idolHeight / 2))*scaleRatio)
            context.cgContext.rotate(by: CGFloat(rotationAngle.radians))
            let newRect = CGRect(x: idolX*scaleRatio, y: idolY*scaleRatio, width: idolWidth*scaleRatio, height: idolHeight*scaleRatio)
            print("x: \(newRect.origin.x)")
            print("y: \(newRect.origin.y)")
            print("width: \(newRect.size.width)")
            print("height: \(newRect.size.height)")
            idolImg.draw(in: newRect)
            context.cgContext.restoreGState()
        }
        
        // 포토 라이브러리에 이미지 저장
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: compositeImage)
        }) { success, error in
            DispatchQueue.main.async {
                if success {
                    showingSavedAlert = true
                } else {
                    saveError = true
                }
            }
        }
    }
}


