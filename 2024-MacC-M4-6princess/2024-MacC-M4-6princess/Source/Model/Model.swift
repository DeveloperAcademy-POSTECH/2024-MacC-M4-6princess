//
//  Model.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 9/30/24.
//

import Foundation
import SwiftUI

// 편집 옵션 데이터 구조체 정의
struct IEEditingOption {
    let name: String
    let icon: String
    let range: ClosedRange<Float>
    var step: Float
}

struct History{
    var size:CGSize
    var loc:CGPoint
    var ang:Angle
    var sliderValues:[Float]
}

/// combin 기능
//init() {
//    // location 값이 변경될 때마다 출력
//    $location
//        .sink { newLocation in
//            print("location 변경됨: \(newLocation)")
//        }
//        .store(in: &cancellables) // 구독을 cancellables에 저장
//}
