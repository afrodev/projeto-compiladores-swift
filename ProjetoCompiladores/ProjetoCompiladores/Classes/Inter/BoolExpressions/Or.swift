//
//  Or.swift
//  ProjetoCompiladores
//
//  Created by Guilherme Paiva on 19/04/2018.
//  Copyright © 2018 GHP Enterprises. All rights reserved.
//

import Foundation

class Or: Logical {
    override init(tok: Token, x1: Expr, x2: Expr) {
        super.init(tok: tok, x1: x1, x2: x2)
    }
    
    override func jumping(t: Int, f: Int) {
        let label = t != 0 ? t : newLabel()
        expr1.jumping(t: label, f: 0)
        expr2.jumping(t: t, f: f)
        if t == 0 {
            emitLabel(i: label)
        }
    }
}
