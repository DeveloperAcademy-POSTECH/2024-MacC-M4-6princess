import SwiftUI


struct imageHistory {
    
}
struct DFModifyFrame: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.managedObjectContext) var managedContext
    @ObservedObject var viewModel: DFModifyFrameViewModel = DFModifyFrameViewModel()
    @State private var isFirstLaunching: Bool = true
    @Binding var resultImage: UIImage?
    
    var body: some View {

            VStack {
                ZStack {
                    if isFirstLaunching == true {
                        DFOnboardingView(isFirstLaunching: $isFirstLaunching)
                            .zIndex(1)
                    }
                    
                    if let image = resultImage {
                        Color(hex: "32322f")
                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 229)
                        imageView
                            .mask(Rectangle().frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 229))

                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color.white)
                            .opacity(viewModel.btnOpacity)
                            .frame(width: 175, height: 38)
                            .overlay(Text("프레임이 저장되었습니다.").foregroundStyle(.black).font(.footnote).opacity(viewModel.btnOpacity))
                        
                    }
                }
            
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            toolBarButtons
        }
        .navigationDestination(isPresented: $viewModel.isShowCamera) {
            CameraView()
        }
        .onAppear {
            makeHistory()
        }
    }
}

private extension CGSize {
    static func + (lhs: Self, rhs: Self) -> Self {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
}

private extension DFModifyFrame {
    var imageView: some View {
        Image(uiImage: resultImage ?? UIImage())
            .resizable()
            .scaledToFit()
            .frame(width: resultImage!.size.width / scaleCompute(resultImage!), height: resultImage!.size.height / scaleCompute(resultImage!))
            .padding(.bottom, 20)
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
                
                saveImage()
                
            } label: {
                Text("저장")
                    .fontWeight(.semibold)
                    .foregroundStyle(.pointPink)
                    .frame(width: UIScreen.main.bounds.width / 5, height: UIScreen.main.bounds.height / 20)
            }
            .padding(.leading, 150)
            
        }
    }
}

private extension DFModifyFrame {
    
    func makeHistory() {
        
        let render = ImageRenderer(content: self.imageView.frame(width: resultImage!.size.width / (scaleCompute(resultImage!) * 2), height: resultImage!.size.height / scaleCompute(resultImage!)))
        render.scale = scaleCompute(resultImage!)
        viewModel.image = render.uiImage
        viewModel.imageHistory.append(viewModel.image!)
        
    }
    
    func scaleCompute(_ image: UIImage) -> CGFloat {
        var scale: CGFloat = image.size.height / (UIScreen.main.bounds.height - 229)
        
        if image.size.width / scale > UIScreen.main.bounds.width || image.size.width >= image.size.height {
            scale = image.size.width / UIScreen.main.bounds.width
            print("\(scale)")
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
    
    func saveImage() {
        
        let render = ImageRenderer(content: self.imageView.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 229))
        render.scale = scaleCompute(resultImage!)
        viewModel.image = render.uiImage
        addImage(data: viewModel.image?.pngData())
        viewModel.btnOpacity = 1
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            viewModel.btnOpacity = 0
        }
        viewModel.isShowCamera = true
        
    }
    func checkScreenState(_ image: UIImage?) -> String {
        if image!.size.width > image!.size.height {
            return "horizon"
        } else {
            return "vertical"
        }
    }
}
