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
//    private var isUserScrolling = false
    var currentSelectedFilter: UUID? {
        didSet {
            print("currentSelectedFilter:\(currentSelectedFilter ?? nil)")
        }
    }
    private let filterCellId = "FilterCell"
    private let emptyCellId = "EmptyCell"
    private let cellSpacing: CGFloat = 20
    private let centerCellSize: CGFloat = 58
//    private let rightOfCenterCellSize: CGFloat = 50
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
        
        // 초기화 시 frameManager에서 선택된 프레임 복원
        if currentSelectedFilter == nil && frameManager.selectedFrame != nil {
            currentSelectedFilter = frameManager.selectedFrame
        }
        
        // 디버깅: 모든 프레임의 UUID와 createdDate 출력
        print("🔍 FilterCollectionViewController viewDidLoad - 총 프레임 수: \(filterImages.count)")
        for (index, image) in filterImages.enumerated() {
            print("🔍 프레임 \(index): UUID=\(image.uuid?.uuidString ?? "nil"), createdDate=\(image.createdDate?.description ?? "nil")")
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollToSelectedFilter(animated: false)
    }
    
    func scrollToSelectedFilter(animated: Bool) {
        // frameManager에서 선택된 프레임이 있지만 currentSelectedFilter가 없으면 복원
        if currentSelectedFilter == nil && frameManager.selectedFrame != nil {
            currentSelectedFilter = frameManager.selectedFrame
        }
        
        guard let selectedUUID = currentSelectedFilter else {
            print("⚠️ 선택된 UUID가 nil")
            let indexPath = IndexPath(item: 0, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
            return
        }
        
        // UUID가 nil이 아닌 프레임들만 필터링
        let validImages = filterImages.filter { $0.uuid != nil }
        guard let index = validImages.firstIndex(where: { $0.uuid == selectedUUID }) else { 
            print("선택된 프레임을 찾을 수 없음: \(selectedUUID)")
            // 선택된 프레임이 없으면 EmptyCell로 스크롤
            let indexPath = IndexPath(item: 0, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
            return 
        }
        
        let indexPath = IndexPath(item: index + 1, section: 0) // item이 0은 빈 셀이라 +1 해줌
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
        
        // 스크롤 후 선택 상태 업데이트
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.updateCellSizesAndSpacing()
        }
    }
    
    private func setupCollectionView() {
        let layout = CustomFlowLayout()
        layout.scrollDirection = .horizontal
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.decelerationRate = .normal
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
                // UUID가 nil이 아닌지 확인
                guard let uuid = filter.uuid else {
                    print("⚠️ UUID가 nil인 프레임 발견: 인덱스 \(filterIndex)")
                    cell.configure(with: UIImage(), size: 0, isSelected: false)
                    return cell
                }
                
                if let imageData = filter.image, let uiImage = UIImage(data: imageData) {
                    let isSelected = uuid == currentSelectedFilter
                    cell.configure(with: uiImage, size: 0, isSelected: isSelected)
                } else {
                    print("⚠️ 이미지 데이터가 nil인 프레임: \(uuid)")
                    cell.configure(with: UIImage(), size: 0, isSelected: false)
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

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 스크롤 중에도 부드러운 애니메이션으로 셀 크기 업데이트
        // 애니메이션 중복 방지를 위해 즉시 실행
        updateCellSizesOnly()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // 드래그 시작 시 중앙이동 비활성화
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // 스크롤이 완전히 멈춘 후에만 중앙이동
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.smoothCenterOnClosestCell()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            // 드래그가 끝나고 감속이 없으면 중앙이동
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.smoothCenterOnClosestCell()
            }
        }
    }
    
    // 스크롤 중에는 셀 크기만 업데이트 (중앙이동 없이)
    private func updateCellSizesOnly() {
        // 모든 보이는 셀의 크기와 테두리만 업데이트
        for cell in collectionView.visibleCells {
            guard let cellIndexPath = collectionView.indexPath(for: cell) else { continue }
            if let filterCell = cell as? FilterCell {
                let filterIndex = cellIndexPath.item - 1
                if filterIndex >= 0 && filterIndex < filterImages.count {
                    let filter = filterImages[filterIndex]
                    if let imageData = filter.image, let uiImage = UIImage(data: imageData) {
                        // UUID를 직접 비교하여 선택 상태 결정
                        let isSelected = filter.uuid == currentSelectedFilter
                        filterCell.configure(with: uiImage, size: 0, isSelected: isSelected)
                    }
                }
            }
        }
        
        // 레이아웃 업데이트를 부드럽게
        UIView.animate(withDuration: 0.1, delay: 0, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.collectionView.layoutIfNeeded()
        })
    }
    
    // 부드러운 중앙이동 (스크롤 완료 후에만 호출)
    private func smoothCenterOnClosestCell() {
        let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
        guard let closestCell = collectionView.visibleCells
            .min(by: { abs($0.frame.midX - centerX) < abs($1.frame.midX - centerX) }),
              let indexPath = collectionView.indexPath(for: closestCell) else {
            return
        }
        
        // 부드러운 애니메이션으로 중앙이동
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            self.collectionView.layoutIfNeeded()
        }) { _ in
            // 애니메이션 완료 후 필터 선택
            if indexPath.item == 0 {
                self.selectedFilter?(nil)
                self.currentSelectedFilter = nil
                self.frameManager.selectedFrame = nil
                self.frameManager.resultImage = nil
            } else {
                let filterIndex = indexPath.item - 1
                if filterIndex >= 0 && filterIndex < self.filterImages.count {
                    let selectedFilter = self.filterImages[filterIndex]
                    
                    // UUID가 유효한지 확인
                    guard let uuid = selectedFilter.uuid else {
                        print("smoothCenterOnClosestCell - 선택된 필터의 UUID가 nil입니다")
                        return
                    }
                    
                    self.selectedFilter?(uuid)
                    self.currentSelectedFilter = uuid
                    self.frameManager.selectedFrame = uuid
                    self.frameManager.resultImage = selectedFilter.image.flatMap { UIImage(data: $0) }
                    
                    // 디버깅을 위한 로그
                    print("🎯 smoothCenterOnClosestCell - 선택된 프레임: \(uuid), 인덱스: \(filterIndex), 총 프레임 수: \(self.filterImages.count)")
                }
            }
            
            // 모든 셀의 크기와 테두리 상태 업데이트
            self.updateCellSizesAndSpacing()
        }
        
        frameManager.isFrameLoading = true
    }
    
    //가까운 셀을 중앙으로 위치 이동 (기존 메서드 - 탭 시 사용)
    private func centerOnClosestCell() {
        let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
        guard let closestCell = collectionView.visibleCells
            .min(by: { abs($0.frame.midX - centerX) < abs($1.frame.midX - centerX) }),
              let indexPath = collectionView.indexPath(for: closestCell) else {
            return
        }
        
        // 빠른 위치 조정 애니메이션
        UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            self.collectionView.layoutIfNeeded()
        }) { _ in
            // 애니메이션 후 필터 선택
            if indexPath.item == 0 {
                self.selectedFilter?(nil)
                self.currentSelectedFilter = nil
                self.frameManager.selectedFrame = nil
                self.frameManager.resultImage = nil
            } else {
                let filterIndex = indexPath.item - 1
                if filterIndex >= 0 && filterIndex < self.filterImages.count {
                    let selectedFilter = self.filterImages[filterIndex]
                    
                    // UUID가 유효한지 확인
                    guard let uuid = selectedFilter.uuid else {
                        print("centerOnClosestCell - 선택된 필터의 UUID가 nil입니다")
                        return
                    }
                    
                    self.selectedFilter?(uuid)
                    self.currentSelectedFilter = uuid
                    self.frameManager.selectedFrame = uuid
                    self.frameManager.resultImage = selectedFilter.image.flatMap { UIImage(data: $0) }
                    
                    // 디버깅을 위한 로그
                    print("🎯 centerOnClosestCell - 선택된 프레임: \(uuid), 인덱스: \(filterIndex), 총 프레임 수: \(self.filterImages.count)")
                }
            }
            
            // 모든 셀의 크기와 테두리 상태 업데이트
            self.updateCellSizesAndSpacing()
        }
        
        frameManager.isFrameLoading = true
    }

    
    
    private func updateCellSizesAndSpacing() {
        // 모든 보이는 셀의 크기와 테두리만 업데이트 (선택 상태 변경 없이)
        for cell in collectionView.visibleCells {
            guard let cellIndexPath = collectionView.indexPath(for: cell) else { continue }
            if let filterCell = cell as? FilterCell {
                let filterIndex = cellIndexPath.item - 1
                if filterIndex >= 0 && filterIndex < filterImages.count {
                    let filter = filterImages[filterIndex]
                    if let imageData = filter.image, let uiImage = UIImage(data: imageData) {
                        // UUID를 직접 비교하여 선택 상태 결정
                        let isSelected = filter.uuid == currentSelectedFilter
                        filterCell.configure(with: uiImage, size: 0, isSelected: isSelected)
                    }
                }
            }
        }
        
        // 레이아웃 업데이트를 부드럽게
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.collectionView.layoutIfNeeded()
        })
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //     self.collectionView.layoutIfNeeded()
        // }) { _ in
        //     // 애니메이션 완료 후 필터 선택 상태 업데이트
        //     if indexPath.item == 0 {
        //         self.selectedFilter?(nil)
        //         self.currentSelectedFilter = nil
        //         self.frameManager.selectedFrame = nil
        //         self.frameManager.resultImage = nil
        //     } else {
        //         let filterIndex = indexPath.item - 1
        //         if filterIndex >= 0 && filterIndex < self.filterImages.count {
        //             let selectedFilter = self.filterImages[filterIndex]
        //             self.selectedFilter?(selectedFilter.uuid)
        //             self.currentSelectedFilter = selectedFilter.uuid
        //             self.frameManager.selectedFrame = selectedFilter.uuid
        //             self.frameManager.resultImage = selectedFilter.image.flatMap { UIImage(data: $0) }
        //         }
        //     }
        //     // 셀 크기 및 테두리 업데이트
        //     self.updateCellSizesAndSpacing()
        // }
        
        
        // 탭 시 애니메이션 없이 바로 중앙 정렬
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        collectionView.layoutIfNeeded()
        // 필터 선택 상태 갱신
        if indexPath.item == 0 {
            self.selectedFilter?(nil)
            self.currentSelectedFilter = nil
            self.frameManager.selectedFrame = nil
            self.frameManager.resultImage = nil
        } else {
            let filterIndex = indexPath.item - 1
            if filterIndex >= 0 && filterIndex < self.filterImages.count {
                let selectedFilter = self.filterImages[filterIndex]
                
                // UUID가 유효한지 확인
                guard let uuid = selectedFilter.uuid else {
                    print("didSelectItemAt - 선택된 필터의 UUID가 nil입니다")
                    return
                }
                
                self.selectedFilter?(uuid)
                self.currentSelectedFilter = uuid
                self.frameManager.selectedFrame = uuid
                self.frameManager.resultImage = selectedFilter.image.flatMap { UIImage(data: $0) }
                
                // 디버깅을 위한 로그
                print("🎯 didSelectItemAt - 선택된 프레임: \(uuid), 인덱스: \(filterIndex), 총 프레임 수: \(self.filterImages.count)")
            }
        }
        self.updateCellSizesAndSpacing()
        self.frameManager.isFrameLoading = true
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
        
        // 버튼 위치 설정 - 컬렉션뷰와 같은 높이로 배치
        NSLayoutConstraint.activate([
            shutterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shutterButton.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor)
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
