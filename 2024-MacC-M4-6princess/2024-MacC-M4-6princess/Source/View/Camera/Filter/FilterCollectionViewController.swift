//
//  FilterCollectionViewController.swift
//  InstaCamTest
//
//  Created by 김이예은 on 2/16/25.
//

import UIKit
import AVFoundation

class FilterCollectionViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    private let motionManager = MotionManager()
    private let viewModel: CameraViewModel
    
    var collectionView: UICollectionView!
    let filterImages: [StoreImages]
    private var selectedFilter: ((UUID) -> Void)?
    private let cellId = "FilterCell"
    var currentSelectedFilter: UUID
    let selectedCellSize: CGFloat = 58
    let normalCellWidth: CGFloat = 33
    let normalCellHeight: CGFloat = 44
    private var spacing: CGFloat = 40
    
    init(filterImages: [StoreImages], selectedFilter: @escaping (UUID) -> Void, initialFilter: UUID, viewModel: CameraViewModel) {
        self.filterImages = filterImages
        self.selectedFilter = selectedFilter
        self.currentSelectedFilter = initialFilter
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        let layout = CustomFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = spacing
        layout.delegate = self
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.decelerationRate = .fast
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(FilterCell.self, forCellWithReuseIdentifier: cellId)
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let inset = self.view.bounds.width / 2 - self.normalCellWidth / 2
            self.collectionView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
            self.collectionView.scrollToItem(
                at: IndexPath(item: 0, section: 0),
                at: .centeredHorizontally,
                animated: false
            )
        }
    }
    
    private func selectFilterAndCenter(at indexPath: IndexPath) {
        let filter = filterImages[indexPath.item]
        currentSelectedFilter = filter.uuid!
        
        // 셔터 효과 추가
            viewModel.isTakePic = true
            DispatchQueue.main.async {
                // 세션이 실행 중인지 확인
                if !self.viewModel.cameraManager.session.isRunning {
                    self.viewModel.cameraManager.startSession()
                    // 세션이 시작될 때까지 잠시 대기
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.viewModel.takePic() // 기존 viewModel의 takePic() 메서드 사용
                    }
                } else {
                    self.viewModel.takePic() // 기존 viewModel의 takePic() 메서드 사용
                }
            }
        
        selectedFilter?(filter.uuid ?? UUID())
        
        collectionView.scrollToItem(
            at: indexPath,
            at: .centeredHorizontally,
            animated: true
        )
        collectionView.reloadData()
    }
    
    private func findNearestFilterIndex(to point: CGPoint) -> Int? {
        var minDistance = CGFloat.greatestFiniteMagnitude
        var nearestIndex: Int?
        
        for cell in collectionView.visibleCells {
            guard let indexPath = collectionView.indexPath(for: cell) else { continue }
            let cellFrame = cell.frame
            let distance = abs(cellFrame.midX - point.x)
            
            if distance < minDistance {
                minDistance = distance
                nearestIndex = indexPath.item
            }
        }
        
        return nearestIndex
    }
}

// MARK: - UICollectionView Delegate & DataSource
extension FilterCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FilterCell
        let filter = filterImages[indexPath.item]
        if let imageData = filter.image, let uiImage = UIImage(data: imageData) {
            cell.configure(with: uiImage, isSelected: filter.uuid == currentSelectedFilter)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectFilterAndCenter(at: indexPath)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            finishScrolling(scrollView)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        finishScrolling(scrollView)
    }
    
    private func finishScrolling(_ scrollView: UIScrollView) {
        let centerPoint = CGPoint(x: scrollView.contentOffset.x + scrollView.bounds.width / 2, y: scrollView.bounds.height / 2)
        
        if let nearestIndex = findNearestFilterIndex(to: centerPoint) {
            selectFilterAndCenter(at: IndexPath(item: nearestIndex, section: 0))
        }
    }
    func reloadData() {
        collectionView.reloadData()
    }
}


