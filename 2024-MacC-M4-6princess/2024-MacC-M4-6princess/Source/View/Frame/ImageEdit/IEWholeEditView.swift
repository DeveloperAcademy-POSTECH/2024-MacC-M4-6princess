//
//  PhotoEditingView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/9/24.
//
import SwiftUI

struct IEWholeEditView: View {
    @State var bgImg = UIImage(named: "6princess")!
    @State var idolImg = UIImage(named: "Felix")!
    @ObservedObject var ievm = IEViewModel()
    
    var resizeView: some View {
            IETestResizeView(ievm: ievm, bgImg: $bgImg, idolImg: $idolImg)
        }
    
    var body: some View {
        VStack {
            Spacer()
            // 이미지 리사이즈 뷰
            ZStack {
                VStack{
                    Spacer()
                    resizeView
                    Spacer()
                }
                    
            }
            if let idx = ievm.selectedIndex {
                SliderView(value: $ievm.sliderValues[idx], range: ievm.colorEdit[idx].range, step: ievm.colorEdit[idx].step)
            }
            
            // 편집 옵션 버튼들
            HStack {
                Spacer()
                ForEach(0..<ievm.colorEdit.count, id: \.self) { index in
                    ZStack {
                        Circle()
                            .fill(Color(hex: "212121") ?? Color.gray)
                            .frame(width: 60)
                        
                        VStack {
                            Image(systemName: ievm.colorEdit[index].icon) // 아이콘
                                .foregroundColor(ievm.selectedIndex == index ? .pointPink : .white) // 색상 설정
                            Text(ievm.colorEdit[index].name) // 텍스트
                                .foregroundColor(ievm.selectedIndex == index ? .pointPink : .white) // 텍스트 색상 설정
                        }
                        .onTapGesture {
                            ievm.selectedIndex = index // 선택된 인덱스 업데이트
                        }
                    }
                    .padding(.horizontal)
                    Spacer()
                }
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    // 뒤로가기
                }) {
                    Image(systemName: "arrow.uturn.left")
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
            }
            
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    // 앞으로가기
                }) {
                    Image(systemName: "arrow.uturn.right")
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    saveRenderedView()
                }) {
                    Text("완료")
                        .foregroundColor(.pointPink)
                }
            }
        }
        .sheet(isPresented: $ievm.isModal) {
            if let rendered = ievm.rendered {
                IEOutputImageView(image: rendered)
            }
        }
    }
    func saveRenderedView() {
           
           // 전체 뷰의 크기를 사용하여 ImageRenderer 초기화
        let renderer = ImageRenderer(content: resizeView.frame(width: ievm.screenSize.width,height: ievm.screenSize.width * ievm.bgRatio))
//        renderer.scale = 3.0
        renderer.scale = UIScreen.main.scale
           
           if let uiImage = renderer.uiImage {
               ievm.rendered = uiImage
               // 여기서 이미지를 저장하거나 공유할 수 있습니다.
               ievm.isModal = true
           }
        else{
            print("렌더링실패")
        }
       }
    
   
}



#Preview {
    IEWholeEditView()
}

