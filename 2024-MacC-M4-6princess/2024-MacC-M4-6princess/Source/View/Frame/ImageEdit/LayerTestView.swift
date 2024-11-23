import SwiftUI
import PhotosUI

struct LayerImage: Identifiable {
    let id = UUID()
    var image: UIImage
    var order: Int
    var position: CGPoint // 이미지 위치
    var scale: CGFloat = 1.0      // 이미지 크기
    var rotation: Angle = .zero   // 이미지 회전 각도
}

struct LayerTestView: View {
    @State var layerImages: [LayerImage] = []
    @State var showImagePicker: Bool = false
    @State var selectedLayerIndex: Int?
    
    @State private var activeDragOffset: CGSize = .zero // 드래그 이동값
    @State private var activeScale: CGFloat = 1.0       // 현재 확대/축소 값
    @State private var activeRotation: Angle = .zero    // 현재 회전 값
    
    @State private var isEditing: Bool = false // 에디팅 모드 활성화 여부
    
    var body: some View {
        ZStack {
            if isEditing{
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
            }
            ZStack {
                ForEach(layerImages.indices, id: \.self) { index in
                    let layer = layerImages[index]
                    Image(uiImage: layer.image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .position(layer.position)
                        .scaleEffect(layer.scale)
                        .rotationEffect(layer.rotation)
                        .overlay(
                            Text("Image \(layer.order)")
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.5))
                                .padding(5),
                            alignment: .bottom
                        )
                        .gesture(combinedGesture(for: index))
                        .onTapGesture {
                            selectedLayerIndex = index
                        }
                        .overlay(
                            LongPressGestureRecognizerWrapper(isEditing: $isEditing, selectedLayerIndex: $selectedLayerIndex, currentIndex: index)
                        )
                }
            }
            .frame(width: 300, height: 300)
            .padding()
            
            VStack {
                if isEditing {
                    Text("레이어를 위아래로 끌어서 변경할 수 있어요")
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .transition(.opacity)
                }
                Spacer()
                Button(action: {
                    showImagePicker = true
                }) {
                    Text("사진 추가")
                        .padding(8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .sheet(isPresented: $showImagePicker) {
            LayerPhotoPicker(layerImages: $layerImages, screenSize: UIScreen.main.bounds.size)
        }
    }
    
    private func combinedGesture(for index: Int) -> some Gesture {
        DragGesture()
            .onChanged { value in
                if selectedLayerIndex == index {
                    activeDragOffset = value.translation
                }
            }
            .onEnded { value in
                if selectedLayerIndex == index {
                    layerImages[index].position.x += activeDragOffset.width
                    layerImages[index].position.y += activeDragOffset.height
                    activeDragOffset = .zero
                }
            }
            .simultaneously(
                with: MagnificationGesture()
                    .onChanged { value in
                        if selectedLayerIndex == index {
                            activeScale = value
                        }
                    }
                    .onEnded { value in
                        if selectedLayerIndex == index {
                            layerImages[index].scale *= activeScale
                            activeScale = 1.0
                        }
                    }
            )
            .simultaneously(
                with: RotationGesture()
                    .onChanged { angle in
                        if selectedLayerIndex == index {
                            activeRotation = angle
                        }
                    }
                    .onEnded { angle in
                        if selectedLayerIndex == index {
                            layerImages[index].rotation += activeRotation
                            activeRotation = .zero
                        }
                    }
            )
    }
}
// UIKit의 LongPressGestureRecognizer를 SwiftUI에 통합
struct LongPressGestureRecognizerWrapper: UIViewRepresentable {
    @Binding var isEditing: Bool // 에디팅 모드 상태를 바인딩
    @Binding var selectedLayerIndex: Int? // 현재 선택된 레이어 인덱스를 바인딩
    var currentIndex: Int // 현재 레이어의 인덱스
    
    // UIView 생성 및 UILongPressGestureRecognizer 추가
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let gestureRecognizer = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleLongPress))
        view.addGestureRecognizer(gestureRecognizer) // 뷰에 제스처 연결
        view.isUserInteractionEnabled = true // 사용자 상호작용 활성화
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // UIView 업데이트 로직 (필요하지 않아 비워둠)
    }
    
    // Coordinator 생성
    func makeCoordinator() -> Coordinator {
        Coordinator(isEditing: $isEditing, selectedLayerIndex: $selectedLayerIndex, currentIndex: currentIndex)
    }
    
    // UILongPressGestureRecognizer 처리를 위한 Coordinator 클래스
    class Coordinator: NSObject {
        @Binding var isEditing: Bool // 에디팅 모드 상태를 바인딩
        @Binding var selectedLayerIndex: Int? // 현재 선택된 레이어 인덱스를 바인딩
        var currentIndex: Int // 현재 레이어의 인덱스
        
        // 초기화
        init(isEditing: Binding<Bool>, selectedLayerIndex: Binding<Int?>, currentIndex: Int) {
            _isEditing = isEditing
            _selectedLayerIndex = selectedLayerIndex
            self.currentIndex = currentIndex
        }
        
        // Long press 동작 처리 메서드
        @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
            if gestureRecognizer.state == .began {
                isEditing = true // 에디팅 모드 시작
                selectedLayerIndex = currentIndex // 현재 레이어 선택
            } else if gestureRecognizer.state == .ended {
                isEditing = false // 에디팅 모드 종료
            }
        }
    }
}
