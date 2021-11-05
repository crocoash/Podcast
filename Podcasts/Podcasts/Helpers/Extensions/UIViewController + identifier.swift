//
//  UIViewController + identifier.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 30.10.2021.
//

// FIXME: Создали отдельные файлы на каждый экстенше для вью контроллера. Я бы рекомендовал (если не слишком много экстеншен методов), то объединить в один файл и назвать его - UIViewController+Extensions

import UIKit

extension UIViewController {
    static var identifier: String {
        return "\(Self.self)"
    }
}

