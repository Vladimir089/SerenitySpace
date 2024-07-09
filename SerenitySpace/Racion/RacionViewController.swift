//
//  RacionViewController.swift
//  SerenitySpace
//
//  Created by Владимир Кацап on 08.07.2024.
//

import UIKit

var racionArr = [blud]() //менять
var user: User?


protocol RacionViewControllerDelegate: AnyObject {
    func reloadTable()
}

 
class RacionViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var mainCollection: UICollectionView?
    var historyCollection: UICollectionView?
    var profileView: UIView?
    
    
    var editImageView: UIImageView?
    var nameTextField: UITextField?
    var ageTextField: UITextField?
    var menButton, womanButton: UIButton?
    var saveButton: UIButton?
    var sex = "Women"
    
    
   
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.view.transform = CGAffineTransform(translationX: 0, y: -100)
            
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.view.transform = .identity
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar()
        mainCollection?.reloadData()
        historyCollection?.reloadData()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        racionArr = loadAthleteArrFromFile() ?? [blud]()
        createInterface()
    }
    
    
    func loadAthleteArrFromFile() -> [blud]? {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to get document directory")
            return nil
        }
        let filePath = documentDirectory.appendingPathComponent("Elements.plist")
        do {
            let data = try Data(contentsOf: filePath)
            let athleteArr = try JSONDecoder().decode([blud].self, from: data)
            return athleteArr
        } catch {
            print("Failed to load or decode athleteArr: \(error)")
            return nil
        }
    }
    
    
    
    func createInterface() {
        
        let gestureHide = UITapGestureRecognizer(target: self, action: #selector(hideKeybpard))
        view.addGestureRecognizer(gestureHide)
        
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
        
        mainCollection = {
            let layout = UICollectionViewFlowLayout()
            let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 20
            collection.showsVerticalScrollIndicator = false
            collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "main")
            collection.backgroundColor = .clear
            collection.delegate = self
            collection.dataSource = self
            return collection
        }()
        view.addSubview(mainCollection!)
        mainCollection?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        })
        
        historyCollection = {
            let layout = UICollectionViewFlowLayout()
            let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 20
            collection.showsVerticalScrollIndicator = false
            collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "second")
            collection.backgroundColor = .clear
            collection.delegate = self
            
            layout.sectionInset = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
            
            collection.dataSource = self
            return collection
        }()
        
        profileView = {
            let view = UIView()
            view.backgroundColor = .white
            view.alpha = 0
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = 0.25
            view.layer.shadowOffset = CGSize(width: 0, height: 2)
            view.layer.shadowRadius = 4
            view.layer.masksToBounds = false
            
            view.layer.cornerRadius = 12
            
            
            let labelProfile = UILabel()
            labelProfile.text = "Profile"
            labelProfile.font = .systemFont(ofSize: 22, weight: .semibold)
            labelProfile.textColor = UIColor(red: 17/255, green: 11/255, blue: 1/255, alpha: 1)
            view.addSubview(labelProfile)
            labelProfile.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().inset(20)
            }
            
            editImageView = {
                var image = UIImage(data: user?.photo ?? Data()) ?? .imageProfile
                
                
                let imageView = UIImageView(image: image)
                imageView.contentMode = .scaleAspectFill
                imageView.layer.cornerRadius = 18
                imageView.layer.borderColor = UIColor(red: 255/255, green: 215/255, blue: 7/255, alpha: 1).cgColor
                imageView.layer.borderWidth = 2
                imageView.clipsToBounds = true
                imageView.isUserInteractionEnabled = true
                return imageView
            }()
            view.addSubview(editImageView!)
            editImageView?.snp.makeConstraints({ make in
                make.height.width.equalTo(100)
                make.centerX.equalToSuperview()
                make.top.equalTo(labelProfile.snp.bottom).inset(-20)
            })
            let gesture = UITapGestureRecognizer(target: self, action: #selector(selectPhoto))
            editImageView?.addGestureRecognizer(gesture)
            
            let nameLabel = UILabel()
            nameLabel.text = "Name"
            nameLabel.font = .systemFont(ofSize: 17, weight: .semibold)
            nameLabel.textColor = UIColor(red: 17/255, green: 11/255, blue: 1/255, alpha: 1)
            view.addSubview(nameLabel)
            nameLabel.snp.makeConstraints { make in
                make.left.equalToSuperview().inset(15)
                make.top.equalTo(editImageView!.snp.bottom).inset(-15)
            }
            
            nameTextField = UITextField()
            nameTextField?.placeholder = "Text"
            nameTextField?.textColor = .black
            nameTextField?.borderStyle = .none
            nameTextField?.delegate = self
            nameTextField?.text = user?.name ?? ""
            view.addSubview(nameTextField!)
            nameTextField?.snp.makeConstraints({ make in
                make.left.right.equalToSuperview().inset(15)
                make.height.equalTo(46)
                make.top.equalTo(nameLabel.snp.bottom).inset(-2)
            })
        
            let separatorView = UIView()
            separatorView.backgroundColor = UIColor(red: 165/255, green: 165/255, blue: 165/255, alpha: 1)
            view.addSubview(separatorView)
            separatorView.snp.makeConstraints { make in
                make.height.equalTo(1)
                make.left.right.equalToSuperview().inset(15)
                make.top.equalTo(nameTextField!.snp.bottom).inset(-3)
            }
            
            let ageLabel = UILabel()
            ageLabel.font = .systemFont(ofSize: 17, weight: .semibold)
            ageLabel.textColor = UIColor(red: 17/255, green: 11/255, blue: 1/255, alpha: 1)
            ageLabel.text = "Age"
            view.addSubview(ageLabel)
            ageLabel.snp.makeConstraints { make in
                make.left.equalToSuperview().inset(15)
                make.top.equalTo(separatorView.snp.bottom).inset(-15 )
            }
            
            
            let sexLabel = UILabel()
            sexLabel.font = .systemFont(ofSize: 17, weight: .semibold)
            sexLabel.textColor = UIColor(red: 17/255, green: 11/255, blue: 1/255, alpha: 1)
            sexLabel.text = "Sex"
            view.addSubview(sexLabel)
            sexLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview().inset(-10)
                make.top.equalTo(separatorView.snp.bottom).inset(-15 )
            }
            
            ageTextField = UITextField()
            ageTextField?.placeholder = "Text"
            ageTextField?.textColor = .black
            ageTextField?.delegate = self
            ageTextField?.text = user?.age as? String ?? ""
            ageTextField?.keyboardType = .numberPad
            view.addSubview(ageTextField!)
            ageTextField?.snp.makeConstraints({ make in
                make.height.equalTo(46)
                make.top.equalTo(ageLabel.snp.bottom).inset(-2)
                make.left.equalToSuperview().inset(15)
                make.right.equalTo(view.snp.centerX).offset(-30)
            })
            
            menButton = {
                let button = UIButton(type: .system)
                button.setTitle("Men", for: .normal)
                button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
                button.layer.cornerRadius = 12
                if user?.sex == "Men" {
                    sex = "Men"
                    button.backgroundColor = UIColor(red: 255/255, green: 215/255, blue: 7/255, alpha: 1)
                    button.setTitleColor(.white, for: .normal)
                    
                } else {
                    button.backgroundColor = .white
                    button.setTitleColor(UIColor(red: 251/255, green: 243/255, blue: 179/255, alpha: 1), for: .normal)
                    button.layer.borderColor = UIColor(red: 251/255, green: 243/255, blue: 179/255, alpha: 1).cgColor
                    button.layer.borderWidth = 1
                }
                return button
            }()
            view.addSubview(menButton!)
            menButton?.snp.makeConstraints({ make in
                make.height.equalTo(40)
                make.width.equalTo(67)
                make.left.equalTo(sexLabel.snp.left)
                make.bottom.equalTo(ageTextField!.snp.bottom)
            })
            menButton?.addTarget(self, action: #selector(menButtonTap), for: .touchUpInside)
            
            
            womanButton = {
                let button = UIButton(type: .system)
                button.setTitle("Women", for: .normal)
                button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
                button.layer.cornerRadius = 12
                if user?.sex == "Women" {
                    sex = "Women"
                    button.backgroundColor = UIColor(red: 255/255, green: 215/255, blue: 7/255, alpha: 1)
                    button.setTitleColor(.white, for: .normal)
                } else if user?.sex == "Men" {
                    button.backgroundColor = .white
                    button.setTitleColor(UIColor(red: 251/255, green: 243/255, blue: 179/255, alpha: 1), for: .normal)
                    button.layer.borderColor = UIColor(red: 251/255, green: 243/255, blue: 179/255, alpha: 1).cgColor
                    button.layer.borderWidth = 1
                } else {
                    button.backgroundColor = UIColor(red: 255/255, green: 215/255, blue: 7/255, alpha: 1)
                    button.setTitleColor(.white, for: .normal)
                }
                return button
            }()
            view.addSubview(womanButton!)
            womanButton?.snp.makeConstraints({ make in
                make.height.equalTo(40)
                make.right.equalTo(separatorView.snp.right)
                make.bottom.equalTo(ageTextField!.snp.bottom)
                make.left.equalTo(menButton!.snp.right).inset(-5)
            })
            womanButton?.addTarget(self, action: #selector(womanButtonTap), for: .touchUpInside)
            
            
            let secondSeparator = UIView()
            secondSeparator.backgroundColor = UIColor(red: 165/255, green: 165/255, blue: 165/255, alpha: 1)
            view.addSubview(secondSeparator)
            secondSeparator.snp.makeConstraints { make in
                make.height.equalTo(1)
                make.left.equalToSuperview().inset(15)
                make.right.equalTo(sexLabel.snp.left).inset(-15)
                make.top.equalTo(ageTextField!.snp.bottom)
            }
            
            let cancelButton: UIButton = {
                let button = UIButton(type: .system)
                button.setTitle("Cancel", for: .normal)
                button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
                button.setTitleColor(UIColor(red: 255/255, green: 215/255, blue: 7/255, alpha: 1), for: .normal)
                button.layer.borderColor = UIColor(red: 255/255, green: 215/255, blue: 7/255, alpha: 1).cgColor
                button.layer.borderWidth = 1
                button.backgroundColor = .white
                button.layer.cornerRadius = 12
                return button
            }()
            view.addSubview(cancelButton)
            cancelButton.snp.makeConstraints { make in
                make.height.equalTo(54)
                make.left.equalToSuperview().inset(15)
                make.right.equalTo(view.snp.centerX).offset(-7.5)
                make.top.equalTo(secondSeparator.snp.bottom).inset(-30)
            }
            cancelButton.addTarget(self, action: #selector(hideProfile), for: .touchUpInside)
            
            saveButton = {
                let button = UIButton(type: .system)
                button.backgroundColor = UIColor(red: 255/255, green: 215/255, blue: 7/255, alpha: 1)
                button.layer.cornerRadius = 12
                button.setTitle("Save", for: .normal)
                button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
                button.setTitleColor(.white, for: .normal)
                button.isUserInteractionEnabled = false
                button.alpha = 0.5
                return button
            }()
            view.addSubview(saveButton!)
            saveButton?.snp.makeConstraints({ make in
                make.height.equalTo(54)
                make.right.equalToSuperview().inset(15)
                make.top.equalTo(secondSeparator.snp.bottom).inset(-30)
                make.left.equalTo(view.snp.centerX).offset(7.5)
            })
            saveButton?.addTarget(self, action: #selector(saveProfile), for: .touchUpInside)
            
            return view
        }()
        view.addSubview(profileView!)
        profileView?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview().inset(30)
            make.height.equalTo(450)
            make.centerY.equalToSuperview()
        })
        checkFill()
    }
    
    @objc func saveProfile() {
        
        let ageText = ageTextField?.text ?? "0"
        let age = Int(ageText) ?? 0
        
        let user = User(name: nameTextField?.text ?? "Text", photo: editImageView?.image?.jpegData(compressionQuality: 0.6) ?? Data(), age: age, sex: sex)
        
        do {
            let encoder = JSONEncoder()
            let userData = try encoder.encode(user)
            UserDefaults.standard.set(userData, forKey: "user")
            print("User object saved to UserDefaults")
            updateUser(userEdit: user)
        } catch {
            print("Failed to encode user: \(error)")
        }
        
        
    }
    
    func updateUser(userEdit: User) {
        user = userEdit
        mainCollection?.reloadData()
        UIView.animate(withDuration: 0.2) {
            self.profileView?.alpha = 0
        }
    }
    
    func checkFill() {
        if nameTextField?.text != "" && ageTextField?.text != "" {
            saveButton?.alpha = 1
            saveButton?.isUserInteractionEnabled = true
        } else {
            saveButton?.alpha = 0.5
            saveButton?.isUserInteractionEnabled = false
        }
        
        editImageView?.image = UIImage(data: user?.photo ?? Data()) ?? .imageProfile
        nameTextField?.text = user?.name ?? ""
        ageTextField?.text = String(user?.age ?? 0)
        
        if user?.sex == "Women" {
            sex = "Women"
            womanButton?.backgroundColor = UIColor(red: 255/255, green: 215/255, blue: 7/255, alpha: 1)
            womanButton?.setTitleColor(.white, for: .normal)
            menButton?.backgroundColor = .white
            menButton?.setTitleColor(UIColor(red: 251/255, green: 243/255, blue: 179/255, alpha: 1), for: .normal)
            menButton?.layer.borderColor = UIColor(red: 251/255, green: 243/255, blue: 179/255, alpha: 1).cgColor
            menButton?.layer.borderWidth = 1
        }
        if user?.sex == "Men" {
            menButton?.backgroundColor = UIColor(red: 255/255, green: 215/255, blue: 7/255, alpha: 1)
            menButton?.setTitleColor(.white, for: .normal)
            womanButton?.backgroundColor = .white
            womanButton?.setTitleColor(UIColor(red: 251/255, green: 243/255, blue: 179/255, alpha: 1), for: .normal)
            womanButton?.layer.borderColor = UIColor(red: 251/255, green: 243/255, blue: 179/255, alpha: 1).cgColor
            womanButton?.layer.borderWidth = 1
        }
    }
    
    @objc func hideProfile() {
        UIView.animate(withDuration: 0.2) {
            self.profileView?.alpha = 0
        }
    }
    
    @objc func menButtonTap() {
        sex = "Men"
        menButton?.backgroundColor = UIColor(red: 255/255, green: 215/255, blue: 7/255, alpha: 1)
        menButton?.setTitleColor(.white, for: .normal)
        womanButton?.backgroundColor = .white
        womanButton?.setTitleColor(UIColor(red: 251/255, green: 243/255, blue: 179/255, alpha: 1), for: .normal)
        womanButton?.layer.borderColor = UIColor(red: 251/255, green: 243/255, blue: 179/255, alpha: 1).cgColor
        womanButton?.layer.borderWidth = 1
        
        
    }
    
    @objc func womanButtonTap() {
        sex = "Women"
        womanButton?.backgroundColor = UIColor(red: 255/255, green: 215/255, blue: 7/255, alpha: 1)
        womanButton?.setTitleColor(.white, for: .normal)
        menButton?.backgroundColor = .white
        menButton?.setTitleColor(UIColor(red: 251/255, green: 243/255, blue: 179/255, alpha: 1), for: .normal)
        menButton?.layer.borderColor = UIColor(red: 251/255, green: 243/255, blue: 179/255, alpha: 1).cgColor
        menButton?.layer.borderWidth = 1
        
        
    }
    
    
    @objc func showEditProfile() {
        UIView.animate(withDuration: 0.5) {
            self.profileView?.alpha = 100
        }
        checkFill()
    }
    
    @objc func selectPhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc func hideKeybpard() {
        self.view.endEditing(true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            editImageView?.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
   

}


extension RacionViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == mainCollection {
            return 2
        } else {
            if racionArr.count != 0 {
                return racionArr.count
            } else {
                return 1
            }
           
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == mainCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "main", for: indexPath)
            cell.subviews.forEach { $0.removeFromSuperview() }
            cell.backgroundColor = .white
            cell.layer.cornerRadius = 12
            
            cell.layer.shadowColor = UIColor.black.cgColor
            cell.layer.shadowOpacity = 0.25
            cell.layer.shadowOffset = CGSize(width: 0, height: 2)
            cell.layer.shadowRadius = 4
            cell.layer.masksToBounds = false
            
            if indexPath.item == 0 {
                
                let labelName: UILabel = {
                    let label = UILabel()
                    label.text = user?.name ?? "Name"
                    label.numberOfLines = 2
                    label.font = .systemFont(ofSize: 22, weight: .semibold)
                    label.textColor = UIColor(red: 17/255, green: 11/255, blue: 1/255, alpha: 1)
                    return label
                }()
                cell.addSubview(labelName)
                labelName.snp.makeConstraints { make in
                    make.top.equalToSuperview().inset(50)
                    make.left.equalToSuperview().inset(15)
                    make.right.equalTo(cell.snp.centerX)
                }
                
                let imageViewPhotoUser: UIImageView = {
                    let image = UIImage(data: user?.photo ?? Data()) ?? .imageProfile
                    let imageView = UIImageView(image: image)
                    imageView.contentMode = .scaleAspectFill
                    imageView.clipsToBounds = true
                    imageView.layer.cornerRadius = 18
                    return imageView
                }()
                cell.addSubview(imageViewPhotoUser)
                imageViewPhotoUser.snp.makeConstraints { make in
                    make.height.width.equalTo(100)
                    make.left.equalToSuperview().inset(15)
                    make.top.equalTo(labelName.snp.bottom).inset(-20)
                }
                
                let ageLabel: UILabel = {
                    let label = UILabel()
                    label.font = .systemFont(ofSize: 15, weight: .semibold)
                    label.textColor = UIColor(red: 17/255, green: 11/255, blue: 1/255, alpha: 1)
                    label.text = "Age : \(user?.age ?? 0)"
                    return label
                }()
                cell.addSubview(ageLabel)
                ageLabel.snp.makeConstraints { make in
                    make.left.equalToSuperview().inset(15)
                    make.top.equalTo(imageViewPhotoUser.snp.bottom).inset(-15)
                }
                
                let sexLabel: UILabel = {
                    let label = UILabel()
                    label.font = .systemFont(ofSize: 15, weight: .semibold)
                    label.textColor = UIColor(red: 17/255, green: 11/255, blue: 1/255, alpha: 1)
                    label.text = "Sex : \(user?.sex ?? "sex")"
                    return label
                }()
                cell.addSubview(sexLabel)
                sexLabel.snp.makeConstraints { make in
                    make.top.equalTo(ageLabel.snp.bottom).inset(-15)
                    make.left.equalToSuperview().inset(15)
                }
                
                let imageViewStandart: UIImageView = {
                    let image = UIImage.standart
                    let imageView = UIImageView(image: image)
                    imageView.layer.cornerRadius = 12
                    imageView.contentMode = .scaleAspectFit
                    return imageView
                }()
                cell.addSubview(imageViewStandart)
                imageViewStandart.snp.makeConstraints { make in
                    make.left.equalTo(cell.snp.centerX)
                    make.right.equalToSuperview().inset(15)
                    make.top.bottom.equalToSuperview().inset(15)
                }
                
                let editUserButton: UIButton = {
                    let button = UIButton(type: .system)
                    button.setImage(.edit.resize(targetSize: CGSize(width: 20, height: 20)), for: .normal)
                    button.backgroundColor = .white
                    button.tintColor = UIColor(red: 255/255, green: 215/255, blue: 7/255, alpha: 1)
                    button.layer.cornerRadius = 12
                    return button
                }()
                cell.addSubview(editUserButton)
                editUserButton.snp.makeConstraints { make in
                    make.height.width.equalTo(44)
                    make.right.equalTo(imageViewStandart.snp.right).inset(5)
                    make.top.equalTo(imageViewStandart.snp.top).inset(3)
                }
                editUserButton.addTarget(self, action: #selector(showEditProfile), for: .touchUpInside)

            } else {
                
                let historyLabel: UILabel = {
                    let label = UILabel()
                    label.font = .systemFont(ofSize: 22, weight: .semibold)
                    label.textColor = UIColor(red: 17/255, green: 11/255, blue: 1/255, alpha: 1)
                    label.text = "History"
                    return label
                }()
                cell.addSubview(historyLabel)
                historyLabel.snp.makeConstraints { make in
                    make.left.top.equalToSuperview().inset(15)
                }
                
                let buttonAdd: UIButton = {
                    let button = UIButton(type: .system)
                    button.setImage(.new.resize(targetSize: CGSize(width: 20, height: 20)), for: .normal)
                    button.backgroundColor = .clear
                    button.tintColor = .black
                    return button
                }()
                cell.addSubview(buttonAdd)
                buttonAdd.snp.makeConstraints { make in
                    make.height.width.equalTo(24)
                    make.right.top.equalToSuperview().inset(15)
                }
                buttonAdd.addTarget(self, action: #selector(openHistory), for: .touchUpInside)
                
                cell.addSubview(historyCollection!)
                historyCollection?.snp.makeConstraints({ make in
                    make.left.right.bottom.equalToSuperview().inset(10)
                    make.top.equalTo(historyLabel.snp.bottom).inset(-15)
                })
                historyCollection?.backgroundColor = .white
                
            }
            
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "second", for: indexPath)
            cell.subviews.forEach { $0.removeFromSuperview() }
            cell.backgroundColor = .white
            cell.layer.cornerRadius = 12
            if racionArr.count == 0 {
                let label = UILabel()
                label.text = "There are no records"
                label.font = .systemFont(ofSize: 17, weight: .semibold)
                label.textColor = .black
                cell.addSubview(label)
                label.snp.makeConstraints { make in
                    make.centerX.centerY.equalToSuperview()
                }
            } else {
                let image = UIImage(data: racionArr[indexPath.row].photo)
                let imageView = UIImageView(image: image)
                imageView.layer.cornerRadius = 12
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                cell.addSubview(imageView)
                imageView.snp.makeConstraints { make in
                    make.height.width.equalTo(50)
                    make.centerY.equalToSuperview()
                    make.left.equalToSuperview().inset(15)
                }
                
                let nameLabel = UILabel()
                nameLabel.font = .systemFont(ofSize: 17, weight: .semibold)
                nameLabel.textColor = .black
                nameLabel.text = racionArr[indexPath.row].name
                cell.addSubview(nameLabel)
                
                nameLabel.snp.makeConstraints { make in
                    make.left.equalTo(imageView.snp.right).inset(-10)
                    make.bottom.equalTo(imageView.snp.centerY).offset(-2)
                }
                
                
                let dateLabel = UILabel()
                dateLabel.font = .systemFont(ofSize: 15, weight: .semibold)
                dateLabel.textColor = UIColor(red: 160/255, green: 159/255, blue: 161/255, alpha: 1)
                dateLabel.text = racionArr[indexPath.row].date
                cell.addSubview(dateLabel)
                dateLabel.snp.makeConstraints { make in
                    make.left.equalTo(imageView.snp.right).inset(-10)
                    make.top.equalTo(imageView.snp.centerY).offset(2)
                }
                
                let imageViewArrow = UIImageView(image: .arrow)
                imageViewArrow.contentMode = .scaleAspectFit
                cell.addSubview(imageViewArrow)
                imageViewArrow.snp.makeConstraints { make in
                    make.width.height.equalTo(24)
                    make.right.equalToSuperview().inset(15)
                    make.centerY.equalToSuperview()
                }
            }
            
            
            cell.layer.shadowColor = UIColor.black.cgColor
            cell.layer.shadowOpacity = 0.25
            cell.layer.shadowOffset = CGSize(width: 0, height: 2)
            cell.layer.shadowRadius = 4
            cell.layer.masksToBounds = false
            return cell
        }
        
    }
    
    @objc func openHistory() {
        let vc = NewHistoryViewController()
        vc.delegate = self
        self.present(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == mainCollection {
            if indexPath.item == 1 && racionArr.count == 0  {
                return CGSize(width: collectionView.frame.width - 30, height: 276)
            } else if racionArr.count != 0 || indexPath.item == 0 {
                return CGSize(width: collectionView.frame.width - 30, height: 314)
            } else {
                return CGSize(width: collectionView.frame.width - 30, height: 200)
            }
        } else {
            if racionArr.count == 0 {
                return CGSize(width: collectionView.frame.width - 15, height: 200)
            } else {
                return CGSize(width: collectionView.frame.width - 15, height: 74)
            }
        }
        
    }
    
    
}


extension RacionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        checkFill()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkFill()
    }
    
}
 

extension RacionViewController: RacionViewControllerDelegate {
    func reloadTable() {
        mainCollection?.reloadData()
        historyCollection?.reloadData()
    }
}
