//
//  AddCalorieViewController.swift
//  CaloriesCalculator
//
//  Created by 장정윤 on 2023/06/06.
//

import UIKit

class AddCalorieViewController: UIViewController {
    
    let baseURL = "http://openapi.foodsafetykorea.go.kr/api"
    let apiKey = "8e76f22662e143f59385"

    @IBOutlet weak var time: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

extension AddCalorieViewController {
    func getCalories(foodName food: String) {
        let urlStr = baseURL + "/" + apiKey + "I2790/json/1/5/DESC_KOR=" + food
        let session = URLSession(configuration: .default)
        let url = URL(string: urlStr)
        let request = URLRequest(url: url!)
        
        let dataTask = session.dataTask(with: request) {
            (data, response, error) in
            guard let jsonData = data else { print(error!); return }
            if let jsonStr = String(data:jsonData, encoding: .utf8) {
                print(jsonStr)
            }
        }
        
    }
}
