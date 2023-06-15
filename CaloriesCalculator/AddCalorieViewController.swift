//
//  AddCalorieViewController.swift
//  CaloriesCalculator
//
//  Created by 장정윤 on 2023/06/06.
//

import UIKit

class AddCalorieViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    let baseURL = "https://openapi.foodsafetykorea.go.kr/api"
    let apiKey = "8e76f22662e143f59385"
    var data: String?
    var isFiltering: Bool = false
    var foodList: [[String: String]] = []
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let time = data {
            self.title = time
        }
        
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.returnKeyType = .search
        
        searchTableView.delegate = self
        searchTableView.dataSource = self
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchFood(searchBar)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
    }
    
    func searchFood(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            print("검색어: \(searchText)")
            getCalories(foodName: searchText)
        }
        searchBar.resignFirstResponder()
    }
}

extension AddCalorieViewController {
    func getCalories(foodName food: String) {
        let encodedFoodName = food.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let urlStr = baseURL + "/" + apiKey + "/I2790/json/1/10/DESC_KOR=" + encodedFoodName!
        let session = URLSession(configuration: .default)
        let url = URL(string: urlStr)
        print("urlStr: \(urlStr)")
        let request = URLRequest(url: url!)
        
        let dataTask = session.dataTask(with: request) {
            (data, response, error) in
            if let error = error {
                print("요청 실패: \(error.localizedDescription)")
                return
            }
            
            guard let jsonData = data else { print(error!); return }
            do {
                if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                   let i2790 = json["I2790"] as? [String: Any],
                   let rows = i2790["row"] as? [[String: Any]] {
                    self.showFoodList(rows)
                }
            } catch {
                print("데이터 처리 실패: \(error.localizedDescription)")
            }
            
            if let jsonStr = String(data:jsonData, encoding: .utf8) {
                print("응답 데이터: \(jsonStr)")
            }
        }
        
        dataTask.resume()
    }
    
    func showFoodList(_ rows: [[String: Any]]) {
        foodList = rows.compactMap { row in
            guard let foodName = row["DESC_KOR"] as? String else {
                return nil
            }
            guard let calorie = row["NUTR_CONT1"] as? String else {
                return nil
            }
            
            return ["foodName": foodName, "calorie": calorie]
        }
        
        print("foodList: \(foodList)")
        DispatchQueue.main.async { [weak self] in
            self?.searchTableView.reloadData()
        }
    }
}

extension AddCalorieViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell")!
        let data = foodList[indexPath.row]
        let foodName = data["foodName"] ?? ""
        let calorie = data["calorie"] ?? ""
        
        cell.textLabel?.text = foodName
        cell.detailTextLabel?.text = calorie + " Kcal"
        
        return cell
    }
}
