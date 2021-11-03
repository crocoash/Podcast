//
//  SettingsViewController.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 02.11.2021.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    private var user: User!
    
    func setUser(_ user: User) {
        self.user = user
    }
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var darkModeSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        userNameLabel.text = user.userName
        
        ApiService.shared.getData(for: URLS.api.rawValue) { [weak self] (result: IpModel?) in
            guard let ipData = result else { return }
            
            self?.locationLabel.text = ipData.country + ipData.city
        }
    }
    @IBAction func darkModeValueChanged(_ sender: UISwitch) {
        
    }
    
    @IBAction func exit(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true)
    }
}
