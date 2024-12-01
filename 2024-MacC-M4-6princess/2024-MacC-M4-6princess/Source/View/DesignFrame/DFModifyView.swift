import SwiftUI
import Foundation
import CoreData

struct DFModifyView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.managedObjectContext) var managedContext
    @EnvironmentObject var naviManager: NavigationManager
    @EnvironmentObject var frameManager: FrameManager
    @EnvironmentObject var imageModel: ImageListModel
    
    @StateObject var viewModel: DFModifyViewModel = DFModifyViewModel()
    
    @AppStorage("onboarding") var isFirstLaunching: Bool = true
    @State var showAgain: Bool = false
//    @State var layerList: [SubjectImage] = []
    @State var isDragging: Bool = false
    @State var selectedLayerIndex: Int?
    @State var isLongPressed: Bool = false
    
    
    var body: some View {
        
        ZStack {
            if isFirstLaunching == true && !showAgain == true {
                DFOnboardingView(isFirstLaunching: $isFirstLaunching, showAgain: $showAgain)
                    .zIndex(1)
            }
            
            if UIScreen.main.bounds.height/UIScreen.main.bounds.width > 2.0{
                VStack {
                    ZStack {
                        Image("checkBox")
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 4/3)
                        
                        imageView
                        
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color.white)
                            .opacity(viewModel.btnOpacity)
                            .frame(width: 175, height: 38)
                            .overlay(Text("\(viewModel.saveStateText)").foregroundStyle(.black).font(.footnote).opacity(viewModel.btnOpacity))
                        
                    }
                    .onTapGesture {
                        viewModel.isTappedImage = false
                        imageModel.imageList.forEach {
                            $0.isTapped = viewModel.isTappedImage
                        }
                    }
                    .mask(Rectangle().frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 4/3))
                    DFImageDecoView(viewModel: viewModel)
                        .padding(.top, 58)
                }
                
            }
            else{
                modifyIpad
            }
            if viewModel.showTextView {
                DFTextView(viewModel:viewModel)
            }
            VStack{
                Spacer()
                HStack{
                    if isLongPressed{
                        layerIndicator
                    }
                    Spacer()
                }
                Spacer()
            }
        }
        .sheet(isPresented: $viewModel.showStickerSheet) {
            DFStickerView(viewModel: viewModel)
                .presentationDetents([.fraction(0.5)]) // 화면의 절반만 차지
                .presentationDragIndicator(.visible) // 드래그 인디케이터 표시
        }
        .ignoresSafeArea(.keyboard)
        .navigationBarBackButtonHidden()
        .toolbar {
            if !viewModel.showTextView {
                toolBarButtons
            }
            
        }
        .onChange(of: viewModel.showCamera) { newValue in
            if newValue {
                // 1초 후에 화면 전환
                DispatchQueue.main.async() {
                    frameManager.showMFView = false
                    naviManager.popToRoot()
                    frameManager.showMFView = false
                    
                }
            }
        }
        .onAppear {
            Task {
                if let image = frameManager.resultImage {
                    try await Task.sleep(for: .seconds(1))
                    viewModel.makeImageList()
                }
            }
        }
    }
}


extension DFModifyView {
    
