//
//  Not.swift
//  ProjetoCompiladores
//
//  Created by Guilherme Paiva on 19/04/2018.
//  Copyright © 2018 GHP Enterprises. All rights reserved.
//

import Foundation

class Not: Logical {
    override init(tok: Token, x1: Expr, x2: Expr) {
        super.init(tok: tok, x1: x2, x2: x2)
    }
    
    override func jumping(t: Int, f: Int) {
        expr2.jumping(t: f, f: t)
    }
    
    override func toString() -> String {
        return op.toString() + " " + expr2.toString()
    }
}
