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
    
    func settingsTableViewControllerDarkModeDidSelect(_ settingsTableViewController: SettingsTableViewController)
}

class SettingsTableViewController: UITableViewController {
    
    private var userViewModel: UserViewModel!
    private var user: User { userViewModel.userDocument.user }
    
    weak var delegate: SettingsTableViewControllerDelegate?
    
    func setUser(_ userViewModel: UserViewModel) {
        self.userViewModel = userViewModel
    }
    
    private var isDarkTheme: Bool {
        self.traitCollection.userInterfaceStyle == .dark
    }
    
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var darkModeSwitch: UISwitch!
    
    @IBOutlet private weak var authorizationSwitch: UISwitch!
    
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
    
    @IBAction func darkModeValueChanged(_ sender: UISwitch) {
        delegate?.settingsTableViewControllerDarkModeDidSelect(self)
        darkModeStyle(value: !isDarkTheme)
    }
    
    @IBAction func avtorizationChangeValue(_ sender: UISwitch) {
        userViewModel.changeAuthorization(value: sender.isOn)
    }
    
    @IBAction func exit(_ sender: UITapGestureRecognizer) {
        dismiss(animated: isDarkTheme)
    }
}

extension SettingsTableViewController {
    
    private func setUpUI() {
        userNameLabel.text = user.userName
        authorizationSwitch.isOn = user.isAuthorization
        darkModeSwitch.isOn = isDarkTheme
    }
    
    func switchDarkMode() {
        darkModeSwitch.isOn.toggle()
        darkModeStyle(value: isDarkTheme)
    }
    
    func darkModeStyle(value: Bool) {
        view.backgroundColor = value ? .black : .white
    }
}
