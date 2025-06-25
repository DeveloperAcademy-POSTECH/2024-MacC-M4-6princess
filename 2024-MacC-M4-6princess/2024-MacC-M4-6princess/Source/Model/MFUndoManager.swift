//
//  MFUndoManager.swift
//  2024-MacC-M4-6princess
//
//  Created by piri kim on 6/23/25.
//

import Foundation

/// MFUndoManager
/// 제네릭 타입(T: NSCopying) 배열 기반의 Undo/Redo 기능을 제공하는 매니저 클래스
/// 내부적으로 undoStack / redoStack 을 관리하며 최대 depth 제한 가능
/// 사용 시: 상태 변경 직전에 push() 호출 → undo()/redo() 를 통해 상태 복원
class MFUndoManager<T: NSCopying> {
    
    /// Undo Stack (최대 50단계로 제한 가능)
    /// 현재 상태 이전의 기록들을 저장
    private(set) var undoStack: [[T]] = []
    
    /// Redo Stack
    /// Undo 후 다시 앞으로 되돌릴 기록 저장
    private(set) var redoStack: [[T]] = []
    
    /// 현재 상태를 UndoStack 에 저장
    /// 상태 변경 전에 반드시 호출할 것!
    /// - Parameter list: 현재 상태 리스트
    func push(_ list: [T],
              file: String = #file,
              function: String = #function,
              line: Int = #line) {
        
        let startTime = CFAbsoluteTimeGetCurrent()
        undoStack.append(copyList(list))
        
        if undoStack.count > 50 {
            undoStack.removeFirst()
        }
        redoStack.removeAll()
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let elapsed = (endTime - startTime) * 1000  // ms 단위
        
        let filename = (file as NSString).lastPathComponent
        
        print("✅ [UndoManager] push() 시간: \(String(format: "%.2f", elapsed)) ms (list.count: \(list.count)) → \(filename):\(line) \(function)")
    }
    
    
    /// Undo 기능 - 이전 상태 복원
    /// - Parameter list: 현재 상태 리스트 (inout 으로 직접 변경)
    func undo(list: inout [T]) {
        // undoStack 에 기록이 없으면 리턴
        guard let previous = undoStack.popLast() else { return }
        
        // 현재 상태를 redoStack 에 저장
        redoStack.append(copyList(list))
        
        // 이전 상태로 복원
        list = previous
    }
    
    /// Redo 기능 - 앞으로 상태 복원
    /// - Parameter list: 현재 상태 리스트 (inout 으로 직접 변경)
    func redo(list: inout [T]) {
        // redoStack 에 기록이 없으면 리턴
        guard let next = redoStack.popLast() else { return }
        
        // 현재 상태를 undoStack 에 저장
        undoStack.append(copyList(list))
        
        // 이후 상태로 복원
        list = next
    }
    
    /// 내부적으로 리스트 전체 deep copy 를 수행
    /// - Parameter list: 복사 대상 리스트
    /// - Returns: deep copy 된 새로운 리스트
    private func copyList(_ list: [T]) -> [T] {
        return list.map { $0.copy() as! T }
    }
}

