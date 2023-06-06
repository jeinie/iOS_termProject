//
//  CaloriesViewController.swift
//  CaloriesCalculator
//
//  Created by 장정윤 on 2023/06/05.
//

import UIKit
import FSCalendar
import JJFloatingActionButton

class CaloriesViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate {

    @IBOutlet weak var calorieConsumption: UILabel!
    @IBOutlet weak var targetCalorie: UILabel!
    @IBOutlet weak var fsCalendar: FSCalendar!
    @IBOutlet weak var calorieList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fsCalendar.dataSource = self
        fsCalendar.delegate = self
        
    }
    
    // 플로팅 버튼 라이브러리 사용
    func addFloatingButton() {
        let addBtn = JJFloatingActionButton()
        
    }
    
    // add 버튼을 눌렀을 때
    
}

