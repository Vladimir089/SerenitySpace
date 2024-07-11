//
//  WaterViewController.swift
//  SerenitySpace
//
//  Created by Владимир Кацап on 10.07.2024.
//

import UIKit

class WaterViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //diagramm
    let pieChartView = UIView()
    var pieChartLayer = CAShapeLayer()
    
    //data
    var atHomeWater = ["0","0"]
    var tripsWater = ["0","0"]
    
    //segmented
    var selectedArea = "At home"
    var segmentedControl: UISegmentedControl?
    
    //collection
    var atHomeEat = [Eat]()
    var tripsEat = [Eat]()
    var collectionView: UIView?
    var collection: UICollectionView?
    var stocksLabel: UILabel?
    var topView: UIView?
    
    //adding new view
    var newView: UIView?
    var newImageView: UIImageView?
    var newNameTextField: UITextField?
    var mewQualTextField: UITextField?
    var newSaveButton: UIButton?
    var isEditingValue = false
    var indexEdit = 0
    
    //top view
    var spentWaterTextField = {
        let textField = UITextField()
        textField.textColor = .black
        textField.placeholder = "Text"
        textField.borderStyle = .none
        textField.keyboardType = .numberPad
        textField.isUserInteractionEnabled = true
        return textField
    }()
    var allWaterTextField = {
        let textField = UITextField()
        textField.textColor = .black
        textField.placeholder = "Text"
        textField.borderStyle = .none
        textField.keyboardType = .numberPad
        textField.isUserInteractionEnabled = true
        return textField
    }()
    var waterDataLabel: UILabel?
    var saveButton: UIButton?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        settingsView()
        checkWaterUserDef()
        loadData()
    }
    
    func loadData() {
        atHomeEat = loadHomeArrFromFile() ?? [Eat]()
        tripsEat = loadTripsArrFromFile() ?? [Eat]()
        checkCollection()
        
        if selectedArea == "At home" {
            collection?.snp.remakeConstraints({ make in
                
                if atHomeEat.count > 5 {
                    make.bottom.equalToSuperview()
                } else {
                    make.height.equalTo(atHomeEat.count * 84)
                }
                
                make.left.right.equalToSuperview().inset(15)
                make.top.equalTo(stocksLabel!.snp.bottom).inset(-15)
            })
            
         
            
            collectionView?.snp.remakeConstraints({ make in
                make.left.right.equalToSuperview().inset(15)
                make.top.equalTo(topView!.snp.bottom).inset(-20)
                make.height.equalTo(collection!.snp.height).inset(-30)
            })
            
        } else {
            
            collection?.snp.remakeConstraints({ make in
                if tripsEat.count > 5 {
                    make.bottom.equalToSuperview()
                } else {
                    make.height.equalTo(tripsEat.count * 84)
                }
                
                make.left.right.equalToSuperview().inset(15)
                make.top.equalTo(stocksLabel!.snp.bottom).inset(-15)
            })
            
            
            
            collectionView?.snp.remakeConstraints({ make in
                make.left.right.equalToSuperview().inset(15)
                make.top.equalTo(topView!.snp.bottom).inset(-20)
                make.height.equalTo(collection!.snp.height).inset(-30)
            })
        }

        collection?.reloadData()
        
    }
    
    
    
    //СОХРАНЕНИЕ В ФАЙЛ
    func saveArrHome(data: Data) throws {
        print(123)
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath = documentDirectory.appendingPathComponent("Home.plist")
            try data.write(to: filePath)
        } else {
            throw NSError(domain: "SaveError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to get document directory"])
        }
    }
    
    func saveArrTrips(data: Data) throws {
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath = documentDirectory.appendingPathComponent("Trips.plist")
            try data.write(to: filePath)
        } else {
            throw NSError(domain: "SaveError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to get document directory"])
        }
    }
    

    
    
    
    
    
    func settingsView() {
        
        allWaterTextField.delegate = self
        
        let backgroundImageView: UIImageView = {
            let image = UIImage.background
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()
        view.addSubview(backgroundImageView)
        backgroundImageView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
        
        
        segmentedControl = {
            let control = UISegmentedControl(items: ["At home", "Trips"])
            control.selectedSegmentIndex = 0
            control.backgroundColor = .white
            control.selectedSegmentTintColor = UIColor(red: 255/255, green: 215/255, blue: 7/255, alpha: 1)
            
            control.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
            
            control.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
            
            return control
        }()
        view.addSubview(segmentedControl!)
        
        segmentedControl?.addTarget(self, action: #selector(segmentedTapped), for: .valueChanged)
        
        segmentedControl?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        })
        
        topView = {
            let view = UIView()
            view.backgroundColor = .white
            view.layer.cornerRadius = 16
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = 0.25
            view.layer.shadowOffset = CGSize(width: 0, height: 2)
            view.layer.shadowRadius = 4
            view.layer.masksToBounds = false
            return view
        }()
        view.addSubview(topView!)
        topView?.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(segmentedControl!.snp.bottom).inset(-20)
            make.height.equalTo(116)
        }
        
        let waterLabel: UILabel = {
            let label = UILabel()
            label.text = "Water"
            label.textColor = .black
            label.font = .systemFont(ofSize: 22, weight: .semibold)
            return label
        }()
        topView?.addSubview(waterLabel)
        waterLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(15)
            make.centerX.equalToSuperview().offset(15)
        }
        
        waterDataLabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 20, weight: .regular)
            label.textColor = .black
            label.text = "0/0"
            return label
        }()
        view.addSubview(waterDataLabel!)
        waterDataLabel?.snp.makeConstraints({ make in
            make.centerX.equalTo(waterLabel.snp.centerX)
            make.top.equalTo(waterLabel.snp.bottom).inset(-2)
        })
        
        topView?.addSubview(dotsView)
        dotsView.snp.makeConstraints { make in
            make.height.equalTo(16)
            make.width.equalTo(75)
            make.centerX.equalTo(waterLabel.snp.centerX)
            make.top.equalTo(waterDataLabel!.snp.bottom).inset(-8)
        }
        
        let editWaterButton: UIButton = {
            let button = UIButton(type: .system)
            button.setImage(.edit, for: .normal)
            button.tintColor = UIColor(red: 255/255, green: 215/255, blue: 7/255, alpha: 1)
            return button
        }()
        editWaterButton.addTarget(self, action: #selector(showWaterEditor), for: .touchUpInside)
        topView?.addSubview(editWaterButton)
        editWaterButton.snp.makeConstraints { make in
            make.height.width.equalTo(24)
            make.right.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
        
        
        
        
        
        
        topView?.addSubview(pieChartView)
        pieChartView.backgroundColor = .white
        pieChartView.snp.makeConstraints { make in
            make.width.height.equalTo(84)
            make.left.equalToSuperview().inset(30)
            make.centerY.equalToSuperview()
        }
        
        pieChartView.layer.addSublayer(pieChartLayer)
        pieChartLayer.frame = CGRect(x: 0, y: 0, width: 84, height: 84)
        updatePieChart(spent: 1, all: 1)
        
        collectionView = {
            let view = UIView()
            view.backgroundColor = .white
            view.layer.cornerRadius = 12
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = 0.25
            view.layer.shadowOffset = CGSize(width: 0, height: 2)
            view.layer.shadowRadius = 4
            view.layer.masksToBounds = false
            return view
        }()
        view.addSubview(collectionView!)
        collectionView?.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(topView!.snp.bottom).inset(-20)
            make.height.equalTo(100)
        }
        
        stocksLabel = {
            let label = UILabel()
            label.text = "Stocks"
            label.font = .systemFont(ofSize: 22, weight: .semibold)
            label.textColor = .black
            return label
        }()
        collectionView?.addSubview(stocksLabel!)
        stocksLabel?.snp.makeConstraints { make in
            make.left.top.equalToSuperview().inset(15)
        }
        
        let addButton: UIButton = {
            let button = UIButton(type: .system)
            button.setImage(.new, for: .normal)
            button.tintColor = .black
            return button
        }()
        collectionView?.addSubview(addButton)
        addButton.snp.makeConstraints { make in
            make.height.width.equalTo(24)
            make.top.right.equalToSuperview().inset(15)
        }
        addButton.addTarget(self, action: #selector(newStock), for: .touchUpInside)
        
        collection = {
            let layout = UICollectionViewFlowLayout()
            let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
            layout.scrollDirection = .vertical
            collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "main")
            collection.layer.cornerRadius = 12
            layout.sectionInset = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
            collection.delegate = self
            collection.dataSource = self
            collection.showsVerticalScrollIndicator = false
            return collection
        }()
        view.addSubview(collection!)
        collection?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(stocksLabel!.snp.bottom).inset(-15)
            if atHomeEat.count > 5 {
                make.bottom.equalToSuperview()
            } else {
                make.height.equalTo(atHomeEat.count * 84)
            }
        })
        
        view.addSubview(editWaterView)
        editWaterView.snp.makeConstraints { make in
            make.height.equalTo(246)
            make.left.right.equalToSuperview().inset(30)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-30)
        }
        let gesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        editWaterView.addGestureRecognizer(gesture)
        
        
        newView = {
            let view = UIView()
            view.backgroundColor = .white
            view.layer.cornerRadius = 12
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = 0.25
            view.layer.shadowOffset = CGSize(width: 0, height: 2)
            view.layer.shadowRadius = 4
            view.layer.masksToBounds = false
            view.alpha = 0
            
            let waterLabel = UILabel()
            waterLabel.text = "Stocks"
            waterLabel.font = .systemFont(ofSize: 22, weight: .semibold)
            waterLabel.textColor = .black
            view.addSubview(waterLabel)
            waterLabel.snp.makeConstraints { make in
                make.top.equalToSuperview().inset(15)
                make.centerX.equalToSuperview()
            }
            
            newImageView = UIImageView()
            newImageView?.image = UIImage.water
            newImageView?.clipsToBounds = true
            newImageView?.layer.cornerRadius = 16
            newImageView?.layer.borderColor = UIColor(red: 255/255, green: 215/255, blue: 7/255, alpha: 1).cgColor
            newImageView?.layer.borderWidth = 2
            newImageView?.contentMode = .scaleAspectFill
            newImageView?.isUserInteractionEnabled = true
            view.addSubview(newImageView!)
            newImageView?.snp.makeConstraints({ make in
                make.height.width.equalTo(140)
                make.centerX.equalToSuperview()
                make.top.equalTo(waterLabel.snp.bottom).inset(-15)
            })
            let gesture = UITapGestureRecognizer(target: self, action: #selector(setNewImageStocks))
            newImageView?.addGestureRecognizer(gesture)
            
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.distribution = .fillEqually
            stackView.spacing = 20
            stackView.isUserInteractionEnabled = true
            
            view.addSubview(stackView)
            stackView.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(30)
                make.top.equalTo(newImageView!.snp.bottom).inset(-20)
                make.bottom.equalToSuperview().inset(30)
            }
            
            //all
            let allView = UIView()
            let labelAll = UILabel()
            allView.isUserInteractionEnabled = true
            labelAll.text = "Name"
            labelAll.textColor = .black
            labelAll.font = .systemFont(ofSize: 17, weight: .semibold)
            allView.addSubview(labelAll)
            labelAll.snp.makeConstraints { make in
                make.left.equalToSuperview()
                make.top.equalToSuperview()
            }
            
            
            newNameTextField = UITextField()
            newNameTextField?.placeholder = "Text"
            newNameTextField?.borderStyle = .none
            newNameTextField?.textColor = .black
            newNameTextField?.delegate = self
            allView.addSubview(newNameTextField!)
            self.newNameTextField?.snp.makeConstraints({ make in
                make.height.equalTo(48)
                make.left.equalToSuperview()
                make.top.equalTo(labelAll.snp.bottom).inset(-5)
                make.right.equalToSuperview()
            })
            
            let oneSep = UIView()
            oneSep.backgroundColor = UIColor(red: 165/255, green: 165/255, blue: 165/255, alpha: 1)
            allView.addSubview(oneSep)
            oneSep.snp.makeConstraints { make in
                make.height.equalTo(1)
                make.left.right.equalToSuperview()
                make.top.equalTo(newNameTextField!.snp.bottom).inset(-2)
            }
            
            let cancelButton = UIButton(type: .system)
            cancelButton.setTitle("Cancel", for: .normal)
            cancelButton.backgroundColor = .white
            cancelButton.layer.borderColor = UIColor(red: 255/255, green: 215/255, blue: 7/255, alpha: 1).cgColor
            cancelButton.layer.borderWidth = 1
            cancelButton.layer.cornerRadius = 12
            cancelButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
            cancelButton.setTitleColor(UIColor(red: 255/255, green: 215/255, blue: 7/255, alpha: 1), for: .normal)
            allView.addSubview(cancelButton)
            cancelButton.snp.makeConstraints { make in
                make.height.equalTo(54)
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview()
            }
            cancelButton.addTarget(self, action: #selector(hideNewEdit), for: .touchUpInside)
            
            
            
            //spent
            let spentView = UIView()
            let labelSpent = UILabel()
            spentView.isUserInteractionEnabled = true
            labelSpent.text = "Quantity"
            labelSpent.textColor = .black
            labelSpent.font = .systemFont(ofSize: 17, weight: .semibold)
            spentView.addSubview(labelSpent)
            labelSpent.snp.makeConstraints { make in
                make.left.equalToSuperview()
                make.top.equalToSuperview()
            }
            
            mewQualTextField = UITextField()
            mewQualTextField?.placeholder = "Text"
            mewQualTextField?.borderStyle = .none
            mewQualTextField?.textColor = .black
            mewQualTextField?.delegate = self
            spentView.addSubview(mewQualTextField!)
            self.mewQualTextField?.snp.makeConstraints({ make in
                make.height.equalTo(48)
                make.left.equalToSuperview()
                make.top.equalTo(labelSpent.snp.bottom).inset(-5)
                make.right.equalToSuperview()
            })
            let twoSep = UIView()
            twoSep.backgroundColor = UIColor(red: 165/255, green: 165/255, blue: 165/255, alpha: 1)
            spentView.addSubview(twoSep)
            twoSep.snp.makeConstraints { make in
                make.height.equalTo(1)
                make.left.right.equalToSuperview()
                make.top.equalTo(mewQualTextField!.snp.bottom).inset(-2)
            }
            
            newSaveButton = UIButton(type: .system)
            newSaveButton?.setTitle("Save", for: .normal)
            newSaveButton?.setTitleColor(.white, for: .normal)
            newSaveButton?.setTitleColor(.white.withAlphaComponent(0.5), for: .disabled)
            newSaveButton?.backgroundColor = UIColor(red: 255/255, green: 215/255, blue: 7/255, alpha: 1)
            newSaveButton?.layer.cornerRadius = 12
            newSaveButton?.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
            newSaveButton?.isUserInteractionEnabled = false
            newSaveButton?.alpha = 0.5
            spentView.addSubview(newSaveButton!)
            newSaveButton?.snp.makeConstraints({ make in
                make.height.equalTo(54)
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview()
            })
            newSaveButton?.addTarget(self, action: #selector(saveNewStock), for: .touchUpInside)
            
            
            stackView.addArrangedSubview(allView)
            stackView.addArrangedSubview(spentView)
            
            let gestureHide = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
            view.addGestureRecognizer(gestureHide)
            
            return view
        }()
        
        view.addSubview(newView!)
        newView?.snp.makeConstraints({ make in
            make.height.equalTo(408)
            make.left.right.equalToSuperview().inset(30)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-30)
        })
        
        
        
    }
    
    @objc func newStock() {
        isEditingValue = false
        UIView.animate(withDuration: 0.3) {
            self.newView?.alpha = 1
        }
    }
    
    @objc func hideNewEdit() {
        isEditingValue = false
        indexEdit = 0
        UIView.animate(withDuration: 0.3) {
            self.newView?.alpha = 0
        }
        hideKeyboard()
        mewQualTextField?.text = ""
        newNameTextField?.text = ""
        newImageView?.image = .water
    }
    
    
    
    @objc func setNewImageStocks() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = false
        present(imagePickerController, animated: true, completion: nil)
    }
    
    // Реализация делегатов UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            newImageView?.image = selectedImage
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func checkCollection() {
        
        let broccoliEat = Eat(image: UIImage.broc.jpegData(compressionQuality: 1) ?? Data(), name: "Broccoli", count: "0")
        let garlicEat = Eat(image: UIImage.garl.jpegData(compressionQuality: 1) ?? Data(), name: "Garlic", count: "0")
        let carrotEat = Eat(image: UIImage.carr.jpegData(compressionQuality: 1) ?? Data(), name: "Carrot", count: "0")
        let tomatoEat = Eat(image: UIImage.tomat.jpegData(compressionQuality: 1) ?? Data(), name: "Tomato", count: "0")
        
        //home
        if atHomeEat.first(where: { $0.name == broccoliEat.name }) == nil {
            atHomeEat.append(broccoliEat)
        }
        if atHomeEat.first(where: { $0.name == garlicEat.name }) == nil {
            atHomeEat.append(garlicEat)
        }
        if atHomeEat.first(where: { $0.name == carrotEat.name }) == nil {
            atHomeEat.append(carrotEat)
        }
        if atHomeEat.first(where: { $0.name == tomatoEat.name }) == nil {
            atHomeEat.append(tomatoEat)
        }
        
        //trips
        if tripsEat.first(where: { $0.name == broccoliEat.name }) == nil {
            tripsEat.append(broccoliEat)
        }
        if tripsEat.first(where: { $0.name == garlicEat.name }) == nil {
            tripsEat.append(garlicEat)
        }
        if tripsEat.first(where: { $0.name == carrotEat.name }) == nil {
            tripsEat.append(carrotEat)
        }
        if tripsEat.first(where: { $0.name == tomatoEat.name }) == nil {
            tripsEat.append(tomatoEat)
        }
        
        

    }
    
    @objc func saveNewStock() {
        print("Tapped")
        let newEat = Eat(image: newImageView?.image?.jpegData(compressionQuality: 0.5) ?? Data(), name: newNameTextField?.text ?? "", count: mewQualTextField?.text ?? "")
        
        if selectedArea == "At home" {
            if isEditingValue == true {
                atHomeEat[indexEdit] = newEat
            } else {
                atHomeEat.append(newEat)
            }
            
            do {
                let data = try JSONEncoder().encode(atHomeEat) //тут мкассив конвертируем в дату
                try saveHomeToFile(data: data)
                hideNewEdit()
                loadData()
            } catch {
                print("Failed to encode or save athleteArr: \(error)")
            }
        } else {
            if isEditingValue == true {
                tripsEat[indexEdit] = newEat
            } else {
                tripsEat.append(newEat)
            }

            do {
                let data = try JSONEncoder().encode(tripsEat) //тут мкассив конвертируем в дату
                try saveTripsToFile(data: data)
                hideNewEdit()
                loadData()
            } catch {
                print("Failed to encode or save athleteArr: \(error)")
            }
        }
    }
    
    
    
    func saveHomeToFile(data: Data) throws {
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath = documentDirectory.appendingPathComponent("Home.plist")
            try data.write(to: filePath)
        } else {
            throw NSError(domain: "SaveError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to get document directory"])
        }
    }
    
    func saveTripsToFile(data: Data) throws {
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath = documentDirectory.appendingPathComponent("Trips.plist")
            try data.write(to: filePath)
        } else {
            throw NSError(domain: "SaveError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to get document directory"])
        }
    }
    
    
    
    
    //ЗАГРУЗКА Home
       func loadHomeArrFromFile() -> [Eat]? {
           let fileManager = FileManager.default
           guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
               print("Unable to get document directory")
               return nil
           }
           let filePath = documentDirectory.appendingPathComponent("Home.plist")
           do {
               let data = try Data(contentsOf: filePath)
               let homeArr = try JSONDecoder().decode([Eat].self, from: data)
               return homeArr
           } catch {
               print("Failed to load or decode athleteArr: \(error)")
               return nil
           }
       }
    
    func loadTripsArrFromFile() -> [Eat]? {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to get document directory")
            return nil
        }
        let filePath = documentDirectory.appendingPathComponent("Trips.plist")
        do {
            let data = try Data(contentsOf: filePath)
            let tripsArr = try JSONDecoder().decode([Eat].self, from: data)
            return tripsArr
        } catch {
            print("Failed to load or decode athleteArr: \(error)")
            return nil
        }
    }
    
    
    func checkWater() {
        if allWaterTextField.text?.count ?? 0 > 0 , spentWaterTextField.text?.count ?? 0 > 0 {
            saveButton?.isUserInteractionEnabled = true
            saveButton?.alpha = 1
        } else {
            saveButton?.isUserInteractionEnabled = false
            saveButton?.alpha = 0.5
        }
    }
    
    
    func checknewWater() {
        if newNameTextField?.text?.count ?? 0 > 0 , mewQualTextField?.text?.count ?? 0 > 0 {
            newSaveButton?.isUserInteractionEnabled = true
            newSaveButton?.alpha = 1
        } else {
            newSaveButton?.isUserInteractionEnabled = false
            newSaveButton?.alpha = 0.5
        }
    }
    
    @objc func segmentedTapped() {
        if selectedArea == "At home" {
            selectedArea = "Trips"
            waterDataLabel?.text = "\(tripsWater[0])/\(tripsWater[1])"
        } else {
            selectedArea = "At home"
            waterDataLabel?.text = "\(atHomeWater[0])/\(atHomeWater[1])"
        }
        setWater()
        loadData()
    }
    
    func setWater() {
        if selectedArea == "At home" {
            waterDataLabel?.text = "\(atHomeWater[0])/\(atHomeWater[1])"
            if let spentCount = Int(atHomeWater[0]), let allCount = Int(atHomeWater[1]) {
                if atHomeWater[0] == "0" , atHomeWater[1] == "0" {
                    updatePieChart(spent: 1, all: 1)
                } else {
                    updatePieChart(spent: spentCount, all: allCount)
                }
            }
        } else {
            waterDataLabel?.text = "\(tripsWater[0])/\(tripsWater[1])"
            if let spentCount = Int(tripsWater[0]), let allCount = Int(tripsWater[1]) {
                if tripsWater[0] == "0" , tripsWater[1] == "0" {
                    updatePieChart(spent: 1, all: 1)
                } else {
                    updatePieChart(spent: spentCount, all: allCount)
                }
            }
            
        }
        fillTextFields()
    }
    
    func fillTextFields() {
        if selectedArea == "At home" {
            allWaterTextField.text = atHomeWater[0]
            spentWaterTextField.text = atHomeWater[1]
        } else {
            allWaterTextField.text = tripsWater[0]
            spentWaterTextField.text = tripsWater[1]
        }
    }
    
    
    let dotsView: UIView = {
        
        let view = UIView()
        view.backgroundColor = .white
        let orangeDot = UIView()
        orangeDot.backgroundColor = UIColor(red: 255/255, green: 215/255, blue: 7/255, alpha: 1)
        orangeDot.layer.cornerRadius = 4.5
        view.addSubview(orangeDot)
        orangeDot.snp.makeConstraints { make in
            make.height.width.equalTo(9)
            make.left.centerY.equalToSuperview()
        }
        
        let allLabel = UILabel()
        allLabel.text = "All"
        allLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        allLabel.textColor = .black
        view.addSubview(allLabel)
        allLabel.snp.makeConstraints { make in
            make.left.equalTo(orangeDot.snp.right).inset(-3)
            make.centerY.equalToSuperview()
        }
        
        let manyOrangeDot = UIView()
        manyOrangeDot.backgroundColor = UIColor(red: 251/255, green: 243/255, blue: 179/255, alpha: 1)
        manyOrangeDot.layer.cornerRadius = 4.5
        view.addSubview(manyOrangeDot)
        manyOrangeDot.snp.makeConstraints { make in
            make.height.width.equalTo(9)
            make.left.equalTo(allLabel.snp.right).inset(-5)
            make.centerY.equalToSuperview()
        }
        
        let spentLabel = UILabel()
        spentLabel.text = "Spent"
        spentLabel.textColor = .black
        spentLabel.font = .systemFont(ofSize: 12, weight: .regular)
        view.addSubview(spentLabel)
        spentLabel.snp.makeConstraints { make in
            make.left.equalTo(manyOrangeDot.snp.right).inset(-3)
            make.centerY.equalToSuperview()
        }
        
        
        return view
    }()
    
    
    lazy var editWaterView: UIView = {
        
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.25
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.masksToBounds = false
        view.alpha = 0
        
        let labelWater = UILabel()
        labelWater.text = "Water"
        labelWater.font = .systemFont(ofSize: 22, weight: .semibold)
        labelWater.textColor = .black
        view.addSubview(labelWater)
        labelWater.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(15)
        }
        
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        stackView.isUserInteractionEnabled = true
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(30)
            make.top.equalTo(labelWater.snp.bottom).inset(-20)
            make.bottom.equalToSuperview().inset(30)
        }
        
        //all
        let allView = UIView()
        let labelAll = UILabel()
        allView.isUserInteractionEnabled = true
        labelAll.text = "All"
        labelAll.textColor = .black
        labelAll.font = .systemFont(ofSize: 17, weight: .semibold)
        allView.addSubview(labelAll)
        labelAll.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        
        allWaterTextField.delegate = self
        allView.addSubview(allWaterTextField)
        self.allWaterTextField.snp.makeConstraints({ make in
            make.height.equalTo(48)
            make.left.equalToSuperview()
            make.top.equalTo(labelAll.snp.bottom).inset(-5)
            make.right.equalToSuperview()
        })
        
        let oneSep = UIView()
        oneSep.backgroundColor = UIColor(red: 165/255, green: 165/255, blue: 165/255, alpha: 1)
        allView.addSubview(oneSep)
        oneSep.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.left.right.equalToSuperview()
            make.top.equalTo(allWaterTextField.snp.bottom).inset(-2)
        }
        
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.backgroundColor = .white
        cancelButton.layer.borderColor = UIColor(red: 255/255, green: 215/255, blue: 7/255, alpha: 1).cgColor
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.cornerRadius = 12
        cancelButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        cancelButton.setTitleColor(UIColor(red: 255/255, green: 215/255, blue: 7/255, alpha: 1), for: .normal)
        allView.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.height.equalTo(54)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        cancelButton.addTarget(self, action: #selector(cancelWater), for: .touchUpInside)
        
        
        
        //spent
        let spentView = UIView()
        let labelSpent = UILabel()
        spentView.isUserInteractionEnabled = true
        labelSpent.text = "Spent"
        labelSpent.textColor = .black
        labelSpent.font = .systemFont(ofSize: 17, weight: .semibold)
        spentView.addSubview(labelSpent)
        labelSpent.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        spentWaterTextField.delegate = self
        spentView.addSubview(spentWaterTextField)
        self.spentWaterTextField.snp.makeConstraints({ make in
            make.height.equalTo(48)
            make.left.equalToSuperview()
            make.top.equalTo(labelSpent.snp.bottom).inset(-5)
            make.right.equalToSuperview()
        })
        let twoSep = UIView()
        twoSep.backgroundColor = UIColor(red: 165/255, green: 165/255, blue: 165/255, alpha: 1)
        spentView.addSubview(twoSep)
        twoSep.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.left.right.equalToSuperview()
            make.top.equalTo(spentWaterTextField.snp.bottom).inset(-2)
        }
        
        saveButton = UIButton(type: .system)
        saveButton?.setTitle("Save", for: .normal)
        saveButton?.setTitleColor(.white, for: .normal)
        saveButton?.setTitleColor(.white.withAlphaComponent(0.5), for: .disabled)
        saveButton?.backgroundColor = UIColor(red: 255/255, green: 215/255, blue: 7/255, alpha: 1)
        saveButton?.layer.cornerRadius = 12
        saveButton?.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        saveButton?.isUserInteractionEnabled = false
        saveButton?.alpha = 0.5
        spentView.addSubview(saveButton!)
        saveButton?.snp.makeConstraints({ make in
            make.height.equalTo(54)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        })
        saveButton?.addTarget(self, action: #selector(saveWater), for: .touchUpInside)
        
        
        stackView.addArrangedSubview(allView)
        stackView.addArrangedSubview(spentView)
        
        
        return view
        
    }()
    
    func updatePieChart(spent: Int, all: Int) {
        pieChartLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        let center = CGPoint(x: pieChartLayer.bounds.midX, y: pieChartLayer.bounds.midY)
        let outerRadius = min(pieChartLayer.bounds.width, pieChartLayer.bounds.height) / 2
        let innerRadius = outerRadius * 0.6 // Задаем внутренний радиус для прозрачного центра
        let startAngle = -CGFloat.pi / 2
        let endAngle = startAngle + 2 * CGFloat.pi * CGFloat(spent) / CGFloat(all)
        
        
        let spentPath = UIBezierPath()
        spentPath.addArc(withCenter: center, radius: outerRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        spentPath.addArc(withCenter: center, radius: innerRadius, startAngle: endAngle, endAngle: startAngle, clockwise: false)
        spentPath.close()
        
        let spentLayer = CAShapeLayer()
        spentLayer.path = spentPath.cgPath
        spentLayer.fillColor = UIColor(red: 255/255, green: 243/255, blue: 179/255, alpha: 1).cgColor
        pieChartLayer.addSublayer(spentLayer)
        
        // Создание слоя для оставшейся воды
        let remainingPath = UIBezierPath()
        remainingPath.addArc(withCenter: center, radius: outerRadius, startAngle: endAngle, endAngle: startAngle, clockwise: true)
        remainingPath.addArc(withCenter: center, radius: innerRadius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        remainingPath.close()
        
        let remainingLayer = CAShapeLayer()
        remainingLayer.path = remainingPath.cgPath
        remainingLayer.fillColor = UIColor(red: 255/255, green: 215/255, blue: 7/255, alpha: 1).cgColor
        pieChartLayer.addSublayer(remainingLayer)
        
        // Создание прозрачного центра
        let centerPath = UIBezierPath(arcCenter: center, radius: innerRadius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        let centerLayer = CAShapeLayer()
        centerLayer.path = centerPath.cgPath
        centerLayer.fillColor = UIColor.white.cgColor
        pieChartLayer.addSublayer(centerLayer)
    }
    
    
    @objc func showWaterEditor() {
        
        fillTextFields()
        UIView.animate(withDuration: 0.3) {
            self.editWaterView.alpha = 1
        }
    }
    
    @objc func cancelWater() {
        UIView.animate(withDuration: 0.3) {
            self.editWaterView.alpha = 0
        }
        hideKeyboard()
    }
    
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    
    @objc func saveWater() {
        
        let value = [allWaterTextField.text ?? "" , spentWaterTextField.text ?? "" ]
        
        if selectedArea == "At home" {
            UserDefaults.standard.setValue(value, forKey: "atHome")
            atHomeWater = value
            if let spentCount = Int(atHomeWater[0]), let allCount = Int(atHomeWater[1]) {
                updatePieChart(spent: spentCount, all: allCount)
            }
        } else {
            UserDefaults.standard.setValue(value, forKey: "Trips")
            tripsWater = value
            if let spentCount = Int(tripsWater[0]), let allCount = Int(tripsWater[1]) {
                updatePieChart(spent: spentCount, all: allCount)
            }
        }
        waterDataLabel?.text = "\(allWaterTextField.text ?? "")/\(spentWaterTextField.text ?? "")"
        
        
    }
    
    func checkWaterUserDef() {
        if UserDefaults.standard.object(forKey: "atHome") != nil {
            atHomeWater = UserDefaults.standard.object(forKey: "atHome") as? [String] ?? ["0", "0"]
        }
        if UserDefaults.standard.object(forKey: "Trips") != nil {
            tripsWater = UserDefaults.standard.object(forKey: "Trips") as? [String] ?? ["0", "0"]
        }
        
        setWater()
    }
    
    
}


extension WaterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        checkWater()
        checknewWater()
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        checkWater()
        checknewWater()
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        checkWater()
        checknewWater()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        checkWater()
        checknewWater()
        return true
    }
    
    
    
}


