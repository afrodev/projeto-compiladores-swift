//
//  Seq.swift
//  ProjetoCompiladores
//
//  Created by Guilherme Paiva on 19/04/2018.
//  Copyright © 2018 GHP Enterprises. All rights reserved.
//

import Foundation

class Seq: Stmt {
    var stmt1: Stmt
    var stmt2: Stmt
    
    init(s1: Stmt, s2: Stmt) {
        self.stmt1 = s1
        self.stmt2 = s2
    }
    
    override func gen(b: Int, a: Int) {
        if stmt1 === Stmt.Null {
            stmt2.gen(b: b, a: a)
        }
            
        else if stmt2 === Stmt.Null {
            stmt1.gen(b: b, a: a)
        }
            
        else {
            let label = newLabel()
            stmt1.gen(b: b, a: label)
            emitLabel(i: label)
            stmt2.gen(b: label, a: a)
        }
    }
}
