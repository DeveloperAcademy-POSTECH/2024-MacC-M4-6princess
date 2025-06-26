import SwiftUI
import Photos
import FirebaseAnalytics

struct PhotosPickerView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var vm: PhotosPickerViewModel = PhotosPickerViewModel()
    @State private var isPresented: Bool = false
    @EnvironmentObject var naviManager: NavigationManager
    @EnvironmentObject var frameManager: FrameManager
    
    var body: some View {
        ZStack {
            VStack {
                toolbarButton
//                ScrollViewWithOffset
//                    .padding(.top, 10)
                ImageScrollViewRepresentable(images: vm.models) {
                    print("끝까지 스크롤")
                    if vm.album.count - vm.currentIndex >= 60 {
                        vm.currentIndex += 60
                        vm.fetchedAlbum += 60
                        print("모델삽입")
                        
                    } else {
                        vm.currentIndex = vm.album.count
                    }
                    vm.fetchAlbum()
                    for i in vm.currentIndex..<vm.album.count {
                        vm.loadImage(for: vm.album[i], size: CGSize(width: UIScreen.main.bounds.width*0.3, height: UIScreen.main.bounds.width*0.3), index: i)
                    }
                    
                }onImageTap: { index in
                    print("사진클릭!")
                    if vm.selectedIndex < 0 {
                        vm.selectedIndex = index
                        vm.models[index].isSelected = true
                        
                    } else {
                        if vm.selectedIndex != index {
                            vm.models[vm.selectedIndex].isSelected = false
                            vm.selectedIndex = index
                            vm.models[index].isSelected = true
                        } else {
                            vm.selectedIndex = -1
                            vm.models[index].isSelected = false
                        }
                    }
                    
                    if vm.selectedIndex >= 0 {
                        vm.getImage(for: vm.album[vm.selectedIndex]) {
                            
                            if let image = vm.outputImage {
                                frameManager.pickedImage = image
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                if frameManager.pickedImage != nil  && vm.models[index].isSelected {
                                    naviManager.push(screen: Screen.frameEdit)
                                }
                            }
                        }
                    }
                }
                .padding(.top, 10)
            }
            VStack {
                toastMessage
                    .padding(.bottom, UIScreen.main.bounds.height * 0.65)
                    .opacity(vm.messageOpacity)
            }
        }
        .onAppear {
            
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                if status == .authorized {
                    //                    DispatchQueue.main.async {
                    if vm.firstAppear {
                        vm.fetchAlbum()
                        print(vm.album.count)
                        for i in 0..<vm.album.count {
                            print("모델 삽입 실행됨")
                            vm.loadImage(for: vm.album[i], size: CGSize(width: UIScreen.main.bounds.width*0.3, height: UIScreen.main.bounds.width*0.3), index: i)
                        }
                        vm.firstAppear = false
                    }
                    //                    }
                }
            }
            vm.changeOpacity()
            Analytics.logEvent("A3_사진선택", parameters: nil)
        }
        .navigationBarBackButtonHidden()
        .onChange(of: vm.selectedIndex) {
            if vm.selectedIndex >= 0 {
                Analytics.logEvent("A3_갤러리사진선택", parameters: nil)
            }
        }
    }
}

extension PhotosPickerView {
    var toastMessage: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.message)
                .opacity(0.9)
                .frame(width: 202, height: 40)
            
            HStack {
                Image("paintImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                
                Text("최애의 사진을 선택하세요.")
                    .foregroundStyle(.white)
                    .font(.footnote)
                    .fontWeight(.bold)
            }
        }
    }
}

extension PhotosPickerView {
    var toolbarButton: some View {
        
        HStack {
            
            Button {
                naviManager.pop()
                //                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .resizable()
                    .foregroundStyle(.black)
                    .frame(width: 15, height: 15)
            }
            .disabled(vm.models.isEmpty ? true : false)
            .padding(.leading, UIScreen.main.bounds.width * 0.09)
            Spacer()
            
            Text("사진 선택")
                .fontWeight(.bold)
                .foregroundStyle(.gray01)
                .padding(.leading, UIScreen.main.bounds.width * 0.04)
                .padding(.trailing, UIScreen.main.bounds.height * 0.075)
            
            Spacer()
            
            
        }
        .padding(.top, 20)
    }
}

#Preview {
    PhotosPickerView()
}