extension WaterViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if selectedArea == "At home" {
            return atHomeEat.count
        } else {
            return tripsEat.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "main", for: indexPath)
        cell.subviews.forEach { $0.removeFromSuperview() }
        cell.backgroundColor = .white
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.25
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.shadowRadius = 4
        cell.layer.masksToBounds = false
        cell.layer.cornerRadius = 12
        
        let ImageView = UIImageView()
        ImageView.layer.cornerRadius = 12
        ImageView.clipsToBounds = true
        ImageView.contentMode = .scaleAspectFill
        cell.addSubview(ImageView)
        ImageView.snp.makeConstraints { make in
            make.height.width.equalTo(50)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(15)
        }
        
        let nameLabel = UILabel()
        nameLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        nameLabel.textColor = .black
        cell.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(ImageView.snp.right).inset(-10)
        }
        
        
        let imageViewEdit = UIImageView(image: .edit)
        imageViewEdit.contentMode = .scaleAspectFit
        cell.addSubview(imageViewEdit)
        imageViewEdit.snp.makeConstraints { make in
            make.height.width.equalTo(19)
            make.right.equalToSuperview().inset(15)
            make.centerY.equalToSuperview()
        }
        
        
        let countLabel = UILabel()
        countLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        countLabel.textColor = .black
        cell.addSubview(countLabel)
        countLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(imageViewEdit.snp.left).inset(-15)
        }
        
        
        if selectedArea == "At home" {
            ImageView.image = UIImage(data: atHomeEat[indexPath.row].image)
            nameLabel.text = atHomeEat[indexPath.row].name
            countLabel.text = atHomeEat[indexPath.row].count
        } else {
            ImageView.image = UIImage(data: tripsEat[indexPath.row].image)
            nameLabel.text = tripsEat[indexPath.row].name
            countLabel.text = tripsEat[indexPath.row].count
        }
        
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 30, height: 74)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if selectedArea == "At home" {
            newImageView?.image = UIImage(data: atHomeEat[indexPath.row].image)
            newNameTextField?.text = atHomeEat[indexPath.row].name
            mewQualTextField?.text = atHomeEat[indexPath.row].count
        } else {
            newImageView?.image = UIImage(data: tripsEat[indexPath.row].image)
            newNameTextField?.text = tripsEat[indexPath.row].name
            mewQualTextField?.text = tripsEat[indexPath.row].count
        }
        
        isEditingValue = true
        indexEdit = indexPath.row
        
        UIView.animate(withDuration: 0.3) {
            self.newView?.alpha = 1
        }

    }
    
    
}
