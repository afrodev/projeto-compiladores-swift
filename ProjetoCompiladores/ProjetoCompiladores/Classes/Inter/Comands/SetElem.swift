//
//  SetElem.swift
//  ProjetoCompiladores
//
//  Created by Guilherme Paiva on 19/04/2018.
//  Copyright © 2018 GHP Enterprises. All rights reserved.
//

import Foundation

class SetElem: Stmt {
    var array: Id
    var index: Expr
    var expr: Expr
    
    init(x: Access, y: Expr) {
        self.array = x.array
        self.index = x.index
        self.expr = y
        super.init()
        
        if check(p1: x.type, p2: expr.type) == nil {
            try! expr.error(s: "type error")
        }
    }
    
    func check(p1: Type?, p2: Type?) -> Type? {
        if p1 is Array || p2 is Array {
            return nil
        }
            
        else if p1 === p2 { // === verifica se p1 aponta pro mesmo endereco de p2
            return p2       // semelhante ao == do Java
        }
            
        else if Type.numeric(p: p1) && Type.numeric(p: p2) {
            return p2
        }
            
        else {
            return nil
        }
    }
    
    override func gen(b: Int, a: Int) {
        let s1: String = index.reduce().toString()
        let s2: String = expr.reduce().toString()
        
        emit(s: "\(array.toString()) [ \(s1) ] = \(s2)")
    }
}
