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
    @Binding var idolImg: UIImage?
    var img:UIImage
    @StateObject var viewModel = IEViewModel()
    @State var isPreview = false
    
    var canvasView: some View {
        IECanvasView(viewModel: viewModel, bgImg: $bgImg, idolImg: .constant(idolImg!))
    }
    var tap: some Gesture {
        LongPressGesture(minimumDuration: 0)
            .onChanged{ _ in
                isPreview = true
                print("프리뷰:true")
                
            }
            .onEnded { _ in
                isPreview = false
                print("프리뷰:false")
            }
    }
    
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                VStack{
                    Spacer()
                    // 후보정 레이어 편집 뷰
                    if idolImg != nil {
                        canvasView
                    }
                    Spacer()
                }
                Spacer()
                VStack{
                    Spacer()
                    HStack{
                        Spacer()
                        Group{
                            if isPreview{
                                Image(systemName:"rectangle.checkered")
                                    .frame(width: 30,height: 30)
                                    .foregroundColor(.gray01)
                                    .gesture(tap)
                            }
                            else{
                                Image(systemName:"rectangle.dashed")
                                    .frame(width: 30,height: 30)
                                    .foregroundColor(.gray01)
                                    .gesture(tap)
                                    .onTapGesture {
                                        isPreview = true
                                    }
                            }
                        }
                        .padding(.horizontal)
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
                                    if viewModel.selectedIndex == index{
                                        Image("\(viewModel.colorEditOptions[index].icon).selected") // 아이콘
                                            .foregroundColor(.pointPink)
                                        
                                        Text(viewModel.colorEditOptions[index].name) // 텍스트
                                            .foregroundColor(.pointPink) // 텍스트 색상 설정
                                    }
                                    else{
                                        Image("\(viewModel.colorEditOptions[index].icon).unselected") // 아이콘
                                            .foregroundColor(.gray01)
                                        
                                        Text(viewModel.colorEditOptions[index].name) // 텍스트
                                            .foregroundColor(.gray01) // 텍스트 색상 설정
                                    }
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
            }
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
                    Image(systemName: "arrow.uturn.right")
                        .foregroundColor(viewModel.imgArray.isEmpty ? .gray01:.gray03)
                    
                }
                .padding(.trailing,100)
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
            if viewModel.isAppend {
                viewModel.appendImg(content: canvasView)
            }
        }
        //뷰모델이닛할때 퍼블리쉬변수로 해서 싱크거는 방법
        
        //        .ignoresSafeArea(.all, edges: .all)
    }
    
}
