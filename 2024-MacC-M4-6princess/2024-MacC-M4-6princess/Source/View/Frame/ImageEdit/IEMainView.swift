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
    var bg:UIImage
    var idol:UIImage
    @StateObject var viewModel = IEViewModel()
    @State var isPreview = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var pinchScale = 1.0 // 전체 보기를 위한 초기 비율을 1.0으로 설정
    @State var pinchValue = 1.0 // 수동 확대/축소를 위한 상태 변수
    @GestureState private var pinchState = 1.0 // 핀치 제스쳐를 위한 State 변수
    @State var isMain = false
    @State var isSave = false
    @State var isAnimate = false
    var pinchGesture: some Gesture {
        MagnifyGesture()
            .updating($pinchState) { value, gestureState, transaction in
                gestureState = value.magnification
            }
            .onEnded { value in
                self.pinchScale *= value.magnification // 확대 제스처가 끝났을 때 스케일을 곱함
            }
    }
    var canvasView: some View {
        IECanvasView(viewModel: viewModel, bgImg: $bgImg, idolImg: $idolImg)
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
            if !isAnimate{
                
                ZStack{
                    // 후보정 레이어 편집 뷰
                    
                        canvasView
                    
                        .scaleEffect(pinchScale * pinchState * pinchValue) // 제스처와 수동 확대/축소를 결합
                        .gesture(pinchGesture)
                        .frame(width: viewModel.frameBGSize.width, height: viewModel.frameBGSize.height)
                        
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
                    }
                    VStack{
                        HStack {
                            Button {
                                // 뒤로가기 버튼
                                self.presentationMode.wrappedValue.dismiss()
                                print("\(UIScreen.main.bounds.width) \(UIScreen.main.bounds.height)")
                            } label: {
                                HStack {
                                    Group{
                                        Image(systemName: "chevron.backward")
                                            .fontWeight(.semibold)
                                        
                                        Text("다시 찍기")
                                            .fontWeight(.regular)
                                    }
                                    .foregroundColor(.gray01)
                                }
                            }
                            .frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.height / 20)
                            
                            Spacer(minLength: UIScreen.main.bounds.width / 20)
                            
                            Button {
                                
                            } label: {
                                Image("back")
                                
                            }
                            .padding(.trailing, 14)
                            
                            Button {
                                
                            } label: {
                                Image("front")
                                
                            }
                            .padding(.trailing, 60)
                            
                            Spacer()
                            Button {
                                //                        pinchScale = 1
                                
                                //                        pinchValue = 1
                                viewModel.saveRenderedView(content: canvasView)
                                isAnimate = true
                                // 5초 후에 isSave를 true로 변경하여 이미지로 전환
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    isSave = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        isAnimate = false
                                        //                                isMain = true
                                        self.presentationMode.wrappedValue.dismiss()
                                        
                                    }
                                }
                            } label: {
                                Text("저장")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.pointPink)
                                    .frame(width: UIScreen.main.bounds.width / 5, height: UIScreen.main.bounds.height / 20)
                            }
                            .padding(1)
                        }
                        Spacer()
                    }
                    .background(.white)
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
                            
                        }
                        Spacer()
                    }
                }
                .padding()
                .background(.white)
                
            }
            else{
                IEProgressView(isSave: $isSave)
            }
        }
        .onAppear{
            bgImg = bg
            idolImg = idol
            
        }
        // 상단 툴바
        .navigationBarBackButtonHidden()
//        .navigationDestination(isPresented: $isMain) {
//            CameraView()
//        }
        
        
        
    }
    
}



