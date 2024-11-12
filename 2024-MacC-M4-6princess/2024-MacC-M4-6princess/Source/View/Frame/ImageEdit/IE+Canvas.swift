//
//  IE+Canvas.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/6/24.
//

import SwiftUI

extension IECanvasView{
    // TODO: Angle 변화 속도를 늦추기
    var rotationGesture: some Gesture{
        RotationGesture()
            .onChanged { angle in
                viewModel.rotationAngle = angle
            }
            .onEnded{ value in
                viewModel.undoHistory.append(viewModel.recentPop)
                viewModel.recentPop.ang = value
                if !viewModel.redoHistory.isEmpty{
                    viewModel.redoHistory = []
                }
            }
    }
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                // 이게 안되는 이유: 드래그 끝나고 위치가 업데이트 됨
                //                viewModel.location=value.location
                viewModel.updateLocation(with: value.translation, startLocation: startLocation)
            }
            .updating($startLocation) { (value, startLocation, transaction) in
                startLocation = startLocation ?? viewModel.location
            }
            .onEnded{ _ in
                if viewModel.isRawImage{
                    
                    let one = viewModel.temp
                    viewModel.recentPop = one
                    
                    viewModel.frameIdolSize = one.size
                    viewModel.location = one.loc
                    viewModel.rotationAngle = one.ang
                    viewModel.sliderValues = one.sliderValues
                    viewModel.isRawImage = false
                }
                else{
                    viewModel.undoHistory.append(viewModel.recentPop)
                    viewModel.recentPop.loc = viewModel.location
                    if !viewModel.redoHistory.isEmpty{
                        viewModel.redoHistory = []
                    }
                }
            }
    }
    // 아이돌 이미지 확대/축소 제스쳐가 끝나면 Undo 리스트에 이전 정보를 추가
    fileprivate func endedMagnify() {
        if viewModel.isRawImage{
            let one = viewModel.temp
            viewModel.recentPop = one
            
            viewModel.frameIdolSize = one.size
            viewModel.location = one.loc
            viewModel.rotationAngle = one.ang
            viewModel.sliderValues = one.sliderValues
            viewModel.isRawImage = false
        }
        else{
            viewModel.undoHistory.append(viewModel.recentPop)
            viewModel.recentPop.size = viewModel.frameIdolSize
            
            if !viewModel.redoHistory.isEmpty{
                viewModel.redoHistory = []
            }
        }
    }
    
    
    
    var magnifyGesture: some Gesture {
        MagnifyGesture()
            .onChanged{ value in
                currentScale = value.magnification
                
            }
            .onEnded { _ in
                viewModel.frameIdolSize.width *= currentScale
                viewModel.frameIdolSize.height *= currentScale
                currentScale = 1
                
                endedMagnify()
            }
    }
    
    var rawImageUnrock: some Gesture {
        TapGesture()
            .onEnded{
                if viewModel.isRawImage{
                    
                    let one = viewModel.temp
                    viewModel.recentPop = one
                    
                    viewModel.frameIdolSize = one.size
                    viewModel.location = one.loc
                    viewModel.rotationAngle = one.ang
                    viewModel.sliderValues = one.sliderValues
                    viewModel.isRawImage = false
                }
                
            }
    }
}

extension IEMainView{
    var pinchGesture: some Gesture {
        MagnifyGesture()
            .updating($pinchState) { value, gestureState, transaction in
                gestureState = value.magnification
            }
            .onEnded { value in
                viewModel.pinchScale *= value.magnification // 확대 제스처가 끝났을 때 스케일을 곱함
            }
    }
    var rawImageTab: some Gesture {
        TapGesture()
            .onEnded{
                if viewModel.isRawImage{ // 원본보기 상태일 때
                    
                    let one = viewModel.temp // 이전 데이터 꺼내오기
                    viewModel.recentPop = one
                    
                    viewModel.frameIdolSize = one.size
                    viewModel.location = one.loc
                    viewModel.rotationAngle = one.ang
                    viewModel.sliderValues = one.sliderValues
                    viewModel.isRawImage.toggle()
                }
                else{
                    viewModel.selectedIndex = nil
                    // 현재 정보를 임시로 넣어놓기
                    viewModel.temp.size = viewModel.frameIdolSize
                    viewModel.temp.loc = viewModel.location
                    viewModel.temp.ang = viewModel.rotationAngle
                    viewModel.temp.sliderValues = viewModel.sliderValues
                    
                    let one = viewModel.firstOne
                    viewModel.frameIdolSize = one.size
                    viewModel.location = one.loc
                    viewModel.rotationAngle = one.ang
                    viewModel.sliderValues = one.sliderValues
                    
                    viewModel.isRawImage.toggle()
                    viewModel.showRawAlert = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        viewModel.showRawAlert = false
                    }
                }
            }
    }
    var rawImageUnrock: some Gesture {
        TapGesture()
            .onEnded{
                if viewModel.isRawImage{
                    
                    let one = viewModel.temp
                    viewModel.recentPop = one
                    
                    viewModel.frameIdolSize = one.size
                    viewModel.location = one.loc
                    viewModel.rotationAngle = one.ang
                    viewModel.sliderValues = one.sliderValues
                    viewModel.isRawImage = false
                }
                
            }
    }
}


