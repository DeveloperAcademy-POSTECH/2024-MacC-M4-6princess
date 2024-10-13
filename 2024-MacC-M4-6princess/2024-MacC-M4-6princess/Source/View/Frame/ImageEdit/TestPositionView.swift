
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
                    
                    Text("아이돌 크기: (width: \(idolWidth, specifier: "%.2f"), height: \(idolHeight, specifier: "%.2f"))")
                        .foregroundColor(.black)
                        .padding()
                    
                    Text("Top-left: \(idolCornerPositions[0])")
                    Text("Top-right: \(idolCornerPositions[1])")
                    Text("Bottom-left: \(idolCornerPositions[2])")
                    Text("Bottom-right: \(idolCornerPositions[3])")
                    
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
        idolPosition = CGPoint(x: dragOffset.width + geometry.size.width / 2,
                               y: dragOffset.height + geometry.size.height / 2)
    }
    func saveCompositeImage() {
        // 배경 이미지 비율 계산
        let backgroundAspectRatio = backgroundImg.size.width / backgroundImg.size.height
        let backgroundWidth = backgroundImg.size.width
        let backgroundHeight = backgroundWidth / backgroundAspectRatio
        
        // 비트맵 그래픽 컨텍스트 생성
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: backgroundWidth, height: backgroundHeight))
        
        let compositeImage = renderer.image { context in
            // 배경 이미지 그리기
            backgroundImg.draw(in: CGRect(x: 0, y: 0, width: backgroundWidth, height: backgroundHeight))
            
            // 아이돌 이미지 크기 계산
            let idolWidth = baseWidth * imageScale
            let idolHeight = (baseWidth / imageAspectRatio) * imageScale
            
            // 아이돌 이미지 그리기 위치 계산
            let idolX = dragOffset.width + (backgroundWidth / 2) - (idolWidth / 2)
            let idolY = dragOffset.height + (backgroundHeight / 2) - (idolHeight / 2)

            // 현재 회전을 적용하여 아이돌 이미지를 그립니다.
            context.cgContext.saveGState()
            context.cgContext.translateBy(x: idolX + (idolWidth / 2), y: idolY + (idolHeight / 2))
            context.cgContext.rotate(by: CGFloat(rotationAngle.radians))
            idolImg.draw(in: CGRect(x: -idolWidth / 2, y: -idolHeight / 2, width: idolWidth, height: idolHeight))
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
