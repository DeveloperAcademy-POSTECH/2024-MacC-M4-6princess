import SwiftUI
import Photos

class PhotosPickerViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var modelsDict: [Int: PickedImageModel] = [:]
    
    var models: [PickedImageModel] {
        return modelsDict.values.sorted { $0.index < $1.index }
    }
    
    @Published var selectedIndex: Int = -1
    @Published var image: [UIImage] = []
    @Published var outputImage: UIImage?
    @Published var messageOpacity: Double = 1
    @Published var currentIndex: Int = 0
    @Published var fetchedAlbum: Int = 60
    @Published var firstAppear: Bool = true
    
    // MARK: - Private Properties
    
    private let imageManager = PHCachingImageManager()
    private var loadedIdentifiers: Set<String> = Set<String>()
    private var loadingIdentifiers: Set<String> = Set<String>()
    
    var album: PHFetchResult<PHAsset> = PHFetchResult<PHAsset>()
    var viewSize: CGSize = .zero
    var offset: CGFloat = 0
    var originOffset: CGFloat = 0
    var isCheckedOriginOffset: Bool = false
    
    // MARK: - View Size Management
    
    func setViewSize(_ size: CGSize) {
        self.viewSize = size
    }
    
    func setOriginOffset(_ offset: CGFloat) {
        guard !isCheckedOriginOffset else { return }
        self.originOffset = offset
        isCheckedOriginOffset = true
    }
    
    func setOffset(_ offset: CGFloat) {
        self.offset = offset
    }
    
    // MARK: - UI
    
    func changeOpacity() {
        for i in 0..<10 {
            if messageOpacity > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.messageOpacity -= 0.1
                }
            }
        }
    }
    
    // MARK: - Album Fetch
    
    func fetchAlbum() {
        let options = PHFetchOptions()
        options.fetchLimit = fetchedAlbum
        options.includeHiddenAssets = false
        options.includeAssetSourceTypes = [.typeUserLibrary]
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        self.album = PHAsset.fetchAssets(with: .image, options: options)
    }
    
    // MARK: - High Quality Image Loading
    
    func getImage(at index: Int, for asset: PHAsset, completionHandler: @escaping () -> Void) {
        let requestOptions = PHImageRequestOptions()
        
        requestOptions.isNetworkAccessAllowed = true
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.resizeMode = .exact
        requestOptions.isSynchronous = false
        
        imageManager.requestImage(
            for: asset,
            targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight),
            contentMode: .aspectFill,
            options: requestOptions
        ) { [weak self] result, _ in
            guard let self = self else { return }
            
            if let model = self.modelsDict[index],
               model.identifier == asset.localIdentifier,
               let image = result {
                DispatchQueue.main.async {
                    self.outputImage = image
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completionHandler()
        }
    }
    
    // MARK: - Thumbnail Loading
    
    func loadImage(for asset: PHAsset, size: CGSize, index: Int) {
        let identifier = asset.localIdentifier
        
        // ✅ 이미 로드되었거나 로딩 중이면 스킵
        guard !loadedIdentifiers.contains(identifier),
              !loadingIdentifiers.contains(identifier) else {
            print("스킵: index=\(index)")
            return
        }
        
        // ✅ 로딩 중 표시
        loadingIdentifiers.insert(identifier)
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isNetworkAccessAllowed = true
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.resizeMode = .exact
        
        imageManager.requestImage(
            for: asset,
            targetSize: size,
            contentMode: .aspectFill,
            options: requestOptions
        ) { [weak self] result, info in
            guard let self = self else { return }
            
            guard identifier == asset.localIdentifier,
                  let image = result else {
                DispatchQueue.main.async { [weak self] in
                    self?.loadingIdentifiers.remove(identifier)
                }
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                // ✅ 로딩 완료, 저장
                self?.loadingIdentifiers.remove(identifier)
                self?.saveImageArray(index: index, image: image, identifier: identifier)
            }
        }
    }
    
    // MARK: - Range-based Loading
    
    func loadImagesInRange(start: Int, end: Int) {
        let endIndex = min(end, album.count)
        
        print("이미지 로드 범위: \(start)..<\(endIndex)")
        
        for i in start..<endIndex {
            guard i < album.count else { break }
            let asset = album[i]
            
            let size = CGSize(
                width: UIScreen.main.bounds.width * 0.3,
                height: UIScreen.main.bounds.width * 0.3
            )
            
            loadImage(for: asset, size: size, index: i)
        }
    }
    
    // MARK: - Save Image
    
    private func saveImageArray(index: Int, image: UIImage, identifier: String?) {
        guard let id = identifier else {
            print("❌ identifier nil")
            return
        }
        
        // ✅ 이미 modelsDict에 있는지 체크 (중복 방지)
        guard modelsDict[index] == nil else {
            print("이미 저장됨: index=\(index)")
            return
        }
        
        var model = PickedImageModel()
        model.image = image
        model.index = index
        model.identifier = identifier
        
        modelsDict[index] = model
        loadedIdentifiers.insert(id)
        
        print("이미지 로드됨: index=\(index), 총 \(modelsDict.count)개")
    }
    
    // MARK: - Selection Management
    
    func selectImage(at index: Int) {
        // ✅ 이전 선택 해제
        if selectedIndex >= 0 {
            modelsDict[selectedIndex]?.isSelected = false
        }
        
        // ✅ 새로운 선택
        if modelsDict[index] != nil {
            selectedIndex = index
            modelsDict[index]?.isSelected = true
        }
    }
    
    // MARK: - Memory Management
    
    func clearImageCache() {
        imageManager.stopCachingImagesForAllAssets()
    }
    
    func cleanup() {
        modelsDict.removeAll()
        loadedIdentifiers = Set<String>()
        loadingIdentifiers = Set<String>()
        image.removeAll()
        outputImage = nil
        clearImageCache()
        
        currentIndex = 0
        fetchedAlbum = 60
        selectedIndex = -1
        messageOpacity = 1
        
        print("PhotosPickerViewModel cleaned up")
    }
    
    func resetSelection() {
        if selectedIndex >= 0 {
            modelsDict[selectedIndex]?.isSelected = false
        }
        selectedIndex = -1
        outputImage = nil
    }
    
    func reset() {
        cleanup()
        album = PHFetchResult<PHAsset>()
        firstAppear = true
        print("PhotosPickerViewModel reset")
    }
    
    deinit {
        cleanup()
        print("PhotosPickerViewModel deinitialized")
    }
}
