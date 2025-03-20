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
    @Environment(\.managedObjectContext) private var viewContext
    
    var frameManager: FrameManager
    private let viewModel: CameraViewModel
    
    var collectionView: UICollectionView!
    var filterImages: [StoreImages]
    private var selectedFilter: ((UUID?) -> Void)?
    var currentSelectedFilter: UUID? {
        didSet {
            scrollToSelectedFilter(animated: true)
        }
    }
    private let filterCellId = "FilterCell"
    private let emptyCellId = "EmptyCell"
    private let cellSpacing: CGFloat = 20
    private let centerCellSpacing: CGFloat = 31
    private let centerCellSize: CGFloat = 58
    private let rightOfCenterCellSize: CGFloat = 50
    private let defaultCellSize: CGFloat = 38
    
    init(filterImages: [StoreImages], selectedFilter: @escaping (UUID?) -> Void, initialFilter: UUID?, viewModel: CameraViewModel, frameManager: FrameManager) {
        self.filterImages = filterImages.sorted { $0.order > $1.order }
        self.selectedFilter = selectedFilter
        self.currentSelectedFilter = initialFilter
        self.viewModel = viewModel
        self.frameManager = frameManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupCollectionView()
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        
        // 앱 시작 시 선택된 필터가 없다면 Empty 셀을 선택
        if currentSelectedFilter == nil {
            DispatchQueue.main.async {
                // Empty 셀 선택
                self.selectedFilter?(nil)
                self.frameManager.selectedFrame = nil
                self.frameManager.resultImage = nil
                
                // Empty 셀로 스크롤
                let emptyIndexPath = IndexPath(item: 0, section: 0)
                self.collectionView.scrollToItem(at: emptyIndexPath, at: .centeredHorizontally, animated: false)
                self.updateCellSizesAndSpacing()
            }
        }
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollToSelectedFilter(animated: false)
    }
    
