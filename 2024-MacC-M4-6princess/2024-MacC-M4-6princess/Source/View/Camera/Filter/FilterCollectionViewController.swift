//
//  FilterCollectionViewController.swift
//  InstaCamTest
//
//  Created by 김이예은 on 2/16/25.
//

import UIKit
import AVFoundation
import FirebaseAnalytics

class FilterCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var frameManager: FrameManager
    private let viewModel: CameraViewModel
    
    var collectionView: UICollectionView!
    var filterImages: [StoreImages]
    private var selectedFilter: ((UUID?) -> Void)?
    private var shutterButton: UIButton!
//    {
//        didSet{
//            print("selectedFilter:\(selectedFilter ?? nil)")
//        }
//    }
    var currentSelectedFilter: UUID? {
        didSet {
            scrollToSelectedFilter(animated: true)
            print("currentSelectedFilter:\(currentSelectedFilter ?? nil)")
        }
    }
    private let filterCellId = "FilterCell"
    private let emptyCellId = "EmptyCell"
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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollToSelectedFilter(animated: false)
    }
    
    func scrollToSelectedFilter(animated: Bool) {
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
        
        // 셔터버튼 여백 고려
        let inset = (view.bounds.width - centerCellSize) / 2
        collectionView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        
        // 셔터 버튼 설정
        setupShutterButton()
        
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
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        // 셔터 버튼 영역 계산
        let shutterFrame = shutterButton.convert(shutterButton.bounds, to: collectionView)
        
        // 선택하려는 셀의 프레임
        guard let cellAttributes = collectionView.layoutAttributesForItem(at: indexPath) else {
            return true
        }
        
        // 셔터 버튼과 겹치는지 확인
        if shutterFrame.intersects(cellAttributes.frame) {
            return false // 셔터 버튼과 겹치면 선택 불가
        }
        
        return true
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
                
                // 추가: resultImage를 강제로 업데이트
                frameManager.resultImage = selectedFilter.image.flatMap { UIImage(data: $0) }
            }
        }
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
        filterImages.append(newFilter)
        
        // collectionView의 데이터 소스를 갱신
        collectionView.reloadData()
        
        // collectionView의 레이아웃을 갱신
        collectionView.collectionViewLayout.invalidateLayout()
        
        // 가장 최근에 추가된 필터를 중앙에 위치시키기
        scrollToNewestFilter()
    }
    
    private func scrollToNewestFilter() {
        // 역순 정렬된 배열에서는 가장 최근 필터가 인덱스 0에 위치
        // EmptyCell을 고려하여 인덱스 1로 설정
        let newestIndexPath = IndexPath(item: 1, section: 0)
        collectionView.scrollToItem(at: newestIndexPath, at: .centeredHorizontally, animated: true)
    }

    private func setupShutterButton() {
        // 셔터 버튼 생성
        shutterButton = UIButton(type: .custom)
        shutterButton.setImage(UIImage(named: "shutterImage"), for: .normal)
        shutterButton.translatesAutoresizingMaskIntoConstraints = false
        
        // 버튼 크기 설정
        shutterButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        shutterButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        // 버튼 액션 추가
        shutterButton.addTarget(self, action: #selector(shutterButtonTapped), for: .touchUpInside)
        
        // 뷰에 버튼 추가
        view.addSubview(shutterButton)
        
        // 버튼 위치 설정 - 컬렉션뷰 중앙에 배치
        NSLayoutConstraint.activate([
            shutterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shutterButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 6)
        ])
        
        // 버튼을 컬렉션뷰 위에 표시하기 위해 z-index 조정
        view.bringSubviewToFront(shutterButton)
    }
    
    @objc private func shutterButtonTapped() {
        guard frameManager.selectedFrame != nil else {
            showAlert(message: "프레임이 선택되지 않았습니다. 프레임을 선택해주세요!")
            return
        }
        
        if frameManager.resultImage != nil {
            viewModel.isTakePic = true
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + viewModel.delayTime) {
                self.viewModel.takePic()
                self.viewModel.cameraManager.stopSession()
                Analytics.logEvent("A1_셔터버튼눌림", parameters: nil)
            }
        } else {
            showAlert(message: "프레임이 선택되지 않았습니다. 프레임을 선택해주세요!")
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(
            title: message,
            message: "",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "닫기", style: .cancel))
        present(alert, animated: true)
    }


    
    
}
