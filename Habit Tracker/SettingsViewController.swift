//
//  SettingsViewController.swift
//  Habit Tracker
//
//  Created by Nicholas Ellis on 2/15/17.
//  Copyright © 2017 Nicholas Ellis. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class SettingsViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {
    
    //  MARK: - Outlets
    
    @IBOutlet weak var morningFirstTextField: UITextField!
    @IBOutlet weak var afternoonFirstTextField: UITextField!
    @IBOutlet weak var eveningFirstTextField: UITextField!
    @IBOutlet weak var anyTextField: UITextField!
    @IBOutlet weak var enableNotificationsButton: UIButton!
    
    static var morning = TimeSettingsController.shared.morning
    static var afternoon = TimeSettingsController.shared.afternoon
    static var evening = TimeSettingsController.shared.evening
    static var any = TimeSettingsController.shared.anytime
    
    let loginButton = FBSDKLoginButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.delegate = self
        view.addSubview(loginButton)
        loginButtonConstraints()
        
        let navigationBarAppearance = UINavigationBar.appearance()
        guard let fontName = UIFont(name: "Avenir", size: 17) else { return }
        navigationBarAppearance.titleTextAttributes = [NSFontAttributeName: fontName]
        self.navigationController?.navigationBar.setBottomBorderColor(color: Keys.shared.iconColor5, height: 1)
        
        let timePicker = UIDatePicker()
        timePicker.datePickerMode = .time
        
        morningFirstTextField.delegate = self
        morningFirstTextField.inputView = timePicker
        
        afternoonFirstTextField.delegate = self
        afternoonFirstTextField.inputView = timePicker
        
        eveningFirstTextField.delegate = self
        eveningFirstTextField.inputView = timePicker
        
        anyTextField.delegate = self
        anyTextField.inputView = timePicker
                
        let tap = UITapGestureRecognizer(target: self, action: #selector(SettingsViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func loginButtonConstraints() {
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        loginButton.widthAnchor.constraint(equalToConstant: 220).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
    }
    
    // MARK: - Keyboard
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let timePicker = UIDatePicker()
        timePicker.datePickerMode = .time
        textField.inputView = timePicker
        timePicker.addTarget(self, action: #selector(SettingsViewController.dateValueChanged), for: .valueChanged)
    }
    
    //  MARK: - Date
    
    func dateValueChanged(sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        guard let timeinterval = DateHelper.thisMorningAtMidnight else {
            return
        }
        
        if sender == morningFirstTextField.inputView {
            morningFirstTextField.text = formatter.string(from: sender.date)
            let morning = sender.date.timeIntervalSince(timeinterval)
            TimeSettingsController.shared.morning = morning
        } else if sender == afternoonFirstTextField.inputView {
            afternoonFirstTextField.text = formatter.string(from: sender.date)
            let afternoon = sender.date.timeIntervalSince(timeinterval)
            TimeSettingsController.shared.afternoon = afternoon
        } else if sender == eveningFirstTextField.inputView {
            eveningFirstTextField.text = formatter.string(from: sender.date)
            let evening = sender.date.timeIntervalSince(timeinterval)
            TimeSettingsController.shared.evening = evening
        } else if sender == anyTextField.inputView {
            anyTextField.text = formatter.string(from: sender.date)
            let anyTime = sender.date.timeIntervalSince(timeinterval)
            TimeSettingsController.shared.anytime = anyTime
        }
    }
    
    // ACTIONS:
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)

    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func enableNotificationsButtonTapped(_ sender: Any) {
        let alertController = UIAlertController (title: "Turn on notifications", message: "Go to Settings?", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Logged out of Facebook.")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
            return
        }
    }
}
