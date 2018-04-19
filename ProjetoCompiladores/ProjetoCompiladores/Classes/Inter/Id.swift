//
//  Id.swift
//  ProjetoCompiladores
//
//  Created by Guilherme Paiva on 19/04/2018.
//  Copyright © 2018 GHP Enterprises. All rights reserved.
//

import Foundation

class Id: Expr {
    var offset: Int
    
    init(id: Word, p: Type, b: Int) {
        self.offset = b
        super.init(tok: id, p: p)
    }
}
