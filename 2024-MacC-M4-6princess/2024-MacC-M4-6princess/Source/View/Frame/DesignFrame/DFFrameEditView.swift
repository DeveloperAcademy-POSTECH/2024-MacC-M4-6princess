import SwiftUI

enum Mode {
    case draw
    case eraser

    init?(rawValue: Int) {
        switch rawValue {
        case 0: self = .draw
        case 1: self = .eraser
        default: return nil
        }
    }
}

struct Line {
    var color: Color
    var points: [CGPoint]
    var mode: Mode
}


struct DFFrameEditView: View {
    
    @State private var picImage: UIImage?
    @State var selectionModeIndex: Int = 0
    @State var lines: [Line] = []
    @State private var lineWidth = 0.0
    @State private var isShow: Bool = false
    
    var body: some View {
        NavigationStack {
            
            ZStack {
                Color(.black)
                    .ignoresSafeArea()
                VStack {
                    HStack(alignment: .center) {
                        Button {
                            print("\(UIScreen.main.bounds.width) \(UIScreen.main.bounds.height)")
                        } label: {
                            HStack {
                                Image(systemName: "chevron.backward")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                                
                                Text("사진 선택")
                                    .fontWeight(.regular)
                                    .foregroundStyle(.white)
                            }
                        }
                        .frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.height / 20)
                        
                        Spacer()
                        
                        Button {
                            
                        } label: {
                            Image("back")
                        }
                        .padding(.trailing, 14)
                        
                        Button {
                            
                        } label: {
                            Image("front")
                        }
                        .padding(.trailing, 45)
                        
                        Spacer()
                        
                        NavigationLink {
                            
                        } label: {
                            Text("확인")
                                .fontWeight(.semibold)
                                .foregroundStyle(.pointPink)
                                .frame(width: UIScreen.main.bounds.width / 5, height: UIScreen.main.bounds.height / 20)
                        }
                        .padding(1)
                    }
                    ZStack {
                        Image("me")
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 1.3)
                            .padding(.bottom, 20)
                        Circle()
                            .stroke(.white)
                            .opacity(isShow ? 1 : 0)
                            .frame(width: lineWidth, height: lineWidth)
                        
                        VStack {
                            Spacer()
                            ZStack {
                                Rectangle()
                                    .fill(Color.black.opacity(0.5))
                                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 20)
                                Slider(
                                    value: $lineWidth,
                                    in: 0...50,
                                    step: 1
                                ) {
                                    Text("Title")
                                } minimumValueLabel: {
                                    Text("\(Int(lineWidth))")
                                        .foregroundStyle(.white)
                                } maximumValueLabel: {
                                    Text("")
                                } onEditingChanged: { editing in
                                    isShow = editing
                                    print("\(isShow)")
                                }
                                .accentColor(.pointPink)
                                .padding(.bottom, 20)
                                .padding([.leading, .trailing, .top], 10)
                            }
                            .onAppear() {
                                let thumbImage = ImageRenderer(content: Circle().frame(width: 16, height: 16).foregroundStyle(.white)).uiImage
                                UISlider.appearance().setThumbImage(thumbImage, for: .normal)
                            }
                        }
                    }
                    
                    HStack(spacing: UIScreen.main.bounds.width / 2.4) {
                        Button {
                            selectionModeIndex = 0
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "212121"))
                                    .frame(width: UIScreen.main.bounds.height / 20, height: UIScreen.main.bounds.height / 20)
                                Image("brush")
                                    .frame(width: UIScreen.main.bounds.height / 20, height: UIScreen.main.bounds.height / 20)
                                    .colorMultiply(selectionModeIndex == 0 ? Color(.pointPink) : Color(.white))
                                Text("브러쉬")
                                    .foregroundStyle(selectionModeIndex == 0 ? Color(.pointPink) : Color(.white))
                                    .font(.custom("Pretendard-medium", size: 13))
                                    .offset(y: 30)
                            }
                        }
                        
                        Button {
                            selectionModeIndex = 1
                            
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "212121"))
                                    .frame(width: UIScreen.main.bounds.height / 20, height: UIScreen.main.bounds.height / 20)
                                Image("erase")
                                    .frame(width: UIScreen.main.bounds.height / 20, height: UIScreen.main.bounds.height / 20)
                                    .colorMultiply(selectionModeIndex == 1 ? Color(.pointPink) : Color(.white))
                                Text("지우개")
                                    .foregroundStyle(selectionModeIndex == 1 ? Color(.pointPink) : Color(.white))
                                    .font(.custom("Pretendard-medium", size: 13))
                                    .offset(y: 30)
                            }
                        }

                    }
                }
            }
        }
    }
}

#Preview {
    DFFrameEditView()
}
