//
//  _024_MacC_M4_6princessApp.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 9/30/24.
//

import SwiftUI
import Firebase
import GoogleMobileAds


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
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        MobileAds.shared.start(completionHandler: nil)
        
        return true
    }
 
    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        //iPhone과 iPad 모두 세로만 지원
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        } else {
            return .portrait
        }
    }

}

// FrameSize 모델 정의
class EnvironmentModel: ObservableObject {
    var frameWidth: CGFloat = 300
    var frameHeight: CGFloat = 500
    var frameRatio: CGFloat = 4/3
    
    // 초기화 메서드 (필요 시 사용 가능)
    init(width: CGFloat = 100, height: CGFloat = 100,frameRatio: CGFloat = 1) {
        self.frameWidth = width
        self.frameHeight = height
    }
    
    // 사이즈 업데이트 메서드
    func updateSize(width: CGFloat, height: CGFloat,frameRatio: CGFloat) {
        self.frameWidth = width
        self.frameHeight = height
    }
}
