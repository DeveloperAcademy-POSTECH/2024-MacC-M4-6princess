//
//  FilterCollectionViewController.swift
//  InstaCamTest
//
//  Created by 김이예은 on 2/16/25.
//

import UIKit
import SwiftUI
import AVFoundation
import FirebaseAnalytics

class FilterCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var frameManager: FrameManager
    private let viewModel: CameraViewModel
    
    var collectionView: UICollectionView!
    let filterImages: [StoreImages]
    private var selectedFilter: ((UUID?) -> Void)?
    private let filterCellId = "FilterCell"
    private let emptyCellId = "EmptyCell"
    var currentSelectedFilter: UUID?
    private let cellSpacing: CGFloat = 20
    private let centerCellSize: CGFloat = 58
    private let rightOfCenterCellSize: CGFloat = 50
    private let defaultCellSize: CGFloat = 38
    
    init(filterImages: [StoreImages], selectedFilter: @escaping (UUID?) -> Void, initialFilter: UUID?, viewModel: CameraViewModel, frameManager: FrameManager) {
        self.filterImages = filterImages
        self.selectedFilter = selectedFilter
        self.currentSelectedFilter = initialFilter
        self.viewModel = viewModel
        self.frameManager = frameManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
//        view.addSubview(shutterButton)
//        shutterButton.center = view.center
    }

//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        view.bringSubviewToFront(shutterButton)
//    }
//
//    
//    private lazy var shutterButton: UIButton = {
//        let button = UIButton(type: .custom)
//        button.setImage(UIImage(named: "shutterImage"), for: .normal)
//        button.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
//        button.addTarget(self, action: #selector(shutterButtonTapped), for: .touchUpInside)
//        return button
//    }()
//
//    
//    @objc private func shutterButtonTapped() {
//        if frameManager.resultImage != nil {
//            self.viewModel.isTakePic = true
//            DispatchQueue.main.asyncAfter(deadline: .now() + viewModel.delayTime) {
//                self.viewModel.takePic()
//                self.viewModel.cameraManager.stopSession()
//                Analytics.logEvent("A1_셔터버튼눌림", parameters: nil)
//            }
//        } else {
//            viewModel.isShowAlert = true
//            // 알림 표시 로직 추가 필요
//        }
//    }


    
    private func setupCollectionView() {
        let layout = CustomFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = cellSpacing
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.decelerationRate = .fast
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(FilterCell.self, forCellWithReuseIdentifier: filterCellId)
        collectionView.register(EmptyCell.self, forCellWithReuseIdentifier: emptyCellId)
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let inset = (view.bounds.width - centerCellSize) / 2
        collectionView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterImages.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCellId, for: indexPath) as! EmptyCell
            cell.configure()
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: filterCellId, for: indexPath) as! FilterCell
            let filterIndex = indexPath.item - 1
            if filterIndex < filterImages.count {
                let filter = filterImages[filterIndex]
                if let imageData = filter.image, let uiImage = UIImage(data: imageData) {
                    let size = cellSize(for: indexPath)
                    let isSelected = filter.uuid == currentSelectedFilter
                    cell.configure(with: uiImage, size: size, isSelected: isSelected)
                }
            }
            return cell
        }
    }
    
    func cellSize(for indexPath: IndexPath) -> CGFloat {
        let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
        let cellFrame = collectionView.layoutAttributesForItem(at: indexPath)?.frame ?? .zero
        let distance = abs(cellFrame.midX - centerX)
        
        if indexPath.item == 0 {
            return defaultCellSize
        } else if distance < (centerCellSize / 2) {
            return centerCellSize
        } else if distance < (centerCellSize / 2 + rightOfCenterCellSize / 2) {
            return rightOfCenterCellSize
        } else {
            return defaultCellSize
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCellSizesAndSpacing()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        centerOnClosestCell()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            centerOnClosestCell()
        }
    }
    
    //가까운 셀을 중앙으로 위치 이동
    private func centerOnClosestCell() {
        let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
        guard let closestCell = collectionView.visibleCells
            .min(by: { abs($0.frame.midX - centerX) < abs($1.frame.midX - centerX) }),
              let indexPath = collectionView.indexPath(for: closestCell) else {
            return
        }
        
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        
        if indexPath.item > 0 && indexPath.item <= filterImages.count {
                let selectedFilter = filterImages[indexPath.item - 1]
                self.selectedFilter?(selectedFilter.uuid)
                currentSelectedFilter = selectedFilter.uuid
                frameManager.selectedFrame = currentSelectedFilter
                frameManager.isFrameLoading = true
//                shutterButton.isHidden = false // 중앙에 필터가 왔을 때 셔터 버튼 표시
            } else {
                self.selectedFilter?(nil)
                currentSelectedFilter = nil
                frameManager.selectedFrame = nil
                frameManager.isFrameLoading = true
//                shutterButton.isHidden = true // 중앙에 필터가 없을 때 셔터 버튼 숨김
            }
        
        updateCellSizesAndSpacing()
    }
    
    
    private func updateCellSizesAndSpacing() {
        for cell in collectionView.visibleCells {
            guard let indexPath = collectionView.indexPath(for: cell) else { continue }
            let size = cellSize(for: indexPath)
            if let filterCell = cell as? FilterCell {
                let filterIndex = indexPath.item - 1
                if filterIndex < filterImages.count {
                    let filter = filterImages[filterIndex]
                    if let imageData = filter.image, let uiImage = UIImage(data: imageData) {
                        let isSelected = filter.uuid == currentSelectedFilter
                        filterCell.configure(with: uiImage, size: size, isSelected: isSelected)
                    }
                }
            }
        }
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
        let cellFrame = collectionView.layoutAttributesForItem(at: indexPath)?.frame ?? .zero

        // 현재 선택된 셀의 중앙 위치와 비교
        if abs(cellFrame.midX - centerX) < (centerCellSize / 2) {
            // 중앙에 있는 셀을 탭했을 경우 아무 동작도 하지 않음
            collectionView.deselectItem(at: indexPath, animated: false)
            return
        }

        selectAndScrollToItem(at: indexPath)
    }

    
    private func selectAndScrollToItem(at indexPath: IndexPath) {
        if indexPath.item > 0 && indexPath.item <= filterImages.count {
            let selectedFilter = filterImages[indexPath.item - 1]
            self.selectedFilter?(selectedFilter.uuid)
            currentSelectedFilter = selectedFilter.uuid
            frameManager.selectedFrame = currentSelectedFilter
            frameManager.isFrameLoading = true
        } else if indexPath.item == 0 {
            self.selectedFilter?(nil)
            currentSelectedFilter = nil
            frameManager.selectedFrame = nil
            frameManager.isFrameLoading = true
        }
        
        // 다음 셀의 인덱스를 계산 (범위를 벗어나지 않도록 주의)
        let nextIndexPath = IndexPath(item: min(indexPath.item + 1, filterImages.count), section: indexPath.section)
        
        let cellWidth = cellSize(for: nextIndexPath) + cellSpacing
        let targetOffset = CGFloat(nextIndexPath.item) * cellWidth - collectionView.bounds.width / 2 + cellWidth / 2
        let safeOffset = max(0, min(targetOffset, collectionView.contentSize.width - collectionView.bounds.width))
        
        collectionView.setContentOffset(CGPoint(x: safeOffset, y: 0), animated: true)
        updateCellSizesAndSpacing()
    }

}
