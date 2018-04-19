//
//  Op.swift
//  ProjetoCompiladores
//
//  Created by Guilherme Paiva on 19/04/2018.
//  Copyright © 2018 GHP Enterprises. All rights reserved.
//

import Foundation

class Op: Expr {
    
    override init(tok: Token, p: Type?) {
        super.init(tok: tok, p: p)
    }
    
    override func reduce() -> Expr {
        let x = gen()
        let t = Temp(p: type)
        
        emit(s: "\(t.toString()) = \(x.toString())")
        
        return t
    }
}
