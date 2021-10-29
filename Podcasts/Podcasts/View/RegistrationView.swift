//
//  RegistrationView.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 26.10.2021.
//

import UIKit

class RegistrationView: UIView {

    private var email: String = ""
    private var password: String = ""
    private var selectedSegmentIndex = 0
 
    private let colorFalls = #colorLiteral(red: 0.5807225108, green: 0.066734083, blue: 0, alpha: 1)
    private let colorOk = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    
    //PlaceHolder
    private let placeHolderEmailMessage = Localized.pleaseEnterEmail
    private let placeHolderPasswordMessage = Localized.pleaseEnterPassword
    
    
}
