import SwiftUI

struct DFImageDecoView: View {
    @EnvironmentObject var naviManager: NavigationManager
    @EnvironmentObject var frameManager: FrameManager
    @ObservedObject var viewModel : DFModifyViewModel
    @EnvironmentObject var imageModel: ImageListModel
    var body: some View {
        HStack(spacing: 24) {
            
            // Undo 버튼
            Button(action: {
                viewModel.undo(imageList: &imageModel.imageList)
            }) {
                Image(systemName: "arrow.uturn.backward")
                    .resizable()
                    .frame(width: 10, height: 10)
                    .padding()
                    .background(
                        (viewModel.history.undoStack.isEmpty ? Color.gray.opacity(0.1) : Color.gray.opacity(0.2))
                    )
                    .clipShape(Circle())
                    .foregroundColor(
                        viewModel.history.undoStack.isEmpty ? .gray : .primary
                    )
            }
            .disabled(viewModel.history.undoStack.isEmpty) // 아예 비활성화
            
            // Redo 버튼
            Button(action: {
                viewModel.redo(imageList: &imageModel.imageList)
            }) {
                Image(systemName: "arrow.uturn.forward")
                    .resizable()
                    .frame(width: 10, height: 10)
                    .padding()
                    .background(
                        (viewModel.history.redoStack.isEmpty ? Color.gray.opacity(0.1) : Color.gray.opacity(0.2))
                    )
                    .clipShape(Circle())
                    .foregroundColor(
                        viewModel.history.redoStack.isEmpty ? .gray : .primary
                    )
            }
            .disabled(viewModel.history.redoStack.isEmpty) // 아예 비활성화
        }
        
        HStack(spacing: 56){
            
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
            
            Text("사진 추가")
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
