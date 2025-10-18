//
//  _024_MacC_M4_6princessApp.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 9/30/24.
//

import SwiftUI
import Firebase
import GoogleMobileAds
import IQKeyboardManagerSwift

@main
struct _024_MacC_M4_6princessApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var environmentModel = EnvironmentModel()
    @StateObject private var frameManager = FrameManager()
    @StateObject private var naviManager = NavigationManager()
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext,
                              persistenceController.container.viewContext)
                .environmentObject(environmentModel)
                .environmentObject(naviManager)
                .environmentObject(frameManager)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        MobileAds.shared.start(completionHandler: nil)
        
        configureIQKeyboardManager()
        
        return true
    }
    
    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        // iPhone과 iPad 모두 세로만 지원
        return .portrait
    }
    
    // MARK: - Private Methods
    
    private func configureIQKeyboardManager() {
        let iq = IQKeyboardManager.shared
        
        // UIKit 뷰 컨트롤러에서 사용 가능하도록 활성화
        iq.isEnabled = true
        iq.enableAutoToolbar = false
        iq.resignOnTouchOutside = true
        iq.keyboardDistance = 20
        
        // DFTextViewController에서는 수동으로 키보드 처리
        iq.disabledDistanceHandlingClasses = [DFTextViewController.self]
    }
}

// MARK: - EnvironmentModel

final class EnvironmentModel: ObservableObject {
    @Published var frameWidth: CGFloat
    @Published var frameHeight: CGFloat
    @Published var frameRatio: CGFloat
    
    init(width: CGFloat = 100, height: CGFloat = 100, frameRatio: CGFloat = 1) {
        self.frameWidth = width
        self.frameHeight = height
        self.frameRatio = frameRatio
    }
    
    func updateSize(width: CGFloat, height: CGFloat, frameRatio: CGFloat) {
        self.frameWidth = width
        self.frameHeight = height
        self.frameRatio = frameRatio
    }
}
