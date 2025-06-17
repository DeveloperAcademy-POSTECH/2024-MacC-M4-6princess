//
//  GoogleAdIOBottomBannerView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 3/6/25.
//

import SwiftUI
import GoogleMobileAds
struct IOBottomBannerAdMob: UIViewRepresentable {
    let adSize: AdSize
    let testUnitID: String = "ca-app-pub-3940256099942544/2435281174"
    let trueUnitID: String = "ca-app-pub-4729766298899130/4801686952"
    init(_ adSize: AdSize) {
        self.adSize = adSize
    }
    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        let banner = context.coordinator.bannerView
        banner.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(banner)

        // 명확한 위치와 크기 지정
        NSLayoutConstraint.activate([
            banner.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            banner.topAnchor.constraint(equalTo: container.topAnchor),
            banner.widthAnchor.constraint(equalToConstant: adSize.size.width),
            banner.heightAnchor.constraint(equalToConstant: adSize.size.height)
        ])

        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.bannerView.adSize = adSize
    }
    
    func makeCoordinator() -> BannerCoordinator {
        return BannerCoordinator(self)
    }
    class BannerCoordinator: NSObject, BannerViewDelegate {
        
        private(set) lazy var bannerView: BannerView = {
            let banner = BannerView(adSize: parent.adSize)
            banner.adUnitID = self.parent.testUnitID
            banner.load(Request())
            banner.delegate = self
            return banner
        }()
        
        let parent: IOBottomBannerAdMob
        
        init(_ parent: IOBottomBannerAdMob) {
            self.parent = parent
        }
    }
}
