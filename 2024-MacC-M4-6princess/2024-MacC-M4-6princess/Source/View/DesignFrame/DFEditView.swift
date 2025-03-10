import SwiftUI
import Vision
import CoreImage.CIFilterBuiltins
import FirebaseAnalytics

struct DFEditView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var imageModel: ImageListModel
    @ObservedObject var viewModel: DFEditViewModel = DFEditViewModel()
    //    @Binding var pickedImage: UIImage?
    @EnvironmentObject var naviManager: NavigationManager
    @EnvironmentObject var frameManager: FrameManager
    
    var body: some View {
        ZStack {
            Color(.black)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                ZStack {
                    inputImageWithMask
                        .mask(Rectangle().frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.64))
                    
                    if let image = viewModel.resultImage {
                        let scale = viewModel.scaleCompute(image)
                        
                        Image(uiImage: image)
                            .resizable()
                            .opacity(viewModel.showPreview ? 1 : 0)
                            .aspectRatio(contentMode: .fit)
                            .background(Color(hex: "32322f").opacity(viewModel.showPreview ? 1 : 0))
                            .frame(width: image.size.width / scale, height: image.size.height / scale)
                            .padding(.bottom, 20)
                        
                    }
                    VStack {
                        ToastMessageView()
                            .padding(.bottom, UIScreen.main.bounds.height * 0.59)
                            .opacity(viewModel.toastMessageOpacity)
                            .task {
                                viewModel.changeMessageOpacity()
                            }
                    }
                    Circle()
                        .stroke(.white)
                        .opacity(viewModel.isShowThick ? 1 : 0)
                        .frame(width: viewModel.thickness , height: viewModel.thickness )
                    
                    VStack {
                        
                        HStack {
                            Spacer()
                            Button {
                                viewModel.showPreview.toggle()
                                viewModel.createResult { success in
                                    if success {

                                    } else {
                                        viewModel.isRenderFailed = true
                                    }
                                }

                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(viewModel.showPreview ? Color.gray02 : Color.white)
                                        .frame(width: 72, height: 27)
                                    Text("미리보기")
                                        .font(.custom("pretendard-medium", size: 16))
                                        .foregroundStyle(viewModel.showPreview ? Color.gray03 : Color.gray02)
                                }
                            }
                            .padding(.trailing)

                        }
                        
                        thicknessControl
                            .padding(.bottom, -10)
                        ZStack {
                            Rectangle()
                                .fill(Color.background)
                                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.047)
                            
                            HStack {
                                Button {
                                    viewModel.reDo()
                                } label: {
                                    Image("back")
                                        .colorMultiply(viewModel.indexOfMask > 0 ? .white : .gray01)
                                }
                                
                                Button {
                                    viewModel.unDo()
                                } label: {
                                    Image("front")
                                        .colorMultiply(viewModel.indexOfMask < viewModel.maskImageList.count - 1 ? .white : .gray01)
                                }
                            }
                        }
                        
                    }
                    .padding(.top, UIScreen.main.bounds.height * 0.55)
                }
                
                
                if UIScreen.main.bounds.height/UIScreen.main.bounds.width > 2.0 {
                    brushToolSelector
                }
                else{
                    brushToolSelectorIpad
                }
                
                Spacer()
            }
            RemovingLoadingView()
                .opacity(viewModel.removingLoadingOpacity)
                .ignoresSafeArea()
        }
        .alert(isPresented: $viewModel.isRenderFailed) {
            Alert(
                title: Text("오류 발생"),
                message: Text("이미지 렌더링에 실패했습니다. 다시 시도해주세요."),
                dismissButton: .default(Text("확인"))
            )
        }
        .onAppear {
            viewModel.showMaskImage(content: pickedImageRender)
            Analytics.logEvent("A4_누끼따기", parameters: nil)
        }
        .onDisappear{ // ✅
            frameManager.resultImage = viewModel.resultImage
        }
        //        .navigationDestination(isPresented: $viewModel.isShowModifyFrame, destination: {
        //            DFFrameModifyView()
        //        })
        .navigationBarBackButtonHidden()
        .toolbar {
            toolBarButtons
        }
        .simultaneousGesture(moveImage)
        .simultaneousGesture(magnification)
    }
    
}


///

///
private extension DFEditView {
    
    var draw: some Gesture {
        
        DragGesture()
            .onChanged{ dragValue in
                if viewModel.selectionModeIndex == 0 || viewModel.selectionModeIndex == 1 {
                    viewModel.drawLines(startLocation: dragValue.startLocation, location: dragValue.location)
                    print("\(dragValue.startLocation)")
                    
                }
            }
            .onEnded{ dragValue in
                
                if viewModel.selectionModeIndex == 0 || viewModel.selectionModeIndex == 1 {
                    makeHistory()
                }
            }
    }
    
