//
//  TrackingScreen.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 12/3/24.
//

import Foundation

struct Tracking {
    // 사용할 때 불필요하게 인스턴스화 하지 않도록 하기 위함.
    private init() { }

    struct Screen {
        private init() { }

        static let cameraView = "A1_카메라"
        static let manageFrame = "A2_프레임관리"
        static let photosPicker = "A3_사진선택"
        static let frameEdit = "A4_누끼따기"
        static let frameModity = "A5_프레임수정"
        static let photoSave = "A6_사진저장" //사진 저장 개수 측정
    }

    struct Event {
        private init() { }

        static let take_picture = "A1_셔터버튼눌림"
        static let create_frame = "A2_새로운프레임만들기"
        static let select_frame = "A2_프레임선택"
        static let select_photo = "A3_갤러리사진선택"
        static let save_frame = "A5_프레임저장"
        
    }
}
