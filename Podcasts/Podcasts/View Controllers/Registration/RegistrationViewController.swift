//
//  RegistrationView.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 26.10.2021.
//

import UIKit
import FirebaseAuth

class RegistrationViewController: UIViewController {
    
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var signButton: UIButton!
    @IBOutlet private weak var forgotPasswordLabel: UILabel!
    @IBOutlet private weak var secureShowButton: UIButton!
    @IBOutlet private weak var privacyPolicyLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var backGroundView: UIView!
    
    private(set) var userViewModel: UserViewModel!
    
    lazy private var tabBarVC: TabBarViewController = {
        let vc = TabBarViewController.loadFromStoryboard
        vc.modalPresentationStyle = .custom
        vc.setUserViewModel(userViewModel)
        vc.transitioningDelegate = self
        return vc
    }()
    
    func configure(userViewModel: UserViewModel) {
        self.userViewModel = userViewModel
    }
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureGestures()
        configureView()
    }
    
    //MARK: - Varibels
    private var firstSegmentedControl: Bool {
        segmentedControl.selectedSegmentIndex == 0
    }
    private let authManger = AuthService()
    private let alert = Alert()
    
    //MARK: - Settings
    lazy private var email: String = userViewModel.userDocument.user.userName ?? "crocoash@gmail.com"
    private var password: String = "123456"
    
    private let colorFails = #colorLiteral(red: 0.5807225108, green: 0.066734083, blue: 0, alpha: 1)
    private let colorOk = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
    
    //PlaceHolder
    private let placeHolderEmailMessage = "Enter email"
    private let placeHolderPasswordMessage = "Enter password"
    
    //Buttton
    private var signIn = "Sign In" // Localized.signIn
    private var signUp = "Sign Up" // Localized.signUp
    
    //TextField
    private let imageLockSecurePassword = UIImage(systemName: "lock.fill")
    private let imageUnLockSecurePassword = UIImage(systemName: "lock.open.fill")
    
    
    //MARK: - @IBAction
    @IBAction func signTouchUpInside(_ sender: UIButton) {
        signButtonDidSelect()
    }
    
    //SecureButtom
    @IBAction func secureTouchUpIncide(_ sender: UIButton) {
        isSecureTextEntry()
    }
    
    //UISegmentedControl
    @IBAction func segmentedControlValueChange(_ sender: UISegmentedControl) {
        setTitleForSignButton()
    }
    
    //UISwipeGestureRecognizer
    @objc private func swipeDirection(sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .up :
            signButtonDidSelect()
        case .right:
            segmentedControl.selectedSegmentIndex = 0
            setTitleForSignButton()
        case .left:
            segmentedControl.selectedSegmentIndex = 1
            setTitleForSignButton()
        case .down:
            view.endEditing(true)
        default: break
        }
    }
    
    //Privacy Infor
    @objc func showPrivacyInfo(_ sender: UILabel) {
        let vc = UIViewController()
        let text = UITextView()
        text.frame = vc.view.frame
        text.text = "Privacy Policy Info"
        text.backgroundColor = .gray
        vc.view.addSubview(text)
        present(vc, animated: true)
    }
    
    //Forgot Passord
    @objc func forgotPasswordTap(_ sender: UIButton) {
        forgotPasswordAlert(with: email)
    }
}

//MARK: - Private methods
extension RegistrationViewController {
    
    private func configureView() {
        secureShowButton.setImage(imageLockSecurePassword, for: .normal)
        
        emailTextField.attributedPlaceholder = nSAttributedString(message: placeHolderEmailMessage, color: colorOk)
        
        if !email.isEmpty { emailTextField.text = email }
    
        passwordTextField.attributedPlaceholder = nSAttributedString(message: placeHolderPasswordMessage, color: colorOk)
        setTitleForSignButton()
        alert.delegate = self
        
        backGroundView.layer.borderColor = UIColor.white.cgColor
        backGroundView.layer.cornerRadius = 10
        backGroundView.layer.borderWidth = 8
    }
    
    private func isSecureTextEntry() {
        secureShowButton.setImage(!passwordTextField.isSecureTextEntry ? imageLockSecurePassword : imageUnLockSecurePassword, for: .normal)
        passwordTextField.isSecureTextEntry.toggle()
    }
    
