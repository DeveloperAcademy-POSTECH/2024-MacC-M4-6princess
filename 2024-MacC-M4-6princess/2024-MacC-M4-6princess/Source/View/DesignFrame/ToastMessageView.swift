import SwiftUI

struct ToastMessageView: View {
    
    var body: some View {
        
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.message)
                .opacity(0.9)
                .frame(width: UIScreen.main.bounds.width * 0.83, height: UIScreen.main.bounds.height * 0.05)
            HStack {
                Image("pencil")
                    .resizable()
                    .frame(width: 20, height: 20)
                Text("선택 추가, 제거 기능으로 선택 영역을 수정하세요.")
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(alignment: .center)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

#Preview {
    ToastMessageView()
}
