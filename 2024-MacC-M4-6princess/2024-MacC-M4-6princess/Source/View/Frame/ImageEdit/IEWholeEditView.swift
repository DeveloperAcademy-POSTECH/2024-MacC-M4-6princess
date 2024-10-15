//
//  PhotoEditingView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/9/24.
//
import SwiftUI
import Photos

// 이미지 편집 메인 화면
struct IEMainView: View {
    // 임의로 넣은 사진 데이터
    @State var bgImg = UIImage(named: "6princess")!
    @State var idolImg = UIImage(named: "Felix")!
    
    @ObservedObject var ievm = IEViewModel()
    
    var canvasView: some View {
        IECanvasView(ievm: ievm, bgImg: $bgImg, idolImg: $idolImg)
    }
    
    var body: some View {
        VStack {
            Spacer()
            // 이미지 리사이즈 뷰
            ZStack {
                VStack{
                    Spacer()
                    canvasView
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
            
            ToolbarItem(placement: .topBarTrailing) { // 사진 저장(테스트 위치)
                Button(action: {
                    ievm.saveRenderedView(content: canvasView)
                }) {
                    Text("완료")
                        .foregroundColor(.pointPink)
                }
            }
        }
        // 저장확인용 시트
        .sheet(isPresented: $ievm.isModal) {
            if let rendered = ievm.compositeImage {
                IEOutputImageView(image: rendered)
            }
        }
    }
    
}



#Preview {
    IEMainView()
}

