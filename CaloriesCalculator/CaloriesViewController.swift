//
//  CaloriesViewController.swift
//  CaloriesCalculator
//
//  Created by 장정윤 on 2023/06/05.
//

import UIKit
import FSCalendar
import Firebase

class CaloriesViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, UITableViewDelegate {

    @IBOutlet weak var calorieConsumption: UILabel!
    @IBOutlet weak var targetCalorie: UILabel!
    @IBOutlet weak var fsCalendar: FSCalendar!
    @IBOutlet weak var caloriesList: UITableView!
    
    var data: [(foodName: String, calorie: String)] = [] // AddCalorieVC 에 전달할 데이터 저장
    var foodTable: [[String: String]] = []
    var foodName: String?
    var calorie: String?
    let db = Firestore.firestore()
    
    private var animation: UIViewPropertyAnimator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fsCalendar.dataSource = self
        fsCalendar.delegate = self
        caloriesList.delegate = self
        
        setUI() // 플로팅 버튼 세팅
        
        morningBtn.addTarget(self, action: #selector(morningBtnTapped), for: .touchUpInside)
        lunchBtn.addTarget(self, action: #selector(lunchBtnTapped), for: .touchUpInside)
        dinnerBtn.addTarget(self, action: #selector(dinnerBtnTapped), for: .touchUpInside)
    }
    
    // 날짜 선택되었을 때 호출
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print(">> 데이터 가져오기")
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let formattedDate = "\(month)월 \(day)일"
        
        let collectionRef = db.collection(formattedDate)
        collectionRef.document("아침").getDocument { (document, error) in
            if let error = error {
                print("문서 가져오기 실패: \(error)")
                return
            }
            
            if let document = document, document.exists {
                let data = document.data()
                print("data: \(data)")
            } else {
                print("문서가 존재하지 않습니다.")
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        self.viewWillAppear(true)
    }

    private lazy var floatingButton: UIButton = {
        let addBtn = UIButton()
        var config = UIButton.Configuration.filled()
        
        config.baseBackgroundColor = .systemMint
        config.cornerStyle = .capsule
        config.image = UIImage(systemName: "plus")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 20, weight: .medium))

        addBtn.configuration = config
        addBtn.layer.shadowRadius = 10
        addBtn.layer.shadowOpacity = 0.3
        addBtn.addTarget(self, action: #selector(tapFloatingBtn), for: .touchUpInside)
        return addBtn
    }()

    // 아침, 점심, 저녁으로 섭취한 칼로리 각각 나눠서 추가 버튼 만들기
    // 아침 버튼
    private let morningBtn: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()

        config.baseBackgroundColor = .white
        config.baseForegroundColor = .red
        config.cornerStyle = .capsule
        config.image = UIImage(systemName: "sun.and.horizon.fill")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 20, weight: .medium))
        
