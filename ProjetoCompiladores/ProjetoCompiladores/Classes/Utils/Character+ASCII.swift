//
//  Character+ASCII.swift
//  ProjetoCompiladores
//
//  Created by Humberto Vieira on 30/03/18.
//  Copyright © 2018 GHP Enterprises. All rights reserved.
//

import Foundation

extension Character {
    var asciiValue: UInt32? {
        return String(self).unicodeScalars.filter{$0.isASCII}.first?.value
    }
    
    func isDigit() -> Bool {
        return CharacterSet.decimalDigits.contains(self.unicodeScalars.first!)
    }
    
    func toInt() -> Int? {
        return Int(String(self))
    }
    
    func isLetter() -> Bool {
        return CharacterSet.letters.contains(self.unicodeScalars.first!)
    }
}
