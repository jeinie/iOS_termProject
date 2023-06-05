//
//  CaloriesViewController.swift
//  CaloriesCalculator
//
//  Created by 장정윤 on 2023/06/05.
//

import UIKit
import FSCalendar

class CaloriesViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate {

    @IBOutlet weak var calorieConsumption: UILabel!
    @IBOutlet weak var targetCalories: UITextField!
    @IBOutlet weak var fsCalendar: FSCalendar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fsCalendar.dataSource = self
        fsCalendar.delegate = self
        
        
    }
}
