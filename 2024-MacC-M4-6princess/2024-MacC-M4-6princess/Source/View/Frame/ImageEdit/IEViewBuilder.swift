//
//  IEViewBuilder.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/11/24.
//

import SwiftUI

struct IEOutputImageView: View {
    var image: UIImage
    
    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
            
        }
        
    }
}

struct SliderView: View {
    @Binding var value: Float// 슬라이더 값
    var range: ClosedRange<Float> // 슬라이더 범위
    var step: Float // 슬라이더 단계
    
    var body: some View {
        HStack {
            Text(String(format: "%.0f", value * 100)) // 텍스트 (밝기 퍼센트)
                .foregroundColor(.white)
            
            // 슬라이더
            Slider(value: $value, in: range, step: Float.Stride(step))
                .padding()
                .foregroundColor(.pointPink) // 슬라이더 색상
                .background(Color.black.opacity(0.5)) // 배경색
        }
        .frame(height:40)
    }
}

struct CustomSliderView: View {
    @Binding var value: Float
    
    var range: ClosedRange<Float>
    var step: Float
    @StateObject var viewModel: IEViewModel
    var idx:Int
    // range의 중간값 계산
    var midValue: Float {
        (range.lowerBound + range.upperBound) / 2
    }
    
    // 0~100 사이로 변환하는 계산
    var displayValue: Float {
        // 실제 슬라이더 값의 범위를 0~100으로 변환
        let normalizedValue = (value - range.lowerBound) / (range.upperBound - range.lowerBound) * 100
        return normalizedValue
    }
    
    // 변환된 값을 원래 범위로 되돌리는 함수
    func valueFromDisplayValue(_ displayValue: Float) -> Float {
        // 0~100을 다시 원래의 range로 변환
        let normalizedValue = (displayValue / 100) * (range.upperBound - range.lowerBound) + range.lowerBound
        return normalizedValue
    }
    
    var body: some View {
        HStack {
            Text(String(format: "%.0f", displayValue)) // 변환된 텍스트 (밝기 퍼센트)
                .foregroundColor(.white)
                .frame(width: 30)
                .padding(.horizontal, 5)
            
            Slider(value: Binding(
                get: { value },
                set: { newValue in
                    // 슬라이더 값 업데이트 시 변환된 값으로 업데이트
                    let clampedValue = min(max(newValue, range.lowerBound), range.upperBound)
                    value = clampedValue
                }
            ), in: range, step: step, onEditingChanged: { editing in
                // 사용자가 슬라이더 조작을 종료했을 때
                if !editing {
                    
                    viewModel.undoHistory.append(viewModel.recentPop)
                    viewModel.recentPop.sliderValues[idx] = value
                    if !viewModel.redoHistory.isEmpty{
                        viewModel.redoHistory = []
                    }
                }
            }
            )
            .tint(Color.pointPink)
            .padding(.horizontal)
        }
        .frame(width: viewModel.screenSize.width,height: 40)
        .background(Color.black.opacity(0.5)) // 배경색
    }
}

extension CGPoint {
    func printPoint() {
        print("x: \(self.x), y: \(self.y)")
    }
}

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
    // 아이돌 이미지 확대/축소 제스쳐
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
                print("scale: \(currentScale)")
                
            }
            .updating($zoomFactor) { value, scale, transaction in
                scale = value.magnification
                currentScale += value.magnification
            }
            .onEnded { _ in
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
    
    func BottomBar() -> some View {
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
    
    func TopBar() -> some View {
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
                .disabled(viewModel.isRawImage)
                .padding(.horizontal)
                
            }
            Spacer()
        }
        .frame(height: 40)
    }
    
}
