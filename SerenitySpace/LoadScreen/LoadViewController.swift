//
//  LoadViewController.swift
//  SerenitySpace
//
//  Created by Владимир Кацап on 08.07.2024.
//

import UIKit
import SnapKit

class LoadViewController: UIViewController {
    
    var progressLabel: UILabel?
    var timer: Timer?
    var progress: Int = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        createInterface()
        startProgress()
    }
    

    func createInterface() {
        
        let imageView: UIImageView = {
            let image = UIImage(named: "load")
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.centerX.centerY.equalToSuperview()
            make.height.equalTo(390)
        }
        
    
        
        let activityView: UIActivityIndicatorView = {
            let activity = UIActivityIndicatorView(style: .medium)
            activity.isHidden = false
            return activity
        }()
        view.addSubview(activityView)
        activityView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).inset(-20)
            make.centerX.equalToSuperview().offset(-15)
            make.height.width.equalTo(22)
        }
        activityView.startAnimating()
        
        
        progressLabel = {
            let label = UILabel()
            label.text = "0%"
            label.font = .systemFont(ofSize: 17, weight: .regular)
            label.textColor = UIColor(red: 60/255, green: 60/255, blue: 67/255, alpha: 1)
            return label
        }()
        view.addSubview(progressLabel!)
        progressLabel?.snp.makeConstraints({ make in
            make.left.equalTo(activityView.snp.right).inset(-5)
            make.centerY.equalTo(activityView)
        })
        
    }
    
    
    func startProgress() {
        progress = 0
        progressLabel?.text = "\(progress)%"      //ПОРМЕНЯТЬ НА timeInterval: 0.07
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
    }
    
    @objc func updateProgress() {
            if progress < 100 {
                progress += 1
                progressLabel?.text = "\(progress)%"
            } else {
                timer?.invalidate()
                timer = nil
                if isUser == true {
                    if UserDefaults.standard.object(forKey: "tab") != nil {
                        self.navigationController?.setViewControllers([TabBarViewController()], animated: true)
                    } else {
                        self.navigationController?.setViewControllers([OneBoardingUserViewController()], animated: true)
                    }
                } else {
                    
                }
            }
        }

}


extension UIViewController {
    func hideNavigationBar() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func showNavigationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
