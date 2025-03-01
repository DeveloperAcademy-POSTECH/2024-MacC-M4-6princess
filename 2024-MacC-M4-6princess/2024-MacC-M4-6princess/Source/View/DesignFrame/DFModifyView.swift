import SwiftUI
import Foundation
import CoreData
import FirebaseAnalytics

struct DFModifyView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.managedObjectContext) var managedContext
    @EnvironmentObject var naviManager: NavigationManager
    @EnvironmentObject var frameManager: FrameManager
    @EnvironmentObject var imageModel: ImageListModel
    @StateObject var viewModel: DFModifyViewModel = DFModifyViewModel()
    @AppStorage("onboarding") var isFirstLaunching: Bool = true
    
    
    /// 구버전 레이어 관련한 것으로 조만간 파일로 정리한 뒤 삭제할 예정입니다.
    @State var isDragging: Bool = false
    @State var selectedLayerIndex: Int?
    @State var isLongPressed: Bool = false
    @State var beforeDragOffsetY: CGFloat = .zero
    
    var body: some View {
        
        ZStack {
            if isFirstLaunching == true && !viewModel.showAgain == true {
                DFOnboardingView(isFirstLaunching: $isFirstLaunching, showAgain: $viewModel.showAgain)
                    .zIndex(1)
            }
            
            Color.clear
                .contentShape(Rectangle()) // 터치 영역을 전체 ZStack으로 설정
                .onTapGesture {
                    isLongPressed = false // 화면 클릭 시 isLongPressed 초기화
                }
            
            if UIScreen.main.bounds.height/UIScreen.main.bounds.width > 2.0{
                VStack {
                    ZStack {
                        Image("checkBox")
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 4/3)
                        
                        imageView
                            .onAppear {
                                if let list = imageModel.imageList.last {
                                    if let _ = list.image {
                                        viewModel.modelListControl(subject: imageModel.imageList[imageModel.imageList.count-1])
                                    }
                                }
                            }
                        
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color.white)
                            .opacity(viewModel.btnOpacity)
                            .frame(width: 175, height: 38)
                            .overlay(Text("\(viewModel.saveStateText)").foregroundStyle(.black).font(.footnote).opacity(viewModel.btnOpacity))
                        if let selected = viewModel.selectedSubject,selected.isTapped{
                            newLayerIndicator
                        }
                    }
                    .gesture(viewModel.backgroundGesture())
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
                DFTextView(modiViewModel:viewModel)
            }
            if frameManager.showTextModifyView, let textStyle = frameManager.selectedTextStyle {
                DFTextModifyView(
                    modiViewModel: viewModel,
                    style: Binding(
                        get: { textStyle },
                        set: { newValue in
                            frameManager.selectedTextStyle = newValue
                        }
                    )
                )
            }
            
            VStack{
                Spacer()
                HStack{
                    if isLongPressed{
                        oldLayerIndicator
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
            if !viewModel.showTextView && !frameManager.showTextModifyView {
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
            Analytics.logEvent("A5_프레임수정", parameters: nil)
        }
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
                                viewModel.selectedIndex = index
                                viewModel.selectedSubject = subject
                            }
                        //                            .gesture(combinedGesture(subject: subject))
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
                                viewModel.selectedIndex = index
                                viewModel.selectedSubject = subject
                            }
                        //                            .gesture(combinedGesture(subject: subject))
                            .simultaneousGesture(longPressAndDragGesture(for: index))
                    }
                } else if let image = subject.text {
                    ZStack {
                        let newText = subject.textStyle?.txt ?? "l"
                        
                        let newWidth = min(CGFloat(newText.count)*UIScreen.main.bounds.width/10,UIScreen.main.bounds.width)
                        let size: CGSize = .init(
                            width: newWidth,
                            height: newWidth * (image.size.height / image.size.width)
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
                                viewModel.selectedIndex = index
                                viewModel.selectedSubject = subject
                            }
                        //                            .gesture(combinedGesture(subject: subject))
                            .simultaneousGesture(longPressAndDragGesture(for: index))
                    }
                }
            }
            
        }
        .onAppear{
            // 선택된 subject의 레이어 변동창 띄어줌
            
            if imageModel.imageList.count > 1{ // 레이어가 한개이하이면 레이어 선택창이 나타나지않음
                viewModel.selectedSubject = imageModel.imageList.last
                viewModel.selectedIndex = imageModel.imageList.indices.last
            }
            //            if selectedSubject != nil {
            //                selectedSubject?.isTapped = true
            //            }
            
        }
    }
}
