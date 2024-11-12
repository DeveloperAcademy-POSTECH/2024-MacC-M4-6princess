import SwiftUI

struct DFModifyFrame: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.managedObjectContext) var managedContext
    @ObservedObject var viewModel: DFModifyFrameViewModel = DFModifyFrameViewModel()
    @State private var isFirstLaunching: Bool = true
    @Binding var resultImage: UIImage?
    @State private var shouldNavigate: Bool = false
    @State private var frameImage: UIImage?
    
    var body: some View {
        VStack {
            ZStack {
                Color(hex: "32322f")
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 229)
                
                if isFirstLaunching == true {
                    DFOnboardingView(isFirstLaunching: $isFirstLaunching)
                        .zIndex(1)
                }
                
                //                    if let _ = viewModel.outputImage {
                //                        imageView
                //                            .mask(Rectangle().frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 229))
                //                    }
                imageView
                    .mask(Rectangle().frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 229))
                
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.white)
                    .opacity(viewModel.btnOpacity)
                    .frame(width: 175, height: 38)
                    .overlay(Text("\(viewModel.saveStateText)").foregroundStyle(.black).font(.footnote).opacity(viewModel.btnOpacity))
                
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
        }
        .onAppear {
            makeHistory()
        }
    }
}

private extension DFModifyFrame {
    
    var rotate: some Gesture {
        
        RotateGesture()
            .onChanged { value in
                
                viewModel.angle = value.rotation + viewModel.current
                viewModel.anchor = value.startAnchor
                
            }
            .onEnded { value in
                viewModel.current += value.rotation
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
                
            }
        
    }
    
    var magnification: some Gesture {
        
        MagnifyGesture()
            .onChanged { value in
                viewModel.setScaleVolume(value.magnification)
            }
            .onEnded { value in
                viewModel.setScaleValue(minimum: 0.2, maximum: 10)
            }
    }
    
    var imageView: some View {
        
        ZStack {
            
            if let image = resultImage {
                
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
                    
                    Text("배경 수정")
                        .fontWeight(.regular)
                        .foregroundStyle(.gray01)
                }
            }
            .frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.height / 20)
            
            Spacer(minLength: UIScreen.main.bounds.width / 10)
            
            Spacer()
            Button {
                
                if let image = resultImage {
                    viewModel.saveStateText = "저장중 입니다..."
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
            .padding(.leading, 150)
            .disabled(viewModel.isPushedSaveBtn)
            
        }
    }
}

private extension DFModifyFrame {
    
    func makeHistory() {
        
        if let image = resultImage {
            
            let render = ImageRenderer(content: self.imageView.frame(width: image.size.width / (scaleCompute(image) * 2), height: image.size.height / scaleCompute(image)))
            render.scale = scaleCompute(image)
            viewModel.image = render.uiImage
            viewModel.imageHistory.append(viewModel.image!)
        }
        
    }
    
    func scaleCompute(_ image: UIImage) -> CGFloat {
        
        //        var scale: CGFloat = image.size.height / (UIScreen.main.bounds.height - 229)
        var scale: CGFloat = image.size.height / (UIScreen.main.bounds.height * 0.76)
        
        if image.size.width / scale > UIScreen.main.bounds.width || image.size.width >= image.size.height {
            scale = image.size.width / UIScreen.main.bounds.width
            //            print("\(scale)")
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
    func addImage(data: Data?) {
        
        let newImage = StoreImages(context: managedContext)
        
        newImage.image = data
        newImage.uuid = UUID()
        newImage.isSelected = false
        saveContext()
    }
    
    func makeImage() {
        let render = ImageRenderer(content: self.imageView)
        render.scale = scaleCompute(resultImage!)
        if let rend = render.uiImage {
            if viewModel.indexOfHistory < viewModel.imageHistory.count - 1 {
                for _ in viewModel.indexOfHistory+1..<viewModel.imageHistory.count {
                    viewModel.imageHistory.removeLast()
                }
            }
            viewModel.imageHistory.append(rend)
            viewModel.indexOfHistory += 1
            
        }
        resultImage = viewModel.imageHistory[viewModel.indexOfHistory]
    }
    
    func saveImage(inputImage: UIImage) {
        
        viewModel.btnOpacity = 1

        // 4. 지연 시간을 둬서 작업을 분산
        Task {
            // 저장 완료 메시지 숨기기
            let render = ImageRenderer(content: self.imageView.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 229))
            render.scale = scaleCompute(inputImage)
            viewModel.image = render.uiImage
//            try await Task.sleep(nanoseconds: 1_000_000_000)
            addImage(data: viewModel.image?.pngData())
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
