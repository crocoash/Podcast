//
//  MyToast.swift
//  MovieApp
//
//  Created by Tsvetkov Anton on 31.07.2021.
//

import UIKit

extension UIViewController {
    
    func addToast(
        title: String,
        animateWithDuration: TimeInterval = 0.2,
        removeWithTimeInterval: TimeInterval = 3,
        _ location: LocationOfPost
    ) {
        view.addToast(title: title, animateWithDuration: animateWithDuration, removeWithTimeInterval: removeWithTimeInterval, location)
    }
}


extension UIView {
    func addToast(
        title: String,
        animateWithDuration: TimeInterval = 0.2,
        removeWithTimeInterval: TimeInterval = 3,
        _ location: LocationOfPost
    ) {
        MyToast.create(title: title, location, animateWithDuration: animateWithDuration, timerToRemove: removeWithTimeInterval, for: self)
    }
}


class MyToast: UITextView {
    
    //MARK: - Settings
    private var textOfColor: UIColor = .white
    private var cornerRadius: CGFloat = 20
    private var backgroundColorOfLayer: CGColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    
    //MARK: - Inits
     private init(title: String, location: LocationOfPost,for bounds: CGRect) {
        super.init(frame: location.createCGRect(for: bounds), textContainer: nil)
        text = title
        textAlignment = .center
        textColor = textOfColor
        layer.cornerRadius = cornerRadius
        layer.backgroundColor = backgroundColorOfLayer
        self.isUserInteractionEnabled = true
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //create MyToast Method
    static func create (title: String,
                        _ location: LocationOfPost,
                                                animateWithDuration: TimeInterval = 0.3,
                        timerToRemove: TimeInterval = 3,
                        for view: UIView)
    {
      
        let toast = MyToast(title: title, location: location, for: view.bounds)
        
        UIView.animate(withDuration: animateWithDuration) {
            view.addSubview(toast)
        }
        
        Timer.scheduledTimer(withTimeInterval: timerToRemove, repeats: false) { _ in
            toast.removeFromSuperview()
        }
    }
}


enum LocationOfPost {
    
    case top
    case center
    case bottom
    case bottomWithTabBar
    case bottomWithPlayer
    case bottomWithPlayerAndTabBar
    
    private var cgFloatValue: CGFloat {
        
        let heightOfTabBar: CGFloat = 50
        let heightOfPlayer: CGFloat = 50
        let padding: CGFloat = 130
        
        switch self {
        case .top: return 4
        case .center : return 2
        case .bottom : return padding
        case .bottomWithTabBar : return padding + heightOfTabBar
        case .bottomWithPlayer : return padding + heightOfPlayer
        case .bottomWithPlayerAndTabBar : return padding + heightOfPlayer + heightOfTabBar
        }
    }
    
    func createCGRect(for bounds: CGRect) -> CGRect {
        let safeAreaBottom = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
        
        var y: CGFloat = 0
        switch self {
        case .top:              y = safeAreaBottom + self.cgFloatValue
        case .center:           y = bounds.height / self.cgFloatValue
        case .bottom:           y = safeAreaBottom + bounds.height - self.cgFloatValue
        case .bottomWithPlayer: y = safeAreaBottom + bounds.height - self.cgFloatValue
        case .bottomWithTabBar : y  = safeAreaBottom + bounds.height - self.cgFloatValue
        case .bottomWithPlayerAndTabBar : y  = safeAreaBottom + bounds.height - self.cgFloatValue
        }
        return CGRect(x: 50, y: y, width: bounds.size.width - 100, height: 50)
    }
}
