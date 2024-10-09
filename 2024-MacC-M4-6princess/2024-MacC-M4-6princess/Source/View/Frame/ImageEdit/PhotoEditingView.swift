//
//  PhotoEditingView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/9/24.
//
import SwiftUI

struct PhotoEditingView: View {
    @State private var brightness: Double = 0.0
    @State private var selectedIndex: Int? = nil // 선택된 인덱스를 저장
    var backgroundImage = UIImage(named: "6princess")!
    var idolImage = UIImage(named: "Felix")!

    // 편집 옵션 데이터 구조체 정의
    struct EditingOption {
        let name: String
        let icon: String
    }

    // 편집 옵션 배열
    let options: [EditingOption] = [
        EditingOption(name: "밝기", icon: "sun.max.fill"),
        EditingOption(name: "채도", icon: "cloud.rainbow.half"),
        EditingOption(name: "대비", icon: "circle.lefthalf.fill")
    ]

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack {
                // 네비게이션 바
                HStack {
                    Text("< 사진 찍기")
                        .foregroundColor(.white)
                        .padding(.horizontal,5)
                    Spacer()
                    Button(action: {
                        // 뒤로가기
                    }) {
                        Image(systemName: "arrow.uturn.left")
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        // 앞으로가기
                    }) {
                        Image(systemName: "arrow.uturn.right")
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal)
                    Spacer()
                    Spacer()
                    Button(action: {
                        // 완료
                    }) {
                        Text("완료")
                            .foregroundColor(Color(hex: "E976DE"))
                    }
                }
                

                Spacer()

                // 이미지 리사이즈 뷰
                ZStack {
                    IETestResizeView(backgroundImage: backgroundImage, idolImage: idolImage)
                }

                HStack{
                    Text(String(format: "%.0f", brightness*100)) // 텍스트
                        .foregroundColor(.white)
                    
                    // 밝기 슬라이더
                    Slider(value: $brightness, in: 0...1, step: 0.01)
                        .padding()
                        .background(Color.black.opacity(0.2))
                    
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
                                    .foregroundColor(selectedIndex == index ? Color(hex: "E976DE") : .white) // 색상 설정
                                Text(options[index].name) // 텍스트
                                    .foregroundColor(selectedIndex == index ? Color(hex: "E976DE"): .white) // 텍스트 색상 설정
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
    }
}

#Preview {
    PhotoEditingView()
}


extension UIColor {
    convenience init?(hex: String) {
        let r, g, b: CGFloat
        
        var hexColor = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexColor = hexColor.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexColor).scanHexInt64(&rgb)
        
        r = CGFloat((rgb >> 16) & 0xFF) / 255.0
        g = CGFloat((rgb >> 8) & 0xFF) / 255.0
        b = CGFloat(rgb & 0xFF) / 255.0
        
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}

extension Color {
    init?(hex: String) {
        if let uiColor = UIColor(hex: hex) {
            self = Color(uiColor)
        } else {
            return nil
        }
    }
}
