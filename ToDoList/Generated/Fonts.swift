//
//  Fonts.swift
//  ToDoList
//
//  Created by Богдан Топорин on 29.01.2025.
//

import UIKit

extension UIFont {
    
    enum Regular {
        static var small = UIFont.systemFont(ofSize: 11, weight: .regular)
        static var medium = UIFont.systemFont(ofSize: 12, weight: .regular)
    }

    enum Medium {
        static var medium = UIFont.systemFont(ofSize: 16, weight: .medium)
    }
    
    enum Bold {
        static var large = UIFont.systemFont(ofSize: 34, weight: .bold)
    }
}
