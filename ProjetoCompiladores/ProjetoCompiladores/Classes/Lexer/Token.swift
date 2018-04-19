//
//  Token.swift
//  ProjetoCompiladores
//
//  Created by Guilherme Paiva on 19/04/2018.
//  Copyright © 2018 GHP Enterprises. All rights reserved.
//

import Foundation

class Token: Hashable {
    var hashValue: Int {
        return tag
    }
    
    static func == (lhs: Token, rhs: Token) -> Bool {
        return lhs.tag == rhs.tag
    }
    
    final let tag: Int
    
    init(t: Int) {
        self.tag = t
    }
    
    func toString() -> String {
        guard let code = UnicodeScalar(tag) else {
            print("Error trying to cast Int to Char")
            return ""
        }
        
        return "\(Character(code))"
    }
}
