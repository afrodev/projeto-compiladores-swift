//
//  While.swift
//  ProjetoCompiladores
//
//  Created by Guilherme Paiva on 19/04/2018.
//  Copyright © 2018 GHP Enterprises. All rights reserved.
//

import Foundation

class While: Stmt {
    var expr: Expr?
    var stmt: Stmt?
    
    override init() {
        self.expr = nil
        self.stmt = nil
    }
    
    init(x: Expr?, s: Stmt?) {
        self.expr = x
        self.stmt = s
        
        if !(expr?.type === Type.Bool) {
            try! expr?.error(s: "boolean required in while")
        }
    }
    
    override func gen(b: Int, a: Int) {
        self.after = a
        self.expr?.jumping(t: 0, f: a)
        
        let label = newLabel()
        emitLabel(i: label)
        stmt?.gen(b: label, a: b)
        emit(s: "goto L \(b)")
    }
}