    var imageView: some View {
        
        ZStack {
            
            ForEach(imageModel.imageList.indices, id: \.self) { index in
                let subject = imageModel.imageList[index]
                
                if let image = subject.image, let realImage = subject.originalImage {
                    ZStack {
                        let size: CGSize = .init(
                            width: image.size.width / viewModel.scaleCompute(realImage),
                            height: image.size.height / viewModel.scaleCompute(realImage)
                        )
                        
                        DFOverlayBoxView(model: subject, size: size)
                            .opacity(subject.isTapped ? 1 : 0)
                            .zIndex(1)
                        
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: size.width, height: size.height)
                            .scaleEffect(subject.getScale())
                            .rotationEffect(subject.getAngle())
                            .offset(subject.getOffset())
                            .onTapGesture {
                                if !subject.isTapped {
                                    viewModel.modelListControl(subject: subject)
                                }
                                subject.isTapped.toggle()
                                imageModel.imageList.append(subject)
                                imageModel.imageList.removeLast()
                            }
                            .gesture(combinedGesture(subject: subject))
                            .simultaneousGesture(longPressAndDragGesture(for: index))
                    }
                } else if let image = subject.sticker {
                    ZStack {
                        let size: CGSize = .init(
                            width: UIScreen.main.bounds.width / 2,
                            height: UIScreen.main.bounds.width / 2 * (image.size.height / image.size.width)
                        )
                        
                        DFOverlayBoxView(model: subject, size: size)
                            .opacity(subject.isTapped ? 1 : 0)
                            .zIndex(1)
                        
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: size.width, height: size.height)
                            .scaleEffect(subject.getScale())
                            .rotationEffect(subject.getAngle())
                            .offset(subject.getOffset())
                            .onTapGesture {
                                if !subject.isTapped {
                                    viewModel.modelListControl(subject: subject)
                                }
                                subject.isTapped.toggle()
                                imageModel.imageList.append(subject)
                                imageModel.imageList.removeLast()
                            }
                            .gesture(combinedGesture(subject: subject))
                            .simultaneousGesture(longPressAndDragGesture(for: index))
                    }
                } else if let image = subject.text {
                    ZStack {
                        let size: CGSize = .init(
                            width: UIScreen.main.bounds.width / 2,
                            height: UIScreen.main.bounds.width / 2 * (image.size.height / image.size.width)
                        )
                        
                        DFOverlayBoxView(model: subject, size: size)
                            .opacity(subject.isTapped ? 1 : 0)
                            .zIndex(1)
                        
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: size.width, height: size.height)
                            .scaleEffect(subject.getScale())
                            .rotationEffect(subject.getAngle())
                            .offset(subject.getOffset())
                            .onTapGesture {
                                if !subject.isTapped {
                                    viewModel.modelListControl(subject: subject)
                                }
                                subject.isTapped.toggle()
                                imageModel.imageList.append(subject)
                                imageModel.imageList.removeLast()
                            }
                            .gesture(combinedGesture(subject: subject))
                            .simultaneousGesture(longPressAndDragGesture(for: index))
                    }
                }
            }
            
        }
    }
    func combinedGesture(subject: SubjectImage) -> some Gesture {
        DragGesture()
            .onChanged { value in
                if !isLongPressed{
                    viewModel.dragGestureTask(subject: subject, changed: value.translation)
                }
            }
            .onEnded { value in
                if !isLongPressed {
                    viewModel.accumulatedOffSet = .zero
                    viewModel.modelListControl(subject: subject)
                    subject.isTapped = true
                    imageModel.imageList.append(subject)
                    imageModel.imageList.removeLast()
                }
                
            }
            .simultaneously(with: RotateGesture()
                .onChanged { value in
                    if !isLongPressed && subject.isTapped  {
                        if viewModel.current == .zero {
                            viewModel.current = subject.getAngle()
                        }
                        viewModel.angle = value.rotation + viewModel.current
                        subject.setAngle(angle: viewModel.angle)
                    }
                }
                .onEnded { value in
                    if !isLongPressed{
                        viewModel.current = .zero
                    }
                }
            )
            .simultaneously(with: MagnifyGesture()
                .onChanged { value in
                    if !isLongPressed && subject.isTapped {
                        viewModel.setScaleVolume(value.magnification, subject: subject)
                    }
                }
                .onEnded { value in
                    if !isLongPressed{
                        viewModel.setScaleValue(minimum: 0.2, maximum: 10, subject: subject)
                    }
                }
            )
    }
    
    // 레이어 순서 표시 뷰
    var layerIndicator: some View {
        VStack(spacing: 6) {
            ForEach(imageModel.imageList.indices.reversed(), id: \.self) { index in
                if index == selectedLayerIndex {
                    VStack {
                        Spacer()
                        HStack {
                            RoundedRectangle(cornerRadius: 3)
                                .frame(width: 24, height: 4)
                                .foregroundColor(.white)
                                .padding(.leading, 4)
                            Spacer()
                        }
                        Spacer()
                    }
                    .frame(height: 6)
                } else {
                    HStack {
                        Image("heart.union")
                            .resizable()
                            .frame(width: 8, height: 6)
                        Spacer()
                    }
                }
            }
        }
        .padding(6)
        .frame(width: 40)
        .background(Color.gray)
        .cornerRadius(8)
        .padding(.horizontal, 5)
    }
    
    // 1초 길게 누르고 드래그 제스처를 생성하는 함수
    func longPressAndDragGesture(for index: Int) -> some Gesture {
        LongPressGesture(minimumDuration: 0.5) // 1초 동안 길게 누름
            .onEnded { _ in
                isLongPressed = true // 길게 눌림 활성화
                selectedLayerIndex = index
                print("isLongPressed 눌림")
            }
            .simultaneously(with: DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if isLongPressed { // 길게 누른 상태에서만 드래그 동작
                        dragOnChanged(value: value, index: index)
                    }
                }
                .onEnded { _ in
                    dragOnEnded()
                    isLongPressed = false // 길게 누름 상태 초기화
                }
            )
    }
    
    // 드래그 중 호출되는 함수
    func dragOnChanged(value: DragGesture.Value, index: Int) {
        if !isDragging {
            selectedLayerIndex = index
            //            dragStartPosition = layerImages[index].position
            isDragging = true
        }
        
        let dragOffsetY = value.translation.height
        let currentStep = Int(dragOffsetY / 50)
        
        if let currentIndex = selectedLayerIndex, currentStep != currentIndex {
            if currentStep < currentIndex {
                moveLayerForward(at: currentIndex, steps: abs(currentStep - currentIndex))
            } else {
                moveLayerBackward(at: currentIndex, steps: abs(currentStep - currentIndex))
            }
//            imageModel.imageList = layerList
            selectedLayerIndex = currentStep
        }
    }
    
    // 드래그 종료 시 호출되는 함수
    func dragOnEnded() {
        isDragging = false
        //        dragStartPosition = nil
        selectedLayerIndex = nil
    }
    
    // 레이어를 앞으로 이동
    func moveLayerForward(at index: Int, steps: Int) {
        guard steps > 0 else { return }
        var currentIndex = index
        for _ in 0..<steps {
            guard currentIndex > 0 else { return }
            guard currentIndex < imageModel.imageList.count else { return }
            print("currentIndex: \(currentIndex),currentIndex - 1: \(currentIndex - 1)")
            imageModel.imageList.swapAt(currentIndex, currentIndex - 1)
            currentIndex -= 1
            imageModel.imageList.append(imageModel.imageList[currentIndex])
            imageModel.imageList.removeLast()
        }
    }
    
    // 레이어를 뒤로 이동
    func moveLayerBackward(at index: Int, steps: Int) {
        guard steps > 0 else { return }
        var currentIndex = index
        for _ in 0..<steps {
            guard currentIndex < imageModel.imageList.count - 1 else { return }
            guard currentIndex >= 0 else { return }
            print("currentIndex: \(currentIndex),currentIndex + 1: \(currentIndex + 1)")
            imageModel.imageList.swapAt(currentIndex, currentIndex + 1)
            currentIndex += 1
            imageModel.imageList.append(imageModel.imageList[currentIndex])
            imageModel.imageList.removeLast()
        }
    }
    var toolBarButtons: some View {
        HStack {
            Button {
                viewModel.isAlert.toggle()
            } label: {
                HStack {
                    Image(systemName: "chevron.backward")
                        .fontWeight(.semibold)
                        .foregroundStyle(.gray01)
                    
                    Text("프레임 선택")
                        .fontWeight(.regular)
                        .foregroundStyle(.gray01)
                }
            }
            .alert("프레임 편집을 종료하시겠습니까?", isPresented: $viewModel.isAlert) {
                Button {
                    viewModel.isAlert.toggle()
                } label: {
                    Text("취소")
                }
                
                Button {
                    imageModel.imageList.removeAll()
                    naviManager.popToRoot()
                } label: {
                    Text("나가기")
                }
                
            } message: {
                Text("종료 시 편집된 내용은 저장되지 않습니다.")
            }
            .frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.height / 20)
            
            Spacer(minLength: UIScreen.main.bounds.width / 20)
            
            Spacer()
                .frame(width: 150)
            Button {
                
                
                
                if let image = frameManager.resultImage {
                    
                    imageModel.imageList.forEach {
                        $0.isTapped = false
                    }
                    
                    viewModel.saveStateText = "저장 중입니다..."
                    viewModel.isPushedSaveBtn = true
                    
                    if let _  = frameManager.selectedFrame {
                        viewModel.updateImage(view: imageView, frameManager: frameManager, viewContext: managedContext) {
                            
                            viewModel.btnOpacity = 0
                            viewModel.showCamera = true
                            imageModel.imageList.removeAll()
                            frameManager.resultImage = viewModel.frameImage
                            frameManager.selectedFrame = nil
                        }
                    } else {
                        
                        viewModel.saveImage(view: imageView, inputImage: image, context: managedContext) {
                            
                            viewModel.btnOpacity = 0
                            viewModel.showCamera = true
                            imageModel.imageList.removeAll()
                            frameManager.resultImage = viewModel.frameImage
                        }
                    }
                    
                    
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
