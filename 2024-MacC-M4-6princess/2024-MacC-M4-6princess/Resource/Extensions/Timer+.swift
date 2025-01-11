//
//  Timer+.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 1/11/25.
//

import Foundation

enum TimerDuration: Int, CaseIterable {
    case off = 0
    case threeSeconds = 3
    case fiveSeconds = 5
    case sevenSeconds = 7
    
    var displayText: String {
        switch self {
        case .off: return ""
        case .threeSeconds: return "3"
        case .fiveSeconds: return "5"
        case .sevenSeconds: return "7"
        }
    }
    
    var icon: String {
        self == .off ? "timerIcon" : "timerSecondBGIcon"
    }
}
