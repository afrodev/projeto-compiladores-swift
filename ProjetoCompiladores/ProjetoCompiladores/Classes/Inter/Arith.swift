//
//  Arith.swift
//  ProjetoCompiladores
//
//  Created by Guilherme Paiva on 19/04/2018.
//  Copyright © 2018 GHP Enterprises. All rights reserved.
//

import Foundation

class Arith: Op {
    let expr1, expr2: Expr
    
    init(tok: Token, x1: Expr, x2: Expr) {
        self.expr1 = x1
        self.expr2 = x2
        super.init(tok: tok, p: nil)
        
        self.type = Type.max(p1: expr1.type, p2: expr2.type)
        
        if type == nil {
            // Deixei sem tratar porque não é pra rodar mais de que der error
            try! error(s: "type error")
        }
        
    }
    
    override func gen() -> Expr {
        return Arith.init(tok: op, x1: expr1.reduce(), x2: expr2.reduce())
    }
    
    override func toString() -> String {
        return "\(expr1.toString()) \(op.toString()) \(expr2.toString())"
    }
}
