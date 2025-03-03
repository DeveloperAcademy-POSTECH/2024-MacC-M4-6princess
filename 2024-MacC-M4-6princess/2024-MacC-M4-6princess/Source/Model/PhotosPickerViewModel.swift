import SwiftUI
import Photos

class PhotosPickerViewModel: ObservableObject {
    
    @Published var models: [PickedImageModel] = []
    @Published var selectedIndex: Int = -1
    @Published var image: [UIImage] = []
    @Published var outputImage: UIImage?
    @Published var messageOpacity: Double = 1
    
    private let imageManager = PHCachingImageManager()
    var album: PHFetchResult<PHAsset> = PHFetchResult<PHAsset>()
    
    func changeOpacity() {
        for i in 0..<10 {
            if messageOpacity > 0 {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.messageOpacity -= 0.1
                }
            }
        }
    }
    
    func fetchAlbum() {
        let options = PHFetchOptions()
        options.includeHiddenAssets = false
        options.includeAssetSourceTypes = [.typeUserLibrary]
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        self.album = PHAsset.fetchAssets(with: .image, options: options)
        
    }
    
    func getImage(for asset: PHAsset, completionHandler: @escaping () -> Void) {
        let requestOptions = PHImageRequestOptions()
        
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.resizeMode = .exact
        
        imageManager.requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFill, options: requestOptions) {
            [self] result, _ in
            if let image = result {
                DispatchQueue.main.async {
                    self.outputImage = image
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completionHandler()
        }
    }
    func loadImage(for asset: PHAsset, size: CGSize, index: Int) {

        let requestOptions = PHImageRequestOptions()
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.resizeMode = .exact
//        requestOptions.version = .original
        
        imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: requestOptions) {
            [self] result, _ in
            if let image = result {
                DispatchQueue.main.async {
                    self.saveImageArray(index: index, image: image)
                    print(image.size)
                }
            }
        }
    }
    
    func saveImageArray(index: Int, image: UIImage) {
        var model = PickedImageModel()
        model.image = image
        model.index = index
        
        models.append(model)
    }
}
