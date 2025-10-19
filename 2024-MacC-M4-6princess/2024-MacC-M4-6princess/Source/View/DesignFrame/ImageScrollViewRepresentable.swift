import SwiftUI
import UIKit

import SwiftUI
import UIKit

struct ImageScrollViewRepresentable: UIViewRepresentable {
    
    var images: [PickedImageModel]
    var onScrollToBottom: () -> Void
    var onImageTap: (Int) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onScrollToBottom: onScrollToBottom, onImageTap: onImageTap)
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = false
        
        return scrollView
    }
    
    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        // ✅ Coordinator 클로저 업데이트
        context.coordinator.onScrollToBottom = onScrollToBottom
        context.coordinator.onImageTap = onImageTap
        
        let contentView: UIView
        if let existingView = scrollView.viewWithTag(1000) {
            contentView = existingView
        } else {
            contentView = UIView()
            contentView.tag = 1000
            scrollView.addSubview(contentView)
        }
        
        let existingCount = contentView.subviews.count
        
        if images.count > existingCount {
            for i in existingCount..<images.count {
                let imageData = images[i]
                let imageView = createImageView(for: imageData, context: context)
                contentView.addSubview(imageView)
            }
        }
        
        let numberOfColumns = 3
        let spacing: CGFloat = 5
        let itemSize = CGSize(
            width: UIScreen.main.bounds.width * 0.32,
            height: UIScreen.main.bounds.height * 0.2
        )
        
        let rows = (images.count + numberOfColumns - 1) / numberOfColumns
        let contentWidth = CGFloat(numberOfColumns) * (itemSize.width + spacing) - spacing
        let contentHeight = CGFloat(rows) * (itemSize.height + spacing) - spacing
        
        contentView.frame = CGRect(x: 0, y: 0, width: contentWidth, height: contentHeight)
        scrollView.contentSize = contentView.frame.size
    }
    
    private func createImageView(for imageData: PickedImageModel, context: Context) -> UIImageView {
        let numberOfColumns = 3
        let spacing: CGFloat = 5
        let itemSize = CGSize(
            width: UIScreen.main.bounds.width * 0.32,
            height: UIScreen.main.bounds.height * 0.2
        )
        
        let row = imageData.index / numberOfColumns
        let col = imageData.index % numberOfColumns
        
        let imageView = UIImageView(image: imageData.image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.tag = imageData.index
        
        let tap = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.imageTapped(_:))
        )
        imageView.addGestureRecognizer(tap)
        
        let x = CGFloat(col) * (itemSize.width + spacing)
        let y = CGFloat(row) * (itemSize.height + spacing)
        imageView.frame = CGRect(x: x, y: y, width: itemSize.width, height: itemSize.height)
        
        return imageView
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        // ✅ var로 변경하여 업데이트 가능하게
        var onScrollToBottom: () -> Void
        var onImageTap: (Int) -> Void
        
        init(onScrollToBottom: @escaping () -> Void, onImageTap: @escaping (Int) -> Void) {
            self.onScrollToBottom = onScrollToBottom
            self.onImageTap = onImageTap
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            let visibleHeight = scrollView.frame.height
            
            if offsetY > contentHeight - visibleHeight - 100 {
                onScrollToBottom()
            }
        }
        
        @objc func imageTapped(_ sender: UITapGestureRecognizer) {
            if let imageView = sender.view as? UIImageView {
                print("이미지뷰 탭됨: tag=\(imageView.tag)")
                onImageTap(imageView.tag)
            }
        }
    }
}
