//
//  SettingsViewController.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 02.11.2021.
//

import UIKit

protocol SettingsTableViewControllerDelegate: AnyObject {
    
    func settingsTableViewControllerDidAppear(_ settingsTableViewController: SettingsTableViewController)
    func settingsTableViewControllerDidDisappear(_ settingsTableViewController: SettingsTableViewController)
}

class SettingsTableViewController: UITableViewController {
    
    private var userViewModel: UserViewModel!
    private var user: User { userViewModel.userDocument.user }
    private let firestorageDatabase = FirestorageDatabase()
    weak var delegate: SettingsTableViewControllerDelegate?
    
    func setUser(_ userViewModel: UserViewModel) {
        self.userViewModel = userViewModel
    }
    
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var darkModeSwitch: UISwitch!
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var authorizationSwitch: UISwitch!
    
    
    private var pickerController: UIImagePickerController = {
        $0.allowsEditing = true
        $0.mediaTypes = ["public.image", "public.movie"]
      
        return $0
    }(UIImagePickerController())
    
    private let cameraPickerController: UIImagePickerController = {
        $0.allowsEditing = true
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            $0.sourceType = .camera
        }
        return $0
    }(UIImagePickerController())
    
    //MARK: - View Methods
    override func loadView() {
        super.loadView()
        ApiService.getData(for: URLS.api.rawValue) { [weak self] (result: IpModel?) in
            guard let ipData = result else { return }
            self?.locationLabel.text = ipData.country + " " + ipData.city
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.settingsTableViewControllerDidAppear(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.settingsTableViewControllerDidDisappear(self)
    }
    
    //MARK: - Actions
    @IBAction func darkModeValueChanged(_ sender: UISwitch) {
        darkModeStyle(value: sender.isOn)
    }
    
    @IBAction func avtorizationChangeValue(_ sender: UISwitch) {
        userViewModel.changeAuthorization(value: sender.isOn)
    }
    
    @IBAction func exit(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true)
    }
    
    @IBAction func editAvatarAction(_ sender: UIButton) {
        present(pickerController, animated: true)
    }
    
    @objc func openCamera() {
        present(cameraPickerController, animated: true)
    }
}

extension SettingsTableViewController {
    
    private func getAvatar() {
        firestorageDatabase.getLogo { [weak self] in
            self?.avatarImageView.image = $0
        }
    }
    
    private func setUpUI() {
        //TODO: -
        userNameLabel.text = user.userName
        authorizationSwitch.isOn = user.isAuthorization
        darkModeSwitch.isOn = userViewModel.userDocument.user.userInterfaceStyleIsDark
        getAvatar()
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2.7
        pickerController.delegate = self
        pickerController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(openCamera))
    }
    
    func darkModeStyle(value: Bool) {
        if let window = UIApplication.shared.windows.first {
            window.overrideUserInterfaceStyle = value ? .dark : .light
            userViewModel.changeUserInterfaceStyle(value: value)
        }
    }
}

extension SettingsTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        avatarImageView.image = image
        firestorageDatabase.saveLogo(logo: image)
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            print("UIImagePickerController: dismissed")
        }
    }
}
