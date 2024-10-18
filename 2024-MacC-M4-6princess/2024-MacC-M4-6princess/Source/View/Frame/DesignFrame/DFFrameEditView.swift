import SwiftUI
import Vision
import CoreImage.CIFilterBuiltins

enum Mode {
    case draw
    case eraser
    
    init?(rawValue: Int) {
        switch rawValue {
        case 0: self = .draw
        case 1: self = .eraser
        default: return nil
        }
    }
}

struct Line {
    var color: Color
    var points: [CGPoint]
    var mode: Mode
    var lineWidth: Double = 10.0
}


struct DFFrameEditView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var pickedImage: UIImage?
    @State private var selectionModeIndex: Int = 0
    @State private var lines: [Line] = []
    @State private var thickness: Double = 10.0
    @State private var isShow: Bool = false
    @State private var colorState: Color = .pink
    @State private var opacState: CGFloat = 0.4
    @State private var maskImage: UIImage? = nil
    @State private var resultImage: UIImage? = nil
    @State private var showPreview: Bool = false
    @State private var maskImages: [UIImage?] = []
    @State private var state: Bool = false
    @State private var isPresented: Bool = false
    @State var index: Int = 0
    @State private var inputImage: UIImage?
    
    var imageRender: some View {
        VStack {
            if let image = pickedImage {
                Image(uiImage: image)
//                    .resizable()
            }
        }
    }
    
    var canvas: some View {
        Canvas { context, size in
            
            if let image = maskImage {
                context.draw(Image(uiImage: image).resizable(), in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            }
            
//            print("w: \(size.width), h: \(size.height)")
            
            for line in lines {
                var path = Path()
                path.addLines(line.points)
                if line.mode == .draw {
                    context.blendMode = .normal
                    context.stroke(path, with: .color(line.color), style: StrokeStyle(lineWidth: line.lineWidth))
                } else {
                    context.blendMode = .clear
                    context.stroke(path, with: .color(line.color), style: StrokeStyle(lineWidth: line.lineWidth))
                }
            }
        }
        .onChange(of: maskImage) {
            if state {
                lines.removeAll()
                state = false
            }
        }
        //        .frame(width: 393, height: 673)
        .colorMultiply(colorState)
        .opacity(opacState)
        .gesture(DragGesture().onChanged({ dragValue in
            print("Changed")
            if lines.isEmpty  {
                lines = [Line(color: .white, points: [dragValue.startLocation], mode: Mode(rawValue: selectionModeIndex)!, lineWidth: thickness)]
            } else {
                var newLine = Line(color: .white, points: [], mode:  Mode(rawValue: selectionModeIndex)!, lineWidth: thickness)
                if dragValue.startLocation != lines[lines.count - 1].points.first {
                    // Start a new line
                    newLine.points = [dragValue.startLocation]
                    lines.append(newLine)
                    print("Start new point")
                } else {
                    print("Change point event")
                    let changedValue = dragValue.location
                    // Just append point to last line
                    lines[lines.count - 1].points.append(changedValue)
                }
            }
        }).onEnded({ dragValue in
            if maskImages.count == 0 {
                maskImages.append(maskImage)
            }
            makeImage()
        }))
    }
    
    var body: some View {
        ZStack {
            Color(.black)
                .ignoresSafeArea()
            VStack {
                ZStack {
                    if let image = inputImage {
                        let scale = scaleCompute(image)
                        
                        Image(uiImage: image)
                            .resizable()
                            .opacity(showPreview ? 0 : 1)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: image.size.width / scale, height: image.size.height / scale)
                            .padding(.bottom, 20)
                        canvas
                            .offset(y: -10)
                            .opacity(showPreview ? 0 : 1)
                            .frame(width: image.size.width / scale, height: image.size.height / scale)
                    }
                    
                    if let image = resultImage {
                        let scale = scaleCompute(image)
                        Image(uiImage: image)
                            .resizable()
                            .opacity(showPreview ? 1 : 0)
                            .aspectRatio(contentMode: .fit)
                            .background(Color(hex: "32322f").opacity(showPreview ? 1 : 0))
                            .frame(width: image.size.width / scale, height: image.size.height / scale)
                            .padding(.bottom, 20)
                    }
                    
                    Circle()
                        .stroke(.white)
                        .opacity(isShow ? 1 : 0)
                        .frame(width: thickness, height: thickness)
                    
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button {
                                showPreview.toggle()
                                createResult()
                                print("\(showPreview)")
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(showPreview ? Color.gray02 : Color.white)
                                        .frame(width: 72, height: 27)
                                    Text("미리보기")
                                        .font(.custom("pretendard-medium", size: 16))
                                        .foregroundStyle(showPreview ? Color.gray03 : Color.gray02)
                                }
                            }
                            .padding(.trailing)
                        }
                        ZStack {
                            Rectangle()
                                .fill(Color.black.opacity(0.5))
                                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 20)
                            Slider(
                                value: $thickness,
                                in: 0...50,
                                step: 1
                            ) {
                                Text("Title")
                            } minimumValueLabel: {
                                Text("\(Int(thickness))")
                                    .foregroundStyle(.white)
                            } maximumValueLabel: {
                                Text("")
                            } onEditingChanged: { editing in
                                isShow = editing
                                print("\(isShow)")
                            }
                            .accentColor(.pointPink)
                            .frame(width: UIScreen.main.bounds.width / 1.2, height: 22)
                            .padding(.bottom, 20)
                            .padding([.leading, .trailing, .top], 10)
                        }
                        .onAppear() {
                            let render = ImageRenderer(content: Circle().frame(width: 16, height: 16).foregroundStyle(.white))
                            render.scale = UIScreen.main.scale
                            let thumbImage = render.uiImage
                            UISlider.appearance().setThumbImage(thumbImage, for: .normal)
                        }
                    }
                }
                
                HStack(spacing: UIScreen.main.bounds.width / 2.4) {
                    Button {
                        selectionModeIndex = 0
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "212121"))
                                .frame(width: UIScreen.main.bounds.height / 20, height: UIScreen.main.bounds.height / 20)
                            Image("brush")
                                .frame(width: UIScreen.main.bounds.height / 20, height: UIScreen.main.bounds.height / 20)
                                .colorMultiply(selectionModeIndex == 0 ? Color(.pointPink) : Color(.white))
                            Text("브러쉬")
                                .foregroundStyle(selectionModeIndex == 0 ? Color(.pointPink) : Color(.white))
                                .font(.custom("Pretendard-medium", size: 13))
                                .offset(y: 30)
                        }
                    }
                    
                    Button {
                        selectionModeIndex = 1
                        
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "212121"))
                                .frame(width: UIScreen.main.bounds.height / 20, height: UIScreen.main.bounds.height / 20)
                            Image("erase")
                                .frame(width: UIScreen.main.bounds.height / 20, height: UIScreen.main.bounds.height / 20)
                                .colorMultiply(selectionModeIndex == 1 ? Color(.pointPink) : Color(.white))
                            Text("지우개")
                                .foregroundStyle(selectionModeIndex == 1 ? Color(.pointPink) : Color(.white))
                                .font(.custom("Pretendard-medium", size: 13))
                                .offset(y: 30)
                        }
                    }
                    
                }
            }
        }
        .onAppear {
            print("\(UIScreen.main.scale)")
            let render = ImageRenderer(content: imageRender)
            render.scale = 1
            inputImage = render.uiImage
            
            removeBackground()
            if maskImages.count == 0 && maskImage != nil {
                maskImages.append(maskImage)
            }
        }
        .navigationDestination(isPresented: $isPresented, destination: {
            DFModifyFrame(resultImage: $resultImage)
        })
        .navigationBarBackButtonHidden()
        .toolbar {
            HStack {
                Button {
                    self.presentationMode.wrappedValue.dismiss()
                    print("\(UIScreen.main.bounds.width) \(UIScreen.main.bounds.height)")
                    print("\(pickedImage!.size.width) x \(pickedImage!.size.height)")
                } label: {
                    HStack {
                        Image(systemName: "chevron.backward")
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                        
                        Text("사진 선택")
                            .fontWeight(.regular)
                            .foregroundStyle(.white)
                    }
                }
                .frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.height / 20)
                
                Spacer(minLength: UIScreen.main.bounds.width / 20)
                
                Button {
                    if index > 0 {
                        index -= 1
                        print("range: \(maskImages.count), index: \(index)")
                        maskImage = maskImages[index]
                        state = true
                    }
                } label: {
                    Image("back")
                        .colorMultiply(index > 0 ? .white : .gray01)
                }
                .padding(.trailing, 14)
                
                Button {
                    if maskImages.count - 1 > index {
                        index += 1
                        print("range: \(maskImages.count), index:\(index)")
                        maskImage = maskImages[index]
                        state = true
                    }
                } label: {
                    Image("front")
                        .colorMultiply(index < maskImages.count - 1 ? .white : .gray01)
                }
                .padding(.trailing, 60)
                
                Spacer()
                Button {
                    createResult()
                    isPresented = true
                    
                } label: {
                    Text("확인")
                        .fontWeight(.semibold)
                        .foregroundStyle(.pointPink)
                        .frame(width: UIScreen.main.bounds.width / 5, height: UIScreen.main.bounds.height / 20)
                }
                .padding(1)
                
            }
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
    
    func createResult() {
        
        guard let inputImage = CIImage(image: inputImage ?? UIImage()) else {
            print("Failed to create CIImage")
            return
        }
        processingQueue.async {
            
            // maskImage 상태 변수 업데이트
            DispatchQueue.main.async {
                if let maskImage = maskImage {// maskImage를 UIImage로 변환하여 저장
                    let outputImage = apply(mask: CIImage(image: maskImage)!, to: inputImage)
                    let image = render(ciImage: outputImage)
                    DispatchQueue.main.async {
                        resultImage = image // 결과 이미지 상태 변수 업데이트
                    }
                }
            }
        }
    }
    
    private func removeBackground() {
        
        guard let inputImage = CIImage(image: inputImage ?? UIImage()) else {
            print("Failed to create CIImage")
            return
        }
        
        processingQueue.async {
            guard let maskImage = subjectMaskImage(from: inputImage) else {
                print("Failed to create mask image")
                return
            }
            //            guard let mask = subjectMaskImage(from: maskImage) else {
            //                print("Failed to create mask image")
            //                return
            //            }
            // maskImage 상태 변수 업데이트
            DispatchQueue.main.async {
                let m = apply(mask: maskImage, to: maskImage)
                self.maskImage = render(ciImage: m) // maskImage를 UIImage로 변환하여 저장
            }
            
            let resultImage = apply(mask: maskImage, to: inputImage)
            let image = render(ciImage: resultImage)
            
            DispatchQueue.main.async {
                self.resultImage = image // 결과 이미지 상태 변수 업데이트
            }
        }
    }
    func makeImage() {
        opacState = 1
        colorState = .white
        let render = ImageRenderer(content: self.canvas.frame(width: inputImage!.size.width / scaleCompute(inputImage!), height: inputImage!.size.height / scaleCompute(inputImage!)))
        render.scale = scaleCompute(inputImage!)
        print("\(render.uiImage)")
        if let rend = render.uiImage {
            if index < maskImages.count - 1 {
                for _ in index+1..<maskImages.count {
                    maskImages.removeLast()
                }
            }
            maskImages.append(rend)
            index += 1
            print("\(index)")
            
        }
        maskImage = maskImages[index]
        opacState = 0.4
        colorState = .pink
    }
    
    private func subjectMaskImage(from inputImage: CIImage) -> CIImage? {
        let handler = VNImageRequestHandler(ciImage: inputImage)
        let request = VNGenerateForegroundInstanceMaskRequest()
        //        let request = VNGeneratePersonInstanceMaskRequest()
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
            return nil
        }
        
        guard let result = request.results?.first else {
            print("No observations found")
            return nil
        }
        do {
            let maskPixelBuffer = try result.generateScaledMaskForImage(forInstances: result.allInstances, from: handler)
            //            let maskPixelBuffer = try result.generateMask(forInstances: result.allInstances)
            return CIImage(cvPixelBuffer: maskPixelBuffer)
        } catch {
            print(error)
            return nil
        }
    }
    
    private func apply(mask: CIImage, to image: CIImage) -> CIImage {
        
        let filter = CIFilter.blendWithMask()
        filter.inputImage = image
        filter.maskImage = mask
        filter.backgroundImage = CIImage.empty()
        return filter.outputImage!
    }
    
    private func render(ciImage: CIImage) -> UIImage {
        guard let cgImage = CIContext(options: nil).createCGImage(ciImage, from: ciImage.extent) else {
            fatalError("Failed to render CGImage")
        }
        return UIImage(cgImage: cgImage)
    }
    
    var processingQueue = DispatchQueue(label: "ProcessingQueue")
}

//#Preview {
//    DFFrameEditView()
//}
