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
               
                HStack {
                    Text(String(format: "%.0f", viewModel.sliderValues[idx] * 100)) // 텍스트 (밝기 퍼센트)
                        .foregroundColor(.white)
                        .frame(width:30)
                        .padding(.horizontal,5)
                    
                        
                    
                    // 슬라이더
                    Slider(value: $viewModel.sliderValues[idx], in: viewModel.colorEditOptions[idx].range, step: viewModel.colorEditOptions[idx].step)
                        .tint(Color.pointPink)
                        
                        
                }
                .frame(height:40)
                .background(Color.black.opacity(0.5)) // 배경색
            }
            
            // 편집 옵션 버튼들
            HStack {
                Spacer()
                ForEach(0..<viewModel.colorEditOptions.count, id: \.self) { index in
                    ZStack {
                        Circle()
                            .fill(.gray10.opacity(0.15))
                            .frame(width: 60)
                            .shadow(color: Color.gray10, radius: 2, x: 0, y: 0)
                            
                        VStack {
                            Image(systemName: viewModel.colorEditOptions[index].icon) // 아이콘
                                .foregroundColor(viewModel.selectedIndex == index ? .pointPink : .gray01)
                            
                            Text(viewModel.colorEditOptions[index].name) // 텍스트
                                .foregroundColor(viewModel.selectedIndex == index ? .pointPink : .gray01) // 텍스트 색상 설정
                            
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
            .frame(maxHeight:116)
            
        }
        
        .onAppear{
            bgImg = img
        }
        // 상단 툴바
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    // 뒤로가기
                    print("back")
                }) {
                    
                    Image(systemName: "arrow.uturn.left")
                        .foregroundColor(viewModel.imgArray.isEmpty ? .gray01:.gray03)
                        
                }
                .padding(.horizontal)
            }
            
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    print("forward")
                }) {
                    Image(systemName: "arrow.uturn.right")
                        .foregroundColor(viewModel.imgArray.isEmpty ? .gray01:.gray03)
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
        .onChange(of:viewModel.isAppend){
            viewModel.appendImg(content: canvasView)
        }
        
//        .ignoresSafeArea(.all, edges: .all)
    }
    
}

