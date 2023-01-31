//
//  MyToast.swift
//  MovieApp
//
//  Created by Tsvetkov Anton on 31.07.2021.
//

import UIKit

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
                        for myView: UIView? = nil)
    {
        
        let view: UIView
        
        if let myView = myView {
            view = myView
        } else {
            guard let myView = UIApplication.shared.windows.first?.rootViewController?.view else { return }
            view = myView
        }
        let toast = MyToast(title: title, location: location, for: view.bounds)
        
        UIView.animate(withDuration: animateWithDuration) {
            view.addSubview(toast)
        }
        
        Timer.scheduledTimer(withTimeInterval: timerToRemove, repeats: false) { _ in
            toast.removeFromSuperview()
        }
    }
}


enum LocationOfPost: CGFloat {
    case top = 4
    case center = 2
    case bottom = 180
    case bottomWithPlayer = 220
    
    func createCGRect(for bounds: CGRect) -> CGRect {
        var y: CGFloat = 0
        switch self {
        case .top:              y = self.rawValue + (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0)
        case .center:           y = bounds.height / self.rawValue
        case .bottom:           y = (UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0) + bounds.height - self.rawValue
        case .bottomWithPlayer: y = (UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0) + bounds.height - self.rawValue
        }
        return CGRect(x: 50, y: y, width: bounds.size.width - 100, height: 50)
    }
}
