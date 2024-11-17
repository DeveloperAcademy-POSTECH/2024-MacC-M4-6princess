import SwiftUI

struct DFModifyFrameView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.managedObjectContext) var managedContext
    @StateObject var viewModel: DFModifyFrameViewModel = DFModifyFrameViewModel()
    @State private var isFirstLaunching: Bool = true
    @Binding var resultImage: UIImage?
    @State private var shouldNavigate: Bool = false
    @State private var frameImage: UIImage?
    
    var body: some View {
        
        ZStack {
            if isFirstLaunching == true {
                DFOnboardingView(isFirstLaunching: $isFirstLaunching)
                    .zIndex(1)
            }
            
            VStack {
                ZStack {
                    Color(hex: "32322f")
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 4/3)
                    
                    imageView
                        .mask(Rectangle().frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 4/3))
                    
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.white)
                        .opacity(viewModel.btnOpacity)
                        .frame(width: 175, height: 38)
                        .overlay(Text("\(viewModel.saveStateText)").foregroundStyle(.black).font(.footnote).opacity(viewModel.btnOpacity))
                    
                }
                DFDecoImageView()
                    .padding(.top, 58)
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            toolBarButtons
        }
        //        .navigationDestination(isPresented: $viewModel.isShowCamera) {
        //            CameraView()
        //        }
        .onChange(of: viewModel.isShowCamera) { newValue in
            if newValue {
                // 1초 후에 화면 전환
                DispatchQueue.main.async() {
                    shouldNavigate = true
                }
            }
        }
        .fullScreenCover(isPresented: $shouldNavigate) {
            CameraView(frameImage: $frameImage)
//            CameraView(frameImage: $resultImage)
        }
        .onAppear {
            
            if let image = resultImage {
                viewModel.detectSubject(inputImage: image)
                //                resultImage = viewModel.outputImage
                makeHistory()
            }
        }
    }
}

private extension DFModifyFrameView {
    
    var rotate: some Gesture {
        
        RotateGesture()
            .onChanged { value in
                viewModel.angle = value.rotation + viewModel.current
            }
            .onEnded { value in
                viewModel.current += value.rotation
                makeHistory()
            }
    }
    var moveImage: some Gesture {
        
        DragGesture()
            .onChanged { value in
                //                viewModel.updateLocation(translation: value.translation, startLocation: value.startLocation)
                viewModel.draggedOffSet.width = viewModel.accumulatedOffSet.width + value.translation.width
                viewModel.draggedOffSet.height = viewModel.accumulatedOffSet.height + value.translation.height
                
            }
            .onEnded { value in
                viewModel.accumulatedOffSet.width = viewModel.accumulatedOffSet.width + value.translation.width
                viewModel.accumulatedOffSet.height = viewModel.accumulatedOffSet.height + value.translation.height
                //                viewModel.accumulatedOffSet.width += (value.translation.width / viewModel.magnifyScale)
                //                viewModel.accumulatedOffSet.height += (value.translation.height / viewModel.magnifyScale)
                print(viewModel.draggedOffSet)
                makeHistory()
                
            }
        
    }
    
    var magnification: some Gesture {
        
        MagnifyGesture()
            .onChanged { value in
                viewModel.setScaleVolume(value.magnification)
            }
            .onEnded { value in
                viewModel.setScaleValue(minimum: 0.2, maximum: 10)
                makeHistory()
            }
    }
}

private extension DFModifyFrameView {
    
