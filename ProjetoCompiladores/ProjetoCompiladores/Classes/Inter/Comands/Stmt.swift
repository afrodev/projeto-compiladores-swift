//
//  Stmt.swift
//  ProjetoCompiladores
//
//  Created by Guilherme Paiva on 19/04/2018.
//  Copyright © 2018 GHP Enterprises. All rights reserved.
//

import Foundation

class Stmt: Node {
    override init() {}
    
    static var Null = Stmt()
    func gen(b: Int, a: Int) {}
    
    var after: Int = 0
    static var Enclosing: Stmt = Stmt.Null
}