extension IEMainView{
    var canvasView: some View {
        IECanvasView(viewModel: viewModel)
    }
    
    func RawImageButton() -> HStack<TupleView<(Spacer, some View)>> {
        return HStack{
            Spacer()
            Image("rawImage.\(viewModel.isRawImage ? "selected" : "unselected")")
                .frame(width: 60, height: 30)
                .gesture(rawImageTab)
                .padding(.horizontal,15)
        }
    }
    
    func ColorSlider(_ idx: Int) -> HStack<CustomSliderView> {
        return HStack {
            CustomSliderView(
                value: $viewModel.sliderValues[idx],
                range: viewModel.colorEditOptions[idx].range,
                step: viewModel.colorEditOptions[idx].step,
                viewModel: viewModel,
                idx: idx
            )
        }
    }
    
    func bottomBarIphone() -> some View {
        return HStack() {
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
                                if viewModel.isRawImage{
                                    
                                    let one = viewModel.temp
                                    viewModel.recentPop = one
                                    viewModel.frameIdolSize = one.size
                                    viewModel.location = one.loc
                                    viewModel.rotationAngle = one.ang
                                    viewModel.sliderValues = one.sliderValues
                                    viewModel.isRawImage = false
                                }
                                viewModel.selectedIndex = index
                            }
                        }
                        
                        Text(viewModel.colorEditOptions[index].name)
                            .foregroundColor(viewModel.selectedIndex == index ? .pointPink : .gray01)
                    }
                    .padding(.top,30)
                }
            }
            .padding(.horizontal, 72)
            Spacer()
        }
        .padding(.horizontal,20)
        .frame(height: 80)
    }
    func bottomBarIpad() -> some View {
        return HStack() {
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
                                if viewModel.isRawImage{
                                    
                                    let one = viewModel.temp
                                    viewModel.recentPop = one
                                    viewModel.frameIdolSize = one.size
                                    viewModel.location = one.loc
                                    viewModel.rotationAngle = one.ang
                                    viewModel.sliderValues = one.sliderValues
                                    viewModel.isRawImage = false
                                }
                                viewModel.selectedIndex = index
                            }
                        }
                        
                        Text(viewModel.colorEditOptions[index].name)
                            .foregroundColor(viewModel.selectedIndex == index ? .pointPink : .gray01)
                    }
                    .padding(.top,30)
                }
            }
            .padding(.horizontal, 72)
            Spacer()
        }
        .padding(.horizontal,20)
        .padding(.bottom,30)
        .frame(height: 80)
    }
    
    func topBar() -> some View {
        return VStack{
            HStack {
                Spacer()
                    .frame(width: 20)
                Button {
                    // 뒤로가기 버튼
                    self.presentationMode.wrappedValue.dismiss()
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
                }
                
                Spacer()
                
                Button {
                    if !viewModel.undoHistory.isEmpty{
                        guard let lastHistory = viewModel.undoHistory.popLast() else { return }
                        viewModel.redoHistory.append(viewModel.recentPop)
                        viewModel.location = lastHistory.loc
                        viewModel.frameIdolSize = lastHistory.size
                        viewModel.rotationAngle = lastHistory.ang
                        viewModel.sliderValues = lastHistory.sliderValues
                        viewModel.recentPop = lastHistory
                    }
                } label: {
                    Image(systemName: "arrow.uturn.backward")
                        .foregroundColor(viewModel.undoHistory.isEmpty ? .gray10:.gray01)
                }
                Spacer()
                    .frame(width: 20)
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
                Spacer()
                Button {
                    viewModel.saveRenderedView(content: canvasView)
                    viewModel.saveAnimate = true
                    // 5초 후에 isSave를 true로 변경하여 이미지로 전환
                    if viewModel.isRawImage{
                        
                        let one = viewModel.temp
                        viewModel.recentPop = one
                        
                        viewModel.frameIdolSize = one.size
                        viewModel.location = one.loc
                        viewModel.rotationAngle = one.ang
                        viewModel.sliderValues = one.sliderValues
                        viewModel.isRawImage = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        viewModel.savePhoto = true
                        //                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        //                            viewModel.saveAnimate = false
                        //                            self.presentationMode.wrappedValue.dismiss()
                        //                        }
                        
                    }
                } label: {
                    Text("저장")
                        .font(.system(size: 17))
                        .fontWeight(.semibold)
                        .foregroundColor(.pointPink)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10.49618)
                }
//                .disabled(viewModel.isRawImage)
                .padding(.horizontal)
                
            }
            Spacer()
        }
        .frame(height: 40)
    }
    
}

extension UIImage {
    func cropToAspectRatio(_ targetAspectRatio: CGFloat) -> UIImage? {
//        let originalWidth = size.width
//        let originalHeight = size.height
//        
        var cropRect: CGRect
        
        
        
//        let newWidth = originalHeight * targetAspectRatio
        
        cropRect = CGRect(x: 0, y: 0, width: size.width, height: size.width * targetAspectRatio)
        // 크롭 영역을 설정하여 CGImage로 변환
        guard let cgImage = self.cgImage?.cropping(to: cropRect) else { return nil }
        
        // 크롭된 CGImage를 UIImage로 변환
        return UIImage(cgImage: cgImage)
    }
}
