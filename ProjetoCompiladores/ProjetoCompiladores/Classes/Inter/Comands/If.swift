//
//  If.swift
//  ProjetoCompiladores
//
//  Created by Guilherme Paiva on 19/04/2018.
//  Copyright © 2018 GHP Enterprises. All rights reserved.
//

import Foundation

class If: Stmt {
    var expr: Expr
    var stmt: Stmt
    
    init(x: Expr, s: Stmt) {
        self.expr = x
        self.stmt = s
        
        if !(expr.type === Type.Bool) {
            try! expr.error(s: "boolean required in if")
        }
    }
    
    override func gen(b: Int, a: Int) {
        let label = newLabel()
        expr.jumping(t: 0, f: a)
        emitLabel(i: label)
        stmt.gen(b: label, a: a)
    }
}
