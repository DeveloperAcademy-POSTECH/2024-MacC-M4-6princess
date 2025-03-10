//
//  FrameManager.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/20/24.
//

import Foundation
import SwiftUI

public final class FrameManager: ObservableObject {
    //온보딩 확인용
    //    @Published var firstTime = false
    @AppStorage("openFirstTime") var firstTime = false
    
    // 뷰 간 데이터를 공유하기 위한 변수들
    @Published var pickedImage: UIImage? = nil // PhotosPickerView에서 선택된 이미지
    @Published var removedImage: UIImage? = nil// DFFrameEditView에서 편집된 결과 이미지
    @Published var resultImage: UIImage? = nil // 최종 만들어지는 프레임 이미지
    @Published var showMFView = false //@@변수명이 뭘하는지 알수없음 showFrameSelect
    // 데이터를 가지고 있으면 의존성이 생김 따른 환경변수 생성 고려
    @Published var changedSubject: SubjectImage? = nil
    
    @Published var updateFrame: UUID? = nil
    @Published var selectedFrame: UUID? = nil //CoreData에서 선택한 프레임 id 받아옴
    @Published var isFrameLoading: Bool = false
    
    // 텍스트 수정뷰 관련 변수
    @Published var selectedTextStyle:TextStyle?
    @Published var showTextModifyView: Bool = false
    @Published var textUUID: UUID?
}
