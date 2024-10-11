//
//  PhotoEditingView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/9/24.
//
import SwiftUI

struct IEWholeEditView: View {
    @State private var brightness: Double = 0.0
    @State private var selectedIndex: Int? = nil // 선택된 인덱스를 저장
    @State var backgroundImage = UIImage(named: "6princess")!
    @State var idolImage = UIImage(named: "Felix")!
    @ObservedObject var viewModel = IEViewModel()
    @State var renderedImg:UIImage?
    
    // 편집 옵션 데이터 구조체 정의
    struct EditingOption {
        let name: String
        let icon: String
        let range: ClosedRange<Float>
        var step: Float
    }
    

    // 편집 옵션 배열
    let options: [EditingOption] = [
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
                    IETestResizeView(viewModel: viewModel, backgroundImg: $backgroundImage, idolImg: $idolImage)
                }
                
//                SliderView()
                if let idx = selectedIndex{
                    SliderView(value: $viewModel.sliders[idx], range: options[idx].range, step: options[idx].step)
                }
                // 편집 옵션 버튼들
                HStack {
                    Spacer()
                    ForEach(0..<options.count, id: \.self) { index in
                        ZStack{
                            Circle()
                                .fill(Color(hex: "212121") ?? Color.gray)
                                .frame(width: 60)
                            
                            VStack {
                                Image(systemName: options[index].icon) // 아이콘
                                    .foregroundColor(selectedIndex == index ? .pointPink : .white) // 색상 설정
                                Text(options[index].name) // 텍스트
                                    .foregroundColor(selectedIndex == index ? .pointPink : .white) // 텍스트 색상 설정
                            }
                            
                            .onTapGesture {
                                selectedIndex = index // 선택된 인덱스 업데이트
                            }
                        }
                        .padding(.horizontal)
                        Spacer()
                        
                    }
                }
                .padding()
            }
        }
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
                    
                     renderedImg=viewModel.renderAndSaveImage(backgroundImage: backgroundImage, idolImage: idolImage)
                    
                }) {
                    Text("완료")
                        .foregroundColor(.pointPink)
                }
            }
        }
        .sheet(isPresented:$viewModel.isModal){
            if let rendered=renderedImg{
                IEOutputImageView(image: rendered)
            }
        }
    }
}

struct IEOutputImageView: View {
    var image: UIImage
    
    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
            
        }
        
    }
}
struct SliderView: View {
    @Binding var value: Float// 슬라이더 값
    var range: ClosedRange<Float> // 슬라이더 범위
    var step: Float // 슬라이더 단계
    
    var body: some View {
        HStack {
            Text(String(format: "%.0f", value * 100)) // 텍스트 (밝기 퍼센트)
                .foregroundColor(.white)
            
            // 슬라이더
            Slider(value: $value, in: range, step: Float.Stride(step))
                .padding()
                .foregroundColor(.pointPink) // 슬라이더 색상
                .background(Color.black.opacity(0.2)) // 배경색
        }
    }
}
#Preview {
    IEWholeEditView()
}

