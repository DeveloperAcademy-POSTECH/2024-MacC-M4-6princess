//
//  NavigationManager.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/17/24.
//
import Foundation
import SwiftUI

// MARK: - NavigationManager
// @EnvironmentObject로 주입하여 전역적으로 사용 가능
public final class NavigationManager: ObservableObject {

    // NavigationPath는 현재 네비게이션 경로를 관리
    @Published public var route = NavigationPath()
    
    public init() { }
    
    /// 화면을 네비게이션 스택에 추가
    /// - Parameter screen: 이동할 화면의 열거형 값 또는 Hashable 타입
    @MainActor
    public func push<T: Hashable>(screen: T) {
        route.append(screen)
    }
//    naviManager.push(screen: .pho)
    /// 네비게이션 스택에서 마지막 화면 제거
    @MainActor
    public func pop() {
        route.removeLast()
    }
    
    /// 네비게이션 스택에서 지정된 깊이만큼 화면 제거
    /// - Parameter depth: 제거할 화면의 개수
    @MainActor
    public func pop(depth: Int) {
        route.removeLast(depth)
    }
    
    /// 네비게이션 스택을 초기화하여 루트로 이동
    @MainActor
    public func popToRoot() {
        route.removeLast(route.count)
    }
    
    /// 현재 화면을 교체 (현재 스택에서 마지막 화면 변경)
    /// - Parameter screen: 새로 설정할 화면
    @MainActor
    public func switchScreen<T: Hashable>(screen: T) {
        guard !route.isEmpty else { return } // 경로가 비어있으면 실행하지 않음
        var tempRoute = route // 현재 경로를 복사
        tempRoute.removeLast() // 마지막 화면 제거
        tempRoute.append(screen) // 새로운 화면 추가
        route = tempRoute // 경로를 업데이트
    }
}

// MARK: - Navigation 관련 화면 열거형
// 네비게이션에서 이동할 화면을 정의
// Hashable을 준수하여 NavigationPath에서 식별 가능
public enum Screen: Hashable {
    case photoPicker // PhotosPickerView 화면
    case frameEdit   // DFFrameEditView 화면
    case modifyFrame // DFModifyFrame 화면
    case testFrame
}

// MARK: - FeatureView
// Screen 열거형에 따라 적절한 뷰를 렌더링하는 컨테이너 뷰
struct FeatureView: View {
    let type: Screen // 현재 화면의 타입
    
    var body: some View {
        // Screen 타입에 따라 다른 뷰를 렌더링
        switch type {
            case .photoPicker:
                PhotosPickerView()
            case .frameEdit:
                DFFrameEditView()
            case .modifyFrame:
                DFFrameModifyView()
            case .testFrame:
                DFTestFrameView()
                
        }
    }
}



struct DFTestFrameView:View{
    @EnvironmentObject var naviManager:NavigationManager
    @EnvironmentObject var frameManager:FrameManager
    var body: some View{
        ZStack{
            Image(uiImage:frameManager.resultImage!)
        }
    }
}
