//
//  AddCalorieViewController.swift
//  CaloriesCalculator
//
//  Created by 장정윤 on 2023/06/06.
//

import UIKit
import FirebaseFirestore

class AddCalorieViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    let db = Firestore.firestore()
    let baseURL = "https://openapi.foodsafetykorea.go.kr/api"
    let apiKey = "8e76f22662e143f59385"
    var selectedDate: Date?
    var month: Int?
    var day: Int?
    var time: String?
    var isFiltering: Bool = false
    var foodList: [[String: String]] = []
    var foodArr: [String] = [] // 파이어베이스에 저장할 음식 이름 배열
    var calorieArr: [String] = [] // 파이어베이스에 저장할 칼로리 배열
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 선택한 날짜
        if let selectedDate = selectedDate {
            let calendar = Calendar.current
            let month = calendar.component(.month, from: selectedDate)
            let day = calendar.component(.day, from: selectedDate)
            
            print("선택한 날짜(월, 일): \(month)월 \(day)일")
            self.month = month
            self.day = day
        }
        // 선택한 시간
        if let time = time {
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
            guard let foodName = row["DESC_KOR"] as? String else { return nil }
            guard let calorie = row["NUTR_CONT1"] as? String else { return nil }
            
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
    
    // 테이블 셀에 검색어에 해당하는 음식들과 칼로리 보이기
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell")!
        let data = foodList[indexPath.row]
        let foodName = data["foodName"] ?? ""
        let calorie = data["calorie"] ?? ""
        
        cell.textLabel?.text = foodName
        cell.detailTextLabel?.text = calorie + " Kcal"
        
        return cell
    }
    
    // 테이블 셀을 클릭하면 액션시트 띄우기
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // 선택된 셀 바로 deselect (회색으로 유지되는 거 방지)
        let actionSheet = UIAlertController(title: "칼로리 추가하기", message: "추가하시겠습니까?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "추가하기", style: .default, handler: {(ACTION:UIAlertAction) in
            print(">> 추가하기 선택")
            
            // 파이어베이스에 선택한 셀의 데이터 추가
            let selectedCell = tableView.cellForRow(at: indexPath)
            if let foodName = selectedCell?.textLabel?.text, let calorie = selectedCell?.detailTextLabel?.text {
                print("선택한 셀의 음식이름: \(foodName)")
                print("선택한 셀의 칼로리: \(calorie)")
                
                self.foodArr.append(foodName)
                self.calorieArr.append(calorie)
                
                // 파이어베이스에 문서 없는 경우, 초기 세팅
                let data: [String: Any] = [
                    "foods": self.foodArr,
                    "calories": self.calorieArr,
                    "calorieTotal": calorie
                ]
                
                let date = "\(self.month!)월 \(self.day!)일"
                let documentRef = self.db.collection(date).document(self.title!)
                documentRef.getDocument { (document, error) in
                    // 문서 이미 존재하면, 기존 칼로리에 더함 (칼로리 총합)
                    if let document = document, document.exists {
                        if var foodArr = document.data()?["foods"] as? [String], var calorieArr = document.data()?["calories"] as? [String], let calorieTotal = document.data()?["calorieTotal"] as? String {
                            
                            foodArr.append(foodName)
                            calorieArr.append(calorie)
                            
                            let extractCalorieTotal = calorieTotal.replacingOccurrences(of: " Kcal", with: "")
                            let extractSearchedCalorie = calorie.replacingOccurrences(of: " Kcal", with: "")
                            if let existCalorieTotalDouble = Double(extractCalorieTotal), let searchedCalorie = Double(extractSearchedCalorie) {
                                let currentCalorie = existCalorieTotalDouble + searchedCalorie
                                print("선택한 칼로리: \(searchedCalorie)")
                                print("더한 칼로리: \(currentCalorie)")
                                let resCalorie = String(format: "%.2f", currentCalorie)
                                let calorieVal = resCalorie + " Kcal"
                                documentRef.updateData([
                                    "foods": foodArr,
                                    "calories": calorieArr,
                                    "calorieTotal": calorieVal]) { error in
                                        if let error = error {
                                            print("칼로리 더하기 실패: \(error)")
                                        } else {
                                            print("칼로리 더하기 성공")
                                        }
                                    }
                            } else {
                                print("칼로리 double 형 변환 실패")
                            }
                        }
                    } else {
                        documentRef.setData(data) { error in
                            if let error = error {
                                print("Firestore 데이터 추가 실패: \(error.localizedDescription)")
                            } else {
                                print("Firestore 데이터 추가 성공")
                            }
                        }
                    }
                }
            }
            
            self.navigationController?.popViewController(animated: true) // 이전 화면으로 이동
        }))
        
        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        // 액션시트 표시
        present(actionSheet, animated: true, completion: nil)
    }
}
