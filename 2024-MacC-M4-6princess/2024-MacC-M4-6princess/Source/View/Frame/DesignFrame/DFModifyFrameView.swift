import SwiftUI
import CoreData

struct DFModifyFrame: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.managedObjectContext) var managedContext
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
    @State private var btnOpacity: Double = 0.0
//    @FetchRequest(
//      entity: StoreImages.entity(),
//      sortDescriptors: [
//        NSSortDescriptor(keyPath: \StoreImages.image, ascending: true)
//      ],
//      predicate: NSPredicate(format: "genre contains 'Action'")
//    ) var images: FetchedResults<StoreImages>
    
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
            .gesture(drag.simultaneously(with: magnification).simultaneously(with: rotate))
        //            .gesture(magnification)
        //            .gesture(rotate)
        
    }
    var body: some View {
        let combined = magnification.sequenced(before: rotate)
        NavigationStack {
            VStack {
                ZStack {
                    if let image = resultImage {
                        Color(hex: "32322f")
                            .frame(width: UIScreen.main.bounds.width, height: image.size.height / scaleCompute(image))
                        imageView
                            .gesture(combined)
                            .mask(Rectangle().frame(width: UIScreen.main.bounds.width, height: image.size.height / scaleCompute(image)))
                        //                    Color(.white)
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color.white)
                            .opacity(btnOpacity)
                            .frame(width: 175, height: 38)
                            .overlay(Text("프레임이 저장되었습니다.").foregroundStyle(.black).font(.footnote).opacity(btnOpacity))
                        
                    }
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
                    addImage(data: image?.pngData())
                    btnOpacity = 1
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                      btnOpacity = 0
                    }
                    isShow = true
//                    print("\(images.count)")
                    
                } label: {
                    Text("저장")
                        .fontWeight(.semibold)
                        .foregroundStyle(.pointPink)
                        .frame(width: UIScreen.main.bounds.width / 5, height: UIScreen.main.bounds.height / 20)
                }
                .padding(1)
            }
        }
        .navigationDestination(isPresented: $isShow) {
            CameraView()
        }
    }
    func scaleCompute(_ image: UIImage) -> CGFloat {
        let scale = image.size.width / UIScreen.main.bounds.width
        return scale
    }
    
    func saveContext() {
        do {
            try managedContext.save()
        } catch {
            print("Error saving managed object context: \(error)")
        }
    }
    func addImage(data: Data?) {
//        let context = managedContext
//        
//        // 현재 저장된 이미지의 개수를 확인
//        let fetchRequest: NSFetchRequest<StoreImages> = StoreImages.fetchRequest()
//        let count = (try? context.count(for: fetchRequest)) ?? 0
        
        let newImage = StoreImages(context: managedContext)
        newImage.image = data
        newImage.uuid = UUID()
        newImage.isSelected = false
//        newImage.order = Int32(count)  현재 개수를 order로 사용
        
        print("이미지 코어에 저장됨")
        saveContext()
    }
}

extension CGSize {
    static func + (lhs: Self, rhs: Self) -> Self {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
}
