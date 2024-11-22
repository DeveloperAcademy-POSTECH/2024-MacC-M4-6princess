import SwiftUI
import Foundation
import CoreData

struct DFFrameModifyView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.managedObjectContext) var managedContext: NSManagedObjectContext
    @StateObject var viewModel: DFFrameModifyViewModel = DFFrameModifyViewModel()
    @State private var isFirstLaunching: Bool = true
    //    @Binding var resultImage: UIImage?
    //    @State private var shouldNavigate: Bool = false
    @EnvironmentObject var naviManager: NavigationManager
    @EnvironmentObject var frameManager: FrameManager
    
    var body: some View {
        
        ZStack {
            if isFirstLaunching == true {
                DFOnboardingView(isFirstLaunching: $isFirstLaunching)
                    .zIndex(1)
            }
            
            VStack {
                ZStack {
                    Color(hex: "32322f")
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 4/3)
                    
                    imageView
                        .mask(Rectangle().frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 4/3))
                    
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.white)
                        .opacity(viewModel.btnOpacity)
                        .frame(width: 175, height: 38)
                        .overlay(Text("\(viewModel.saveStateText)").foregroundStyle(.black).font(.footnote).opacity(viewModel.btnOpacity))
                    
                }
                DFImageDecoView(viewModel: viewModel)
                    .padding(.top, 58)
            }
            
            if viewModel.showTextView {
                DFTextView(viewModel: viewModel)
            }
        }
        .sheet(isPresented: $viewModel.showStickerSheet) {
                    DFStickerView()
                        .presentationDetents([.fraction(0.5)]) // 화면의 절반만 차지
                        .presentationDragIndicator(.visible) // 드래그 인디케이터 표시
                }
        //        .navigationDestination(isPresented: $viewModel.isShowImagePickerView, destination: {
        //            PhotosPickerView()
        //        })
        .navigationBarBackButtonHidden()
        .toolbar {
            toolBarButtons
        }
        .onChange(of: viewModel.isShowCamera) { newValue in
            if newValue {
                // 1초 후에 화면 전환
                DispatchQueue.main.async() {
                    //                    shouldNavigate = true
//                    frameManager.isFrameSelect = false
                    naviManager.popToRoot()
                    frameManager.showMFView = false
                }
            }
        }
        //        .fullScreenCover(isPresented: $shouldNavigate) {
        //            CameraView(frameImage: $viewModel.frameImage)
        //            //            CameraView(frameImage: $resultImage)
        //        }
        .onAppear {
            Task {
                if let image = frameManager.resultImage {
                    viewModel.detectSubject(inputImage: image)
                    try await Task.sleep(for: .seconds(1))
                    try await viewModel.makeImageList()
                }
            }
        }
    }
}

private extension DFFrameModifyView {
    
    var rotate: some Gesture {
        
        RotateGesture()
            .onChanged { value in
                viewModel.angle = value.rotation + viewModel.current
            }
            .onEnded { value in
                viewModel.current += value.rotation
                viewModel.makeHistory()
            }
    }
    var moveImage: some Gesture {
        
        DragGesture()
            .onChanged { value in
                viewModel.draggedOffSet.width = viewModel.accumulatedOffSet.width + value.translation.width
                viewModel.draggedOffSet.height = viewModel.accumulatedOffSet.height + value.translation.height
                
            }
            .onEnded { value in
                viewModel.accumulatedOffSet.width = viewModel.accumulatedOffSet.width + value.translation.width
                viewModel.accumulatedOffSet.height = viewModel.accumulatedOffSet.height + value.translation.height
                print(viewModel.draggedOffSet)
                
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
}

private extension DFFrameModifyView {
    
    var imageView: some View {
        
        ZStack {
            
            ForEach(viewModel.imageHistory, id: \.self) { subject in
                
                if let image = subject.image, let realImage = frameManager.resultImage {
                    
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: image.size.width / viewModel.scaleCompute(realImage), height: image.size.height / viewModel.scaleCompute(realImage))
                        .scaleEffect(viewModel.magnifyScale)
                        .rotationEffect(viewModel.angle)
                        .offset(viewModel.draggedOffSet)
                        .gesture(magnification.simultaneously(with: moveImage).simultaneously(with: rotate))
                    
                }
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
                    
                    Text("프레임선택")
                        .fontWeight(.regular)
                        .foregroundStyle(.gray01)
                }
            }
            .frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.height / 20)
            
            Spacer(minLength: UIScreen.main.bounds.width / 20)
            
            Button {
                viewModel.reDo()
                print(viewModel.draggedOffSet)
            } label: {
                Image("back")
                    .colorMultiply(viewModel.indexOfImageList > 0 ? .black : .gray03)
            }
            .padding(.trailing, 14)
            
            Button {
                viewModel.unDo()
                print(viewModel.draggedOffSet)
            } label: {
                Image("front")
                    .colorMultiply(viewModel.indexOfImageList < viewModel.imageList.count - 1 ? .black : .gray03)
            }
            .padding(.trailing, 60)
            
            Spacer()
            Button {
                
                if let image = frameManager.resultImage {
                    viewModel.saveStateText = "저장 중입니다..."
                    viewModel.isPushedSaveBtn = true
                    viewModel.saveImage(view: imageView, inputImage: image, context: managedContext)
                    
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
