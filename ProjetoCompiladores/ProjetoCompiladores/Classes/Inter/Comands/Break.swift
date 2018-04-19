//
//  Break.swift
//  ProjetoCompiladores
//
//  Created by Guilherme Paiva on 19/04/2018.
//  Copyright © 2018 GHP Enterprises. All rights reserved.
//

import Foundation

class Break: Stmt {
    var stmt: Stmt
    
    // eis um problema! pg.617 ou pg.14
    override init() {
        self.stmt = Stmt.Enclosing
        super.init()
        
        if Stmt.Enclosing === Stmt.Null { // talvez isso resolva mas sem ctz
            try! error(s: "unenclosed break")
        }
    }
    
    override func gen(b: Int, a: Int) {
        emit(s: "goto L \(stmt.after)")
    }
}
