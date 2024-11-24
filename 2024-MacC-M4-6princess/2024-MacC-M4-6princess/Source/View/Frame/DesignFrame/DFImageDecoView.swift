import SwiftUI

struct DFImageDecoView: View {
    @EnvironmentObject var naviManager: NavigationManager
    @EnvironmentObject var frameManager: FrameManager
    @ObservedObject var viewModel : DFModifyViewModel
    
    var body: some View {
            
        HStack(spacing: 40){
            
            appendImageView
            
            stickerView
            
            textView
        }
    }
}

extension DFImageDecoView {
    
    var appendImageView: some View {
        
        VStack {
            Button  {
                
//                isShowImagePickerView.toggle()
                naviManager.push(screen: Screen.photoPicker)
                
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
                viewModel.showStickerSheet = true
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
    
    var textView: some View {
        
        VStack {
            
            Button  {
                viewModel.showTextView = true // zstack 최상단에 텍스트뷰가 보임
            } label: {
                ZStack {
                    Circle()
                        .fill(Color(hex: "d9d9d9"))
                        .frame(width: 40, height: 40)
                        .opacity(0.15)
                    Image("TextIcon")
                }
            }
            .padding(.bottom, 5)
            
            Text("텍스트")
                .font(.caption)
                .foregroundStyle(.gray01)
        }
    }
}
