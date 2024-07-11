//
//  SettingsViewController.swift
//  SerenitySpace
//
//  Created by Владимир Кацап on 11.07.2024.
//

import UIKit
import StoreKit
import WebKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        settingsView()
    }
    

    func settingsView() {
        
        let imageView = UIImageView(image: .background)
        
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
        
        let setLabel = UILabel()
        setLabel.text = "Settings"
        setLabel.font = .systemFont(ofSize: 34, weight: .bold)
        setLabel.textColor = .black
        view.addSubview(setLabel)
        setLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(40)
        }
        
        let shareBut = createButton(title: "Share app")
        view.addSubview(shareBut)
        shareBut.snp.makeConstraints { make in
            make.height.equalTo(80)
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(setLabel.snp.bottom).inset(-30)
        }
        shareBut.addTarget(self, action: #selector(shareApp), for: .touchUpInside)
        
        
        let rateBut = createButton(title: "Rate Us")
        view.addSubview(rateBut)
        rateBut.snp.makeConstraints { make in
            make.height.equalTo(80)
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(shareBut.snp.bottom).inset(-15)
        }
        rateBut.addTarget(self, action: #selector(rateApp), for: .touchUpInside)
       
        
        let usageBut = createButton(title: "Usage Policy")
        view.addSubview(usageBut)
        usageBut.snp.makeConstraints { make in
            make.height.equalTo(80)
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(rateBut.snp.bottom).inset(-15)
        }
        usageBut.addTarget(self, action: #selector(policy), for: .touchUpInside)
        
    }
    
    
    func createButton(title: String) -> UIButton {
        let butt = UIButton(type: .system)
        butt.layer.cornerRadius = 12
        butt.layer.shadowColor = UIColor.black.cgColor
        butt.layer.shadowOpacity = 0.25
        butt.layer.shadowOffset = CGSize(width: 0, height: 2)
        butt.layer.shadowRadius = 4
        butt.layer.masksToBounds = false
        butt.backgroundColor = .white
        
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .black
        
        butt.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(15)
        }
        
        let imageView = UIImageView(image: .but)
        imageView.backgroundColor = .clear
        butt.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.height.width.equalTo(40)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(15)
        }
        return butt
    }
    
    
    
    
    @objc func shareApp() {
        let appURL = URL(string: "https://apps.apple.com/app/gainsguru/id6526495618")!
        let activityViewController = UIActivityViewController(activityItems: [appURL], applicationActivities: nil)
        
        // Настройка для показа в виде popover на iPad
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }

        self.present(activityViewController, animated: true, completion: nil)
    }
    
    
    @objc func rateApp() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            if let url = URL(string: "https://apps.apple.com/app/gainsguru/id6526495618") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    
    @objc func policy() {
        let webVC = WebViewController()
        webVC.urlString = "https://www.termsfeed.com/live/20e7917c-4e12-44cf-9b01-da5f8cea8760"
        present(webVC, animated: true, completion: nil)
    }
    
}



class WebViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var urlString: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
        
        // Загружаем URL
        if let urlString = urlString, let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
    }
}
