//
//  AddHabitViewController.swift
//  Habit Tracker
//
//  Created by Ilias Basha on 2/14/17.
//  Copyright © 2017 Nicholas Ellis. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKShareKit

class AddHabitViewController: UIViewController, UITextFieldDelegate {
    
    static var time: TimeInterval?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        habitNameTextField.delegate = self
        
        let swipeRight = UISwipeGestureRecognizer()
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        swipeRight.addTarget(self, action: #selector(respondToSwipeGesture(_:)))
        
        
        let swipeLeft = UISwipeGestureRecognizer()
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        swipeLeft.addTarget(self, action: #selector(respondToSwipeGesture(_:)))
        
        
        iconCollectionView.delegate = self
        iconCollectionView.dataSource = self
        
        iconCollectionView.backgroundColor = .clear
        iconCollectionView.allowsMultipleSelection = false
        
        
        colorsForIconView.delegate = self
        colorsForIconView.select(index: 0)
        self.setupColorMenu()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(AddHabitViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
        
        self.view.backgroundColor = Keys.shared.background
        
    }
    
    // MARK: -Keyboard
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    // MARK: - Choice of notification gesture
    
    func respondToSwipeGesture(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case UISwipeGestureRecognizerDirection.left:
            indexIncreasing()
        case UISwipeGestureRecognizerDirection.right:
            indexDecreasing()
        default:
            return
        }
    }
    
    
    func selectTime(index: Int) {
        switch index {
        case 0:
            timeOfDayLabel.text = "Any"
        case 1:
            timeOfDayLabel.text = "Morning"
        case 2:
            timeOfDayLabel.text = "Afternoon"
        case 3:
            timeOfDayLabel.text = "Evening"
        default:
            return
        }
    }
    
    
    // MARK: - Properties
    
    var index: Int = 0
    
    var icon: String?
    
    let imageIcon = Keys.shared.iconNames
    
    var colorKey: String?
    
    var color: UIColor? {
        didSet {
            self.iconCollectionView.reloadData()
        }
    }
    
    var selectedIcon: String?
    
    
    // MARK: - Outlets
    
    @IBOutlet var habitNameTextField: UITextField!
    @IBOutlet var timeOfDayLabel: UILabel!
    @IBOutlet var iconCollectionView: UICollectionView!
    @IBOutlet var colorsForIconView: ColorMenuView!
    
    
    // MARK: - Actions
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        
        guard let name = habitNameTextField.text,
            let image = icon,
            let time = timeOfDayLabel.text,
            let colorKey = colorKey
            else {
                return }
        
        _ = HabitController.shared.addHabit(name: name, imageName: image, timeOfNotification: time, color: colorKey)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dismissButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func leftToDButtonTapped(_ sender: Any) {
        indexDecreasing()
    }
    
    @IBAction func rightToDButtonTapped(_ sender: Any) {
        indexIncreasing()
    }
}


// MARK: - EXTENSION: ColorMenuDelegate Methods

extension AddHabitViewController: ColorMenuDelegate {
    
    func colorMenuButtonTapped(at index: Int, with color: UIColor) {
        self.color = color
        self.colorsForIconView.select(index: index)
        self.colorKey = colorsForIconView.setColorKey()
    }
    
}


// MARK: - EXTENSION: Helper Methods

extension AddHabitViewController {
    
    func indexDecreasing() {
        if(index > 0 && index <= 4) { index -= 1 }
        selectTime(index: index)
    }
    
    func indexIncreasing() {
        if(index >= 0 && index < 4) { index += 1 }
        selectTime(index: index)
    }
    
    
    func setupColorMenu() {
        self.view.addSubview(self.colorsForIconView)
        let frame = CGRect(x: 0, y: view.frame.height - 60, width: view.frame.width, height: 46)
        UIView.animate(withDuration: 0.75,
                       delay: 0.0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.7,
                       options: [],
                       animations: {
                        
                        self.colorsForIconView.frame = frame
        }, completion: nil)
    }
    
}


// MARK: - EXTENSION: Collection View Data Source

extension AddHabitViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageIcon.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "iconCell", for: indexPath) as? IconsCollectionViewCell
        cell?.backgroundColor = UIColor.clear
        cell?.iconImage.tintColor = .lightGray
        let icon = imageIcon[indexPath.row]
        if let color = self.color {
            cell?.iconImage.tintColor = color
        }
        if icon == selectedIcon {
            cell?.layer.cornerRadius = 5
            let selectColor: UIColor = UIColor(colorLiteralRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.05)
            cell?.layer.backgroundColor = selectColor.cgColor
        } else {
            cell?.layer.backgroundColor = UIColor.clear.cgColor
        }
        
        cell?.iconImage.image = UIImage(named:icon)
        return cell ?? UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.cornerRadius = 5
        let icon = imageIcon[indexPath.row]
        let selectColor: UIColor = UIColor(colorLiteralRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.05)
        cell?.layer.backgroundColor = selectColor.cgColor
        self.icon = icon
        self.selectedIcon = icon
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.backgroundColor = UIColor.clear.cgColor
        collectionView.reloadData()
    }
    
}








