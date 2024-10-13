//
//  TestImagePositionView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/14/24.
//

import SwiftUI

struct TestImagePositionView: View {
    @State private var bgMidPosition: CGPoint = .zero
    @State var bgRect:CGRect = .zero
    @State var viewSize:CGSize = .zero
    var bgImg:UIImage
    var bgRatio:CGFloat
    
    // 아이돌 이미지
    @StateObject var viewModel = TestDragViewModel()
    @GestureState var startLocation: CGPoint? = nil
    
    var simpleDrag: some Gesture {
        DragGesture()
            .onChanged { value in
                viewModel.updateLocation(with: value.translation, startLocation: startLocation)
            }
            .updating($startLocation) { (value, startLocation, transaction) in
                startLocation = startLocation ?? viewModel.location
            }
    }
    
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
                    .frame(width: geometry.size.width,height: geometry.size.width*bgRatio)
                    .onAppear {
                        // 이미지의 중앙 좌표를 계산하여 저장
                        let frame = geometry.frame(in: .global)
                        bgMidPosition = CGPoint(x: frame.midX, y: frame.midY)
                        // 전체 뷰 크기를 저장
                        viewSize = frame.size
                        
                        // 배경높이 크기
                        let bgHeight = viewSize.width * bgRatio
                        bgRect = CGRect(x: .zero, y: bgMidPosition.y - bgHeight / 2, width: viewSize.width, height: bgHeight)
                        viewModel.location = bgMidPosition
                        
                        
                    }
            }
            
            Image(uiImage: viewModel.idolImg)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: viewModel.idolWidth, height: viewModel.idolWidth * viewModel.idolRatio)
                .position(viewModel.location)
                .gesture(simpleDrag)
               
            VStack(alignment:.leading){
                Spacer()
                // 이미지 위치를 텍스트로 표시
                Text("배경사진 위치: (\(bgRect.origin.x), \(bgRect.origin.y))")
                Text("배경사진 크기: (\(bgRect.width), \(bgRect.height))")
                Text("뷰 크기: (\(Int(viewSize.width)), \(Int(viewSize.height)))")
                Text("아이돌 좌표: (\(Int(viewModel.location.x)), \(Int(viewModel.location.y)))")
            }
        }
    }
}
