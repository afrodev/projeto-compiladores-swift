//
//  Tag.swift
//  ProjetoCompiladores
//
//  Created by Guilherme Paiva on 19/04/2018.
//  Copyright © 2018 GHP Enterprises. All rights reserved.
//

import Foundation

// MARK: É utilizada nos analisadores, sendo INDEX, MINUS e TEMP usadas nas árvores sintáticas
class Tag {
    static let
    AND   = 256, BASIC = 257, BREAK = 258, DO   = 259, ELSE  = 260,
    EQ    = 261, FALSE = 262, GE    = 263, ID   = 264, IF    = 265,
    INDEX = 266, LE    = 267, MINUS = 268, NE   = 269, NUM   = 270,
    OR    = 271, REAL  = 272, TEMP  = 273, TRUE = 274, WHILE = 275
}
