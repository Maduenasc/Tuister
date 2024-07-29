//
//  Utilidades.swift
//  Proyecto
//
//  Created by Roberto Puentes Marchal on 14/05/2020.
//  Copyright © 2020 Roberto Puentes Marchal. All rights reserved.
//

import Foundation
import UIKit

class Utilidades {
    
    static func isPasswordValid(_ password : String) -> Bool {
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
}


