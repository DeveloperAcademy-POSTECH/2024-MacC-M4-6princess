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