    var imageView: some View {
        
        ZStack {
            
            if let image = viewModel.outputImage {
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: image.size.width / scaleCompute(resultImage!), height: image.size.height / scaleCompute(resultImage!))
                //                    .padding(.bottom, 20)
                    .scaleEffect(viewModel.magnifyScale)
                    .rotationEffect(viewModel.angle)
                    .offset(viewModel.draggedOffSet)
                    .gesture(magnification.simultaneously(with: moveImage).simultaneously(with: rotate))
                
            }
        }
    }
    
    var toolBarButtons: some View {
        HStack {
            Button {
                self.presentationMode.wrappedValue.dismiss()
            } label: {
                HStack {
                    Image(systemName: "chevron.backward")
                        .fontWeight(.semibold)
                        .foregroundStyle(.gray01)
                    
                    Text("프레임선택")
                        .fontWeight(.regular)
                        .foregroundStyle(.gray01)
                }
            }
            .frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.height / 20)
            
            Spacer(minLength: UIScreen.main.bounds.width / 20)
            
            Button {
                viewModel.reDo()
                print(viewModel.draggedOffSet)
            } label: {
                Image("back")
                    .colorMultiply(viewModel.indexOfImageList > 0 ? .black : .gray03)
            }
            .padding(.trailing, 14)
            
            Button {
                viewModel.unDo()
                print(viewModel.draggedOffSet)
            } label: {
                Image("front")
                    .colorMultiply(viewModel.indexOfImageList < viewModel.imageList.count - 1 ? .black : .gray03)
            }
            .padding(.trailing, 60)
            
            Spacer()
            Button {
                
                if let image = resultImage {
                    viewModel.saveStateText = "저장 중입니다..."
                    viewModel.isPushedSaveBtn = true
                    saveImage(inputImage: image)
                } else {
                    viewModel.saveStateText = "저장할 이미지가 없습니다."
                    Task {
                        viewModel.btnOpacity = 1
                        try await Task.sleep(for: .seconds(1))
                        viewModel.btnOpacity = 0
                    }
                }
                
            } label: {
                Text("저장")
                    .fontWeight(.semibold)
                    .foregroundStyle(isFirstLaunching ? .gray01 : .pointPink)
                    .frame(width: UIScreen.main.bounds.width / 5, height: UIScreen.main.bounds.height / 20)
            }
            .padding(.leading, 1)
            .disabled(viewModel.isPushedSaveBtn)
            
        }
    }
}

private extension DFModifyFrameView {
    
    func makeHistory() {
        
        var inputImage = subjectImage()
        
        inputImage.image = viewModel.outputImage
        inputImage.angle = viewModel.angle
        inputImage.scale = viewModel.magnifyScale
        inputImage.offSet = viewModel.draggedOffSet

        if viewModel.imageList.count > 0 {
            viewModel.indexOfImageList += 1
        }
        
        viewModel.imageList.append(inputImage)
        
    }
    
    func scaleCompute(_ image: UIImage) -> CGFloat {
        
        //        var scale: CGFloat = image.size.height / (UIScreen.main.bounds.height - 229)
        //        var scale: CGFloat = image.size.height / (UIScreen.main.bounds.height * 0.76)
        var scale: CGFloat = image.size.height / (UIScreen.main.bounds.width * 4/3)
        
        
        if image.size.width / scale > UIScreen.main.bounds.width || image.size.width >= image.size.height {
            scale = image.size.width / UIScreen.main.bounds.width
        }
        return scale
    }
    
    
    func saveContext() {
        do {
            try managedContext.save()
        } catch {
            print("Error saving managed object context: \(error)")
        }
    }
    func addImage(albumImageData: Data?, subjectImageData: Data?) {
        
        let newImage = StoreImages(context: managedContext)
        
        newImage.image = albumImageData
        newImage.subjectImage = subjectImageData
        newImage.uuid = UUID()
        newImage.isSelected = false
        newImage.angle = viewModel.angle.degrees
        newImage.x = viewModel.draggedOffSet.width
        newImage.y = viewModel.draggedOffSet.height
        newImage.scale = viewModel.magnifyScale
        
        saveContext()
    }
    
    func makeImage() {
        
        let render = ImageRenderer(content: self.imageView)
        render.scale = scaleCompute(resultImage!)
        if let rend = render.uiImage {
            if viewModel.indexOfImageList < viewModel.imageList.count - 1 {
                for _ in viewModel.indexOfImageList+1..<viewModel.imageList.count {
                    viewModel.imageList.removeLast()
                }
            }
            viewModel.imageList[viewModel.indexOfImageList].image = rend
            viewModel.indexOfImageList += 1
            
        }
        resultImage = viewModel.imageList[viewModel.indexOfImageList].image
    }
    
    func saveImage(inputImage: UIImage) {
        
        viewModel.btnOpacity = 1
        
        // 4. 지연 시간을 둬서 작업을 분산
        Task {
            // 저장 완료 메시지 숨기기
            let render = ImageRenderer(content: self.imageView.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 229))
            render.scale = scaleCompute(inputImage)
            viewModel.image = render.uiImage
            frameImage = render.uiImage
            //            try await Task.sleep(nanoseconds: 1_000_000_000)
            addImage(albumImageData: viewModel.image?.pngData(), subjectImageData: viewModel.outputImage?.pngData())
            //            try await Task.sleep(nanoseconds: 200_000_000)
            try await Task.sleep(nanoseconds: 1_000_000_000)
            viewModel.btnOpacity = 0
            viewModel.isShowCamera = true
        }
        
    }
    
    
    func checkScreenState(_ image: UIImage?) -> String {
        if image!.size.width > image!.size.height {
            return "horizon"
        } else {
            return "vertical"
        }
    }
}
