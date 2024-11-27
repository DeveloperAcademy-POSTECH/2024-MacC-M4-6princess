import SwiftUI

struct DFOverlayBoxView: View {
    
    @EnvironmentObject var naviManager: NavigationManager
    @EnvironmentObject var frameManager: FrameManager
    @EnvironmentObject var imageModel: ImageListModel
    @ObservedObject var viewModel: DFOverlayBoxViewModel = DFOverlayBoxViewModel()
    @Binding var model: SubjectImage
    var size: CGSize
    
    var body: some View {
        
        ZStack {
            
            
            Rectangle()
                .stroke(Color.white)
                .frame(width: size.width, height: size.height)
                .scaleEffect(model.getScale())
                .rotationEffect(model.getAngle())
                .offset(model.getOffset())
            
            if let realImage = model.originalImage {
                
                Button {
                    
                    frameManager.pickedImage = realImage
                    frameManager.changedSubject = model
                    naviManager.push(screen: Screen.frameEdit)
                    
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
                .offset(viewModel.OffsetCompute(x: -size.width/2, y: -size.height/2, subject: model))
            }
            
            Button {
                imageModel.imageList.removeAll(where: { $0.id == model.id })
                
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
            .offset(viewModel.OffsetCompute(x: size.width/2, y: -size.height/2, subject: model))
            
//            Button {
//                viewModel.isPushedZoom = true
//            } label: {
//                ZStack {
//                    
//                    Circle()
//                        .foregroundStyle(Color.white)
//                        .frame(width: 26, height: 26)
//                    Image("zoomButton")
//                        .resizable()
//                        .frame(width: 20, height: 20)
//                }
//                
//            }
//            .offset(viewModel.OffsetCompute(x: size.width/2, y: size.height/2, subject: model))
//            .gesture(zoomDrag)
        }
        
    }
}

private extension DFOverlayBoxView {
    
    var zoomDrag: some Gesture {
        DragGesture()
            .onChanged { value in
                if value.translation.width > 0 && value.translation.height > 0 {
                    model.scale *= 1.00003
                } else {
                    model.scale /= 1.00003
                }
            }
            .onEnded { value in
                if model.scale < 0.2 {
                    model.scale = 0.2
                    model.offset = .zero
                } else if model.scale > 10 {
                    model.scale = 10
                }
            }
    }
}
