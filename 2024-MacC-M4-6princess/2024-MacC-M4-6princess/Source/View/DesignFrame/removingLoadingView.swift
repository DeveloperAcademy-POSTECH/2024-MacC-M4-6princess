import SwiftUI

struct removingLoadingView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .opacity(0.5)
            VStack {
                Image("removingLoading")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width * 0.11, height: UIScreen.main.bounds.width * 0.11)
                
                Text("배경제거중...")
                    .font(.system(size: 14))
                    .fontWeight(.regular)
                    .foregroundStyle(.white)
                
            }
        }
    }
}

#Preview {
    removingLoadingView()
}

