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

class SettingsTableViewController: UITableViewController, IPerRequest {
    
    
    typealias Arguments = Void
    
    private var userViewModel: UserViewModel
    private let firestorageDatabase: FirestorageDatabase
    private let apiService: ApiService

    private var user: User { userViewModel.userDocument.user }
    weak var delegate: SettingsTableViewControllerDelegate?
    
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var darkModeSwitch: UISwitch!
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var authorizationSwitch: UISwitch!
    @IBOutlet private weak var wifiSegmentedControl: UISegmentedControl!
    
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
    
    //MARK: init
    required init(container: IContainer, args: Void) {
        
        self.userViewModel = container.resolve()
        self.firestorageDatabase = container.resolve()
        self.apiService = container.resolve()
        
        super.init(nibName: Self.identifier, bundle: nil)
    }
    
    required init(coder: NSCoder) {
        fatalError()
    }
    
    //MARK: - View Methods
    override func loadView() {
        super.loadView()
        apiService.getData(for: URLS.api.rawValue) { [weak self] (result: Result<IpModel>) in
            switch result {
                
            case .failure(let error):
                
                error.showAlert(vc: self)
                
            case .success(result: let result) :
                self?.locationLabel.text = result.country + " " + result.city
            }
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
    
    @IBAction func handleSegmentControlValueChanged(_ sender: Any) {
        
    }
}

//MARK: - private Methods
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
        wifiSegmentedControl.selectedSegmentIndex = selectedSegment
    }
    
    private func darkModeStyle(value: Bool) {
        if let window = UIApplication.shared.windows.first {
            window.overrideUserInterfaceStyle = value ? .dark : .light
            userViewModel.changeUserInterfaceStyle(value: value)
        }
    }
    
    private var selectedSegment: Int {
        if MobileNetwork.checkNetworkStatus(network: .wiFi) {
            return 0
        } else if MobileNetwork.checkNetworkStatus(network: .alwaysAsk) {
            return 1
        } else if MobileNetwork.checkNetworkStatus(network: .alwaysAllow) {
            return 2
        } else {
            MobileNetwork.configureNetworkPermission(network: .wiFi)
            return 0
        }
    }
}

//MARK: - UIImagePickerControllerDelegate
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
