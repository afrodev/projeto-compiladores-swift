//
//  Else.swift
//  ProjetoCompiladores
//
//  Created by Guilherme Paiva on 19/04/2018.
//  Copyright © 2018 GHP Enterprises. All rights reserved.
//

import Foundation

class Else: Stmt {
    var expr: Expr
    var stmt1: Stmt
    var stmt2: Stmt
    
    init(x: Expr, s1: Stmt, s2: Stmt) {
        self.expr = x
        self.stmt1 = s1
        self.stmt2 = s2
        if !(expr.type === Type.bool) {
            try! expr.error(s: "boolean required in if")
        }
    }
    
    override func gen(b: Int, a: Int) {
        let label1 = newLabel()
        let label2 = newLabel()
        
        expr.jumping(t: 0, f: label2)
        emitLabel(i: label1)
        stmt1.gen(b: label1, a: a)
        emit(s: "goto L \(a)")
        
        emitLabel(i: label2)
        stmt1.gen(b: label2, a: a)
    }
}
