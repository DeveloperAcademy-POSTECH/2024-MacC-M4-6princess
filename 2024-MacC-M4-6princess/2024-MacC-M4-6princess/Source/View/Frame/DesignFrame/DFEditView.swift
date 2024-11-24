import SwiftUI
import Vision
import CoreImage.CIFilterBuiltins

struct DFEditView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var imageModel: ImageListModel
    @ObservedObject var viewModel: DFEditViewModel = DFEditViewModel()
    @State private var selectionModeIndex: Int = 3
    @State private var lines: [Line] = []
    @State private var thickness: Double = 10.0
    //    @Binding var pickedImage: UIImage?
    @EnvironmentObject var naviManager: NavigationManager
    @EnvironmentObject var frameManager: FrameManager
    
    var body: some View {
        ZStack {
            Color(.black)
                .ignoresSafeArea()
            VStack {
                ZStack {
                    
                    inputImageWithMask
                        .mask(Rectangle().frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 4/3))
                    
                    if let image = viewModel.resultImage {
                        let scale = scaleCompute(image)
                        
                        Image(uiImage: image)
                            .resizable()
                            .opacity(viewModel.showPreview ? 1 : 0)
                            .aspectRatio(contentMode: .fit)
                            .background(Color(hex: "32322f").opacity(viewModel.showPreview ? 1 : 0))
                            .frame(width: image.size.width / scale, height: image.size.height / scale)
                            .padding(.bottom, 20)
                        
                    }
                    
                    Circle()
                        .stroke(.white)
                        .opacity(viewModel.isShowThick ? 1 : 0)
                        .frame(width: thickness, height: thickness)
                    
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button {
                                viewModel.showPreview.toggle()
                                viewModel.createResult{
                                    
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
                        
                    }
                }
                if UIScreen.main.bounds.height/UIScreen.main.bounds.width > 2.0 {
                    brushToolSelector
                }
                else{
                    brushToolSelectorIpad
                }
            }
        }
        .onAppear {
            showMaskImage()
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
private extension DFEditView {
    
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
    
}

///
private extension DFEditView {
    
    var draw: some Gesture {
        
        DragGesture()
            .onChanged{ dragValue in
                if selectionModeIndex == 0 || selectionModeIndex == 1 {
                    drawLines(startLocation: dragValue.startLocation, location: dragValue.location)
                    print("\(dragValue.startLocation)")
                    
                }
            }
            .onEnded{ dragValue in
                
                if selectionModeIndex == 0 || selectionModeIndex == 1 {
                    makeHistory()
                }
            }
    }
    
    var moveImage: some Gesture {
        
        DragGesture()
            .onChanged { value in
                if selectionModeIndex == 3 && viewModel.magnifyScale > 1.0 {
                    
                    viewModel.draggedOffSet.width = viewModel.accumulatedOffSet.width + value.translation.width
                    viewModel.draggedOffSet.height = viewModel.accumulatedOffSet.height + value.translation.height
                    
                }
            }
            .onEnded { value in
                
                if selectionModeIndex == 3 && viewModel.magnifyScale > 1.0 {
                    
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
                
                let scale = scaleCompute(image)
                
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
                viewModel.isShowThick = editing
            }
            .accentColor(.pointPink)
            .frame(width: UIScreen.main.bounds.width / 1.2, height: 22)
            .padding(.bottom, 20)
            .padding([.leading, .trailing, .top], 10)
        }
        .onAppear() {
            thumbImageCustom()
        }
    }
    
    var canvas: some View {
        
        Canvas { context, size in
            
            if let image = viewModel.maskImage {
                context.draw(Image(uiImage: image).resizable(), in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            }
            
            for line in lines {
                var path = Path()
                path.addLines(line.points)
                if line.mode == .draw {
                    context.blendMode = .normal
                    context.stroke(path, with: .color(line.color), style: StrokeStyle(lineWidth: line.lineWidth, lineCap: .round, lineJoin: .round))
                } else {
                    context.blendMode = .clear
                    context.stroke(path, with: .color(line.color), style: StrokeStyle(lineWidth: line.lineWidth, lineCap: .round, lineJoin: .round))
                }
            }
        }
        .onChange(of: viewModel.maskImage) {
            deleteAllLines()
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
        HStack {
            Button {
                self.presentationMode.wrappedValue.dismiss()
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
                viewModel.reDo()
            } label: {
                Image("back")
                    .colorMultiply(viewModel.indexOfMask > 0 ? .white : .gray01)
            }
            .padding(.trailing, 14)
            
            Button {
                viewModel.unDo()
            } label: {
                Image("front")
                    .colorMultiply(viewModel.indexOfMask < viewModel.maskImageList.count - 1 ? .white : .gray01)
            }
            .padding(.trailing, 60)
            
            Spacer()
            Button {
                
                viewModel.createResult {
                    viewModel.detectSubject(inputImage: viewModel.resultImage) {
                        
                        if let image = viewModel.outputImage {
                            var newImage = SubjectImage()
                            newImage.image = image
                            newImage.originalImage = frameManager.pickedImage
                            imageModel.imageList.append(newImage)
                            print("\(imageModel.imageList.count) 길이")
                        }
                    }
                }
                viewModel.isShowModifyFrame.toggle()
                //                viewModel.isShowModifyFrame.toggle()
                
                if naviManager.route.count > 1 {
                    naviManager.pop()
                } else {
                    naviManager.push(screen: Screen.modifyFrame)
                }//✅
                
            } label: {
                Text("확인")
                    .fontWeight(.semibold)
                    .foregroundStyle(.pointPink)
                    .frame(width: UIScreen.main.bounds.width / 5, height: UIScreen.main.bounds.height / 20)
            }
            .padding(1)
            
        }
    }
    
    var brushToolSelector: some View {
        
        HStack(spacing: UIScreen.main.bounds.width / 2.4) {
            Button {
                toolSelect("brush")
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
                toolSelect("erase")
                
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
    var brushToolSelectorIpad: some View {
        
        HStack(spacing: UIScreen.main.bounds.width / 2.4) {
            Button {
                toolSelect("brush")
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
                toolSelect("erase")
                
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
        .padding(.bottom,30)
    }
    
}

private extension DFEditView {
    
    private func showMaskImage() {
        
        let render = ImageRenderer(content: pickedImageRender)
        render.scale = 1
        viewModel.inputImage = render.uiImage
        viewModel.removeBackground()
        if viewModel.maskImageList.count == 0 && viewModel.maskImage != nil {
            viewModel.maskImageList.append(viewModel.maskImage)
        }
        
    }
    
    private func scaleCompute(_ image: UIImage) -> CGFloat {
        var scale: CGFloat = image.size.height / (UIScreen.main.bounds.width * 4/3)
        
        if image.size.width / scale > UIScreen.main.bounds.width || image.size.width >= image.size.height {
            scale = image.size.width / UIScreen.main.bounds.width
        }
        return scale
    }
    
    private func makeHistory() {
        
        if viewModel.maskImageList.count == 0 {
            viewModel.maskImageList.append(viewModel.maskImage)
        }
        
        viewModel.opacity = 1
        viewModel.maskColor = .white
        let render = ImageRenderer(content: self.canvas.frame(width: viewModel.getWidth() / scaleCompute(viewModel.inputImage!), height: viewModel.getHeight() / scaleCompute(viewModel.inputImage!)))
        render.scale = scaleCompute(viewModel.inputImage!)
        
        viewModel.appendMaskImage(render.uiImage)
    }
    
    private func drawLines(startLocation: CGPoint, location: CGPoint) {
        if lines.isEmpty  {
            lines = [Line(color: .white, points: [startLocation], mode: Mode(rawValue: selectionModeIndex)!, lineWidth: thickness / viewModel.magnifyScale)]
        } else {
            var newLine = Line(color: .white, points: [], mode:  Mode(rawValue: selectionModeIndex)!, lineWidth: thickness / viewModel.magnifyScale)
            if startLocation != lines[lines.count - 1].points.first {
                newLine.points = [startLocation]
                lines.append(newLine)
                print("Start new point")
            } else {
                print("Change point event")
                let changedValue = location
                lines[lines.count - 1].points.append(changedValue)
            }
        }
    }
    
    private func thumbImageCustom() {
        let render = ImageRenderer(content: Circle().frame(width: 16, height: 16).foregroundStyle(.white))
        render.scale = UIScreen.main.scale
        let thumbImage = render.uiImage
        UISlider.appearance().setThumbImage(thumbImage, for: .normal)
    }
    
    private func toolSelect(_ selected: String) {
        
        if selectionModeIndex != 3 {
            
            if (selected == "brush" && selectionModeIndex == 0) || (selected == "erase" && selectionModeIndex == 1) {
                selectionModeIndex = 3
            } else if selected == "brush" && selectionModeIndex == 1 {
                selectionModeIndex = 0
            } else if selected == "erase" && selectionModeIndex == 0 {
                selectionModeIndex = 1
            }
            
        } else {
            
            if selected == "brush" {
                selectionModeIndex = 0
                
            } else {
                selectionModeIndex = 1
            }
        }
    }
    
    private func deleteAllLines() {
        if viewModel.deleteLines {
            lines.removeAll()
            viewModel.deleteLines = false
        }
    }
}
//#Preview {
//    DFEditView()
//}
