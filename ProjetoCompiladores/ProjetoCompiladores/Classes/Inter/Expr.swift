//
//  Expr.swift
//  ProjetoCompiladores
//
//  Created by Guilherme Paiva on 19/04/2018.
//  Copyright © 2018 GHP Enterprises. All rights reserved.
//

import Foundation

class Expr: Node {
    var op: Token
    var type: Type?
    
    init(tok: Token, p: Type?) {
        self.op = tok
        self.type = p
    }
    
    func gen() -> Expr {
        return self
    }
    
    func reduce() -> Expr {
        return self
    }
    
    func jumping(t: Int, f: Int) {
        emitJumps(test: toString(), t: t, f: f)
    }
    
    func emitJumps(test: String, t: Int, f: Int) {
        if t != 0 && f != 0 {
            emit(s: "if \(test) goto L \(t)")
            emit(s: "goto L \(f)")
        } else if t != 0 {
            emit(s: "if \(test) goto L \(t)")
        } else if f != 0 {
            emit(s: "iffalse \(test) goto L \(f)")
        }
        // Se não nenhum desses casos não faz nada
    }
    
    func toString() -> String {
        return self.op.toString()
    }
}
