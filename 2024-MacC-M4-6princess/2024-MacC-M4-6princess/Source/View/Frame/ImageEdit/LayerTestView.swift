//
//  LayerTestView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/13/24.
//
import SwiftUI

struct LayerTestView: View {
    // 이미지 파일명 배열
    let images = ["frameTest1", "frameTest2", "frameTest3", "frameTest4", "frameTest5"]
    
    // 현재 레이어 순서
    @State private var layerOrder: [Int] = [0, 1, 2, 3, 4]
    
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
            
            // 드래그 앤 드롭을 통한 순서 변경
            HStack {
                ForEach(layerOrder, id: \.self) { index in
                    let imageName = images[index]
                    Text("\(index + 1)")
                        .frame(width: 50, height: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .onDrag {
                            // 드래그할 때 전달할 데이터
                            NSItemProvider(object: "\(index)" as NSString)
                        }
                        .onDrop(of: [.text], isTargeted: nil) { providers in
                            handleDrop(providers: providers, targetIndex: index)
                        }
                }
            }
            .padding()
        }
    }
    
    // 드롭 이벤트 핸들링 함수
    private func handleDrop(providers: [NSItemProvider], targetIndex: Int) -> Bool {
        guard let itemProvider = providers.first else { return false }
        
        itemProvider.loadObject(ofClass: NSString.self) { object, _ in
            DispatchQueue.main.async {
                if let fromIndexString = object as? String,
                   let fromIndex = Int(fromIndexString),
                   fromIndex != targetIndex {
                    
                    // 드래그된 아이템의 위치를 새로운 위치로 이동
                    withAnimation {
                        layerOrder.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: targetIndex > fromIndex ? targetIndex + 1 : targetIndex)
                    }
                }
            }
        }
        
        return true
    }
}

struct LayerTestView_Previews: PreviewProvider {
    static var previews: some View {
        LayerTestView()
    }
}
