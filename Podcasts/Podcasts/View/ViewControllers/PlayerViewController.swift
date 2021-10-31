//
//  NewPlayerViewController.swift
//  test
//
//  Created by mac on 30.10.2021.
//

import UIKit

class PlayerViewController: UIViewController {

    @IBOutlet weak var heightSmallPlayer: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    var isPlayerBig = false {
        didSet {
            setupUI()
        }
    }
    
    @IBOutlet private weak var bigPlayerView: UIView!
    @IBOutlet private weak var smallPlayerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    private func setupUI() {
        bigPlayerView.isHidden = !isPlayerBig
        smallPlayerView.isHidden = isPlayerBig
    }


}
