//
//  Bool+Extension.swift
//  WebServiceDemo
//
//  Created by Mohammed Sobhei Abdualal on 10/27/18.
//  Copyright © 2018 Mohammed Sobhei Abdualal. All rights reserved.
//

import Foundation


extension Bool {
    
    var toInt:Int{
        return NSNumber.init(booleanLiteral: self).intValue
    }
}
