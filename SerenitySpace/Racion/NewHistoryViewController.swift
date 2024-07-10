//
//  NewHistoryViewController.swift
//  SerenitySpace
//
//  Created by Владимир Кацап on 09.07.2024.
//

import UIKit

class NewHistoryViewController: UIViewController,  UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    weak var delegate: RacionViewControllerDelegate?
    
    var collection: UICollectionView?
    var saveEditButton: UIButton?
    var addNewComponent: UIView?
    var nameComponentTextField, quanComponentTextField: UITextField?
    var saveComponentButton: UIButton?
    var nameTextField, dateTextField: UITextField?
    var carbsTextField, kcalTextField, proteinTextField, fatsTextField: UITextField?
    var isEdit = 0
    var isEditElement: Bool?
    var index = 0
    var isEditOldValue = false
    
    var imageViewBlude: UIImageView?
    var indgridients: [Ingridients] = []
    var name, date, carbs, kcal, protein, fats: String?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        createInerface()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        checkFill()
        UIView.animate(withDuration: 0.3) {
            self.view.transform = CGAffineTransform(translationX: 0, y: -150)
            
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        checkFill()
        UIView.animate(withDuration: 0.3) {
            self.view.transform = .identity
        }
    }
    
    @objc func saveComponent() {
        
        let newBlud = blud(name: name ?? "", date: date ?? "", carbs: carbs ?? "", protein: protein ?? "", kcal: kcal ?? "", fats: fats ?? "", photo: imageViewBlude?.image?.jpegData(compressionQuality: 0.5) ?? Data(), ingridients: indgridients)
        
        
        print(isEditElement)

        
        if isEditOldValue == false {
            racionArr.append(newBlud)
        } else {
            racionArr[index] = newBlud
        }
        
        
        
        do {
            let data = try JSONEncoder().encode(racionArr) //тут мкассив конвертируем в дату
            try saveAthleteArrToFile(data: data)
           
            delegate?.reloadTable()
            dismiss(animated: true)
        } catch {
            print("Failed to encode or save athleteArr: \(error)")
        }
        
        
    }
    
    func check() {
        if let nameText = nameTextField?.text, !nameText.isEmpty,
           let dateText = dateTextField?.text, !dateText.isEmpty,
           let carbsText = carbsTextField?.text, !carbsText.isEmpty,
           let kcalText = kcalTextField?.text, !kcalText.isEmpty,
           let proteinText = proteinTextField?.text, !proteinText.isEmpty,
           let fatsText = fatsTextField?.text, !fatsText.isEmpty {
            saveEditButton?.isEnabled = true
        } else {
            saveEditButton?.isEnabled = false
        }
    }
    
    
    //СОХРАНЕНИЕ В ФАЙЛ
    func saveAthleteArrToFile(data: Data) throws {
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath = documentDirectory.appendingPathComponent("Elements.plist")
            try data.write(to: filePath)
        } else {
            throw NSError(domain: "SaveError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to get document directory"])
        }
    }
    
    @objc func hideKey() {
        view.endEditing(true)
    }
    
    func createInerface() {
        

        
        let hideView: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor(red: 60/255, green: 60/255, blue: 67/255, alpha: 0.3)
            view.layer.cornerRadius = 2.5
            return view
        }()
        view.addSubview(hideView)
        hideView.snp.makeConstraints { make in
            make.height.equalTo(5)
            make.width.equalTo(36)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(10)
        }
        
        saveEditButton = {
            let button = UIButton(type: .system)
            button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
            button.backgroundColor = .clear
            button.setTitle("Save", for: .normal)
            button.setTitleColor(UIColor(red: 30/255, green: 171/255, blue: 78/255, alpha: 1), for: .normal)
            button.setTitleColor(UIColor(red: 30/255, green: 171/255, blue: 78/255, alpha: 0.5), for: .disabled)
            return button
        }()
        view.addSubview(saveEditButton!)
        saveEditButton?.snp.makeConstraints { make in
            make.right.top.equalToSuperview().inset(15)
        }
        saveEditButton?.addTarget(self, action: #selector(saveComponent), for: .touchUpInside)
        
        imageViewBlude = {
            let imageView = UIImageView()
            if isEditOldValue == false {
                let image = UIImage.newBlude
                imageView.image = image
            } else {
                let image = UIImage(data: racionArr[index].photo)
                imageView.image = image
            }
           
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = 16
            imageView.clipsToBounds = true
            imageView.layer.borderColor = UIColor(red: 255/255, green: 215/255, blue: 7/255, alpha: 1).cgColor
            imageView.layer.borderWidth = 2
            imageView.isUserInteractionEnabled = true
            return imageView
        }()
        view.addSubview(imageViewBlude!)
        imageViewBlude?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview().inset(30)
            make.height.equalTo(200)
            make.top.equalTo(saveEditButton!.snp.bottom).inset(-20)
        })
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(changePhoto))
        imageViewBlude?.addGestureRecognizer(gesture)
        
        collection = {
            let layout = UICollectionViewFlowLayout()
            let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 20
            collection.showsVerticalScrollIndicator = false
            collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "main")
            collection.backgroundColor = .clear
            collection.delegate = self
            collection.dataSource = self
            collection.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 24, right: 0)
            return collection
        }()
        view.addSubview(collection!)
        collection?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview().inset(30)
            make.bottom.equalToSuperview()
            make.top.equalTo(imageViewBlude!.snp.bottom).inset(-20)
        })
        
        addNewComponent = {
            let view = UIView()
            view.alpha = 0
            view.backgroundColor = .white
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = 0.25
            view.layer.shadowOffset = CGSize(width: 0, height: 2)
            view.layer.shadowRadius = 4
            view.layer.masksToBounds = false
            
            view.layer.cornerRadius = 12
            
            let label = UILabel()
            label.text = "Ingredients"
            label.font = .systemFont(ofSize: 22, weight: .semibold)
            label.textColor = .black
            view.addSubview(label)
            label.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().inset(20)
            }
            
            let nameLabel = UILabel()
            nameLabel.text = "Name"
            nameLabel.font = .systemFont(ofSize: 17, weight: .semibold)
            nameLabel.textColor = .black
            view.addSubview(nameLabel)
            nameLabel.snp.makeConstraints { make in
                make.left.equalToSuperview().inset(15)
                make.top.equalTo(label.snp.bottom).inset(-20)
            }
            
            
            nameComponentTextField = UITextField()
            nameComponentTextField?.placeholder = "Text"
            nameComponentTextField?.textColor = .black
            nameComponentTextField?.delegate = self
            nameComponentTextField?.borderStyle = .none
            
            view.addSubview(nameComponentTextField!)
            nameComponentTextField?.snp.makeConstraints({ make in
                make.height.equalTo(44)
                make.left.right.equalToSuperview().inset(15)
                make.top.equalTo(nameLabel.snp.bottom).inset(-10)
            })
            let sepOne = UIView()
            sepOne.backgroundColor = UIColor(red: 165/255, green: 165/255, blue: 165/255, alpha: 1)
            view.addSubview(sepOne)
            sepOne.snp.makeConstraints { make in
                make.height.equalTo(1)
                make.left.right.equalToSuperview().inset(15)
                make.top.equalTo(nameComponentTextField!.snp.bottom)
            }
            
            let quanLabel = UILabel()
            quanLabel.text = "Quantity"
            quanLabel.font = .systemFont(ofSize: 17, weight: .semibold)
            quanLabel.textColor = .black
            view.addSubview(quanLabel)
            quanLabel.snp.makeConstraints { make in
                make.left.equalToSuperview().inset(15)
                make.top.equalTo(sepOne.snp.bottom).inset(-20)
            }
            
            quanComponentTextField = UITextField()
            quanComponentTextField?.placeholder = "Text"
            quanComponentTextField?.textColor = .black
            quanComponentTextField?.delegate = self
            quanComponentTextField?.borderStyle = .none
            view.addSubview(quanComponentTextField!)
            quanComponentTextField?.snp.makeConstraints({ make in
                make.height.equalTo(44)
                make.left.right.equalToSuperview().inset(15)
                make.top.equalTo(quanLabel.snp.bottom).inset(-10)
            })
            let sepTwo = UIView()
            sepTwo.backgroundColor = UIColor(red: 165/255, green: 165/255, blue: 165/255, alpha: 1)
            view.addSubview(sepTwo)
            sepTwo.snp.makeConstraints { make in
                make.height.equalTo(1)
                make.left.right.equalToSuperview().inset(15)
                make.top.equalTo(quanComponentTextField!.snp.bottom)
            }
            
            
            let cancelButton: UIButton = {
                let button = UIButton(type: .system)
                button.setTitle("Cancel", for: .normal)
                button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
                button.backgroundColor = .white
                button.setTitleColor(UIColor(red: 255/255, green: 215/255, blue: 7/255, alpha: 1), for: .normal)
                button.layer.borderColor = UIColor(red: 255/255, green: 215/255, blue: 7/255, alpha: 1).cgColor
                button.layer.borderWidth = 1
                button.layer.cornerRadius = 12
                return button
            }()
            view.addSubview(cancelButton)
            cancelButton.snp.makeConstraints { make in
                make.height.equalTo(54)
                make.left.bottom.equalToSuperview().inset(15)
                make.width.equalTo(140)
            }
            cancelButton.addTarget(self, action: #selector(hide), for: .touchUpInside)
            
            saveComponentButton = UIButton(type: .system)
            saveComponentButton?.setTitle("Save", for: .normal)
            saveComponentButton?.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
            saveComponentButton?.setTitleColor(.white, for: .normal)
            saveComponentButton?.backgroundColor = UIColor(red: 255/255, green: 215/255, blue: 7/255, alpha: 1)
            saveComponentButton?.layer.cornerRadius = 12
            saveComponentButton?.isUserInteractionEnabled = false
            saveComponentButton?.alpha = 0.5
            view.addSubview(saveComponentButton!)
            saveComponentButton?.snp.makeConstraints({ make in
                make.height.equalTo(54)
                make.right.bottom.equalToSuperview().inset(15)
                make.width.equalTo(140)
            })
            
            saveComponentButton?.addTarget(self, action: #selector(newComponent), for: .touchUpInside)
            
            
            let gesture = UITapGestureRecognizer(target: self, action: #selector(hideEditViewKeyboard))
            view.addGestureRecognizer(gesture)
            return view
        }()
        
        view.addSubview(addNewComponent!)
        addNewComponent?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview().inset(30)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(334)
        })
        
        check()
    }
    
    func checkBut() {
        if isEditElement == true {
            saveComponentButton?.removeTarget(nil, action: nil, for: .allEvents)
            saveComponentButton?.addTarget(self, action: #selector(editElement), for: .touchUpInside)
        } else {
            saveComponentButton?.removeTarget(nil, action: nil, for: .allEvents)
            saveComponentButton?.addTarget(self, action: #selector(newComponent), for: .touchUpInside)
        }
        check()
    }
    
    @objc func editElement() {
        let newComponent = Ingridients(name: nameComponentTextField?.text ?? "", quanity: quanComponentTextField?.text ?? "")
        indgridients[isEdit] = newComponent
        collection?.reloadData()
        hide()
        check()
    }
    
    @objc func newComponent() {
        let newComponent = Ingridients(name: nameComponentTextField?.text ?? "", quanity: quanComponentTextField?.text ?? "")
        indgridients.append(newComponent)
        collection?.reloadData()
        check()
        hide()
    }
    
    func checkFill() {
        if nameComponentTextField?.text != "" && quanComponentTextField?.text != "" {
            saveComponentButton?.alpha = 1
            saveComponentButton?.isUserInteractionEnabled = true
        } else {
            saveComponentButton?.alpha = 0.5
            saveComponentButton?.isUserInteractionEnabled = false
        }
        check()
    }
    
    @objc func hideEditViewKeyboard() {
        view.endEditing(true)
        checkFill()
    }
    
    @objc func hide() {
        isEditElement = false
        nameComponentTextField?.text = ""
        quanComponentTextField?.text = ""
        UIView.animate(withDuration: 0.3) {
            self.addNewComponent?.alpha = 0
        }
        view.endEditing(true)
        check()
    }
    
    
    @objc func changePhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
        check()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            imageViewBlude?.image = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            imageViewBlude?.image = originalImage
        }
        dismiss(animated: true, completion: nil)
        check()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        check()
    }
    
    
}


