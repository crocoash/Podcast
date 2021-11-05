//
//  SettingsViewController.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 02.11.2021.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    private var userViewModel: UserViewModel!
    private var user: User { userViewModel.userDocument.user }
    
    func setUser(_ userViewModel: UserViewModel) {
        self.userViewModel = userViewModel
    }
    
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var darkModeSwitch: UISwitch!
    @IBOutlet private weak var autorizationSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // FIXME: В приватный метод
    
        userNameLabel.text = user.userName
        autorizationSwitch.isOn = user.isAuthorization
        
        
        ApiService.getData(for: URLS.api.rawValue) { [weak self] (result: IpModel?) in
            guard let ipData = result else { return }
            
            self?.locationLabel.text = ipData.country + ipData.city
        }
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
