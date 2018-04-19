//
//  Node.swift
//  ProjetoCompiladores
//
//  Created by Guilherme Paiva on 19/04/2018.
//  Copyright © 2018 GHP Enterprises. All rights reserved.
//

import Foundation

extension String: Error {}

class Node {
    var lexline: Int = 0
    
    init() {
        self.lexline = Lexer.line
    }
    
    func error(s: String) throws {
        throw "near line \(lexline): \(s)"
    }
    
    static var labels: Int = 0
    
    func newLabel() -> Int {
        return Node.labels + 1
    }
    
    func emitLabel(i: Int) {
        print("L", i, ":")
    }
    
    func emit(s: String) {
        print("\t", s)
    }
}
