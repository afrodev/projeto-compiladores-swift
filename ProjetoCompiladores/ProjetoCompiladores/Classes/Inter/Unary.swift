//
//  Unary.swift
//  ProjetoCompiladores
//
//  Created by Guilherme Paiva on 19/04/2018.
//  Copyright © 2018 GHP Enterprises. All rights reserved.
//

import Foundation

class Unary: Op {
    var expr: Expr
    
    init(tok: Token, x: Expr) {
        self.expr = x
        super.init(tok: tok, p: nil)
        
        self.type = Type.max(p1: Type.int, p2: expr.type)
        if type == nil {
            try! error(s: "type error")
        }
    }
    
    override func gen() -> Expr {
        return Unary(tok: op, x: expr.reduce())
    }
    
    override func toString() -> String {
        return "\(op.toString()) \(expr.toString())"
    }
}
