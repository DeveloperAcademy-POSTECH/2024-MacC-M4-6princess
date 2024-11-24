import SwiftUI

struct DFImageView: View {
    
    @Binding var subjectModel: SubjectImage
    @StateObject var viewModel: DFImageViewModel = DFImageViewModel()
    @EnvironmentObject var naviManager: NavigationManager
    @EnvironmentObject var frameManager: FrameManager
//    @ObservedObject var viewModel: DFImageViewModel = DFImageViewModel()
    
    var body: some View {
        
        ZStack{
            
            if let image = subjectModel.image, let realImage = subjectModel.originalImage {
                
                overlayRect
                    .opacity(viewModel.isTappedImage ? 1 : 0)
                    .zIndex(1)
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: image.size.width / viewModel.scaleCompute(realImage), height: image.size.height / viewModel.scaleCompute(realImage))
                    .scaleEffect(viewModel.magnifyScale)
                    .rotationEffect(viewModel.angle)
                    .offset(viewModel.draggedOffSet)
                    .opacity(viewModel.isPushedDeleteButton ? 0 : 1)
//                    .offset(subjectModel.offSet)
                
            }
            
        }
        .gesture(rotate.simultaneously(with: moveImage).simultaneously(with: magnification).simultaneously(with: tap))
        .onAppear {
            
            if let image = subjectModel.image, let realImage = subjectModel.originalImage {
                viewModel.width = image.size.width / viewModel.scaleCompute(realImage)
                viewModel.height = image.size.height / viewModel.scaleCompute(realImage)
            }
        }
        
    }
}

private extension DFImageView {
    
    var overlayRect: some View {
        
        ZStack {
            
            Rectangle()
                .stroke(Color.white)
                .frame(width: viewModel.width, height: viewModel.height)
                .scaleEffect(viewModel.magnifyScale)
                .rotationEffect(viewModel.angle)
                .offset(viewModel.draggedOffSet)
            
            Button {
                if let realImage = subjectModel.originalImage {
                    frameManager.pickedImage = realImage
                    naviManager.push(screen: Screen.frameEdit)
                    
                }
                
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 13)
                        .foregroundStyle(Color.white)
                        .frame(width: 40, height: 26)
                    Text("수정")
                        .font(.footnote)
                        .foregroundStyle(Color.black)
                }
            }
            .offset(viewModel.OffsetCompute(x: -viewModel.width/2, y: -viewModel.height/2))
            
            Button {
                viewModel.isPushedDeleteButton.toggle()
                viewModel.isTappedImage = false
                
            } label: {
                ZStack {
                    Circle()
                        .foregroundStyle(Color.white)
                        .frame(width: 26, height: 26)
                    Image(systemName: "xmark")
                        .foregroundStyle(Color.black)
                        .frame(width: 20, height: 20)
                }
            }
            .offset(viewModel.OffsetCompute(x: viewModel.width/2, y: -viewModel.height/2))
            
            Button {
                print("허허")
            } label: {
                ZStack {
                    
                    Circle()
                        .foregroundStyle(Color.white)
                        .frame(width: 26, height: 26)
                    Image("zoomButton")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                
            }
            .offset(viewModel.OffsetCompute(x: viewModel.width/2, y: viewModel.height/2))
        }
    }
}

private extension DFImageView {
    
    
        
    var tap: some Gesture {
        
        TapGesture()
            .onEnded { _ in
                print("tapped")
                viewModel.isTappedImage.toggle()
            }
    }
    
    var rotate: some Gesture {
        
        RotateGesture()
        
            .onChanged { value in
                if viewModel.isTappedImage {
                    viewModel.angle = value.rotation + viewModel.current
                    
                    print(viewModel.angle.degrees)
                }
            }
            .onEnded { value in
                if viewModel.isTappedImage {
                    viewModel.current += value.rotation
                }
            }
    }
    var moveImage: some Gesture {
        
        DragGesture()
            .onChanged { value in
                if viewModel.isTappedImage {
                    viewModel.draggedOffSet.width = (viewModel.accumulatedOffSet.width + value.translation.width)
                    viewModel.draggedOffSet.height = (viewModel.accumulatedOffSet.height + value.translation.height)
                }
                
            }
            .onEnded { value in
                if viewModel.isTappedImage {
                    viewModel.accumulatedOffSet.width = viewModel.accumulatedOffSet.width + value.translation.width
                    viewModel.accumulatedOffSet.height = viewModel.accumulatedOffSet.height + value.translation.height
                }
            }
        
    }
    
    var magnification: some Gesture {
        
        MagnifyGesture()
            .onChanged { value in
                if viewModel.isTappedImage {
                    viewModel.setScaleVolume(value.magnification)
                }
            }
            .onEnded { value in
                if viewModel.isTappedImage {
                    viewModel.setScaleValue(minimum: 0.2, maximum: 10)
                }
            }
    }
}
