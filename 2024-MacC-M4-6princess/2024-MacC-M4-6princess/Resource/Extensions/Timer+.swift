//
//  Timer+.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 1/11/25.
//

import Foundation

enum TimerState: Int, CaseIterable {
    case off = 0
    case threeSeconds = 1
    case fiveSeconds = 2
    case sevenSeconds = 3
    
    var duration: TimeInterval {
        switch self {
        case .off: return 0
        case .threeSeconds: return 3
        case .fiveSeconds: return 5
        case .sevenSeconds: return 7
        }
    }
    
    var icon: String {
        switch self {
        case .off: return "timerIcon"
        case .threeSeconds, .fiveSeconds, .sevenSeconds: return "timerSecondBGIcon"
        }
    }
    
    var displayText: String? {
        switch self {
        case .off: return nil
        case .threeSeconds: return "3"
        case .fiveSeconds: return "5"
        case .sevenSeconds: return "7"
        }
    }
}