    var moveImage: some Gesture {
        
        DragGesture()
            .onChanged { value in
                if viewModel.selectionModeIndex == 3 && viewModel.magnifyScale > 1.0 {
                    
                    viewModel.draggedOffSet.width = viewModel.accumulatedOffSet.width + value.translation.width
                    viewModel.draggedOffSet.height = viewModel.accumulatedOffSet.height + value.translation.height
                    
                }
            }
            .onEnded { value in
                
                if viewModel.selectionModeIndex == 3 && viewModel.magnifyScale > 1.0 {
                    
                    viewModel.accumulatedOffSet.width += value.translation.width
                    viewModel.accumulatedOffSet.height += value.translation.height
                    
                }
            }
    }
    
    var magnification: some Gesture {
        
        MagnifyGesture()
            .onChanged { value in
                viewModel.setScaleVolume(value.magnification)
            }
            .onEnded { value in
                
                viewModel.setScaleValue(minimum: 1.0, maximum: 4.0)
            }
    }
    
    
    
    var inputImageWithMask: some View {
        
        ZStack {
            
            if let image = viewModel.inputImage {
                
                let scale = viewModel.scaleCompute(image)
                
                Image(uiImage: image)
                    .resizable()
                    .opacity(viewModel.showPreview ? 0 : 1)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: image.size.width / scale, height: image.size.height / scale)
                    .padding(.bottom, 20)
                    .scaleEffect(viewModel.magnifyScale)
                    .offset(viewModel.draggedOffSet)
                
                
                canvas
                    .offset(y: -10)
                    .opacity(viewModel.showPreview ? 0 : 1)
                    .frame(width: image.size.width / scale, height: image.size.height / scale)
                    .scaleEffect(viewModel.magnifyScale)
                    .offset(viewModel.draggedOffSet)
            }
            
        }
    }
    
    var thicknessControl: some View {
        
        ZStack {
            Rectangle()
                .fill(Color.black.opacity(0.5))
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.05)
            Slider(
                value: $viewModel.thickness ,
                in: 0...50,
                step: 1
            ) {
                Text("Title")
            } minimumValueLabel: {
                Text("\(Int(viewModel.thickness ))")
                    .foregroundStyle(.white)
            } maximumValueLabel: {
                Text("")
            } onEditingChanged: { editing in
                viewModel.isShowThick = editing
            }
            .accentColor(.pointPink)
            .frame(width: UIScreen.main.bounds.width / 1.2, height: 22)
//            .padding([.leading, .trailing, .top, .bottom], 10)
        }
        .onAppear() {
            print(UIScreen.main.bounds.width)
            print(UIScreen.main.bounds.height)
            thumbImageCustom()
        }
    }
    
    var canvas: some View {
        
        Canvas { context, size in
            
            if let image = viewModel.maskImage {
                context.draw(Image(uiImage: image).resizable(), in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            }
            
            viewModel.updateLine(context: &context)
        }
        .onChange(of: viewModel.maskImage) {
            viewModel.deleteAllLines()
        }
        .colorMultiply(viewModel.maskColor)
        .opacity(viewModel.opacity)
        .gesture(draw)
    }
    
    var pickedImageRender: some View {
        VStack {
            if let image = frameManager.pickedImage {
                Image(uiImage: image)
            }
        }
    }
    var toolBarButtons: some View {
        HStack(spacing: 50) {
            Button {
                self.presentationMode.wrappedValue.dismiss()
            } label: {
                HStack {
                    Image(systemName: "chevron.backward")
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                    
                }
            }
            .padding(.leading, UIScreen.main.bounds.width * 0.2)
            .padding(.trailing, UIScreen.main.bounds.width * 0.07)
            .frame(width: UIScreen.main.bounds.width * 0.1, height: UIScreen.main.bounds.height * 0.05)
            
            Text("배경 제거")
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(width: UIScreen.main.bounds.width * 0.2, height: UIScreen.main.bounds.height * 0.04)
                .padding(.leading, UIScreen.main.bounds.width * 0.2)
            
            Button {
                viewModel.removingLoadingOpacity = 1
                guard !viewModel.clickedButton else { return } // 이미 클릭되었는지 확인
                viewModel.clickedButton = true
                viewModel.createResult { success in
                    if success {
                        viewModel.detectSubject(inputImage: viewModel.resultImage) { success in
                            if success, let image = viewModel.outputImage {
                                if let model = frameManager.changedSubject {
                                    model.image = image
                                    frameManager.changedSubject = nil
                                } else {
                                    imageModel.imageList.forEach {
                                        $0.isTapped = false
                                    }
                                    let newImage = SubjectImage()
                                    newImage.image = image
                                    newImage.originalImage = frameManager.pickedImage
                                    imageModel.imageList.append(newImage)
                                }
                                naviManager.push(screen: Screen.modifyFrame)
                                viewModel.isRenderFailed = false
                                viewModel.removingLoadingOpacity = 0
                            } else {
                                print("Failed in detectSubject")
                                viewModel.isRenderFailed = true
                                viewModel.removingLoadingOpacity = 0
                            }
                            
                            
                            naviManager.push(screen: Screen.modifyFrame)
                        }
                    } else {
                        print("Failed in createResult")
                        viewModel.isRenderFailed = true
                    }
                    viewModel.clickedButton = false
                }
            } label: {
                Text("확인")
                    .fontWeight(.semibold)
                    .foregroundStyle(.pointPink)
                    .padding(.leading, UIScreen.main.bounds.width * 0.04)
                    .padding(.trailing, UIScreen.main.bounds.width * 0.01 )
                    .frame(width: UIScreen.main.bounds.width / 5, height: UIScreen.main.bounds.height / 20)
            }
            .padding(.trailing, UIScreen.main.bounds.width * 0.051)
            .disabled(viewModel.clickedButton) // 버튼이 클릭된 동안 비활성화
            
            
            
            
        }
    }
    
    var brushToolSelector: some View {
        
        HStack(spacing: UIScreen.main.bounds.width / 2.4) {
            Button {
                viewModel.toolSelect("brush")
            } label: {
                ZStack {
                    Circle()
                        .fill(Color(hex: "212121"))
                        .frame(width: UIScreen.main.bounds.height / 20, height: UIScreen.main.bounds.height / 20)
                    Image("brush")
                        .frame(width: UIScreen.main.bounds.height / 20, height: UIScreen.main.bounds.height / 20)
                        .colorMultiply(viewModel.selectionModeIndex == 0 ? Color(.pointPink) : Color(.white))
                    Text("선택 추가")
                        .foregroundStyle(viewModel.selectionModeIndex == 0 ? Color(.pointPink) : Color(.white))
                        .font(.custom("Pretendard-medium", size: 13))
                        .offset(y: 30)
                }
            }
            
            Button {
                viewModel.toolSelect("erase")
                
            } label: {
                ZStack {
                    Circle()
                        .fill(Color(hex: "212121"))
                        .frame(width: UIScreen.main.bounds.height / 20, height: UIScreen.main.bounds.height / 20)
                    Image("erase")
                        .frame(width: UIScreen.main.bounds.height / 20, height: UIScreen.main.bounds.height / 20)
                        .colorMultiply(viewModel.selectionModeIndex == 1 ? Color(.pointPink) : Color(.white))
                    Text("선택 제거")
                        .foregroundStyle(viewModel.selectionModeIndex == 1 ? Color(.pointPink) : Color(.white))
                        .font(.custom("Pretendard-medium", size: 13))
                        .offset(y: 30)
                }
            }
        }
        .padding(.top, 20)
        
    }
    var brushToolSelectorIpad: some View {
        
        HStack(spacing: UIScreen.main.bounds.width / 2.4) {
            Button {
                viewModel.toolSelect("brush")
            } label: {
                ZStack {
                    Circle()
                        .fill(Color(hex: "212121"))
                        .frame(width: UIScreen.main.bounds.height / 20, height: UIScreen.main.bounds.height / 20)
                    Image("brush")
                        .frame(width: UIScreen.main.bounds.height / 20, height: UIScreen.main.bounds.height / 20)
                        .colorMultiply(viewModel.selectionModeIndex == 0 ? Color(.pointPink) : Color(.white))
                    Text("선택 추가")
                        .foregroundStyle(viewModel.selectionModeIndex == 0 ? Color(.pointPink) : Color(.white))
                        .font(.custom("Pretendard-medium", size: 13))
                        .offset(y: 30)
                }
            }
            
            Button {
                viewModel.toolSelect("erase")
                
            } label: {
                ZStack {
                    Circle()
                        .fill(Color(hex: "212121"))
                        .frame(width: UIScreen.main.bounds.height / 20, height: UIScreen.main.bounds.height / 20)
                    Image("erase")
                        .frame(width: UIScreen.main.bounds.height / 20, height: UIScreen.main.bounds.height / 20)
                        .colorMultiply(viewModel.selectionModeIndex == 1 ? Color(.pointPink) : Color(.white))
                    Text("선택 제거")
                        .foregroundStyle(viewModel.selectionModeIndex == 1 ? Color(.pointPink) : Color(.white))
                        .font(.custom("Pretendard-medium", size: 13))
                        .offset(y: 30)
                }
            }
        }
        .padding(.bottom,30)
    }
    
}

private extension DFEditView {
    
    
    private func makeHistory() {
        
        if viewModel.maskImageList.count == 0 {
            viewModel.maskImageList.append(viewModel.maskImage)
        }
        
        viewModel.opacity = 1
        viewModel.maskColor = .white
        let render = ImageRenderer(content: self.canvas.frame(width: viewModel.getWidth() / viewModel.scaleCompute(viewModel.inputImage!), height: viewModel.getHeight() / viewModel.scaleCompute(viewModel.inputImage!)))
        render.scale = viewModel.scaleCompute(viewModel.inputImage!)
        
        viewModel.appendMaskImage(render.uiImage)
    }
        
    private func thumbImageCustom() {
        let render = ImageRenderer(content: Circle().frame(width: 16, height: 16).foregroundStyle(.white))
        render.scale = UIScreen.main.scale
        let thumbImage = render.uiImage
        UISlider.appearance().setThumbImage(thumbImage, for: .normal)
    }
}
//#Preview {
//    DFEditView()
//}
