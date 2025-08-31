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
    
    var currentSelectedFilter: UUID? {
        didSet {
            print("currentSelectedFilter: \(currentSelectedFilter?.uuidString ?? "nil")")
            updateSelectedIndexPath()
        }
    }
    
    var selectedIndexPath: IndexPath? {
        didSet {
            if let indexPath = selectedIndexPath {
                collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }
        }
    }
    
    private func updateSelectedIndexPath() {
        if let uuid = currentSelectedFilter,
           let index = filterImages.firstIndex(where: { $0.uuid == uuid }) {
            selectedIndexPath = IndexPath(item: index + 1, section: 0)
        } else {
            selectedIndexPath = IndexPath(item: 0, section: 0)
        }
    }
    
    private let filterCellId = "FilterCell"
    private let emptyCellId = "EmptyCell"
    private let centerCellSize: CGFloat = 58
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
        
        if currentSelectedFilter == nil && frameManager.selectedFrame != nil {
            currentSelectedFilter = frameManager.selectedFrame
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollToSelectedFilter(animated: false)
    }
    
    // MARK: - Setup
    
    private func setupCollectionView() {
        let layout = CustomFlowLayout()
        layout.scrollDirection = .horizontal
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.decelerationRate = UIScrollView.DecelerationRate(rawValue: 0.6)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(FilterCell.self, forCellWithReuseIdentifier: filterCellId)
        collectionView.register(EmptyCell.self, forCellWithReuseIdentifier: emptyCellId)
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        let inset = (view.bounds.width - centerCellSize) / 2
        collectionView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        
        setupShutterButton()
    }
    
    private func setupShutterButton() {
        shutterButton = UIButton(type: .custom)
        shutterButton.setImage(UIImage(named: "shutterImage"), for: .normal)
        shutterButton.translatesAutoresizingMaskIntoConstraints = false
        
        shutterButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        shutterButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
        shutterButton.addTarget(self, action: #selector(shutterButtonTapped), for: .touchUpInside)
        
        view.addSubview(shutterButton)
        NSLayoutConstraint.activate([
            shutterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shutterButton.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor)
        ])
        
        view.bringSubviewToFront(shutterButton)
    }
    
    // MARK: - CollectionView DataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterImages.count + 1 // EmptyCell 포함
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
                guard let uuid = filter.uuid else {
                    cell.configure(with: UIImage(), size: 0, isSelected: false)
                    return cell
                }
                
                if let imageData = filter.image, let uiImage = UIImage(data: imageData) {
                    let isSelected = uuid == currentSelectedFilter
                    cell.configure(with: uiImage, size: 0, isSelected: isSelected)
                } else {
                    cell.configure(with: UIImage(), size: 0, isSelected: false)
                }
            }
            return cell
        }
    }
    
    // MARK: - CollectionView Delegate
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let shutterFrame = shutterButton.convert(shutterButton.bounds, to: collectionView)
        guard let cellAttributes = collectionView.layoutAttributesForItem(at: indexPath) else {
            return true
        }
        
        return !shutterFrame.intersects(cellAttributes.frame)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 먼저 필터 선택
        self.selectFilterAtIndex(indexPath)
        
        // 자연스러운 중앙 이동 애니메이션
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.6, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            self.collectionView.layoutIfNeeded()
        }) { _ in
            // 애니메이션 완료 후 상태 업데이트
            self.updateCellSelectionState()
        }
    }
    
    // MARK: - ScrollView Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isTracking {
            UIView.animate(withDuration: 0.1, delay: 0, options: [.allowUserInteraction, .curveEaseOut], animations: {
                self.collectionView.collectionViewLayout.invalidateLayout()
            })
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.selectClosestCellToCenter()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.selectClosestCellToCenter()
            }
        }
    }
    
    // MARK: - Filter Selection
    
    private func selectFilterAtIndex(_ indexPath: IndexPath) {
        if indexPath.item == 0 {
            selectedFilter?(nil)
            currentSelectedFilter = nil
            frameManager.selectedFrame = nil
            frameManager.resultImage = nil
            frameManager.updateFrame = nil
        } else {
            let filterIndex = indexPath.item - 1
            if filterIndex >= 0 && filterIndex < filterImages.count {
                let selectedFilter = filterImages[filterIndex]
                guard let uuid = selectedFilter.uuid else { return }
                
                // 상태 업데이트 순서 변경
                currentSelectedFilter = uuid
                frameManager.selectedFrame = uuid
                
                if let imageData = selectedFilter.image {
                    frameManager.resultImage = UIImage(data: imageData)
                }
                
                // 마지막으로 콜백 호출
                self.selectedFilter?(uuid)
            }
        }
    }
    
    private func selectClosestCellToCenter() {
        let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
        
        // 현재 화면에 보이는 셀들 중에서 중앙에 가장 가까운 셀 찾기
        guard let layoutAttributes = collectionView.collectionViewLayout.layoutAttributesForElements(in: collectionView.bounds) else { return }
        
        var closestIndexPath: IndexPath?
        var minDistance: CGFloat = CGFloat.greatestFiniteMagnitude
        
        for attribute in layoutAttributes {
            let distance = abs(attribute.center.x - centerX)
            if distance < minDistance {
                minDistance = distance
                closestIndexPath = attribute.indexPath
            }
        }
        
        guard let indexPath = closestIndexPath else { return }
        
        // 가장 가까운 셀을 선택하고 중앙으로 이동
        selectFilterAtIndex(indexPath)
        
        // 자연스러운 중앙 이동 애니메이션
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            self.collectionView.layoutIfNeeded()
        }) { _ in
            self.updateCellSelectionState()
        }
    }
    
    private func updateCellSelectionState() {
        for cell in collectionView.visibleCells {
            guard let cellIndexPath = collectionView.indexPath(for: cell) else { continue }
            if let filterCell = cell as? FilterCell {
                let filterIndex = cellIndexPath.item - 1
                if filterIndex >= 0 && filterIndex < filterImages.count {
                    let filter = filterImages[filterIndex]
                    if let imageData = filter.image, let uiImage = UIImage(data: imageData) {
                        let isSelected = filter.uuid == currentSelectedFilter
                        filterCell.configure(with: uiImage, size: 0, isSelected: isSelected)
                    }
                }
            }
        }
    }
    
    func scrollToSelectedFilter(animated: Bool) {
        if currentSelectedFilter == nil && frameManager.selectedFrame != nil {
            currentSelectedFilter = frameManager.selectedFrame
        }
        
        guard let selectedUUID = currentSelectedFilter else {
            let indexPath = IndexPath(item: 0, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
            return
        }
        
        if let index = filterImages.firstIndex(where: { $0.uuid == selectedUUID }) {
            let indexPath = IndexPath(item: index + 1, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.updateCellSelectionState()
            }
        }
    }
    
    // MARK: - Public Methods
    
    func addNewFilter(_ newFilter: StoreImages) {
        filterImages.append(newFilter)
        collectionView.reloadData()
        collectionView.collectionViewLayout.invalidateLayout()
        
        let newestIndexPath = IndexPath(item: 1, section: 0)
        collectionView.scrollToItem(at: newestIndexPath, at: .centeredHorizontally, animated: true)
    }
    
    // MARK: - Actions
    
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
        let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "닫기", style: .cancel))
        present(alert, animated: true)
    }
}

