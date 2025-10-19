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
    
    var body: some View {
        
        ZStack {
            Color.clear
                .contentShape(Rectangle())
            
            if UIScreen.main.bounds.height/UIScreen.main.bounds.width > 2.0{
                let extractedExpr: VStack<TupleView<(some View, some View)>> = VStack {
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
                            .frame(width: 203, height: 38)
                            .overlay(Text("\(viewModel.saveStateText)").foregroundStyle(.black).font(.footnote).opacity(viewModel.btnOpacity))
                        if let selected = viewModel.selectedSubject,selected.isTapped,imageModel.imageList.count > 1{
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
                extractedExpr
            }
            else{
                modifyIpad
            }
            
            // 새 텍스트 생성
            if viewModel.showTextView {
                DFTextViewControllerRepresentable(
                    viewModel: DFTextViewModel(),
                    modiViewModel: viewModel
                )
                .environmentObject(imageModel)
                .ignoresSafeArea()
            }
            
            // 텍스트 수정
            if frameManager.showTextModifyView, let textStyle = frameManager.selectedTextStyle {
                DFTextViewControllerRepresentable(
                    viewModel: DFTextViewModel(),
                    modiViewModel: viewModel,
                    textStyle: textStyle
                )
                .environmentObject(imageModel)
                .ignoresSafeArea()
            }
            
        }
        .sheet(isPresented: $viewModel.showStickerSheet) {
            DFStickerView(viewModel: viewModel)
                .presentationDetents([.fraction(0.5)])
                .presentationDragIndicator(.visible)
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
                DispatchQueue.main.async() {
                    frameManager.showMFView = false
                    naviManager.popToRoot()
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
                    }
                } else if let image = subject.sticker {
                    ZStack {
                        let size: CGSize = .init(
                            width: image.size.width / viewModel.scaleCompute(image),
                            height: image.size.height / viewModel.scaleCompute(image)
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
                    }
                }
            }
        }
        .onAppear{
            if imageModel.imageList.count > 1{
                viewModel.selectedSubject = imageModel.imageList.last
                viewModel.selectedIndex = imageModel.imageList.indices.last
            }
        }
    }
}
