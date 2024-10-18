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
    var bg:UIImage
    var idol:UIImage
    @StateObject var viewModel = IEViewModel()
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @GestureState private var pinchState = 1.0 // 핀치 제스쳐를 위한 State 변수
    
    
    var pinchGesture: some Gesture {
        MagnifyGesture()
            .updating($pinchState) { value, gestureState, transaction in
                gestureState = value.magnification
            }
            .onEnded { value in
                viewModel.pinchScale *= value.magnification // 확대 제스처가 끝났을 때 스케일을 곱함
            }
    }
    var canvasView: some View {
        IECanvasView(viewModel: viewModel, bgImg: $viewModel.bgImg, idolImg: $viewModel.idolImg)
    }
    var tap: some Gesture {
        LongPressGesture(minimumDuration: 0)
            .onChanged{ _ in
                viewModel.isPreview = true
                print("프리뷰:true")
                
            }
            .onEnded { _ in
                viewModel.isPreview = false
                print("프리뷰:false")
            }
    }
    
    var body: some View {
        VStack {
            if !viewModel.isAnimate{
                
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
                        
                        
                    }
                    .padding(.trailing, 14)
                    
                    Button {
                        
                    } label: {
                        Image("front")
                        
                    }
                    .padding(.trailing, 60)
                    
                    Spacer()
                    Button {
                        viewModel.saveRenderedView(content: canvasView)
                        viewModel.isAnimate = true
                        // 5초 후에 isSave를 true로 변경하여 이미지로 전환
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            viewModel.isSave = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                viewModel.isAnimate = false
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
                ZStack{
                    
                    // 후보정 레이어 편집 뷰
                    canvasView
                    //                        .scaleEffect(pinchScale * pinchState * pinchValue) // 제스처와 수동 확대/축소를 결합
                    //                        .gesture(pinchGesture)
                        .frame(width: viewModel.frameBGSize.width, height: viewModel.frameBGSize.height)
                    
                    VStack{
                        Spacer()
                        HStack{
                            Spacer()
                            Group{
                                if viewModel.isPreview{
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
                                            viewModel.isPreview = true
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
            else{
                IEProgressView(isSave: $viewModel.isSave)
            }
        }
        .onAppear{
            viewModel.bgImg = bg
            viewModel.idolImg = idol
        }
        // 상단 툴바
        .navigationBarBackButtonHidden()
    }
    
}

