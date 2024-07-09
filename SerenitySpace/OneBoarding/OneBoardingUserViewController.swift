//
//  OneBoardingUserViewController.swift
//  SerenitySpace
//
//  Created by Владимир Кацап on 08.07.2024.
//

import UIKit

class OneBoardingUserViewController: UIViewController {
    
    var oneView, twoView: UIView?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        createInterface()
    }
    
    func createInterface() {
        oneView = createView(text: "All food intake data in one app", image: .user1, action: 1)
        view.addSubview(oneView!)
        oneView?.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
        
        twoView = createView(text: "Edit and update your list", image: .user2, action: 2)
        twoView?.alpha = 0
        view.addSubview(twoView!)
        twoView?.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
        
    }
   

    
    func createView(text: String, image: UIImage, action: Int) -> UIView {
        let mainView = UIView()
        
        let imageView = UIImageView(image: image)
        mainView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
        
        let secondView = UIView()
        secondView.backgroundColor = .white
        secondView.layer.cornerRadius = 20
        mainView.addSubview(secondView)
        
        let label = UILabel()
        label.text = text
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 32, weight: .semibold)
        label.textColor = .black
        label.textAlignment = .center
        secondView.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(20)
        }
        
        let buttonNext: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("Next", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
            button.backgroundColor = UIColor(red: 255/255, green: 215/255, blue: 7/255, alpha: 1)
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 12
            return button
        }()
        secondView.addSubview(buttonNext)
        buttonNext.snp.makeConstraints { make in
            make.height.equalTo(54)
            make.width.equalTo(140)
            make.top.equalTo(label.snp.bottom).offset(30)
            make.right.equalToSuperview().inset(20)
        }
        
        let twoView = UIView()
        twoView.layer.cornerRadius = 2.5
        twoView.backgroundColor = action == 1 ? UIColor(red: 208/255, green: 208/255, blue: 208/255, alpha: 1) : .black
        secondView.addSubview(twoView)
        
        let oneView = UIView()
        oneView.layer.cornerRadius = 2.5
        oneView.backgroundColor = action == 1 ? .black : UIColor(red: 208/255, green: 208/255, blue: 208/255, alpha: 1)
        secondView.addSubview(oneView)
        
        
        twoView.snp.makeConstraints { make in
            make.height.equalTo(5)
            make.width.equalTo(40)
            make.right.equalTo(buttonNext.snp.left).offset(-65)
            make.centerY.equalTo(buttonNext.snp.centerY)
        }
        
        oneView.snp.makeConstraints { make in
            make.height.equalTo(5)
            make.width.equalTo(40)
            make.right.equalTo(twoView.snp.left).offset(-10)
            make.centerY.equalTo(buttonNext.snp.centerY)
        }
        
        secondView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(-20)
            make.top.equalTo(label.snp.top)
            make.bottom.equalTo(buttonNext.snp.bottom).offset(65)
        }
        
        
        if action == 1 {
            buttonNext.addTarget(self, action: #selector(nextPage), for: .touchUpInside)
        } else {
            buttonNext.addTarget(self, action: #selector(finishPage), for: .touchUpInside)
        }
        
        return mainView
    }
    
    @objc func nextPage() {
        UIView.animate(withDuration: 0.2) { [self] in
            oneView?.alpha = 0
            twoView?.alpha = 100
        }
    }
    
    @objc func finishPage() {
        self.navigationController?.setViewControllers([TabBarViewController()], animated: true)
    }
    
}
