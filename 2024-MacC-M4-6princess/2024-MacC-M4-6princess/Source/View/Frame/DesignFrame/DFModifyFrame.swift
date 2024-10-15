import SwiftUI

struct DFModifyFrame: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var resultImage: UIImage?
    @State private var draggedOffset = CGSize.zero
    @State private var accumulatedOffset = CGSize.zero
    @State private var image: UIImage?
    @State private var isShow: Bool = false
    @State private var currentSize = 0.0
    @State private var finalSize = 1.0
    @State private var currentAngle = Angle.zero
    @State private var finalAngle = Angle.zero
    @State private var isZoom: Bool = true
    
    var rotate: some Gesture {
        RotateGesture()
             .onChanged { value in
                 currentAngle = value.rotation
             }
             .onEnded { value in
                 withAnimation {
                     finalAngle += currentAngle
                     currentAngle = .zero
                     isZoom = true
                 }
             }
    }
    
    var magnification: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                currentSize = value.magnification - 1
            }
            .onEnded { value in
                withAnimation {
                    finalSize += currentSize
                    currentSize = 0
                    isZoom = false
                }
            }
    }
    
    var drag: some Gesture {
        DragGesture()
            .onChanged { gesture in
                print("\(draggedOffset.width) \(draggedOffset.height)")
                print("\(UIScreen.main.bounds.width), \(resultImage!.size.height / scaleCompute(resultImage!))")
                draggedOffset = accumulatedOffset + gesture.translation
            }
            .onEnded { gesture in
                accumulatedOffset = accumulatedOffset + gesture.translation
            }
    }
    var imageView: some View {
        Image(uiImage: resultImage ?? UIImage())
            .resizable()
            .scaledToFit()
            .frame(width: UIScreen.main.bounds.width, height: resultImage!.size.height / scaleCompute(resultImage!))
            .padding(.bottom, 20)
            .offset(draggedOffset)
            .scaleEffect(finalSize + currentSize)
            .rotationEffect(currentAngle + finalAngle)
            .gesture(drag)
//            .gesture(magnification)
//            .gesture(rotate)
        
    }
    var body: some View {
        let combined = magnification.sequenced(before: rotate)
        VStack {
            ZStack {
                if let image = resultImage {
                    Color(hex: "32322f")
                        .frame(width: UIScreen.main.bounds.width, height: image.size.height / scaleCompute(image))
                    imageView
                        .gesture(combined)
                        .mask(Rectangle().frame(width: UIScreen.main.bounds.width, height: image.size.height / scaleCompute(image)))
                    //                    Color(.white)
                }
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            HStack {
                Button {
                    self.presentationMode.wrappedValue.dismiss()
                    print("\(UIScreen.main.bounds.width) \(UIScreen.main.bounds.height)")
                } label: {
                    HStack {
                        Image(systemName: "chevron.backward")
                            .fontWeight(.semibold)
                            .foregroundStyle(.gray01)
                        
                        Text("배경 수정")
                            .fontWeight(.regular)
                            .foregroundStyle(.gray01)
                    }
                }
                .frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.height / 20)
                
                Spacer(minLength: UIScreen.main.bounds.width / 20)
                
                Button {
                } label: {
                    Image("back")
                }
                .padding(.trailing, 14)
                
                Button {
                } label: {
                    Image("front")
                }
                .padding(.trailing, 60)
                
                Spacer()
                Button {
                    let render = ImageRenderer(content: self.imageView.frame(width: UIScreen.main.bounds.width, height: resultImage!.size.height / scaleCompute(resultImage!)))
                    render.scale = scaleCompute(resultImage!)
                    image = render.uiImage
                    isShow = true
                    
                } label: {
                    Text("저장")
                        .fontWeight(.semibold)
                        .foregroundStyle(.pointPink)
                        .frame(width: UIScreen.main.bounds.width / 5, height: UIScreen.main.bounds.height / 20)
                }
                .padding(1)
            }
        }
        .sheet(isPresented: $isShow) {
            ResultView(image: $image)
        }
    }
    func scaleCompute(_ image: UIImage) -> CGFloat {
        let scale = image.size.width / UIScreen.main.bounds.width
        return scale
    }
}

extension CGSize {
    static func + (lhs: Self, rhs: Self) -> Self {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
}
