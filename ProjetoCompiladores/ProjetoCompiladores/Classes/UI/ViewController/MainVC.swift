//
//  MainVC.swift
//  ProjetoCompiladores
//
//  Created by Humberto Vieira on 30/03/18.
//  Copyright © 2018 GHP Enterprises. All rights reserved.
//

import Cocoa

class MainVC: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        Analisador léxico
        let lexer = Lexer()
        
//        Analisador sintático
        do {
            let parse = try Parser(lexer: lexer)
            try parse.program()
        } catch let error {
            print("\n", error)
            fatalError()
        }
        
        print("\n")
    }
}
