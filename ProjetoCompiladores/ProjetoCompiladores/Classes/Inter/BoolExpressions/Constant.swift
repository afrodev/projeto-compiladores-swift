//
//  Constant.swift
//  ProjetoCompiladores
//
//  Created by Guilherme Paiva on 19/04/2018.
//  Copyright © 2018 GHP Enterprises. All rights reserved.
//

import Foundation

class Constant: Expr {
    override init(tok: Token, p: Type?) {
        super.init(tok: tok, p: p)
    }
    
    init(i: Int) {
        super.init(tok: Num(v: i), p: Type.int)
    }
    
    static var True  = Constant(tok: Word.True, p: Type.bool),
    False = Constant(tok: Word.False, p: Type.bool)
    
    override func jumping(t: Int, f: Int) {
        if self === Constant.True && t != 0 {
            emit(s: "goto L \(t)")
        } else if self === Constant.False && f != 0 {
            emit(s: "goto L \(f)")
        }
    }
}
