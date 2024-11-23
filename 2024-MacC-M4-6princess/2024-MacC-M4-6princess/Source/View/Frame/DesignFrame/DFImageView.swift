import SwiftUI

struct DFImageView: View {
    
    var subjectModel: SubjectImage
    @StateObject var viewModel: DFImageViewModel = DFImageViewModel()
//    @ObservedObject var viewModel: DFImageViewModel = DFImageViewModel()
    
    var body: some View {
        
        ZStack{
//            
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
                    .gesture(magnification.simultaneously(with: moveImage).simultaneously(with: rotate).simultaneously(with: tap))
                
            }
            
        }
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
                print("오 클릭되었소")
            } label: {
                Circle()
                    .foregroundStyle(Color.gray)
                    .frame(width: 20, height: 20)
            }
            .offset(viewModel.OffsetCompute(x: -viewModel.width/2, y: -viewModel.height/2))
            
            Button {
                print("좋아요")
            } label: {
                Circle()
                    .foregroundStyle(Color.gray)
                    .frame(width: 20, height: 20)
            }
            .offset(viewModel.OffsetCompute(x: viewModel.width/2, y: -viewModel.height/2))
            
            Button {
                print("허허")
            } label: {
                Circle()
                    .foregroundStyle(Color.gray)
                    .frame(width: 20, height: 20)
                
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
                viewModel.angle = value.rotation + viewModel.current
            }
            .onEnded { value in
                viewModel.current += value.rotation
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