    private func setTitleForSignButton() {
        signButton.setTitle( firstSegmentedControl ? signIn : signUp, for: .normal)
    }
    
    private func configureGestures() {
                           addMyGestureRecognizer(self,  type: .swipe(), #selector(swipeDirection))
                           addMyGestureRecognizer(view,  type: .tap(),   #selector(view.endEditing(_:)))
        privacyPolicyLabel.addMyGestureRecognizer(self,  type: .tap(),   #selector(showPrivacyInfo))
        forgotPasswordLabel.addMyGestureRecognizer(self, type: .tap(),   #selector(forgotPasswordTap))
    }
    
    private func nSAttributedString(message: String, color: UIColor) -> NSAttributedString {
        NSAttributedString(string: message, attributes: [NSAttributedString.Key.foregroundColor: color])
    }
    
    private func signButtonDidSelect() {
        
        if email.isEmpty {
            emailTextField.attributedPlaceholder = nSAttributedString(message: placeHolderEmailMessage, color: colorFails)
        }
            
        if password.isEmpty {
            passwordTextField.attributedPlaceholder = nSAttributedString(message: placeHolderPasswordMessage, color: colorFails)
        }
          
        if email.isEmpty {
            emailTextField.becomeFirstResponder()
        } else if password.isEmpty {
            passwordTextField.becomeFirstResponder()
        } else {
            activityIndicator.startAnimating()
            
            //signInWithEmail
            if firstSegmentedControl {
                authManger.signInWithEmail(email: email, password: password) { [weak self] (result, err) in
                    self?.signInOrUp(err: err, result: result)
                }
            //signUpWithEmail
            } else  {
                authManger.signUpWithEmail(email: email, password: password) { [weak self] (result, err) in
                    self?.signInOrUp(err: err, result: result)
                }
            }
        }
    }
    
    private func signInOrUp(err: String, result: Bool) {
        activityIndicator.stopAnimating()

        let timeInterval: TimeInterval = 2
        
        if !result {
            
            alert.create(vc: self, title: err.debugDescription, withTimeIntervalToDismiss: timeInterval)
            
            Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] _ in
                if err.contains("email") {
                    self?.emailTextField.becomeFirstResponder()
                } else if err.contains("password") {
                    self?.passwordTextField.becomeFirstResponder()
                }
            }
        } else {
            userViewModel.changeUserName(newName: email)
            present(tabBarVC, animated: true)
        }
    }
    
    private func forgotPasswordAlert(with text : String) {
        alert.create(
            for: self, title: "Password will be send to your email",
            message: nil,
            actions: { text in
                [
                    UIAlertAction(title: "Send Password", style: .default, handler: { [weak self] _ in
                        guard let self = self else { return }
                        self.authManger.forgotPassword(with: text) { error in
                            
                            if let error = error {
                                self.alert.create(vc: self, title: error.localizedDescription, withTimeIntervalToDismiss: 2)
                            } else {
                                self.alert.create(vc: self, title: "email will be send to \(self.email)", withTimeIntervalToDismiss: 2)
                                self.email = self.emailTextField.text!
                                self.forgotPasswordAlert(with: self.email)
                            }
                        }
                    }),
                    UIAlertAction(title: "Close", style: .destructive, handler: nil),
                ]
            }, configureTextField: { textField in
                if text.isEmpty {
                    textField.placeholder = "Enter your email"
                } else {
                    textField.text = text
                    textField.keyboardType = .emailAddress
                }
            })
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
    }
}

//MARK: - UITextFieldDelegate
extension RegistrationViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == emailTextField {
            setupNativeClearButton()
        } else {
            secureShowButton.isHidden = false
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text, !text.isEmpty else { return }
        
        if textField == emailTextField { email = text }
        if textField == passwordTextField { password = text }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        signButtonDidSelect()
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if textField == passwordTextField {
            secureShowButton.isHidden = true
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        
        if textField == emailTextField { email.removeAll() }
        if textField == passwordTextField { password.removeAll() }
        textField.text?.removeAll()
        
        return true
    }
}

//MARK: - AlertDelegate
extension RegistrationViewController: AlertDelegate {
    func alertEndShow(_ alert: Alert) {
        dismiss(animated: true)
    }
    
    func alertShouldShow(_ alert: Alert, alertController: UIAlertController) {
        present(alertController, animated: true)
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension RegistrationViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentTransition()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissTransition()
    }
}


