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
    @State private var showAgain: Bool = false
    var body: some View {
        
        ZStack {
            if isFirstLaunching == true && !showAgain == true {
                DFOnboardingView(isFirstLaunching: $isFirstLaunching, showAgain: $showAgain)
                    .zIndex(1)
            }
            
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
                .mask(Rectangle().frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 4/3))
                DFImageDecoView(viewModel: viewModel)
                    .padding(.top, 58)
            }
            if viewModel.showTextView {
                DFTextView(viewModel:viewModel)
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


private extension DFModifyView {
    
    var imageView: some View {
        
        ZStack {
            
            ForEach($imageModel.imageList) { $subject in
                
                if let image = subject.image, let realImage = subject.originalImage {
                    
                    ZStack {
                        
                        let size: CGSize = .init(width: image.size.width / viewModel.scaleCompute(realImage), height: image.size.height / viewModel.scaleCompute(realImage))
                        
                        DFOverlayBoxView(model: $subject, size: size)
                            .opacity(subject.isTapped && viewModel.isTappedImage ? 1 : 0)
                            .zIndex(1)
                        
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: image.size.width / viewModel.scaleCompute(realImage), height: image.size.height / viewModel.scaleCompute(realImage))
                            .scaleEffect(subject.getScale())
                            .rotationEffect(subject.getAngle())
                            .offset(subject.getOffset())
                            .onTapGesture {
                                if subject.isTapped {
                                    subject.isTapped = false
                                } else {
                                    subject.isTapped = true
                                }
                                viewModel.isTappedImage = true                            }
                            .gesture(DragGesture()
                                .onChanged({ value in
                                    if subject.isTapped {
                                        print(value.translation)
                                        viewModel.dragGestureTask(subject: subject, changed: value.translation)
                                    }
                                })
                                    .onEnded({ value in
                                        viewModel.accumulatedOffSet = .zero
                                    }))
                            .simultaneousGesture(RotateGesture()
                                .onChanged({ value in
                                    if subject.isTapped {
                                        if viewModel.current == .zero {
                                            viewModel.current = subject.getAngle()
                                        }
                                        viewModel.angle = value.rotation + viewModel.current
                                        subject.setAngle(angle: viewModel.angle)
                                    }
                                })
                                    .onEnded({ value in
                                        viewModel.current = .zero
                                    }))
                            .simultaneousGesture(MagnifyGesture()
                                .onChanged({ value in
                                    if subject.isTapped {
                                        viewModel.setScaleVolume(value.magnification, subject: subject)
                                    }
                                })
                                    .onEnded({ value in
                                        viewModel.setScaleValue(minimum: 0.2, maximum: 10, subject: subject)
                                    }))
                    }
                }
                /// 이미지가 아닌 경우, 즉 스티커 및 텍스트인 경우의 코드를 밑에 적어주세요
            }
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
                    
                    Text("프레임선택")
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
            
//            Button {
//                //                viewModel.reDo()
//            } label: {
//                Image("back")
//                    .colorMultiply(viewModel.indexOfImageList > 0 ? .black : .gray03)
//            }
//            .padding(.trailing, 14)
//            
//            Button {
//                //                viewModel.unDo()
//            } label: {
//                Image("front")
//                    .colorMultiply(viewModel.indexOfImageList < viewModel.imageList.count - 1 ? .black : .gray03)
//            }
//            .padding(.trailing, 60)
            
            Spacer()
                .frame(width: 150)
            Button {
                
                if let image = frameManager.resultImage {
                    
                    viewModel.isTappedImage = false
                    viewModel.saveStateText = "저장 중입니다..."
                    viewModel.isPushedSaveBtn = true
                    viewModel.saveImage(view: imageView, inputImage: image, context: managedContext) {
                        
                        viewModel.btnOpacity = 0
                        viewModel.showCamera = true
                        imageModel.imageList.removeAll()
                        
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
