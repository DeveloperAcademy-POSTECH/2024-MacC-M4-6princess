import SwiftUI
import PhotosUI

struct PhotosPickerView: View {
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var pickedImage: UIImage?
    var body: some View {
        VStack {
            PhotosPicker(selection: $selectedItem, matching: .images) {
            }
            .photosPickerAccessoryVisibility(.visible)
            .photosPickerDisabledCapabilities([.search, .collectionNavigation, .stagingArea])
            .photosPickerStyle(.inline)
        }
        .navigationBarBackButtonHidden()
        .onChange(of: selectedItem) {
            Task {
                if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                    pickedImage = UIImage(data:data)
                }
            }
        }
    }
}

#Preview {
    PhotosPickerView()
}
