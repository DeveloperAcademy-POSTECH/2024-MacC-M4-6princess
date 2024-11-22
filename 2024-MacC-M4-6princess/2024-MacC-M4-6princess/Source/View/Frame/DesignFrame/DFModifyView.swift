import SwiftUI
import Foundation
import CoreData

struct DFModifyView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.managedObjectContext) var managedContext
    @EnvironmentObject var imageModel: ImageListModel
    
    @StateObject var viewModel: DFModifyViewModel = DFModifyViewModel()
    
    @State private var isFirstLaunching: Bool = true
    @Binding var resultImage: UIImage?
    @Binding var realImage: UIImage?
    @State private var shouldNavigate: Bool = false
    
    var body: some View {
        
        ZStack {
            if isFirstLaunching == true {
                DFOnboardingView(isFirstLaunching: $isFirstLaunching)
                    .zIndex(1)
            }
            
            VStack {
                ZStack {
                    Color(Color.background)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 4/3)
                    
                    imageView
                        .mask(Rectangle().frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 4/3))
                    
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.white)
                        .opacity(viewModel.btnOpacity)
                        .frame(width: 175, height: 38)
                        .overlay(Text("\(viewModel.saveStateText)").foregroundStyle(.black).font(.footnote).opacity(viewModel.btnOpacity))
                    
                }
                DFImageDecoView(showImagePickerView: $viewModel.showImagePickerView)
                    .padding(.top, 58)
            }
        }
        .navigationDestination(isPresented: $viewModel.showImagePickerView, destination: {
            PhotosPickerView()
        })
        .navigationBarBackButtonHidden()
        .toolbar {
            toolBarButtons
        }
        .onChange(of: viewModel.showCamera) { newValue in
            if newValue {
                // 1초 후에 화면 전환
                DispatchQueue.main.async() {
                    shouldNavigate = true
                }
            }
        }
        .fullScreenCover(isPresented: $shouldNavigate) {
            CameraView(frameImage: $viewModel.frameImage)
        }
        .onAppear {
            
            if let image = resultImage {
                
                viewModel.makeImageList()
                
            }
        }
    }
}

private extension DFModifyView {
    
    var imageView: some View {
        
        ZStack {
            ForEach(imageModel.imageList, id: \.self) { subject in
                
                DFImageView(subjectModel: subject)
                
            }
            
        }
    }
    
    var toolBarButtons: some View {
        HStack {
            Button {
                imageModel.imageList.removeAll()
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
                //                viewModel.reDo()
            } label: {
                Image("back")
                    .colorMultiply(viewModel.indexOfImageList > 0 ? .black : .gray03)
            }
            .padding(.trailing, 14)
            
            Button {
                //                viewModel.unDo()
            } label: {
                Image("front")
                    .colorMultiply(viewModel.indexOfImageList < viewModel.imageList.count - 1 ? .black : .gray03)
            }
            .padding(.trailing, 60)
            
            Spacer()
            Button {
                
                if let image = resultImage {
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
