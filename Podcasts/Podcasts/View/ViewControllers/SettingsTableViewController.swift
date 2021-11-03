//
//  SettingsViewController.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 02.11.2021.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let url = URL(string: "http://ip-api.com/json/") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            guard let data = data, error == nil else { return }
            
            do {
                let data = try JSONSerialization.jsonObject(with: data, options: [])
                print("print data \(data)")
            } catch let error {
                print("print error \(error.localizedDescription)")
            }
        }.resume()
    }
    
    @IBAction func exit(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true)
    }
}
