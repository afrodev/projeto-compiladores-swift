//
//  Num.swift
//  ProjetoCompiladores
//
//  Created by Guilherme Paiva on 19/04/2018.
//  Copyright © 2018 GHP Enterprises. All rights reserved.
//

import Foundation

class Num: Token {
    final var value: Int
    
    init(v: Int) {
        self.value = v
        super.init(t: Tag.NUM)
    }
    
    override func toString() -> String {
        guard let code = UnicodeScalar(value) else {
            print("Error trying to cast Int to Char")
            return ""
        }
        
        return "\(Character(code))"
    }
}
