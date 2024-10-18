//
//  Model.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 9/30/24.
//

import Foundation

// 편집 옵션 데이터 구조체 정의
struct IEEditingOption {
    let name: String
    let icon: String
    let range: ClosedRange<Float>
    var step: Float
}
