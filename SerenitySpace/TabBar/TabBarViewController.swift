//
//  TabBarViewController.swift
//  SerenitySpace
//
//  Created by Владимир Кацап on 08.07.2024.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.backgroundColor = .black
        settingsTab()
        tabBar.unselectedItemTintColor = UIColor(red: 251/255, green: 243/255, blue: 179/255, alpha: 1)
        tabBar.tintColor = UIColor(red: 255/255, green: 215/255, blue: 7/255, alpha: 1)
        
        user = loadUser()
    }
    
    
    func settingsTab() {
        let racionVC = RacionViewController()
        let racionTabItem = UITabBarItem(title: "", image: .tab1.resize(targetSize: CGSize(width: 24, height: 24)), tag: 0)
        racionVC.tabBarItem = racionTabItem
        
        let waterVC = WaterViewController()
        let waterTabItem = UITabBarItem(title: "", image: .tab2.resize(targetSize: CGSize(width: 24, height: 24)), tag: 0)
        waterVC.tabBarItem = waterTabItem
        
        viewControllers = [racionVC, waterVC]
        
    }
    
    func loadUser() -> User? {
        if let userData = UserDefaults.standard.data(forKey: "user") {
            do {
                let decoder = JSONDecoder()
                let user = try decoder.decode(User.self, from: userData)
                return user
            } catch {
                print("Failed to decode user: \(error)")
            }
        }
        return nil
    }

    

}



extension UIImage {
    func resize(targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
