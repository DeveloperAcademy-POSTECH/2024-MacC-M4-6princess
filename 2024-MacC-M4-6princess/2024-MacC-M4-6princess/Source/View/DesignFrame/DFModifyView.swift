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
    @State var isDragging: Bool = false
    @State var selectedLayerIndex: Int?
    @State var isLongPressed: Bool = false
    @State var beforeDragOffsetY: CGFloat = .zero
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
                    imageListUpdate()
    
                    print("isLongPressed 눌림")
                }
                .simultaneously(with: DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if isLongPressed { // 길게 누른 상태에서만 드래그 동작
                            
                                dragOnChanged(value: value, index: index)
                            
                        }
                    }
                    .onEnded { _ in
                        withAnimation{
                            dragOnEnded()
                            beforeDragOffsetY = .zero
                            isLongPressed = false
                            imageListUpdate()
                        }
    
                    }
                )
        }
    
    func imageListUpdate() {
        // 길게 누름 상태 초기화
        if imageModel.imageList.count > 0 {
            imageModel.imageList.append(imageModel.imageList[0])
            imageModel.imageList.removeLast()
        }
    }
    // 드래그 중 호출되는 함수
    func dragOnChanged(value: DragGesture.Value, index: Int) {
        if !isDragging {
            selectedLayerIndex = index
            isDragging = true
        }
        
        let dragOffsetY = value.translation.height
        // 차이
        let diff = dragOffsetY - beforeDragOffsetY
        /*
         0 -> 50 (backward) => 50
         0 -> -50 (forward) => -50
         */
        var currentStep = Int(diff / 50)
        if diff < 0 && diff > -50 {
            currentStep = 0
        }
        // 밑으로 내리면 -> backward (index 증가)
        // 밑으로 내리면 dragOffsetY가 양수
        // 위로 올리면 -> Forward (index 감소)
        // 위로 올리면 dragOffsetY가 마이너스
        
        if let currentIndex = selectedLayerIndex,
           currentStep != 0
        //            currentStep != currentIndex
        {
            if diff > 0 {
                if currentIndex - currentStep < 0{
                    currentStep = currentIndex
                }
                /// 인덱스 감소
                selectedLayerIndex = moveLayerForward(at: currentIndex, steps: abs(currentStep))
                beforeDragOffsetY = dragOffsetY
                imageModel.imageList.append(imageModel.imageList[0])
                imageModel.imageList.removeLast()
            } else {
                if currentStep + currentIndex > imageModel.imageList.count{
                    let diff = currentStep + currentIndex - imageModel.imageList.count
                    currentStep = imageModel.imageList.count - currentIndex
                }
                /// 인덱스 증가
                selectedLayerIndex = moveLayerBackward(at: currentIndex, steps: abs(currentStep))
                beforeDragOffsetY = dragOffsetY
                imageModel.imageList.append(imageModel.imageList[0])
                imageModel.imageList.removeLast()
            }
        }
    }
    
    // 드래그 종료 시 호출되는 함수
    func dragOnEnded() {
        isDragging = false
        selectedLayerIndex = nil
    }
    
    
    // 레이어를 앞으로 이동
    func moveLayerForward(at index: Int, steps: Int) -> Int{
        guard steps > 0 else { return index}
        var currentIndex = index
        print("forward steps:\(steps)")
        for _ in 0..<steps {
            guard currentIndex > 0 else { return 0}
            guard currentIndex < imageModel.imageList.count else { return imageModel.imageList.count - 1}
            print("currentIndex: \(currentIndex),currentIndex - 1: \(currentIndex - 1)")
            imageModel.imageList.swapAt(currentIndex, currentIndex - 1)
            currentIndex -= 1
        }
        return currentIndex
    }
    
    // 레이어를 뒤로 이동
    func moveLayerBackward(at index: Int, steps: Int) -> Int{
        guard steps > 0 else { return index}
        var currentIndex = index
        for _ in 0..<steps {
            guard currentIndex < imageModel.imageList.count - 1 else { return imageModel.imageList.count-1}
            guard currentIndex >= 0 else { return 0}
            print("currentIndex: \(currentIndex),currentIndex + 1: \(currentIndex + 1)")
            imageModel.imageList.swapAt(currentIndex, currentIndex + 1)
            currentIndex += 1
        }
        return currentIndex
    }
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
                            .gesture(longPressAndDragGesture(for: index))
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
                            .gesture(longPressAndDragGesture(for: index))
                    }
                } else if let image = subject.text {
                    ZStack {
                        let newText = subject.textStyle?.rawText ?? "l"

                        let newWidth = min(CGFloat(newText.count)*UIScreen.main.bounds.width/10,UIScreen.main.bounds.width)
                        let size: CGSize = .init(
                            width: newWidth,
                            height: newWidth * (image.size.height / image.size.width)
                        )
//                        let size: CGSize = .init(
//                            width: UIScreen.main.bounds.width,
//                            height: UIScreen.main.bounds.width)
//                        
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
                            .gesture(longPressAndDragGesture(for: index))
                    }
                }
            }
            
        }
    }
    
    
}