//    func scrollToSelectedFilter(animated: Bool) {
//        guard let selectedUUID = currentSelectedFilter,
//              let index = filterImages.firstIndex(where: { $0.uuid == selectedUUID }) else { return }
//        
//        let indexPath = IndexPath(item: index + 1, section: 0) // item이 0은 빈 셀이라 +1 해줌
//        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
//    }
    
    // scrollToSelectedFilter 메서드 수정
        func scrollToSelectedFilter(animated: Bool) {
            if currentSelectedFilter == nil {
                // Empty 셀로 스크롤
                let indexPath = IndexPath(item: 0, section: 0)
                collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
                return
            }
            
            guard let selectedUUID = currentSelectedFilter,
                  let index = filterImages.firstIndex(where: { $0.uuid == selectedUUID }) else { return }
            
            let indexPath = IndexPath(item: index + 1, section: 0) // item이 0은 빈 셀이라 +1 해줌
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
        }
    
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
        return filterImages.count + 1 //
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCellId, for: indexPath) as! EmptyCell
            cell.configure()
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: filterCellId, for: indexPath) as! FilterCell
            let filterIndex = indexPath.item - 1 //
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
    
    //    func cellSize(for indexPath: IndexPath) -> CGFloat {
    //        let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
    //        let cellFrame = collectionView.layoutAttributesForItem(at: indexPath)?.frame ?? .zero
    //        let distance = abs(cellFrame.midX - centerX)
    //        
    //        if indexPath.item == 0 {
    //            return defaultCellSize
    //        } else if distance < (centerCellSize / 2) {
    //            return centerCellSize
    //        } else if distance < (centerCellSize / 2 + rightOfCenterCellSize / 2) {
    //            return rightOfCenterCellSize
    //        } else {
    //            return defaultCellSize
    //        }
    //    }
    
    func cellSize(for indexPath: IndexPath) -> CGFloat {
        // 화면 중앙 위치 계산
        let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
        
        // 현재 화면에 보이는 모든 셀 중 가장 중앙에 가까운 셀 찾기
        let visibleCells = collectionView.visibleCells
        var closestCell: UICollectionViewCell?
        var minDistance: CGFloat = .greatestFiniteMagnitude
        
        for cell in visibleCells {
            let distance = abs(cell.frame.midX - centerX)
            if distance < minDistance {
                minDistance = distance
                closestCell = cell
            }
        }
        
        guard let closestIndexPath = closestCell.flatMap({ collectionView.indexPath(for: $0) }) else {
            return defaultCellSize
        }
        
        // 이제 인덱스를 기준으로 고정된 크기 반환
        if indexPath == closestIndexPath {
            return centerCellSize // 중앙 셀 (58)
        } else if indexPath.item == closestIndexPath.item + 1 {
            return rightOfCenterCellSize // 중앙 바로 오른쪽 셀 (50)
        } else {
            return defaultCellSize // 나머지 모든 셀들 (38)
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
        
        if indexPath.item == 0 {
            // EmptyCell 선택 시
            self.selectedFilter?(nil)
            currentSelectedFilter = nil
            frameManager.selectedFrame = nil
        } else {
            // FilterCell 선택 시
            let filterIndex = indexPath.item - 1
            if filterIndex >= 0 && filterIndex < filterImages.count {
                let selectedFilter = filterImages[filterIndex]
                self.selectedFilter?(selectedFilter.uuid)
                currentSelectedFilter = selectedFilter.uuid
                frameManager.selectedFrame = currentSelectedFilter
            }
        }
        frameManager.isFrameLoading = true
        updateCellSizesAndSpacing()
        //        print("현재 셀의 인덱스: \(filterImages[indexPath.item])")
    }
    
    private func updateCellSizesAndSpacing() {
        for cell in collectionView.visibleCells {
            guard let indexPath = collectionView.indexPath(for: cell) else { continue }
            let size = cellSize(for: indexPath)
            if let filterCell = cell as? FilterCell {
                let filterIndex = indexPath.item - 1 // EmptyCell 고려
                if filterIndex >= 0 && filterIndex < filterImages.count {
                    let filter = filterImages[filterIndex]
                    if let imageData = filter.image, let uiImage = UIImage(data: imageData) {
                        let isSelected = filter.uuid == currentSelectedFilter
                        filterCell.configure(with: uiImage, size: size, isSelected: isSelected)
                    }
                }
                // 셀의 레이아웃 즉시 업데이트
                filterCell.layoutIfNeeded()
            }
        }
        collectionView.collectionViewLayout.invalidateLayout()
    }

    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
        let cellFrame = collectionView.layoutAttributesForItem(at: indexPath)?.frame ?? .zero
        
        // 현재 선택된 셀의 중앙 위치와 비교
        if abs(cellFrame.midX - centerX) < (centerCellSize / 2) {
            // 중앙지점 탭했을 경우 반응 안함
            collectionView.deselectItem(at: indexPath, animated: false)
            return
        }
        
        selectAndScrollToItem(at: indexPath)
    }
    
    private func selectAndScrollToItem(at indexPath: IndexPath) {
        
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        
        // EmptyCell 처리
        if indexPath.item == 0 {
            self.selectedFilter?(nil)
            currentSelectedFilter = nil
            frameManager.selectedFrame = nil
            frameManager.resultImage = nil
        } else {
            let filterIndex = indexPath.item - 1
            if filterIndex >= 0 && filterIndex < filterImages.count {
                let selectedFilter = filterImages[filterIndex]
                self.selectedFilter?(selectedFilter.uuid)
                currentSelectedFilter = selectedFilter.uuid
                frameManager.selectedFrame = currentSelectedFilter
            }
        }
        
        frameManager.isFrameLoading = true
        updateCellSizesAndSpacing()
    }
    
    // 필터 추가 함수 - 삭제 예정
    func addNewFilter(_ newFilter: StoreImages) {
        
        let newOrder = (filterImages.max { $0.order < $1.order }?.order ?? 0) + 1
            let newFilter = StoreImages(context: viewContext)
            newFilter.order = newOrder
        
        filterImages.append(newFilter)
        
        // collectionView의 데이터 소스를 갱신
        collectionView.reloadData()
        
        // collectionView의 레이아웃을 갱신
        collectionView.collectionViewLayout.invalidateLayout()
        
        // 가장 최근에 추가된 필터를 중앙에 위치시키기
        scrollToNewestFilter()
    }
    
    //    // 가장 최근에 추가된 필터를 중앙에 위치시키는 함수
    //    private func scrollToNewestFilter() {
    //        let newIndexPath = IndexPath(item: filterImages.count, section: 0)
    //        
    //        // 실제 IndexPath는 EmptyCell을 고려해야 하므로 1을 더함
    //        let actualIndexPath = IndexPath(item: filterImages.count, section: 0)
    //        
    //        collectionView.scrollToItem(at: actualIndexPath, at: .centeredHorizontally, animated: true)
    //    }
    private func scrollToNewestFilter() {
        // 역순 정렬된 배열에서는 가장 최근 필터가 인덱스 0에 위치
        // EmptyCell을 고려하여 인덱스 1로 설정
        let newestIndexPath = IndexPath(item: 1, section: 0)
        collectionView.scrollToItem(at: newestIndexPath, at: .centeredHorizontally, animated: true)
    }

    
    
    
}
