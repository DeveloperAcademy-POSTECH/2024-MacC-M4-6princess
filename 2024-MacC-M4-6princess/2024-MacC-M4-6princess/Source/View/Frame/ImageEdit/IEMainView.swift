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
                //툴바 커스텀
                ZStack{
                    ZStack{
                        // 후보정 레이어 편집 뷰
                        
                        canvasView
                        
                            .scaleEffect(pinchScale * pinchState * pinchValue) // 제스처와 수동 확대/축소를 결합
                            .gesture(pinchGesture)
                            .frame(width: viewModel.frameBGSize.width, height: viewModel.frameBGSize.height)
//                        
//                        VStack{
//                            Spacer()
//
//                        }
                    }
                    VStack{
                        
                        ZStack {
                            
                            HStack {
                                Button {
                                    // 뒤로가기 버튼
                                    self.presentationMode.wrappedValue.dismiss()
                                    print("\(UIScreen.main.bounds.width) \(UIScreen.main.bounds.height)")
                                } label: {
                                    HStack(alignment: .center, spacing: 4) {
                                        Group{
                                            Image(systemName: "chevron.backward")
                                                .fontWeight(.semibold)
                                                .padding(.leading, 10)
                                            Text("다시 찍기")
                                                .font(.system(size: 16))
                                                .foregroundColor(Color(red: 0.38, green: 0.38, blue: 0.38))
                                        }
                                        .foregroundColor(.gray01)
                                    }
                                }.padding(10)
                                
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
                                            self.presentationMode.wrappedValue.dismiss()
                                            
                                        }
                                    }
                                } label: {
                                    Text("저장")
                                        .font(.system(size: 17))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.pointPink)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10.49618)
                                }
                                
                            }
                            HStack(alignment: .center, spacing: 14) {
                                Button {
                                    
                                } label: {
                                    Image("back")
                                    
                                }
                                
                                Button {
                                    
                                } label: {
                                    Image("front")
                                    
                                }
                            }
                            
                        }
                        .background(.white)
                        Spacer()
                    }
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
                        HStack() {
                            Spacer()
                            HStack(spacing: 45) { // 여기에 spacing: 45 추가
                                ForEach(0..<viewModel.colorEditOptions.count, id: \.self) { index in
                                    VStack(alignment: .center, spacing: 8) {
                                        ZStack {
                                            Circle()
                                                .fill(Color(red: 0.85, green: 0.85, blue: 0.85).opacity(0.15))
                                                .frame(width: 40, height: 40) // height 추가
                                                .overlay(
                                                    Circle().stroke(Color.black.opacity(0.15), lineWidth: 0.5)
                                                    //shadow가 자꾸 적용이 안되서 최대한 비슷하게 맞춰놨습니다
                                                )
                                            
                                            
                                            VStack {
                                                if viewModel.selectedIndex == index {
                                                    Image("\(viewModel.colorEditOptions[index].icon).selected")
                                                        .foregroundColor(.pointPink)
                                                } else {
                                                    Image("\(viewModel.colorEditOptions[index].icon).unselected")
                                                        .foregroundColor(.gray01)
                                                }
                                            }
                                        }
                                        .onTapGesture {
                                            viewModel.selectedIndex = index
                                        }
                                        
                                        Text(viewModel.colorEditOptions[index].name)
                                            .foregroundColor(viewModel.selectedIndex == index ? .pointPink : .gray01)
                                    }
                                    .onTapGesture {
                                        viewModel.selectedIndex = index
                                    }
                                }
                            }
                            .padding(.horizontal, 72)
                            Spacer()
                        }
                        .padding()
                        .background(.white)
                    }
                }
                
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
       
    }
    
}


