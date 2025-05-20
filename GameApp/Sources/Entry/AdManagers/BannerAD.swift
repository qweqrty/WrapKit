import SwiftUI
import GoogleMobileAds

// ca-app-pub-3940256099942544/2435281174

//struct BannerAd: UIViewControllerRepresentable {
//    
//    func makeUIViewController(context: Context) -> some UIViewController {
//        let view = BannerView(adSize: AdSizeBanner)
//        let viewController = UIViewController()
//        view.adUnitID = "ca-app-pub-3940256099942544/2435281174"
//        view.rootViewController = viewController
//        viewController.view.addSubview(view)
//        viewController.view.frame = CGRect(origin: .zero, size: AdSizeBanner.size)
//        view.load(Request())
//        return viewController
//    }
//    
//    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
//    }
//}

struct BannerAd: UIViewControllerRepresentable {
    let adSize: AdSize
    
    init(adSize: AdSize) {
        self.adSize = adSize
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let bannerView = BannerView(adSize: adSize)
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2435281174"
        bannerView.rootViewController = viewController
        viewController.view.addSubview(bannerView)
        
        // Устанавливаем размер фрейма для viewController на основе размера баннера
        viewController.view.frame = CGRect(origin: .zero, size: adSize.size)
        bannerView.frame = viewController.view.frame
        
        // Загружаем рекламу
        bannerView.load(Request())
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Обновление не требуется, но метод должен быть реализован
    }
}

