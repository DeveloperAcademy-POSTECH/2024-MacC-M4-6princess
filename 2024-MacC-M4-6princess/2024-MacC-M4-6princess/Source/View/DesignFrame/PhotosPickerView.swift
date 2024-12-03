import SwiftUI
import PhotosUI
import FirebaseAnalytics

struct PhotosPickerView: View {
    //    enum PickerType {
    //        case base
    //        case new
    //    }
    //
    //    let pickerType: PickerType
    //
    //    init(_ pickerType: PickerType) {
    //        self.pickerType = pickerType
    //    }
    //
    @State private var selectedItem: [PhotosPickerItem] = []
    @State private var item: PhotosPickerItem? = nil
    //    @State private var pickedImage: UIImage? = nil
    @State private var isPresented: Bool = false
    @EnvironmentObject var naviManager: NavigationManager
    @EnvironmentObject var frameManager: FrameManager
    var body: some View {
        VStack {
            PhotosPicker(selection: $selectedItem, maxSelectionCount: 1, matching: .images) {
            }
            .photosPickerAccessoryVisibility(.visible)
            .photosPickerDisabledCapabilities([.search, .collectionNavigation, .stagingArea])
            .photosPickerStyle(.inline)
        }
        .onAppear {
            Analytics.logEvent("A3_사진선택", parameters: nil)
        }
        .navigationBarBackButtonHidden()
        .onChange(of: selectedItem) {
            if !selectedItem.isEmpty {
                Analytics.logEvent("A3_갤러리사진선택", parameters: nil)
            }
            Task {
                if let data = try await selectedItem[0].loadTransferable(type: Data.self) {
                    frameManager.pickedImage = UIImage(data:data)
                    if frameManager.pickedImage != nil {
                        //                        isPresented = true
                        naviManager.push(screen: Screen.frameEdit) // ✅
                    }
                }
                
            }
        }
    }
}

#Preview {
    PhotosPickerView()
}
