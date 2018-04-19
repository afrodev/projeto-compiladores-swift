//
//  Logical.swift
//  ProjetoCompiladores
//
//  Created by Guilherme Paiva on 19/04/2018.
//  Copyright © 2018 GHP Enterprises. All rights reserved.
//

import Foundation

class Logical: Expr {
    var expr1, expr2: Expr
    
    init(tok: Token, x1: Expr, x2: Expr) {
        self.expr1 = x1
        self.expr2 = x2
        super.init(tok: tok, p: nil)
        self.type = check(p1: expr1.type, p2: expr2.type)
        
        if type == nil {
            try! error(s: "type error")
        }
    }
    
    func check(p1: Type?, p2: Type?) -> Type? {
        if p1 === Type.bool && p2 === Type.bool {
            return Type.bool
        } else {
            return nil
        }
    }
    
    override func gen() -> Expr {
        let f = newLabel()
        let a = newLabel()
        
        let temp = Temp(p: type)
        self.jumping(t: 0, f: f)
        
        emit(s: "\(temp.toString()) = true")
        emit(s: "goto L \(a)")
        emitLabel(i: f)
        emit(s: "\(temp.toString()) = false")
        emitLabel(i: a)
        
        return temp
    }
    
    override func toString() -> String {
        return expr1.toString() + " " + op.toString() + " " + expr2.toString()
    }
}
