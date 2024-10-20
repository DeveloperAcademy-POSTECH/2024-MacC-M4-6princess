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
        IECanvasView(viewModel: viewModel)
    }
    var rawImageTab: some Gesture {
        TapGesture()
            .onEnded{
                if viewModel.showRawImage{
                    
                    let one = viewModel.tmpHistory
                    print("firstOne:\(viewModel.firstOne)")
                    print("recentPop:\(viewModel.recentPop)")
                    viewModel.recentPop = one
                    
                    viewModel.frameIdolSize = one.size
                    viewModel.location = one.loc
                    viewModel.rotationAngle = one.ang
                    viewModel.sliderValues = one.sliderValues
                    viewModel.showRawImage = false
                }
                else{
                    viewModel.selectedIndex = nil
                    // 현재 정보를 넣기
                    viewModel.tmpHistory.size = viewModel.frameIdolSize
                    viewModel.tmpHistory.ang = viewModel.rotationAngle
                    viewModel.tmpHistory.loc = viewModel.location
                    viewModel.tmpHistory.sliderValues = viewModel.sliderValues
                    
                    let one = viewModel.firstOne
                    viewModel.frameIdolSize = one.size
                    viewModel.location = one.loc
                    viewModel.rotationAngle = one.ang
                    viewModel.sliderValues = one.sliderValues
                    
                    viewModel.showRawImage = true
                    viewModel.showRawAlert = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        viewModel.showRawAlert = false
                    }
                }
            }
    }
    
    
    
    var body: some View {
        VStack {
            if !viewModel.saveAnimate{
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
                            viewModel.saveRenderedView(content: canvasView)
                            viewModel.saveAnimate = true
                            // 5초 후에 isSave를 true로 변경하여 이미지로 전환
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                viewModel.savePhoto = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    viewModel.saveAnimate = false
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
                    //                    .disabled(viewModel.showRawImage)
                    
                    HStack(alignment: .center, spacing: 14) {
                        Button {
                            if !viewModel.undoHistory.isEmpty{
                                guard let lastHistory = viewModel.undoHistory.popLast() else { return }
                                viewModel.redoHistory.append(viewModel.recentPop)
                                viewModel.location = lastHistory.loc
                                viewModel.frameIdolSize = lastHistory.size
                                viewModel.rotationAngle = lastHistory.ang
                                viewModel.sliderValues = lastHistory.sliderValues
                                viewModel.recentPop = lastHistory
                                print(lastHistory)
                                
                            }
                        } label: {
                            Image(systemName: "arrow.uturn.backward")
                                .foregroundColor(viewModel.undoHistory.isEmpty ? .gray10:.gray01)
                        }
                        
                        Button {
                            if !viewModel.redoHistory.isEmpty{
                                guard let lastHistory = viewModel.redoHistory.popLast() else { return }
                                viewModel.undoHistory.append(viewModel.recentPop)
                                viewModel.location = lastHistory.loc
                                viewModel.frameIdolSize = lastHistory.size
                                viewModel.rotationAngle = lastHistory.ang
                                viewModel.sliderValues = lastHistory.sliderValues
                                viewModel.recentPop = lastHistory
                            }
                        } label: {
                            Image(systemName: "arrow.uturn.forward")
                                .foregroundColor(viewModel.redoHistory.isEmpty ? .gray10:.gray01)
                            
                        }
                    }
                    .disabled(viewModel.showRawImage)
                }
                .background(.white)
                
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
                            Image("rawImage.\(viewModel.showRawImage ? "selected" : "unselected")")
                                .frame(width: 60, height: 30)
                                .gesture(rawImageTab)
                                .padding(.horizontal,15)
                        }
                        
                        if let idx = viewModel.selectedIndex {
                            HStack {
                                
                                CustomSliderView(
                                    value: $viewModel.sliderValues[idx],
                                    range: viewModel.colorEditOptions[idx].range,
                                    step: viewModel.colorEditOptions[idx].step,
                                    viewModel: viewModel,
                                    idx: idx
                                )
                            }
                            .frame(width: viewModel.screenSize.width,height: 40)
                            .background(Color.black.opacity(0.5)) // 배경색
                            
                        }
                    }
                    if viewModel.showRawAlert{
                        Image("rawImageAlert")
                            .frame(width: UIScreen.main.bounds.width/2,height: UIScreen.main.bounds.height/4)
                    }
                    
                } //end
                
                
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
                                                .onTapGesture{
                                                    
                                                    viewModel.selectedIndex = nil // 다시 선택하면 슬라이더 내려감
                                                    
                                                }
                                        } else {
                                            Image("\(viewModel.colorEditOptions[index].icon).unselected")
                                                .foregroundColor(.gray01)
                                        }
                                    }
                                }
                                .onTapGesture {
                                    if viewModel.selectedIndex == index{ // 이미 선택되어 있으면 슬라이더가 내려감
                                        viewModel.selectedIndex = nil
                                    }
                                    else{
                                        viewModel.selectedIndex = index
                                    }
                                }
                                
                                Text(viewModel.colorEditOptions[index].name)
                                    .foregroundColor(viewModel.selectedIndex == index ? .pointPink : .gray01)
                            }
                            .onTapGesture {
                                if viewModel.selectedIndex == index{ // 이미 선택되어 있으면 슬라이더가 내려감
                                    viewModel.selectedIndex = nil
                                }
                                else{
                                    viewModel.selectedIndex = index
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 72)
                    Spacer()
                }
                .disabled(viewModel.showRawImage)
                .padding()
                .background(.white)
                
                
            }
            else{
                IEProgressView(isSave: $viewModel.savePhoto)
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

