//
//  IEWidthFixView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/1/24.
//
import SwiftUI

// 사진 편집시 초기 프레임 크기를 확인하기 위한 aspect ratio를 위한 enum
enum CropRatio {
    case horizantal
    case vertical
    
    // CGSize를 미리 지정
    var cropSize: CGSize {
        switch self {
            case .horizantal:
                return CGSize(width: 4, height: 3)
            case .vertical:
                return CGSize(width: 3, height: 4)
        }
    }
}

struct IERatioChangeTestView: View {
    @State private var rawImageName: String = "6공주들"
    @State private var rawImage: UIImage? = nil // 원본 UIImage
    @State private var croppedImage: UIImage? = nil // 크롭된 이미지를 저장할 변수
    @State private var currentRatio: CropRatio = .horizantal // 초기값을 4:3으로 지정
    
    var body: some View {
        ZStack {
            /* 크롭 후 사진 보이는 부분 */
            VStack {
                if let cropped = croppedImage {
                    Image(uiImage: cropped)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 10)
                } else {
                    Text("이미지를 찾을 수 없습니다.")
                        .onAppear {
                            loadImage() // 뷰가 나타날 때 이미지 로드
                        }
                }
            }
            .padding()
            
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
    IERatioChangeTestView()
}
