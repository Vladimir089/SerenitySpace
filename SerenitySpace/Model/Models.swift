//
//  Models.swift
//  SerenitySpace
//
//  Created by Владимир Кацап on 08.07.2024.
//

import Foundation


struct User: Codable {
    let name: String
    let photo: Data
    let age: Int
    let sex: String
    
    init(name: String, photo: Data, age: Int, sex: String) {
        self.name = name
        self.photo = photo
        self.age = age
        self.sex = sex
    }
}


struct blud: Codable {
    var name: String
    var date: String
    var carbs: String
    var protein: String
    var kcal: String
    var fats: String
    var photo: Data
    var ingridients: [Ingridients]
    
    init(name: String, date: String, carbs: String, protein: String, kcal: String, fats: String, photo: Data, ingridients: [Ingridients]) {
        self.name = name
        self.date = date
        self.carbs = carbs
        self.protein = protein
        self.kcal = kcal
        self.fats = fats
        self.photo = photo
        self.ingridients = ingridients
    }
}


struct Ingridients: Codable {
    var name: String
    var quanity: String
}
