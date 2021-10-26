//
//  RegistrationView.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 26.10.2021.
//

import UIKit
import FirebaseAuth

protocol RegistrationViewDelegate {
    
}

class RegistrationView: UIView {
    
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var segmentalControl: UISegmentedControl!
    
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    
    @IBOutlet private weak var signButton: UIButton!
    
    
    weak var delegate: RegistrationViewDelegate?
    
    private var email: String = ""
    private var password: String = ""
    private var selectedSegmentIndex = 0
    
    private let colorFalls = #colorLiteral(red: 0.5807225108, green: 0.066734083, blue: 0, alpha: 1)
    private let colorOk = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    
    //PlaceHolder
    private let placeHolderEmailMessage = ""
    private let placeHolderPasswordMessage = ""
    
    
    
    @IBAction func signTouchUpUpInside(_ sender: UIButton) {
        
    }
    
}

//MARK: - objc Methods
extension RegistrationView {
    
}

//MARK: - Private methods
extension RegistrationView {
    private func setUI() {
        [emailTextField,passwordTextField].forEach { $0.delegate = self }
    }
    
    private func buttonSender(sender: UIButton) {
        endEditing(true)
        
        email.isEmpty ? emailTextField.attributedPlaceholder = nSAttributedString(message: placeHolderEmailMessage, color: colorFalls) : nil
        password.isEmpty ? passwordTextField.attributedPlaceholder = nSAttributedString(message: placeHolderPasswordMessage, color: colorFalls) : nil
        
        if email.isEmpty {
            emailTextField.becomeFirstResponder()
        } else if password.isEmpty {
            passwordTextField.becomeFirstResponder()
        } else {
            
            //signUpWithEmail
            if segmentalControl.selectedSegmentIndex == 0 {
                signInWithEmail(email: email, password: password) { [weak self] (result, err) in
                    self?.ifErrorSingInOrUp(err: err, result: result)
                }
                //signInWithEmail
            } else if segmentalControl.selectedSegmentIndex == 1 {
                signUpWithEmail(email: email, password: password) { [weak self] (result, err) in
                    self?.ifErrorSingInOrUp(err: err, result: result)
                }
            }
        }
    }
    
    private func ifErrorSingInOrUp(err: String, result: Bool) {
        
        if !result {
            //activate email TextField if err contains "Email"
            MyAlert.create(title: err.debugDescription, withTimeIntervalToDismiss: 3)
            let timeInterval: TimeInterval = 1
            Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] _ in
                if err.contains("email") {
                    self?.emailTextField.becomeFirstResponder()
                    //activate email TextField if err contains "passw"
                } else if err.contains("password") {
                    self?.passwordTextField.becomeFirstResponder()
                }
            }
        } else {
            delegat?.setAuthorization(value: result)
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                MyAlert.create(title: "Success", withTimeIntervalToDismiss: 1.2)
            }
        }
    }
    
    private func setupNativeClearButton() {
        guard let clearButton = emailTextField.value(forKey: "_clearButton") as? UIButton else { return }
        let templateImage = clearButton.imageView?.image?.withRenderingMode(.automatic)
        clearButton.adjustsImageSizeForAccessibilityContentSizeCategory = true
        clearButton.adjustsImageWhenHighlighted = true
        clearButton.adjustsImageWhenDisabled = true
        clearButton.setImage(templateImage, for: .normal)
        clearButton.setImage(templateImage, for: .highlighted)
        clearButton.imageView?.contentMode = .scaleAspectFill
        
        let extractedExpr: CGFloat = -30
        clearButton.contentEdgeInsets = .init(top: extractedExpr, left: extractedExpr, bottom: extractedExpr, right: extractedExpr)
    }
    
    private func nSAttributedString(message: String, color: UIColor) -> NSAttributedString {
        NSAttributedString(string: message, attributes: [NSAttributedString.Key.foregroundColor: color])
    }
}

extension RegistrationView: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        setupNativeClearButton()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            textField == emailTextField ? email = text : nil
            textField == passwordTextField ? password = text : nil
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        buttonSender(sender: myButton)
        return false
    }
    
}



// MARK: - AuthMethods
extension RegistrationView {
    private func signInWithEmail (email: String, password: String, completion: @escaping (Bool, String) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, err) in
            if err != nil {
                completion(false, (err!.localizedDescription))
                return
            }
            
            completion(true, (result?.user.email)!)
        }
    }
    
    private func signUpWithEmail (email: String, password: String, completion: @escaping (Bool, String) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
            
            if err != nil {
                completion (false, (err!.localizedDescription))
                return
            }
            
            completion(true, (result?.user.email)!)
        }
    }
}
