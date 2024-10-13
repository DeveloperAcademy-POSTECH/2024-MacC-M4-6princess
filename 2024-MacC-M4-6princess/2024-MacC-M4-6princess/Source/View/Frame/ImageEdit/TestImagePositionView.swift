//
//  TestImagePositionView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/14/24.
//

import SwiftUI

struct TestImagePositionView: View {
    @State private var imagePosition: CGPoint = .zero
    @State var bgRect:CGRect = .zero
    @State var viewSize:CGSize = .zero
    var bgImg:UIImage
    var bgRatio:CGFloat
    
    init() {
        let princess = "6princess"
        guard let bgCGImage = UIImage(named: princess)?.cgImage else {
            fatalError("이미지 로드 실패")
        }
        
        self.bgImg = UIImage(cgImage: bgCGImage, scale: 1.0, orientation: .up)
        self.bgRatio = bgImg.size.height / bgImg.size.width

    }
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                Image(uiImage: bgImg)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .position(CGPoint(x: geometry.size.width/2, y: geometry.size.height/2))
                    .onAppear {
                        // 이미지의 중앙 좌표를 계산하여 저장
                        let frame = geometry.frame(in: .global)
                        imagePosition = CGPoint(x: frame.midX, y: frame.midY)
                        viewSize = frame.size
                        let bgHeight = viewSize.width * bgRatio
                        bgRect = CGRect(x: .zero, y: imagePosition.y - bgHeight / 2, width: viewSize.width, height: bgHeight)
                        
                    }
            }
            VStack(alignment:.leading){
                Spacer()
                // 이미지 위치를 텍스트로 표시
                Text("배경사진 위치: (\(bgRect.origin.x), \(bgRect.origin.y))")
                Text("배경사진 크기: (\(bgRect.width), \(bgRect.height))")
                Text("뷰 크기: (\(Int(viewSize.width)), \(Int(viewSize.height)))")
            }
        }
    }
}
