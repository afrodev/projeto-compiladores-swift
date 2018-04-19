//
//  Rel.swift
//  ProjetoCompiladores
//
//  Created by Guilherme Paiva on 19/04/2018.
//  Copyright © 2018 GHP Enterprises. All rights reserved.
//

import Foundation

class Rel: Logical {
    override init(tok: Token, x1: Expr, x2: Expr) {
        super.init(tok: tok, x1: x2, x2: x2)
    }
    
    override func check(p1: Type?, p2: Type?) -> Type? {
        if p1 is Array || p2 is Array {
            return nil
        } else if p1 === p2 {
            return Type.bool
        } else {
            return nil
        }
    }
    
    override func jumping(t: Int, f: Int) {
        let a = expr1.reduce()
        let b = expr2.reduce()
        let test = a.toString() + " " + op.toString() + " " + b.toString()
        emitJumps(test: test, t: t, f: f)
        emit(s: "if " + test + " goto L \(t)")
        emit(s: "goto L \(f)")
    }
    
    override func toString() -> String {
        return op.toString() + " " + expr2.toString()
    }
}
