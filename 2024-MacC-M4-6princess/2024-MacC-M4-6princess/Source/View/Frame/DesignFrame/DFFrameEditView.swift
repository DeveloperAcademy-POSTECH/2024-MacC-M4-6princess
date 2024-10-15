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
                                .frame(width: UIScreen.main.bounds.width / 5, height: UIScreen.main.bounds.height / 20)
                        }
                        .padding(1)
                    }
                    ZStack {
                        Image("me")
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 1.3)
                            .padding(.bottom, 20)
                        
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
                                }
                                .accentColor(.pink)
                                .padding(.bottom, 20)
                                .padding([.leading, .trailing, .top], 10)
                            }
                        }
                    }
                    
                    HStack(spacing: UIScreen.main.bounds.width / 2.4) {
                        Button {
                            selectionModeIndex = 0
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "212121"))                            .frame(width: UIScreen.main.bounds.height / 20, height: UIScreen.main.bounds.height / 20)
                                Image("brush")
                                    .frame(width: UIScreen.main.bounds.height / 20, height: UIScreen.main.bounds.height / 20)
                                Text("브러쉬")
                                    .font(.custom("Pretendard-medium", size: 13))
                                    .offset(y: 30)
                            }
                        }
                        
                        Button {
                            selectionModeIndex = 1
                            
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "212121"))                            .frame(width: UIScreen.main.bounds.height / 20, height: UIScreen.main.bounds.height / 20)
                                Image("erase")
                                    .frame(width: UIScreen.main.bounds.height / 20, height: UIScreen.main.bounds.height / 20)
                                Text("지우개")
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