        button.configuration = config
        button.layer.shadowRadius = 10
        button.layer.shadowOpacity = 0.3
        button.alpha = 0.0
        return button
    }()
    
    // 점심 버튼
    private let lunchBtn: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()

        config.baseBackgroundColor = .blue
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule
        config.image = UIImage(systemName: "sun.max.fill")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 20, weight: .medium))
        
        button.configuration = config
        button.layer.shadowRadius = 10
        button.layer.shadowOpacity = 0.3
        button.alpha = 0.0
        return button
    }()
    
    // 저녁 버튼
    private let dinnerBtn: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()

        config.baseBackgroundColor = .gray
        config.baseForegroundColor = .yellow
        config.cornerStyle = .capsule
        config.image = UIImage(systemName: "moon.stars")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 20, weight: .medium))
        
        button.configuration = config
        button.layer.shadowRadius = 10
        button.layer.shadowOpacity = 0.3
        button.alpha = 0.0
        return button
    }()
    
    @objc private func morningBtnTapped() {
        print("아침 버튼 눌림")
        if let date = fsCalendar.selectedDate {
//            performSegue(withIdentifier: "AddCalories", sender: (date, "아침"))
            if let addCalorieVC = storyboard?.instantiateViewController(withIdentifier: "AddCalorieViewController") as? AddCalorieViewController {
                addCalorieVC.selectedDate = date
                addCalorieVC.title = "아침"
                
                navigationController?.pushViewController(addCalorieVC, animated: true)
            }
        } else { // 날짜를 선택하지 않은 경우 알림창 띄우기
            let alertController = UIAlertController(title: "알림", message: "날짜를 선택해주세요!", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "확인", style: .default))
            present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc private func lunchBtnTapped() {
        print("점심 버튼 눌림")
        if let date = fsCalendar.selectedDate {
//            performSegue(withIdentifier: "AddCalories", sender: (date, "점심"))
            if let addCalorieVC = storyboard?.instantiateViewController(withIdentifier: "AddCalorieViewController") as? AddCalorieViewController {
                addCalorieVC.selectedDate = date
                addCalorieVC.title = "점심"
                navigationController?.pushViewController(addCalorieVC, animated: true)
            }
        } else {
            let alertController = UIAlertController(title: "알림", message: "날짜를 선택해주세요!", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "확인", style: .default))
            present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc private func dinnerBtnTapped() {
        print("저녁 버튼 눌림")
        if let date = fsCalendar.selectedDate {
//            performSegue(withIdentifier: "AddCalories", sender: (date, "저녁"))
            if let addCalorieVC = storyboard?.instantiateViewController(withIdentifier: "AddCalorieViewController") as? AddCalorieViewController {
                addCalorieVC.selectedDate = date
                addCalorieVC.title = "저녁"
                
                navigationController?.pushViewController(addCalorieVC, animated: true)
            }
        } else {
            let alertController = UIAlertController(title: "알림", message: "날짜를 선택해주세요!", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "확인", style: .default))
            present(alertController, animated: true, completion: nil)
        }
    }

    @objc private func tapFloatingBtn() {
        isActive.toggle()
    }

    private var isActive: Bool = false {
        didSet {
            showActionButtons()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        floatingButton.frame = CGRect(x: view.frame.size.width - 60 - 8 - 20, y: view.frame.size.height - 60 - 8 - 40, width: 60, height: 60)
        morningBtn.frame = CGRect(x: view.frame.size.width - 60 - 8 - 20, y: view.frame.size.height - 60 - 240 - 8 - 40, width: 60, height: 60)
        lunchBtn.frame = CGRect(x: view.frame.size.width - 60 - 8 - 20, y: view.frame.size.height - 60 - 160 - 8 - 40, width: 60, height: 60)
        dinnerBtn.frame = CGRect(x: view.frame.size.width - 60 - 8 - 20, y: view.frame.size.height - 60 - 80 - 8 - 40, width: 60, height: 60)
    }

    private func setUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(floatingButton) // add 버튼
        view.addSubview(morningBtn) // 아침에 섭취한 칼로리 추가 버튼
        view.addSubview(lunchBtn) // 점심에 섭취한 칼로리 추가 버튼
        view.addSubview(dinnerBtn) // 저녁에 섭취한 칼로리 추가 버튼
    }


    private func showActionButtons() {
        popButtons()
        rotateFloatingButton()
    }

    private func popButtons() {
        if isActive {
            morningBtn.layer.transform = CATransform3DMakeScale(0.4, 0.4, 1)
            UIView.animate(withDuration: 0.3, delay: 0.2, usingSpringWithDamping: 0.55, initialSpringVelocity: 0.3, options: [.curveEaseInOut], animations: { [weak self] in
                
                guard let self = self else { return }
                self.morningBtn.layer.transform = CATransform3DIdentity
                self.morningBtn.alpha = 1.0
                
                self.lunchBtn.layer.transform = CATransform3DMakeScale(0.4, 0.4, 1)
                self.lunchBtn.layer.transform = CATransform3DIdentity
                self.lunchBtn.alpha = 1.0
                
                self.dinnerBtn.layer.transform = CATransform3DMakeScale(0.4, 0.4, 1)
                self.dinnerBtn.layer.transform = CATransform3DIdentity
                self.dinnerBtn.alpha = 1.0
            })
        } else {
            UIView.animate(withDuration: 0.15, delay: 0.2, options: []) { [weak self] in
                guard let self = self else { return }
                self.morningBtn.layer.transform = CATransform3DMakeScale(0.4, 0.4, 0.1)
                self.morningBtn.alpha = 0.0
                self.lunchBtn.layer.transform = CATransform3DMakeScale(0.4, 0.4, 0.1)
                self.lunchBtn.alpha = 0.0
                self.dinnerBtn.layer.transform = CATransform3DMakeScale(0.4, 0.4, 0.1)
                self.dinnerBtn.alpha = 0.0
            }
        }
    }

    private func rotateFloatingButton() {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        let fromValue = isActive ? 0 : CGFloat.pi / 4
        let toValue = isActive ? CGFloat.pi / 4 : 0
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.duration = 0.3
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        floatingButton.layer.add(animation, forKey: nil)
    }
    
}

// 콜백 처리 메서드
extension CaloriesViewController {
    func handleDataFromAddCalorieVC(_ data: (String, String)) {
        let (_, _) = data
    }
}

//extension CaloriesViewController {
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "AddCalories" {
//            if let navigationController = segue.destination as? UINavigationController,
//               let destinationVC = segue.destination as? AddCalorieViewController {
//            }
//        }
//    }
//}

extension CaloriesViewController {
    // 테이블 셀에 해당 날짜에 추가한 내용들 보이기
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CaloriesCell")!
        let data = data[indexPath.row]
        cell.textLabel?.text = data.foodName
        cell.detailTextLabel?.text = data.calorie
        
        return cell
    }
}