extension NewHistoryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if indgridients.count == 0 {
            return 4
        } else {
            return 3 + indgridients.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "main", for: indexPath)
        cell.subviews.forEach { $0.removeFromSuperview() }
        let gestureHide = UITapGestureRecognizer(target: self, action: #selector(hideKey))
        cell.layer.shadowOpacity = 0
        cell.layer.shadowRadius = 0
        cell.layer.shadowOffset = .zero
        cell.layer.shadowColor = nil
        cell.backgroundColor = .white
        
        if indexPath.row == 0 {
            cell.addGestureRecognizer(gestureHide)
            let labelName = UILabel()
            labelName.text = "Name"
            labelName.textColor = .black
            labelName.font = .systemFont(ofSize: 17, weight: .semibold)
            cell.addSubview(labelName)
            labelName.snp.makeConstraints { make in
                make.top.left.equalToSuperview()
            }
            
            var oneSeparator = UIView()
            oneSeparator.backgroundColor = UIColor(red: 165/255, green: 165/255, blue: 165/255, alpha: 1)
            cell.addSubview(oneSeparator)
            oneSeparator.snp.makeConstraints { make in
                make.height.equalTo(1)
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview()
            }
            
            nameTextField = UITextField()
            nameTextField?.placeholder = "Text"
            nameTextField?.textColor = .black
            nameTextField?.borderStyle = .none
            nameTextField?.delegate = self
            nameTextField?.text = name ?? ""
            cell.addSubview(nameTextField!)
            nameTextField?.snp.makeConstraints({ make in
                make.left.right.equalToSuperview()
                make.bottom.equalTo(oneSeparator.snp.top)
                make.height.equalTo(46)
            })
        }
        
        if indexPath.row == 1 {
            cell.addGestureRecognizer(gestureHide)
            let labelName = UILabel()
            labelName.text = "Date"
            labelName.textColor = .black
            labelName.font = .systemFont(ofSize: 17, weight: .semibold)
            cell.addSubview(labelName)
            labelName.snp.makeConstraints { make in
                make.top.left.equalToSuperview()
            }
            
            var oneSeparator = UIView()
            oneSeparator.backgroundColor = UIColor(red: 165/255, green: 165/255, blue: 165/255, alpha: 1)
            cell.addSubview(oneSeparator)
            oneSeparator.snp.makeConstraints { make in
                make.height.equalTo(1)
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview()
            }
            
            dateTextField = UITextField()
            dateTextField?.placeholder = "Text"
            dateTextField?.textColor = .black
            dateTextField?.borderStyle = .none
            dateTextField?.delegate = self
            dateTextField?.text = date ?? ""
            cell.addSubview(dateTextField!)
            dateTextField?.snp.makeConstraints({ make in
                make.left.right.equalToSuperview()
                make.bottom.equalTo(oneSeparator.snp.top)
                make.height.equalTo(46)
            })

            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            if #available(iOS 13.4, *) {
                datePicker.preferredDatePickerStyle = .wheels
            } else {
                //
            }
            datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
            dateTextField?.inputView = datePicker
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
            toolbar.setItems([doneButton], animated: true)
            dateTextField?.inputAccessoryView = toolbar
        }
        
        if indexPath.row == 2 {
            cell.addGestureRecognizer(gestureHide)
            let carbImageView = UIImageView(image: .star)
            cell.addSubview(carbImageView)
            carbImageView.snp.makeConstraints { make in
                make.height.width.equalTo(44)
                make.top.left.equalToSuperview()
            }
            
            let separatorViewOne = UIView()
            separatorViewOne.backgroundColor = UIColor(red: 165/255, green: 165/255, blue: 165/255, alpha: 1)
            cell.addSubview(separatorViewOne)
            separatorViewOne.snp.makeConstraints { make in
                make.height.equalTo(1)
                make.left.equalTo(carbImageView.snp.right).inset(-10)
                make.right.equalTo(cell.snp.centerX).offset(-20)
                make.bottom.equalTo(carbImageView.snp.bottom)
            }
            
            carbsTextField = UITextField()
            carbsTextField?.textColor = .black
            carbsTextField?.placeholder = "0g carbs"
            carbsTextField?.borderStyle = .none
            carbsTextField?.delegate = self
            carbsTextField?.text = carbs ?? ""
            cell.addSubview(carbsTextField!)
            carbsTextField?.snp.makeConstraints({ make in
                make.height.equalTo(44)
                make.left.equalTo(carbImageView.snp.right).inset(-10)
                make.right.equalTo(cell.snp.centerX).offset(-20)
                make.bottom.equalTo(separatorViewOne.snp.top)
            })
            
            
            
            let protImageView = UIImageView(image: .kcal)
            protImageView.contentMode = .scaleAspectFit
            cell.addSubview(protImageView)
            protImageView.snp.makeConstraints { make in
                make.height.width.equalTo(44)
                make.left.equalToSuperview()
                make.top.equalTo(carbImageView.snp.bottom).inset(-15)
            }
            
            let separatorViewTwo = UIView()
            separatorViewTwo.backgroundColor = UIColor(red: 165/255, green: 165/255, blue: 165/255, alpha: 1)
            cell.addSubview(separatorViewTwo)
            separatorViewTwo.snp.makeConstraints { make in
                make.height.equalTo(1)
                make.left.equalTo(protImageView.snp.right).inset(-10)
                make.right.equalTo(cell.snp.centerX).offset(-20)
                make.bottom.equalTo(protImageView.snp.bottom)
            }
            
            
            kcalTextField = UITextField()
            kcalTextField?.textColor = .black
            kcalTextField?.placeholder = "0 Kcal"
            kcalTextField?.borderStyle = .none
            kcalTextField?.text = kcal ?? ""
            kcalTextField?.delegate = self
            cell.addSubview(kcalTextField!)
            kcalTextField?.snp.makeConstraints({ make in
                make.height.equalTo(44)
                make.left.equalTo(protImageView.snp.right).inset(-10)
                make.right.equalTo(cell.snp.centerX).offset(-20)
                make.bottom.equalTo(separatorViewTwo.snp.top)
            })
            
            
            let protImageViewOff = UIImageView(image: .prot)
            protImageViewOff.contentMode = .scaleAspectFit
            cell.addSubview(protImageViewOff)
            protImageViewOff.snp.makeConstraints { make in
                make.height.width.equalTo(44)
                make.left.equalTo(cell.snp.centerX).offset(20)
                make.top.equalToSuperview()
            }
            
            let sepThree = UIView()
            sepThree.backgroundColor = UIColor(red: 165/255, green: 165/255, blue: 165/255, alpha: 1)
            cell.addSubview(sepThree)
            sepThree.snp.makeConstraints { make in
                make.height.equalTo(1)
                make.right.equalToSuperview()
                make.bottom.equalTo(protImageViewOff.snp.bottom)
                make.left.equalTo(protImageViewOff.snp.right).inset(-10)
            }
            
            proteinTextField = UITextField()
            proteinTextField?.textColor = .black
            proteinTextField?.placeholder = "0g proteins"
            proteinTextField?.borderStyle = .none
            proteinTextField?.delegate = self
            proteinTextField?.text = protein ?? ""
            cell.addSubview(proteinTextField!)
            proteinTextField?.snp.makeConstraints({ make in
                make.height.equalTo(44)
                make.left.right.equalTo(sepThree)
                make.bottom.equalTo(sepThree.snp.top)
            })
            
            
            let fatsImageView = UIImageView(image: .fat)
            fatsImageView.contentMode = .scaleAspectFit
            cell.addSubview(fatsImageView)
            fatsImageView.snp.makeConstraints { make in
                make.height.width.equalTo(44)
                make.left.equalTo(cell.snp.centerX).offset(20)
                make.top.equalTo(protImageViewOff.snp.bottom).inset(-15)
            }
            
            let sepFour = UIView()
            sepFour.backgroundColor = UIColor(red: 165/255, green: 165/255, blue: 165/255, alpha: 1)
            cell.addSubview(sepFour)
            sepFour.snp.makeConstraints { make in
                make.height.equalTo(1)
                make.right.equalToSuperview()
                make.bottom.equalTo(fatsImageView.snp.bottom)
                make.left.equalTo(fatsImageView.snp.right).inset(-10)
            }
            
            fatsTextField = UITextField()
            fatsTextField?.textColor = .black
            fatsTextField?.placeholder = "0g fats"
            fatsTextField?.borderStyle = .none
            fatsTextField?.delegate = self
            fatsTextField?.text = fats ?? ""
            cell.addSubview(fatsTextField!)
            fatsTextField?.snp.makeConstraints({ make in
                make.height.equalTo(44)
                make.left.right.equalTo(sepFour)
                make.bottom.equalTo(sepFour.snp.top)
            })
            
            let ingridientsLabel = UILabel()
            ingridientsLabel.text = "Ingredients"
            ingridientsLabel.font = .systemFont(ofSize: 22, weight: .semibold)
            ingridientsLabel.textColor = .black
            cell.addSubview(ingridientsLabel)
            ingridientsLabel.snp.makeConstraints { make in
                make.left.bottom.equalToSuperview()
            }
            
            let buttonAdd: UIButton = {
                let button = UIButton(type: .system)
                button.setImage(.new.resize(targetSize: CGSize(width: 18, height: 18)), for: .normal)
                button.backgroundColor = .clear
                button.tintColor = .black
                return button
            }()
            cell.addSubview(buttonAdd)
            buttonAdd.snp.makeConstraints { make in
                make.height.width.equalTo(24)
                make.right.equalToSuperview()
                make.centerY.equalTo(ingridientsLabel)
            }
            buttonAdd.addTarget(self, action: #selector(openComp), for: .touchUpInside)
                  
        }
        
        
        
        if indexPath.row == 3 && indgridients.count == 0 {
            cell.layer.shadowColor = UIColor.black.cgColor
            cell.layer.shadowOpacity = 0.25
            cell.layer.shadowOffset = CGSize(width: 0, height: 2)
            cell.layer.shadowRadius = 4
            cell.layer.masksToBounds = false
            cell.backgroundColor = .white
            cell.layer.cornerRadius = 12
            
            let label = UILabel()
            label.text = "There are no records"
            label.font = .systemFont(ofSize: 17, weight: .semibold)
            label.textColor = .black
            cell.addSubview(label)
            label.snp.makeConstraints { make in
                make.centerX.centerY.equalToSuperview()
            }
        }
        if indexPath.row >= 3 && indgridients.count != 0 {
            cell.layer.shadowColor = UIColor.black.cgColor
            cell.layer.shadowOpacity = 0.25
            cell.layer.shadowOffset = CGSize(width: 0, height: 2)
            cell.layer.shadowRadius = 4
            cell.layer.masksToBounds = false
            cell.backgroundColor = .white
            cell.layer.cornerRadius = 12
            let labelIng = UILabel()
            labelIng.text = indgridients[indexPath.row - 3].name
            labelIng.font = .systemFont(ofSize: 17, weight: .semibold)
            labelIng.textColor = .black
            cell.addSubview(labelIng)
            labelIng.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.left.equalToSuperview().inset(10)
            }
            
            
            let imageView = UIImageView(image: .edit)
            cell.addSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.height.width.equalTo(24)
                make.right.equalToSuperview().inset(10)
                make.centerY.equalToSuperview()
            }
            
            var labelCount = UILabel()
            labelCount.text = indgridients[indexPath.row - 3].quanity
            labelCount.font = .systemFont(ofSize: 17, weight: .semibold)
            labelCount.textColor = .black
            cell.addSubview(labelCount)
            labelCount.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.right.equalTo(imageView.snp.left).inset(-10)
            }
            print(indexPath.row)
           
            
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row >= 3 && indgridients.count != 0 {
            
            isEdit = indexPath.row - 3
            nameComponentTextField?.text = indgridients[isEdit].name
            quanComponentTextField?.text = indgridients[isEdit].quanity
            isEditElement = true
            checkBut()
            UIView.animate(withDuration: 0.3) {
                self.addNewComponent?.alpha = 1
            }
            
        }
    }
    
    @objc func del() {
        print(1)
    }
    
    @objc func openComp() {
        isEditElement = false
        checkBut()
        UIView.animate(withDuration: 0.3) {
            self.addNewComponent?.alpha = 1
        }
        view.endEditing(true)
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        dateTextField?.text = dateFormatter.string(from: sender.date)
    }
    
    @objc func donePressed() {
        view.endEditing(true)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 0 || indexPath.row == 1 {
            return CGSize(width: collectionView.frame.width, height: 76)
        } else if indexPath.row == 2 {
            return CGSize(width: collectionView.frame.width, height: 150)
        } else {
            return CGSize(width: collectionView.frame.width - 5, height: 54)
            
        }
    }
    
    
}


extension NewHistoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        checkFill()
        check()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        check()
        switch textField {
        case nameTextField:
            name = nameTextField?.text ?? ""
        case dateTextField:
            date = dateTextField?.text ?? ""
        case carbsTextField:
            carbs = carbsTextField?.text ?? ""
        case kcalTextField:
            kcal = kcalTextField?.text ?? ""
        case proteinTextField:
            protein = proteinTextField?.text ?? ""
        case fatsTextField:
            fats = fatsTextField?.text ?? ""
        default:
            break
        }
        
    }
    
    
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        check()
        switch textField {
        case nameTextField:
            name = nameTextField?.text ?? ""
        case dateTextField:
            date = dateTextField?.text ?? ""
        case carbsTextField:
            carbs = carbsTextField?.text ?? ""
        case kcalTextField:
            kcal = kcalTextField?.text ?? ""
        case proteinTextField:
            protein = proteinTextField?.text ?? ""
        case fatsTextField:
            fats = fatsTextField?.text ?? ""
        default:
            break
        }
        return true
    }
}
