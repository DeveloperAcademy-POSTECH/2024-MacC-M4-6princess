import SwiftUI

struct LayerTestView: View {
    // 이미지 파일명 배열
    let images = ["frameTest1", "frameTest2", "frameTest3", "frameTest4", "frameTest5"]
    
    // 현재 레이어 순서
    @State private var layerOrder: [Int] = [0, 1, 2, 3, 4]
    @State private var isEditing: Bool = false
    
    var body: some View {
        VStack {
            // ZStack으로 레이어 순서대로 이미지 표시
            ZStack {
                ForEach(layerOrder, id: \.self) { index in
                    let imageName = images[index]
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                        .overlay(
                            Text(imageName)
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.5))
                                .padding(5),
                            alignment: .bottom
                        )
                }
            }
            .frame(width: 300, height: 300)
            .background(Color.gray.opacity(0.2))
            .border(Color.black, width: 1)
            .padding()
            
            // EditButton과 List를 사용한 순서 변경
            HStack {
                EditButton()
                Spacer()
                Text(isEditing ? "Editing" : "Not Editing")
                Spacer()
            }
            .padding()
            
            List {
                ForEach(layerOrder, id: \.self) { index in
                    HStack {
                        Text("Image \(index + 1)")
                        Spacer()
                    }
                }
                .onMove { indices, newOffset in
                    layerOrder.move(fromOffsets: indices, toOffset: newOffset)
                }
            }
            .environment(\.editMode, .constant(isEditing ? .active : .inactive))
            .onAppear {
                self.isEditing = true
            }
        }
    }
}

struct LayerTestView_Previews: PreviewProvider {
    static var previews: some View {
        LayerTestView()
    }
}
