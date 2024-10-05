//
//  IERatioChangeView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/3/24.
//

import SwiftUI

struct IERatioChangeView: View {
    @State private var rawImageName: String = "6공주들"
    @State private var rawImage: UIImage? = nil // 원본 UIImage
    @State private var croppedImage: UIImage? = nil // 크롭된 이미지를 저장할 변수
    @State private var currentRatio: CropRatio = .horizantal // 초기값을 4:3으로 지정
    
    var body: some View {
        ZStack {
            /* 크롭 후 사진 보이는 부분 */
            CropImageView(croppedImage: $croppedImage, rawImage: rawImage)
                .onAppear {
                    loadImage() // 뷰가 나타날 때 이미지 로드
                }
            
            /* 크롭 트리거 버튼 부분 */
            VStack {
                HStack {
                    Spacer()
                    // 비율 변경 버튼
                    Button(action: {
                        if let image = rawImage {
                            switch currentRatio {
                                case .horizantal:
                                    croppedImage = cropImage(image: image, aspectRatio: .vertical) // 세로가 긴 4:3 비율로 크롭
                                    currentRatio = .vertical
                                case .vertical:
                                    croppedImage = cropImage(image: image, aspectRatio: .horizantal) // 가로가 긴 4:3 비율로 크롭
                                    currentRatio = .horizantal
                            }
                        }
                    }) {
                        Image(systemName: currentRatio == .horizantal ? "rotate.right" : "rotate.left") // 비율에 따른 아이콘 교차 변경
                            .foregroundColor(.gray)
                    }
                    .padding()
                }
                Spacer()
            }
        }
    }
    
    private func loadImage() {
        // UIImage 이름을 사용하여 이미지 로드
        rawImage = UIImage(named: rawImageName)
        if let image = rawImage {
            croppedImage = cropImage(image: image, aspectRatio: .horizantal) // 4:3 비율로 초기 크롭
        }
    }
    
    private func cropImage(image: UIImage, aspectRatio: CropRatio) -> UIImage? {
        let width = image.size.width
        let height = image.size.height
        let aspectSize = aspectRatio.cropSize
        
        // 비율에 따라 크롭할 크기 계산
        var cropWidth: CGFloat
        var cropHeight: CGFloat
        
        if width / height > aspectSize.width / aspectSize.height {
            // 이미지가 가로로 긴 경우
            cropHeight = height
            cropWidth = height * aspectSize.width / aspectSize.height
        } else {
            // 이미지가 세로로 긴 경우
            cropWidth = width
            cropHeight = width * aspectSize.height / aspectSize.width
        }
        
        let cropX = (width - cropWidth) / 2
        let cropY = (height - cropHeight) / 2
        
        let cropRect = CGRect(x: cropX, y: cropY, width: cropWidth, height: cropHeight)
        
        // 이미지를 크롭
        guard let cgImage = image.cgImage?.cropping(to: cropRect) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
}

#Preview {
    IERatioChangeView()
}
struct CropImageView: View {
    @Binding var croppedImage: UIImage?
    var rawImage: UIImage? // 원본 이미지를 저장하는 변수
    
    // 아이돌 이미지의 위치와 크기를 위한 상태 변수
    @State private var idolImagePosition: CGPoint = CGPoint(x: 30, y: 30) // 아이돌 이미지의 위치
    @State private var idolImageSize: CGSize = CGSize(width: 100, height: 100) // 아이돌 이미지의 크기
    @State private var idolImageName: String = "필릭스디즈니누끼"
    
    // 아이돌 이미지의 위치를 저장하기 위한 상태 변수
    @State private var idolImagePositionX: CGFloat = 30.0
    @State private var idolImagePositionY: CGFloat = 30.0
    
    // 상단과 왼쪽으로부터의 거리 저장을 위한 상태 변수
    @State private var offsetX: CGFloat = 0.0
    @State private var offsetY: CGFloat = 0.0
    
    var body: some View {
        VStack {
            if let cropped = croppedImage, let raw = rawImage {
                VStack {
                    ZStack {
                        GeometryReader { geometry in
                            // 크롭된 이미지를 배경으로 설정
                            Image(uiImage: cropped)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: raw.size.width, maxHeight: raw.size.height) // rawImage의 크기로 프레임 설정
                                .background(GeometryReader { imgGeometry in
                                    Color.clear
                                        .onAppear {
                                            // GeometryReader를 사용해 이미지의 위치를 얻고, 상단과 왼쪽에서 떨어진 거리를 계산
                                            let frame = imgGeometry.frame(in: .local)
                                            offsetX = frame.minX
                                            offsetY = frame.minY
                                        }
                                })
                            
                            // 아이돌 이미지를 크롭된 이미지 위에 올리기
                            Image(idolImageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: idolImageSize.width, height: idolImageSize.height)
                                .position(x: idolImagePosition.x+offsetX, y: idolImagePosition.y+offsetY) // 위치 조정
                                .onChange(of: idolImagePosition) { newValue in
                                    // 아이돌 이미지 위치가 변경될 때 상태 변수에 저장
                                    idolImagePositionX = newValue.x
                                    idolImagePositionY = newValue.y
                                }
                        }
                    }
                }
                .background(Color.red)
                .frame(maxWidth: raw.size.width, maxHeight: raw.size.height)
                
                // 상단과 왼쪽에서 얼마나 떨어져 있는지 텍스트로 표시
                Text("상단으로부터 거리: \(offsetY, specifier: "%.2f")")
                Text("왼쪽으로부터 거리: \(offsetX, specifier: "%.2f")")
                Text("아이돌 이미지 X 위치: \(idolImagePositionX, specifier: "%.2f")")
                Text("아이돌 이미지 Y 위치: \(idolImagePositionY, specifier: "%.2f")")
            } else {
                Text("이미지를 찾을 수 없습니다.")
            }
        }
    }
}

