//
//  IEMainView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/15/24.
//
import SwiftUI
import Photos

// 이미지 편집 메인 화면
struct IEMainView: View {
    // 임의로 넣은 사진 데이터
    @State var bgImg = UIImage(named: "6princess")!
    @State var idolImg = UIImage(named: "Felix")!
    var img:UIImage
    @ObservedObject var viewModel = IEViewModel()
    
    var canvasView: some View {
        IECanvasView(viewModel: viewModel, bgImg: $bgImg, idolImg: $idolImg)
    }
    
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                VStack{
                    Spacer()
                    // 후보정 레이어 편집 뷰
                    canvasView
                    Spacer()
                }
            }
            
            if let idx = viewModel.selectedIndex {
                SliderView(value: $viewModel.sliderValues[idx], range: viewModel.colorEditOptions[idx].range, step: viewModel.colorEditOptions[idx].step)
            }
            
            // 편집 옵션 버튼들
            HStack {
                Spacer()
                ForEach(0..<viewModel.colorEditOptions.count, id: \.self) { index in
                    ZStack {
                        Circle()
                            .fill(.gray01)
                            .frame(width: 60)
                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                        
                        VStack {
                            if index == 1{
                                Image(viewModel.colorEditOptions[index].icon) // 아이콘
                                    .foregroundColor(viewModel.selectedIndex == index ? .pointPink : .white) // 색상 설정
                            }
                            else{
                                Image(systemName: viewModel.colorEditOptions[index].icon) // 아이콘
                                    .foregroundColor(viewModel.selectedIndex == index ? .pointPink : .white) // 색상 설정
                            }
                            Text(viewModel.colorEditOptions[index].name) // 텍스트
                                .foregroundColor(viewModel.selectedIndex == index ? .pointPink : .white) // 텍스트 색상 설정
                        }
                        .onTapGesture {
                            viewModel.selectedIndex = index // 선택된 인덱스 업데이트
                        }
                        .frame(minHeight:116)
                    }
                    .padding(.horizontal)
                    Spacer()
                }
            }
            .padding()
        }
        .padding()
        .onAppear{
            bgImg = img
        }
        // 상단 툴바
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    // 뒤로가기
                }) {
                    Image(systemName: "arrow.uturn.left")
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
            }
            
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    // 앞으로가기
                }) {
                    Image(systemName: "arrow.uturn.right")
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
            }
            
            ToolbarItem(placement: .topBarTrailing) { // 사진 저장(테스트 위치)
                Button(action: {
                    viewModel.saveRenderedView(content: canvasView)
                }) {
                    Text("완료")
                        .foregroundColor(.pointPink)
                }
            }
        }
        // 저장확인용 시트
        .sheet(isPresented: $viewModel.isModal) {
            if let rendered = viewModel.compositeImage {
                IEOutputImageView(image: rendered)
            }
        }
    }
    
}

