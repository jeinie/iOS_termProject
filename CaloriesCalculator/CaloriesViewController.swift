//
//  CaloriesViewController.swift
//  CaloriesCalculator
//
//  Created by 장정윤 on 2023/06/05.
//

import UIKit
import FSCalendar
//import JJFloatingActionButton

class CaloriesViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate {

    @IBOutlet weak var calorieConsumption: UILabel!
    @IBOutlet weak var targetCalorie: UILabel!
    @IBOutlet weak var fsCalendar: FSCalendar!
    @IBOutlet weak var calorieList: UITableView!
    
    private lazy var floatingButton: UIButton = {
        let addBtn = UIButton()
        var config = UIButton.Configuration.filled()
        
        config.baseBackgroundColor = .blue
        config.cornerStyle = .capsule
        config.image = UIImage(systemName: "plus")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 20, weight: .medium))

        addBtn.configuration = config
        addBtn.layer.shadowRadius = 10
        addBtn.layer.shadowOpacity = 0.3
        addBtn.addTarget(self, action: #selector(tapFloatingBtn), for: .touchUpInside)
        return addBtn
    }()

    private let morningBtn: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.filled()

        config.baseBackgroundColor = .white
        config.cornerStyle = .capsule
        config.image = UIImage(systemName: "sun")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 20, weight: .medium))

        button.configuration = config
        button.layer.shadowRadius = 10
        button.layer.shadowOpacity = 0.3
        button.alpha = 0.0
        return button
    }()

    @objc private func tapFloatingBtn() {
        isActive.toggle()
    }

    private var isActive: Bool = false {
        didSet {
            showActionButtons()
        }
    }

    private var animation: UIViewPropertyAnimator?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()

        fsCalendar.dataSource = self
        fsCalendar.delegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        floatingButton.frame = CGRect(x: view.frame.size.width - 60 - 8 - 20, y: view.frame.size.height - 60 - 8 - 40, width: 60, height: 60)
        morningBtn.frame = CGRect(x: view.frame.size.width - 60 - 8 - 20, y: view.frame.size.height - 60 - 80 - 8 - 40, width: 60, height: 60)
    }

    private func setUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(floatingButton)
        view.addSubview(morningBtn)
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
            })
        } else {
            UIView.animate(withDuration: 0.15, delay: 0.2, options: []) { [weak self] in
                guard let self = self else { return }
                self.morningBtn.layer.transform = CATransform3DMakeScale(0.4, 0.4, 0.1)
                self.morningBtn.alpha = 0.0
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

