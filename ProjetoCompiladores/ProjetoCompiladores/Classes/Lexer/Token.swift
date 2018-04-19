//
//  Token.swift
//  ProjetoCompiladores
//
//  Created by Guilherme Paiva on 19/04/2018.
//  Copyright © 2018 GHP Enterprises. All rights reserved.
//

import Foundation

class Token: Hashable {
    final let tag: Int
    
    var hashValue: Int {
        return tag
    }
    
    init(t: Int) {
        self.tag = t
    }
    
    static func == (lhs: Token, rhs: Token) -> Bool {
        return lhs.tag == rhs.tag
    }
    
    func toString() -> String {
        guard let code = UnicodeScalar(tag) else {
            print("Error trying to cast Int to Char")
            return ""
        }
        
        return "\(Character(code))"
    }
}
