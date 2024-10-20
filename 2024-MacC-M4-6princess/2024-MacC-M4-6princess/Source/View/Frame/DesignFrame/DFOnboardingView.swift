import SwiftUI

struct DFOnboardingView: View {
    @Binding var isFirstLaunching: Bool
    var coloredSubstring: String = ""
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack {

                Spacer()
                
                Image("pinch")
                    .resizable()
                    .frame(width: 60, height: 70)
                    .padding(.trailing)
                    .padding(.bottom, 5)
                
                Text("두 손가락을 벌리면")
                    .font(.footnote)
                    .foregroundStyle(.white)
                TextWithColoredSubstring(originalText: "이미지가 커져요.", coloredSubstring: "커져요")
                    .font(.footnote)
                Spacer()
                Image("spread")
                    .resizable()
                    .frame(width: 60, height: 70)
                    .padding(.trailing)
                    .padding(.bottom, 5)
                
                Text("두 손가락을 모으면")
                    .font(.footnote)
                    .foregroundStyle(.white)
                TextWithColoredSubstring(originalText: "이미지가 작아져요.", coloredSubstring: "작아져요")
                    .font(.footnote)
                Spacer()
                Image("drag")
                    .resizable()
                    .frame(width: 60, height: 70)
                    .padding(.trailing)
                    .padding(.bottom, 5)
                
                Text("손가락을 움직이면")
                    .font(.footnote)
                    .foregroundStyle(.white)
                TextWithColoredSubstring(originalText: "이미지가 이동해요.", coloredSubstring: "이동해요")
                    .font(.footnote)
                Spacer()
            }
        }
        .onTapGesture {
            isFirstLaunching.toggle()
        }
    }
}
//#Preview {
//    DFOnboardingView()
//}
