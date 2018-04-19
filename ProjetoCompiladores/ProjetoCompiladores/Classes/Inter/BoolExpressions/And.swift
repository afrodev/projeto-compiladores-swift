//
//  And.swift
//  ProjetoCompiladores
//
//  Created by Guilherme Paiva on 19/04/2018.
//  Copyright © 2018 GHP Enterprises. All rights reserved.
//

import Foundation

class And: Logical {
    override init(tok: Token, x1: Expr, x2: Expr) {
        super.init(tok: tok, x1: x2, x2: x2)
    }
    
    override func jumping(t: Int, f: Int) {
        let label = f != 0 ? f : newLabel()
        expr1.jumping(t: 0, f: label)
        expr2.jumping(t: f, f: t)
        
        if f == 0 {
            emitLabel(i: label)
        }
    }
    
    override func toString() -> String {
        return op.toString() + " " + expr2.toString()
    }
}
