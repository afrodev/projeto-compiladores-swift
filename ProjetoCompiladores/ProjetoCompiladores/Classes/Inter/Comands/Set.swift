//
//  Set.swift
//  ProjetoCompiladores
//
//  Created by Guilherme Paiva on 19/04/2018.
//  Copyright © 2018 GHP Enterprises. All rights reserved.
//

import Foundation

class Set: Stmt {
    var id: Id
    var expr: Expr
    
    init(i: Id, x: Expr) {
        self.id = i
        self.expr = x
        super.init()
        
        if check(p1: id.type, p2: x.type) == nil {
            try! error(s: "type error")
        }
    }
    
    func check(p1: Type?, p2: Type?) -> Type? {
        if Type.numeric(p: p1) && Type.numeric(p: p2) {
            return p2
        }
            
        else if p1?.lexeme == Type.Bool.lexeme && p2?.lexeme == Type.Bool.lexeme {
            return p2
        }
            
        else {
            return nil
        }
    }
    
    func gen(a: Int, b: Int) {
        emit(s: "\(id.toString()) = \(expr.gen().toString())")
    }
}
