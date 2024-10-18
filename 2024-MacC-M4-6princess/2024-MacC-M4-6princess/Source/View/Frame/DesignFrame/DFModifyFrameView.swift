import SwiftUI


struct imageHistory {
    
}
struct DFModifyFrame: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.managedObjectContext) var managedContext
    @Binding var resultImage: UIImage?
    @State private var draggedOffset = CGSize.zero
    @State private var accumulatedOffset = CGSize.zero
    @State private var image: UIImage?
    @State private var isShow: Bool = false
    @State private var currentSize = 0.0
    @State private var finalSize = 1.0
    @State private var currentAngle = Angle.zero
    @State private var finalAngle = Angle.zero
    @State private var isZoom: Bool = true
    @State private var btnOpacity: Double = 0.0
    @State private var imageHistory: [UIImage?] = []
    @State private var index: Int = 0

    var rotate: some Gesture {
        RotateGesture()
            .onChanged { value in
                currentAngle = value.rotation
            }
            .onEnded { value in
                withAnimation {
                    finalAngle += currentAngle
                    currentAngle = .zero
                    isZoom = true
                }
//                makeImage()
            }
    }
    
    var magnification: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                currentSize = value.magnification - 1
            }
            .onEnded { value in
                withAnimation {
                    finalSize += currentSize
                    currentSize = 0
                    isZoom = false
                }
//                makeImage()
            }
    }
    
    var drag: some Gesture {
        DragGesture()
            .onChanged { gesture in
                print("\(draggedOffset.width) \(draggedOffset.height)")
                draggedOffset = accumulatedOffset + gesture.translation
            }
            .onEnded { gesture in
                accumulatedOffset = accumulatedOffset + gesture.translation
//                makeImage()
            }
    }
    var imageView: some View {
        Image(uiImage: resultImage ?? UIImage())
            .resizable()
            .scaledToFit()
            .frame(width: resultImage!.size.width / scaleCompute(resultImage!), height: resultImage!.size.height / scaleCompute(resultImage!))
            .padding(.bottom, 20)
            .offset(draggedOffset)
            .scaleEffect(finalSize + currentSize)
            .rotationEffect(currentAngle + finalAngle)
            .gesture(drag.simultaneously(with: magnification).simultaneously(with: rotate))
        
    }
    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    if let image = resultImage {
                        Color(hex: "32322f")
                            .frame(width: image.size.width / scaleCompute(image), height: image.size.height / scaleCompute(image))
                        imageView
                            .mask(Rectangle().frame(width: image.size.width / scaleCompute(image), height: image.size.height / scaleCompute(image)))
                        //                    Color(.white)
//                        VStack {
//                            Spacer()
//                            Button {
//
//                            } label: {
//                                Image(checkScreenState(image))
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(width: 83, height: 38)
//                            }
//                            .padding(.bottom, 40)
//                        }

                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color.white)
                            .opacity(btnOpacity)
                            .frame(width: 175, height: 38)
                            .overlay(Text("프레임이 저장되었습니다.").foregroundStyle(.black).font(.footnote).opacity(btnOpacity))
                        
                    }
                }
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            HStack {
                Button {
                    self.presentationMode.wrappedValue.dismiss()
//                    print("\(UIScreen.main.bounds.width) \(UIScreen.main.bounds.height)")
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
                
                Spacer(minLength: UIScreen.main.bounds.width / 20)
                
                Button {
                    if index > 0 {
                        index -= 1
//                        print("range: \(imageHistory.count), index: \(index)")
                        resultImage = imageHistory[index]
//                        state = true
                    }
                } label: {
                    Image("back")
                        .colorMultiply(index > 0 ? .black : .gray03)
                }
                .padding(.trailing, 14)
                
                Button {
                    if imageHistory.count - 1 > index {
                        index += 1
//                        print("range: \(imageHistory.count), index:\(index)")
                        resultImage = imageHistory[index]
//                        state = true
                    }
                } label: {
                    Image("front")
                        .colorMultiply(index < imageHistory.count - 1 ? .black: .gray03)
                }
                .padding(.trailing, 60)
                
                Spacer()
                Button {
                    let render = ImageRenderer(content: self.imageView.frame(width: resultImage!.size.width / scaleCompute(resultImage!), height: resultImage!.size.height / scaleCompute(resultImage!)))
                    render.scale = scaleCompute(resultImage!)
                    image = render.uiImage
                    addImage(data: image?.pngData())
                    btnOpacity = 1
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                      btnOpacity = 0
                    }
                    isShow = true
//                    print("\(images.count)")
                    
                } label: {
                    Text("저장")
                        .fontWeight(.semibold)
                        .foregroundStyle(.pointPink)
                        .frame(width: UIScreen.main.bounds.width / 5, height: UIScreen.main.bounds.height / 20)
                }
                .padding(1)
            }
        }
        .navigationDestination(isPresented: $isShow) {
            CameraView()
        }
        .onAppear {
            let render = ImageRenderer(content: self.imageView.frame(width: resultImage!.size.width / (scaleCompute(resultImage!) * 2), height: resultImage!.size.height / scaleCompute(resultImage!)))
            render.scale = scaleCompute(resultImage!)
            image = render.uiImage
            imageHistory.append(image!)
        }
    }
    
    func scaleCompute(_ image: UIImage) -> CGFloat {
        var scale: CGFloat = image.size.height / (UIScreen.main.bounds.height * 0.76)
        
        if image.size.width / scale > UIScreen.main.bounds.width || image.size.width >= image.size.height {
            scale = image.size.width / UIScreen.main.bounds.width
            print("\(scale)")
        }
        print("\(image.size.width)  \(image.size.height)")
        print("\(UIScreen.main.bounds.width) \(UIScreen.main.bounds.height)")
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
        
        saveContext()
    }
    func makeImage() {
        let render = ImageRenderer(content: self.imageView)
//        render.scale = (1 / resultImage!.scale)
        render.scale = scaleCompute(resultImage!)
        
        print("\(render.scale ), \(scaleCompute(resultImage!))")
        print("\(resultImage!.size.width) \(resultImage!.size.height)")
        if let rend = render.uiImage {
            if index < imageHistory.count - 1 {
                for _ in index+1..<imageHistory.count {
                    imageHistory.removeLast()
                }
            }
            imageHistory.append(rend)
            index += 1
            print("\(index)")
            
        }
        resultImage = imageHistory[index]
    }
    
    func checkScreenState(_ image: UIImage?) -> String {
        if image!.size.width > image!.size.height {
            return "horizon"
        } else {
            return "vertical"
        }
    }
}

extension CGSize {
    static func + (lhs: Self, rhs: Self) -> Self {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
}
