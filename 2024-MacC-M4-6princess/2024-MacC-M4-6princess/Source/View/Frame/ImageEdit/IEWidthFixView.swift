//
//  IEWidthFixView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/3/24.
//
import SwiftUI

struct IEWidthFixView: View {
    @State private var uiImage: UIImage? = nil // 사진 편집기능을 위해 Image가 아닌 UIImage를 사용
    @State private var croppedImage: UIImage? = nil // 크롭된 이미지를 저장할 변수
    
    var body: some View {
        VStack {
            if let image = croppedImage {
                Image(uiImage: image)
                    .resizable() // 이미지 크기를 조정할 수 있도록 함
                    .scaledToFit() // 이미지 비율을 유지하며 프레임에 맞춤
                    .frame(maxWidth: .infinity) // 가로를 화면에 꽉 채움
                    .overlay(
                        Rectangle()
                            .stroke(Color.red, lineWidth: 2) // 빨간색 테두리 추가
                            .aspectRatio(4/3, contentMode: .fit) // 4:3 비율 프레임
                    )
                    .padding(.bottom, 10) // 프레임과 버튼 간 간격 조정
            } else {
                Text("이미지를 찾을 수 없습니다.") // 이미지가 없을 때 메시지 표시
                    .onAppear {
                        loadImage() // 뷰가 나타날 때 이미지 로드
                    }
            }
            
            HStack {
                // 4:3 비율 크롭 버튼
                Button(action: {
                    if let image = uiImage {
                        croppedImage = cropImage(image: image, aspectRatio: CGSize(width: 4, height: 3))
                    }
                }) {
                    Text("4:3 비율로 크롭")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                // 세로가 긴 16:9 비율 크롭 버튼
                Button(action: {
                    if let image = uiImage {
                        croppedImage = cropImage(image: image, aspectRatio: CGSize(width: 9, height: 16)) // 세로가 긴 16:9 비율
                    }
                }) {
                    Text("세로가 긴 16:9 비율로 크롭")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            
            // 세로가 긴 16:9 비율 프레임
            if let image = croppedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .overlay(
                        Rectangle()
                            .stroke(Color.red, lineWidth: 2) // 빨간색 테두리 추가
                            .aspectRatio(9/16, contentMode: .fit) // 세로가 긴 16:9 비율 프레임
                    )
                    .padding(.bottom, 10)
            }
        }
        .padding()
    }
    
    private func loadImage() {
        // 추후 바인딩 변수로 받아와야하기 때문에 현재는 UIImage를 로드하여 State 변수에 저장
        let princess = "6princess"
        uiImage = UIImage(named: princess)
    }
    
    private func cropImage(image: UIImage, aspectRatio: CGSize) -> UIImage? {
        let width = image.size.width
        let height = image.size.height
        
        let aspectWidth = aspectRatio.width
        let aspectHeight = aspectRatio.height
        
        // 비율에 따라 크롭할 크기 계산
        var cropWidth: CGFloat
        var cropHeight: CGFloat
        
        if width / height > aspectWidth / aspectHeight {
            // 이미지가 가로로 긴 경우
            cropHeight = height
            cropWidth = height * aspectWidth / aspectHeight
        } else {
            // 이미지가 세로로 긴 경우
            cropWidth = width
            cropHeight = width * aspectHeight / aspectWidth
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
    IEWidthFixView()
}
