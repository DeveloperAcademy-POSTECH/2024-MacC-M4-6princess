import SwiftUI

struct DFDecoImageView: View {
    
    var body: some View {
            
        HStack(spacing: 40){
            appendImageView
            
            stickerView
            
            TextView
        }
    }
}

extension DFDecoImageView {
    
    var appendImageView: some View {
        
        VStack {
            
            Button  {
                
            } label: {
                ZStack {
                    Circle()
                        .fill(Color(hex: "d9d9d9"))
                        .frame(width: 40, height: 40)
                        .opacity(0.15)
                    Image("photo")
                }
            }
            .padding(.bottom, 5)
            
            Text("사진추가")
                .font(.caption)
                .foregroundStyle(.gray01)
        }
    }
    
    var stickerView: some View {
        
        VStack {
            
            Button  {
                
            } label: {
                ZStack {
                    Circle()
                        .fill(Color(hex: "d9d9d9"))
                        .frame(width: 40, height: 40)
                        .opacity(0.15)
                    Image("sticker")
                }
            }
            .padding(.bottom, 5)
            
            Text("스티커")
                .font(.caption)
                .foregroundStyle(.gray01)
        }
    }
    
    var TextView: some View {
        
        VStack {
            
            Button  {
                
            } label: {
                ZStack {
                    Circle()
                        .fill(Color(hex: "d9d9d9"))
                        .frame(width: 40, height: 40)
                        .opacity(0.15)
                    Image("textIcon")
                }
            }
            .padding(.bottom, 5)
            
            Text("텍스트")
                .font(.caption)
                .foregroundStyle(.gray01)
        }
    }
}

#Preview {
    DFDecoImageView()
}
