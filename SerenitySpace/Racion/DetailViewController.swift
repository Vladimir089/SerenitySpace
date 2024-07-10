//
//  DetailViewController.swift
//  SerenitySpace
//
//  Created by Владимир Кацап on 10.07.2024.
//

import UIKit

class DetailViewController: UIViewController {
    
    var index = 0
    var collection: UICollectionView?
    weak var delegate: RacionViewControllerDelegate?

   
    override func viewDidLoad() {
        super.viewDidLoad()

        createInterface()
    }
    
    
    func createInterface() {
        view.backgroundColor = .gray
        
        let imageView = UIImageView(image: UIImage(data: racionArr[index].photo))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(view.snp.centerY)
        }
        
        
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
        
        
        let whiteView: UIView = {
            let view = UIView()
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = 0.25
            view.layer.shadowOffset = CGSize(width: 0, height: 2)
            view.layer.shadowRadius = 4
            view.layer.masksToBounds = false
            view.layer.cornerRadius = 20
            view.backgroundColor = .white
            return view
        }()
        view.addSubview(whiteView)
        whiteView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).inset(30)
        }
        
        
        let nameLabel: UILabel = {
            let label = UILabel()
            label.text = racionArr[index].name
            label.font = .systemFont(ofSize: 28, weight: .bold)
            label.textAlignment = .left
            label.numberOfLines = 2
            label.textColor = .black
            return label
        }()
        whiteView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(25)
            make.top.equalToSuperview().inset(25)
        }
        
        
        var dateLabel: UILabel = {
            let label = UILabel()
            label.text = racionArr[index].date
            label.font = .systemFont(ofSize: 15, weight: .semibold)
            label.textColor = UIColor(red: 160/255, green: 159/255, blue: 161/255, alpha: 1)
            label.textAlignment = .left
            return label
        }()
        whiteView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(25)
            make.top.equalTo(nameLabel.snp.bottom).inset(-5)
        }
        
        
        let oneStackView: UIStackView = {
            let stack = UIStackView()
            stack.axis = .horizontal
            stack.spacing = 10
            stack.distribution = .fillEqually
            return stack
        }()
        whiteView.addSubview(oneStackView)
        oneStackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(25)
            make.top.equalTo(dateLabel.snp.bottom).inset(-25)
            make.height.equalTo(44)
        }
        let carbsView = createOtherView(text: "\(racionArr[index].carbs)g carbs", image: UIImage.star)
        let proteinView = createOtherView(text: "\(racionArr[index].protein)g proteins", image: UIImage.prot)
        oneStackView.addArrangedSubview(carbsView)
        oneStackView.addArrangedSubview(proteinView)
        
        
        let twoStackView: UIStackView = {
            let stack = UIStackView()
            stack.axis = .horizontal
            stack.spacing = 10
            stack.distribution = .fillEqually
            return stack
        }()
        whiteView.addSubview(twoStackView)
        twoStackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(25)
            make.top.equalTo(oneStackView.snp.bottom).inset(-15)
            make.height.equalTo(44)
        }
        
        let kcalView = createOtherView(text: "\(racionArr[index].kcal) Kcal", image: UIImage.kcal)
        let fatsView = createOtherView(text: "\(racionArr[index].fats)g fats", image: UIImage.fat)
        twoStackView.addArrangedSubview(kcalView)
        twoStackView.addArrangedSubview(fatsView)
        
        let labelIngr = UILabel()
        labelIngr.text = "Ingredients"
        labelIngr.font = .systemFont(ofSize: 22, weight: .bold)
        labelIngr.textColor = .black
        view.addSubview(labelIngr)
        labelIngr.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(25)
            make.top.equalTo(twoStackView.snp.bottom).inset(-25)
        }
        
        collection = {
            let layout = UICollectionViewFlowLayout()
            let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "main")
            collection.showsVerticalScrollIndicator = false
            collection.delegate = self
            collection.dataSource = self
            layout.sectionInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
            layout.scrollDirection = .vertical
            return collection
        }()
        whiteView.addSubview(collection!)
        collection?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview().inset(15)
            make.bottom.equalToSuperview()
            make.top.equalTo(labelIngr.snp.bottom).inset(-20)
        })
        
        let editButton = UIButton(type: .system)
        editButton.setTitle("Edit", for: .normal)
        editButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        editButton.setTitleColor(.white, for: .normal)
        view.addSubview(editButton)
        editButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(15)
            make.top.equalToSuperview().inset(15)
        }
        editButton.addTarget(self, action: #selector(edit), for: .touchUpInside)
    }
    
    
    @objc func edit() {
        
        
        self.dismiss(animated: true)
        delegate?.openEdit(index: index)
    }
    
    
    func createOtherView(text: String, image: UIImage) -> UIView {
        let view = UIView()
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.height.width.equalTo(44)
        }
        
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .black
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalTo(imageView.snp.right).inset(-5)
            make.centerY.equalToSuperview()
        }
        
        return view
    }


}


extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return racionArr[index].ingridients.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "main", for: indexPath)
        cell.subviews.forEach { $0.removeFromSuperview() }
        cell.backgroundColor = .white
        cell.layer.cornerRadius = 12
        
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.25
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.shadowRadius = 4
        cell.layer.masksToBounds = false
        
        let labelName = UILabel()
        labelName.text =  racionArr[index].ingridients[indexPath.row].name
        labelName.font = .systemFont(ofSize: 17, weight: .semibold)
        labelName.textColor = .black
        cell.addSubview(labelName)
        labelName.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(10)
        }
        
        let labelCount = UILabel()
        labelCount.text =  racionArr[index].ingridients[indexPath.row].quanity
        labelCount.font = .systemFont(ofSize: 17, weight: .semibold)
        labelCount.textColor = .black
        cell.addSubview(labelCount)
        labelCount.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(10)
        }
        
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 10, height: 48)
    }
    
    
}
