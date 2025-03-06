//
//  GoogleAdIOBottomBannerView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 3/6/25.
//

import SwiftUI
import GoogleMobileAds
struct BannerViewContainer: UIViewRepresentable {
    let adSize: AdSize
    let testUnitID: String = "ca-app-pub-3940256099942544/2435281174"
    let trueUnitId: String = "ca-app-pub-4729766298899130/4801686952"
    init(_ adSize: AdSize) {
        self.adSize = adSize
    }
    
    func makeUIView(context: Context) -> UIView {
        // Wrap the GADBannerView in a UIView. GADBannerView automatically reloads a new ad when its
        // frame size changes; wrapping in a UIView container insulates the GADBannerView from size
        // changes that impact the view returned from makeUIView.
        let view = UIView()
        view.addSubview(context.coordinator.bannerView)
        return view
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
        
        let parent: BannerViewContainer
        
        init(_ parent: BannerViewContainer) {
            self.parent = parent
        }
    }
}
