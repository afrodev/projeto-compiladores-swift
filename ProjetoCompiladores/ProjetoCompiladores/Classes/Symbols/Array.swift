//
//  Array.swift
//  ProjetoCompiladores
//
//  Created by Guilherme Paiva on 19/04/2018.
//  Copyright © 2018 GHP Enterprises. All rights reserved.
//

import Foundation

class Array: Type {
    var of: Type        // arranjo *of* type
    var size: Int = 1   // numero de elementos
    
    init(sz: Int, p: Type) {
        self.of = p
        super.init(s: "[]", tag: Tag.INDEX, w: sz * p.width)
        self.size = sz
    }
    
    override func toString() -> String {
        return "[\(size)]\(of.toString())"
    }
}
