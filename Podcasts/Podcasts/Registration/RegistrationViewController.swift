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
    
    lazy var tabBarVC: TabBarViewController = {
        let vc = storyboard?.instantiateViewController(withIdentifier: TabBarViewController.identifier) as! TabBarViewController
        vc.modalPresentationStyle = .custom
        vc.setUserViewModel(userViewModel)
        vc.transitioningDelegate = self
        
        return vc
    }()
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        createGestureRecognizers()
        configureView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if userViewModel.userDocument.user.isAuthorization {
            present(tabBarVC, animated: true)
        }
    }
    
    //MARK: - Varibels
    private var firstSegmentedControl: Bool {
        segmentedControl.selectedSegmentIndex == 0
    }
    
    private var userViewModel = UserViewModel()
    private let alert = Alert()
    
    //MARK: - Settings
    lazy private var email: String = userViewModel.userDocument.user.userName
    private var password: String = ""
    
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
        buttonSender(sender: sender)
    }
    
    //SecureButtom
    @IBAction func secureTouchUpIncide(_ sender: UIButton) {
        isSecureTextEntry()
    }
    
    //UISegmentedControl
    @IBAction func segmentedControlValueChange(_ sender: UISegmentedControl) {
        selectedValue()
    }
    
    //UISwipeGestureRecognizer
    @objc private func swipeDirection(sender: UISwipeGestureRecognizer) {
        
        switch sender.direction {
            
        case .up :
            buttonSender(sender: signButton)
            
        case .right:
            segmentedControl.selectedSegmentIndex -= 1
            selectedValue()
            
        case .left:
            segmentedControl.selectedSegmentIndex += 1
            selectedValue()
            
        case .down:
            view.endEditing(true)
            
        default: break
        }
    }
    
    //tap for dissmiss keyboard
    @objc func handlerTap(sender: UITapGestureRecognizer) {
        view.endEditing(true)
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
        emailTextField.text = email
    
        passwordTextField.attributedPlaceholder = nSAttributedString(message: placeHolderPasswordMessage, color: colorOk)
        
        alert.delegate = self
    }
    
    private func isSecureTextEntry() {
        secureShowButton.setImage(!passwordTextField.isSecureTextEntry ? imageLockSecurePassword : imageUnLockSecurePassword, for: .normal)
        passwordTextField.isSecureTextEntry.toggle()
    }
    
    private func selectedValue() {
        signButton.setTitle( firstSegmentedControl ? signIn : signUp, for: .normal)
    }
    
    private func createGestureRecognizers() {
        view.addMyGestureRecognizer(self, type: .swipe(), selector: #selector(swipeDirection))
        view.addMyGestureRecognizer(self, type: .tap(), selector:  #selector(handlerTap))
        privacyPolicyLabel.addMyGestureRecognizer(self, type: .tap(), selector: #selector(showPrivacyInfo))
        forgotPasswordLabel.addMyGestureRecognizer(self, type: .tap(), selector: #selector(forgotPasswordTap))
    }
    
    private func nSAttributedString(message: String, color: UIColor) -> NSAttributedString {
        NSAttributedString(string: message, attributes: [NSAttributedString.Key.foregroundColor: color])
    }
    
    private func buttonSender(sender: UIButton) {
        
        if email.isEmpty {
            
            emailTextField.attributedPlaceholder = nSAttributedString(message: placeHolderEmailMessage, color: colorFails)
            
            emailTextField.becomeFirstResponder()
            
        } else if password.isEmpty {
    
            passwordTextField.attributedPlaceholder = nSAttributedString(message: placeHolderPasswordMessage, color: colorFails)
            passwordTextField.becomeFirstResponder()
            
        } else {
            
            //signInWithEmail
            if firstSegmentedControl {
                signInWithEmail(email: email, password: password) { [weak self] (result, err) in
                    self?.signIn(err: err, result: result)
                }
                
                //signUpWithEmail
            } else  {
                signUpWithEmail(email: email, password: password) { [weak self] (result, err) in
                    self?.signIn(err: err, result: result)
                }
            }
        }
    }
    
    private func signIn(err: String, result: Bool) {
        
        let timeInterval: TimeInterval = 2
        
        if !result {
            
            alert.create(title: err.debugDescription, withTimeIntervalToDismiss: timeInterval)
            
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
            title: "Password will be send to your email",
            message: nil,
            actions: { text in
                [
                    UIAlertAction(title: "Send Password", style: .default, handler: { [weak self] _ in
                        self?.forgotPassword(with: text)
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
//            setupNativeClearButton()
        } else {
            secureShowButton.isHidden = false
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text, !text.isEmpty else { return  }
        if textField == emailTextField {
            email = text
        }
        if textField == passwordTextField { password = text }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        buttonSender(sender: signButton)
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if textField == passwordTextField {
            secureShowButton.isHidden = true
        }
    }
}

// MARK: - AuthMethods
extension RegistrationViewController {
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
    
    private func forgotPassword(with email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            if let error = error {
                self?.alert.create(title: error.localizedDescription, withTimeIntervalToDismiss: 2)
            } else {
                self?.alert.create(title: "email will be send to \(email)", withTimeIntervalToDismiss: 2)
                self?.email = email
                self?.forgotPasswordAlert(with: email)
            }
        }
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
