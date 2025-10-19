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
                
                ImageScrollViewRepresentable(images: vm.models) {
                    print("끝까지 스크롤")
                    
                    let nextStart = vm.currentIndex
                    let nextEnd = min(vm.currentIndex + 60, vm.album.count)
                    
                    if nextStart < vm.album.count {
                        vm.currentIndex = nextEnd
                        vm.fetchedAlbum = nextEnd
                        vm.fetchAlbum()
                        vm.loadImagesInRange(start: nextStart, end: nextEnd)
                    }
                } onImageTap: { index in
                    print("=== 탭 이벤트 발생 ===")
                    print("클릭한 index: \(index)")
                    print("modelsDict 개수: \(vm.modelsDict.count)")
                    print("현재 selectedIndex: \(vm.selectedIndex)")
                    
                    guard vm.modelsDict[index] != nil else {
                        print("❌ 모델을 찾을 수 없음")
                        return
                    }
                    
                    print("✅ 모델 찾음")
                    
                    // ✅ 로직 수정: 항상 새로운 선택으로 업데이트
                    vm.selectImage(at: index)
                    print("✅ 선택 완료: selectedIndex=\(vm.selectedIndex)")
                    
                    guard index < vm.album.count else {
                        print("❌ 잘못된 인덱스: \(index) >= \(vm.album.count)")
                        return
                    }
                    
                    let asset = vm.album[index]
                    print("✅ 고해상도 이미지 로드 시작")
                    
                    vm.getImage(at: index, for: asset) {
                        print("✅ 이미지 로드 완료")
                        
                        if let image = vm.outputImage {
                            frameManager.pickedImage = image
                            print("✅ frameManager에 이미지 설정 완료")
                        } else {
                            print("❌ outputImage가 nil")
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            let hasImage = frameManager.pickedImage != nil
                            let hasModel = vm.modelsDict[index] != nil
                            let isSelected = vm.modelsDict[index]?.isSelected ?? false
                            
                            print("이동 체크: hasImage=\(hasImage), hasModel=\(hasModel), isSelected=\(isSelected)")
                            
                            if hasImage && hasModel && isSelected {
                                print("✅ frameEdit로 이동")
                                naviManager.push(screen: Screen.frameEdit)
                            } else {
                                print("❌ 이동 조건 불충족")
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
            print("=== PhotosPickerView onAppear ===")
            print("vm 인스턴스: \(ObjectIdentifier(vm))")
            print("현재 selectedIndex: \(vm.selectedIndex)")
            print("현재 modelsDict 개수: \(vm.modelsDict.count)")
            
            // ✅ 완전히 초기화
            vm.resetSelection()
            frameManager.pickedImage = nil
            frameManager.removedImage = nil
            
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                if status == .authorized {
                    if vm.firstAppear {
                        print("첫 진입, 앨범 로드 시작")
                        vm.fetchAlbum()
                        print("앨범 개수: \(vm.album.count)")
                        
                        DispatchQueue.main.async {
                            vm.loadImagesInRange(start: 0, end: 60)
                            vm.currentIndex = 60
                            vm.firstAppear = false
                        }
                    } else {
                        print("재진입, 기존 데이터 사용")
                        print("기존 modelsDict: \(vm.modelsDict.count)개")
                    }
                }
            }
            
            vm.changeOpacity()
            Analytics.logEvent("A3_사진선택", parameters: nil)
        }
        .onDisappear {
            print("=== PhotosPickerView onDisappear ===")
            // ✅ 화면 떠날 때만 캐시 정리
            vm.clearImageCache()
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
