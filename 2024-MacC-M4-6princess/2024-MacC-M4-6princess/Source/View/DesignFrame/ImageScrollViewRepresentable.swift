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

        let contentView = buildGridView(with: images, context: context)
        contentView.tag = 1000
        scrollView.addSubview(contentView)
        scrollView.contentSize = contentView.frame.size

        return scrollView
    }

    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        
        scrollView.subviews.forEach {
            if $0.tag == 1000 { $0.removeFromSuperview() }
        }

        let contentView = buildGridView(with: images, context: context)
        contentView.tag = 1000
        scrollView.addSubview(contentView)
        scrollView.contentSize = contentView.frame.size
        
    }
    
    func buildGridView(with images: [PickedImageModel], context: Context) -> UIView {
        let contentView = UIView()
        let numberOfColumns = 3
        let spacing: CGFloat = 5
        let itemSize: CGSize = CGSize(width: UIScreen.main.bounds.width * 0.32, height: UIScreen.main.bounds.height * 0.2)
//        let itemSize: CGFloat = UIScreen.main.bounds.width * 0.32

        for i in images {
            let row = i.index / numberOfColumns
            let col = i.index % numberOfColumns

            let imageView = UIImageView(image: i.image)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.isUserInteractionEnabled = true
            imageView.tag = i.index

            // 탭 제스처 추가
            let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.imageTapped(_:)))
            imageView.addGestureRecognizer(tap)

            let x = CGFloat(col) * (itemSize.width + spacing)
            let y = CGFloat(row) * (itemSize.height + spacing)
            imageView.frame = CGRect(x: x, y: y, width: itemSize.width, height: itemSize.height)

            contentView.addSubview(imageView)
        }

        let rows = (images.count + numberOfColumns - 1) / numberOfColumns
        let contentWidth = CGFloat(numberOfColumns) * (itemSize.width + spacing) - spacing
        let contentHeight = CGFloat(rows) * (itemSize.height + spacing) - spacing
        contentView.frame = CGRect(x: 0, y: 0, width: contentWidth, height: contentHeight)

        return contentView
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
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
                onImageTap(imageView.tag)
            }
        }
    }
}
