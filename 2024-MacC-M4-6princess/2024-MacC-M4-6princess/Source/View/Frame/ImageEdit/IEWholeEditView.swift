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
    @State var rendered:UIImage?
    
    // 편집 옵션 배열
    let colorEdit: [EditingOption] = [
        EditingOption(name: "밝기", icon: "sun.max.fill",range:-1...1,step: 0.1),
        EditingOption(name: "채도", icon: "cloud.rainbow.half",range: 0...2,step: 0.1),
        EditingOption(name: "대비", icon: "circle.lefthalf.fill",range: 0.5...2,step: 0.1)
    ]
    
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            VStack {
                
                Spacer()
                
                // 이미지 리사이즈 뷰
                ZStack {
                    IETestResizeView(ievm: ievm, bgImg: $bgImg, idolImg: $idolImg)
                }
                
                if let idx = ievm.selectedIndex{
                    SliderView(value: $ievm.sliderValues[idx], range: colorEdit[idx].range, step: colorEdit[idx].step)
                }
                
                // 편집 옵션 버튼들
                HStack {
                    Spacer()
                    ForEach(0..<colorEdit.count, id: \.self) { index in
                        ZStack{
                            Circle()
                                .fill(Color(hex: "212121") ?? Color.gray)
                                .frame(width: 60)
                            
                            VStack {
                                Image(systemName: colorEdit[index].icon) // 아이콘
                                    .foregroundColor(ievm.selectedIndex == index ? .pointPink : .white) // 색상 설정
                                Text(colorEdit[index].name) // 텍스트
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
        }
        
        //MARK: 위치를 잡기가 어려워요
        .toolbar{
            ToolbarItem(placement: .automatic){
                
                Button(action: {
                    // 뒤로가기
                }) {
                    Image(systemName: "arrow.uturn.left")
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
            }
            
            ToolbarItem(placement: .automatic){
                
                
                Button(action: {
                    // 앞으로가기
                }) {
                    Image(systemName: "arrow.uturn.right")
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
                
            }
            
            ToolbarItem(placement: .topBarTrailing){
                
                
                Button(action: {
                    
                    rendered=ievm.renderAndSaveImage(backgroundImage: bgImg, idolImage: idolImg)
                    
                }) {
                    Text("완료")
                        .foregroundColor(.pointPink)
                }
            }
        }
        .sheet(isPresented:$ievm.isModal){
            if let rendered=rendered{
                IEOutputImageView(image: rendered)
            }
        }
    }
}


#Preview {
    IEWholeEditView()
}

