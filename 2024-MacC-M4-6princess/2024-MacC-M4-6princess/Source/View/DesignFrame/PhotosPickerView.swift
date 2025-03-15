import SwiftUI
import Photos
import FirebaseAnalytics

struct PhotosPickerView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var vm: PhotosPickerViewModel = PhotosPickerViewModel()
    @State private var isPresented: Bool = false
    @EnvironmentObject var naviManager: NavigationManager
    @EnvironmentObject var frameManager: FrameManager
    
    let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 5), count: 3)
    var body: some View {
        ZStack {
            VStack {
                toolbarButton
//                Spacer()
                ScrollViewWithOffset
                    .padding(.top, 20)
            }
            VStack {
                toastMessage
                    .padding(.bottom, UIScreen.main.bounds.height * 0.63)
                    .opacity(vm.messageOpacity)
            }
        }
        .onAppear {
            print("w: \(UIScreen.main.bounds.width)")
            print("h: \(UIScreen.main.bounds.height)")
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                if status == .authorized {
//                    DispatchQueue.main.async {
                        vm.fetchAlbum()
                        print(vm.album.count)
                        for i in 0..<vm.album.count {
                            print("모델 삽입 실행됨")
                            vm.loadImage(for: vm.album[i], size: CGSize(width: UIScreen.main.bounds.width*0.3, height: UIScreen.main.bounds.width*0.3), index: i)
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

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

extension PhotosPickerView {
    
    private var scrollObservableView: some View {
        GeometryReader { proxy in
            let offsetY = proxy.frame(in: .global).origin.y
            Color.clear
                .preference(
                    key: ScrollOffsetKey.self,
                    value: offsetY
                )
                .onAppear { // 나타날때 뷰의 최초위치를 저장하는 로직
                    vm.setOriginOffset(offsetY)
                }
        }
        .frame(height: 0)
    }
}

extension PhotosPickerView {
    
    var ScrollViewWithOffset: some View {
        
        ScrollView() {
            scrollObservableView
            LazyVGrid(columns: columns, alignment: .center, spacing: 5) {
                if vm.models.count != 0 {
                    ForEach(0..<vm.models.count, id: \.self) { i in
                        ZStack {
                            if let image = vm.models[i].image {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: UIScreen.main.bounds.width*0.32, height: UIScreen.main.bounds.width*0.32)
                                    .onTapGesture {
                                        
                                        if vm.selectedIndex < 0 {
                                            vm.selectedIndex = i
                                            vm.models[i].isSelected = true
                                            
                                        } else {
                                            if vm.selectedIndex != i {
                                                vm.models[vm.selectedIndex].isSelected = false
                                                vm.selectedIndex = i
                                                vm.models[i].isSelected = true
                                            } else {
                                                vm.selectedIndex = -1
                                                vm.models[i].isSelected = false
                                            }
                                        }
                                        
                                        if vm.selectedIndex >= 0 {
                                            vm.getImage(for: vm.album[vm.selectedIndex]) {
                                                
                                                if let image = vm.outputImage {
                                                    frameManager.pickedImage = image
                                                }
                                                
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                    if frameManager.pickedImage != nil  && vm.models[i].isSelected {
                                                        naviManager.push(screen: Screen.frameEdit)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                VStack {
                                    HStack {
                                        Spacer()
                                        Image("frameCheckIcon")
                                            .resizable()
                                            .frame(width:20, height: 20)
                                            .padding([.trailing, .top], 5)
                                            .opacity(vm.models[i].isSelected ? 1 : 0)
                                    }
                                    Spacer()
                                }
                            }
                        }
                    }
                }
                
            }
            .onReadSize() {
                
                vm.setViewSize($0)
                print("전체 뷰 사이즈 : \(vm.viewSize.height)")
            }
        }
        .onPreferenceChange(ScrollOffsetKey.self) {
            vm.setOffset($0)
            Task {
                if vm.offset < vm.viewSize.height * -0.65 {
                    
                    if vm.album.count - vm.currentIndex >= 60 {
                        vm.currentIndex += 60
                        vm.fetchedAlbum += 60
                        
                    } else {
                        vm.currentIndex = vm.album.count
                    }
                    
                    vm.fetchAlbum()
                    print(vm.album.count)
                    for i in vm.currentIndex..<vm.album.count {
                        print("모델 삽입 실행됨")
                        vm.loadImage(for: vm.album[i], size: CGSize(width: UIScreen.main.bounds.width*0.3, height: UIScreen.main.bounds.width*0.3), index: i)
                    }
                }
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
            
            Text("사진선택")
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
