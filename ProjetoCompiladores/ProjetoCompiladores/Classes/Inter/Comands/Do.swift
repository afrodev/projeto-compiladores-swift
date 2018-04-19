//
//  Do.swift
//  ProjetoCompiladores
//
//  Created by Guilherme Paiva on 19/04/2018.
//  Copyright © 2018 GHP Enterprises. All rights reserved.
//

import Foundation

class Do: Stmt {
    var expr: Expr?
    var stmt: Stmt?
    
    override init() {
        self.expr = nil
        self.stmt = nil
    }
    
    init(s: Stmt, x: Expr) {
        self.expr = x
        self.stmt = s
        super.init()
        
        if !(expr?.type === Type.bool) {
            try! error(s: "boolean required in do")
        }
    }
    
    override func gen(b: Int, a: Int) {
        self.after = a
        let label = newLabel()
        stmt?.gen(b: b, a: label)
        emitLabel(i: label)
        expr?.jumping(t: b, f: 0)
    }
}
