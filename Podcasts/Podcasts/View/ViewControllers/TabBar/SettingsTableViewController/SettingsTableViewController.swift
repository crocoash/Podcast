//
//  SettingsViewController.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 02.11.2021.
//

import UIKit

protocol SettingsTableViewControllerDelegate: AnyObject {
    func settingsTableViewControllerDidApear(_ settingsTableViewController: SettingsTableViewController)
    func settingsTableViewControllerDidDisapear(_ settingsTableViewController: SettingsTableViewController)
}

class SettingsTableViewController: UITableViewController {
    
    private var userViewModel: UserViewModel!
    private var user: User { userViewModel.userDocument.user }
    
    weak var delegate: SettingsTableViewControllerDelegate?
    
    func setUser(_ userViewModel: UserViewModel) {
        self.userViewModel = userViewModel
    }
    
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var darkModeSwitch: UISwitch!
    @IBOutlet private weak var autorizationSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        userNameLabel.text = user.userName
        autorizationSwitch.isOn = user.isAuthorization
        
        
        ApiService.getData(for: URLS.api.rawValue) { [weak self] (result: IpModel?) in
            guard let ipData = result else { return }
            
            self?.locationLabel.text = ipData.country + ipData.city
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.settingsTableViewControllerDidApear(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.settingsTableViewControllerDidDisapear(self)
    }
    
    @IBAction func darkModeValueChanged(_ sender: UISwitch) {
        
    }
    
    @IBAction func avtorizationChangeValue(_ sender: UISwitch) {
        userViewModel.changeAuthorization(value: sender.isOn)
    }
    
    @IBAction func exit(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true)
    }
}
