//import SwiftUI
//import Photos
//
//struct DFPhotoPickView: View {
//    
//    @State var photos: [UIImage?] = []
//    @State private var album: PHFetchResult<PHAsset>?
//    let imageManager = PHImageManager.default()
//    let fetchOptions = PHFetchOptions()
//    @State var allAssets: PHFetchResult<PHAsset>?
//    @State private var index: Int?
////    var asset = PHAsset()
//    
//    var body: some View {
//        VStack {
//            if let index = index {
//                ForEach(0..<4) { index in
//                    if let photo = photos[index] {
//                        Image(uiImage: photo)
//                            .resizable()
//                            .frame(width: 100, height: 100)
//                            .scaledToFit()
//                    }
//                }
//            }
//        }
//        .onAppear {
//            
//            getAuthorization()
////            album = vm.fetchAlbum()
//            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "mediaType", ascending: true)]
//            allAssets = PHAsset.fetchAssets(with: fetchOptions)
//            index = allAssets!.count
//            print("\(index)")
//            if let index = index {
//                getPhotos(index: 11)
//            }
//        }
//    }
//    func getAuthorization() {
//        PHPhotoLibrary.requestAuthorization { status in
//            switch status {
//            case .authorized:
//                print("Authorized")
//            case .denied, .restricted:
//                print("Denied")
//            case .notDetermined:
//                print("Not Determined")
//            @unknown default:
//                print("Unknown")
//            }
//        }
//    }
//
//    @MainActor
//    func getPhotos(index: Int) {
//        
//        for i in 0..<index {
//            if let asset = allAssets?.object(at: index) {
//                let targetSize = CGSize(width: 300, height: 300)
//                let options = PHImageRequestOptions()
//                options.isSynchronous = true
//                
//                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { image, info in
//                    
//                    if let image = image {
//                        DispatchQueue.main.async {
//                            //                        imageView.image = image
//                            photos.append(image)
//                        }
//                    }
//                }
//            }
//        }
//    }
//}
////#Preview {
////    DFPhotoPickView()
////}
