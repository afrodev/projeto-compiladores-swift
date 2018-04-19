//
//  Access.swift
//  ProjetoCompiladores
//
//  Created by Guilherme Paiva on 19/04/2018.
//  Copyright © 2018 GHP Enterprises. All rights reserved.
//

import Foundation

class Access: Op {
    var array: Id
    var index: Expr
    
    init(a: Id, i: Expr, p: Type?) {
        self.array = a
        self.index = i
        
        super.init(tok: Word(s: "[]", tag: Tag.INDEX), p: p)
    }
    
    override func gen() -> Expr {
        return Access(a: array, i: index.reduce(), p: type)
    }
    
    override func jumping(t: Int, f: Int) {
        emitJumps(test: reduce().toString(), t: t, f: f)
    }
    
    override func toString() -> String {
        return array.toString() + " [ " + index.toString() + " ] "
    }
}
