//
//  Parser.swift
//  ProjetoCompiladores
//
//  Created by Guilherme Paiva on 19/04/2018.
//  Copyright © 2018 GHP Enterprises. All rights reserved.
//

import Foundation

class Parser {
    private let lexer: Lexer
    private var look: Token
    var top: Env? = nil
    var used: Int = 0
    
    init(lexer: Lexer) throws {
        self.lexer = lexer
        self.look = Token(t: 0)
        try! self.move()
    }
    
    func move() throws {
        
        guard let token = self.lexer.scan() else {
            throw "error durring scan"
        }
        
        self.look = token
    }
    
    func error(_ s: String) throws {
        throw "near line \(Lexer.line): \(s)"
    }
    
    func match(t: Int) throws {
        
        do {
            if self.look.tag == t {
                try self.move()
            } else {
                throw "syntax error"
            }
        } catch let error {
            throw error
        }
    }
    
    func program() throws {
        do {
            let s: Stmt = try self.block()
            let begin: Int = s.newLabel()
            let after: Int = s.newLabel()
            s.emitLabel(i: begin)
            s.gen(b: begin, a: after)
            s.emitLabel(i: after)
        } catch let error {
            throw error
        }
    }
    
    func block() throws -> Stmt {
        do {
            try match(t: Int(Character("{").asciiValue!))
            let savedEnv = self.top
            self.top = Env(n: self.top)
            try self.decls()
            let s = try self.stmts()
            
            try match(t: Int(Character("}").asciiValue!))
            self.top = savedEnv
            return s
        } catch let error {
            throw error
        }
    }
    
    func decls() throws {
        do {
            while self.look.tag == Tag.BASIC {
                let p = try self.type()
                let tok = self.look
                try match(t: Tag.ID)
                try match(t: Int(Character(";").asciiValue!))
                let id = Id(id: tok as! Word, p: p, b: used)
                top?.put(w: tok, i: id)
                used = used + p.width
            }
        } catch let error {
            throw error
        }
    }
    
    func type() throws -> Type {
        do {
            let p = self.look as! Type
            try match(t: Tag.BASIC)
            if self.look.tag != Int(Character("[").asciiValue!) {
                return p
            } else {
                return try self.dims(p)
            }
        } catch let error {
            throw error
        }
    }
    
    func dims(_ p: Type) throws -> Type {
        
        do {
            var param = p
            try match(t: Int(Character("[").asciiValue!))
            let tok = self.look
            try match(t: Tag.NUM)
            try match(t: Int(Character("]").asciiValue!))
            if self.look.tag == Int(Character("[").asciiValue!) {
                param = try dims(param)
            }
            return Array(sz: tok.tag.hashValue, p: param)
        } catch let error {
            throw error
        }
    }
    
    func stmts() throws -> Stmt {
        do {
            if self.look.tag == Int(Character("}").asciiValue!) {
                return Stmt.Null
            } else {
                return Seq(s1: try self.stmt(), s2: try self.stmts())
            }
        } catch let error {
            throw error
        }
    }
    
    func stmt() throws -> Stmt {
        var x: Expr
        //        var s: Stmt
        var s1: Stmt
        var s2: Stmt
        var savedStmt: Stmt
        
        do {
            switch self.look.tag {
            case Int(Character(";").asciiValue!):
                try self.move()
                return Stmt.Null
                
            case Tag.IF:
                try match(t: Tag.IF)
                try match(t: Int(Character("(").asciiValue!))
                x = try self.bool()
                try match(t: Int(Character(")").asciiValue!))
                s1 = try self.stmt()
                if self.look.tag != Tag.ELSE {
                    return If(x: x, s: s1)
                }
                try match(t: Tag.ELSE)
                s2 = try self.stmt()
                return Else(x: x, s1: s1, s2: s2)
                
            case Tag.WHILE:
                var whilenode = While()
                savedStmt = Stmt.Enclosing
                Stmt.Enclosing = whilenode
                try match(t: Tag.WHILE)
                try match(t: Int(Character("(").asciiValue!))
                x = try self.bool()
                try match(t: Int(Character(")").asciiValue!))
                s1 = try self.stmt()
                whilenode = While(x: x, s: s1)
                Stmt.Enclosing = savedStmt
                return whilenode
                
            case Tag.DO:
                var donode = Do()
                savedStmt = Stmt.Enclosing
                Stmt.Enclosing = donode
                try match(t: Tag.DO)
                s1 = try self.stmt()
                try match(t: Tag.WHILE)
                try match(t: Int(Character("(").asciiValue!))
                x = try self.bool()
                try match(t: Int(Character(")").asciiValue!))
                try match(t: Int(Character(";").asciiValue!))
                donode = Do(s: s1, x: x)
                Stmt.Enclosing = savedStmt
                return donode
                
            case Tag.BREAK:
                try match(t: Tag.BREAK)
                try match(t: Int(Character(";").asciiValue!))
                return Break()
                
            case Int(Character("{").asciiValue!):
                return try self.block()
                
            default:
                return try self.assign()
            }
        } catch let error {
            throw error
        }
    }
    
    func assign() throws -> Stmt {
        
        do {
            var stmt = Stmt()
            let t = self.look
            try match(t: Tag.ID)
            let id = top?.get(w: t)
            if id == nil {
                throw "\(t.toString()) undeclared"
            }
            if self.look.tag == Int(Character("=").asciiValue!) {
                try self.move()
                stmt = Set(i: id!, x: try self.bool())
            } else {
                let x: Access = try self.offset(id!)
                try match(t: Int(Character("=").asciiValue!))
                stmt = SetElem(x: x, y: try self.bool())
            }
            try match(t: Int(Character(";").asciiValue!))
            return stmt
        } catch let error {
            throw error
        }
    }
    
    func bool() throws -> Expr {
        do {
            var x = try self.join()
            while self.look.tag == Tag.OR {
                let tok = self.look
                try self.move()
                x = Or(tok: tok, x1: x, x2: try self.join())
            }
            return x
        } catch let error {
            throw error
        }
        
    }
    
    func join() throws -> Expr {
        
        do {
            var x = try self.equality()
            while self.look.tag == Tag.AND {
                let tok = self.look
                try self.move()
                x = Rel(tok: tok, x1: x, x2: try self.equality())
            }
            return x
        } catch let error {
            throw error
        }
    }
    
    func equality() throws -> Expr {
        
        do {
            var x  = try self.rel()
            while self.look.tag == Tag.EQ || self.look.tag == Tag.NE {
                let tok = self.look
                try self.move()
                x = Rel(tok: tok, x1: x, x2: try self.rel())
            }
            return x
        } catch let error {
            throw error
        }
    }
    
    func rel() throws -> Expr {
        
        do {
            let x = try self.expr()
            switch self.look.tag {
            case Int(Character("<").asciiValue!), Tag.LE, Tag.GE, Int(Character(">").asciiValue!):
                let tok = self.look
                try self.move()
                return Rel(tok: tok, x1: x, x2: try self.expr())
                
            default:
                return x
            }
        } catch let error {
            throw error
        }
    }
    
    func expr() throws -> Expr {
        
        do {
            var x = try self.term()
            while self.look.tag == Int(Character("+").asciiValue!) ||
                self.look.tag == Int(Character("-").asciiValue!) {
                    let tok = self.look
                    try self.move()
                    x = Arith(tok: tok, x1: x, x2: try self.term())
            }
            return x
        } catch let error {
            throw error
        }
    }
    
    func term() throws -> Expr {
        
        do {
            var x = try self.unary()
            while self.look.tag == Int(Character("*").asciiValue!) ||
                self.look.tag == Int(Character("/").asciiValue!) {
                    let tok = self.look
                    try self.move()
                    x = Arith(tok: tok, x1: x, x2: try self.unary())
            }
            return x
        } catch let error {
            throw error
        }
    }
    
    func unary() throws -> Expr {
        
        do {
            if self.look.tag == Int(Character("-").asciiValue!) {
                try self.move()
                return Unary(tok: Word.minus, x: try self.unary())
            } else if self.look.tag == Int(Character("!").asciiValue!) {
                let tok = self.look
                try self.move()
                return Not(tok: tok, x1: try self.unary(), x2: try self.unary())
            } else {
                return (try self.factor())!
            }
        } catch let error {
            throw error
        }
    }
    
    func factor() throws -> Expr? {
        
        do {
            var x: Expr?
            switch self.look.tag {
            case Int(Character("(").asciiValue!):
                try self.move()
                x = try self.bool()
                try match(t: Int(Character(")").asciiValue!))
                return x
            case Tag.NUM:
                x = Constant(tok: self.look, p: Type.Int)
                try self.move()
                return x
            case Tag.REAL:
                x = Constant(tok: self.look, p: Type.Float)
                try self.move()
                return x
            case Tag.TRUE:
                x = Constant.True
                try self.move()
                return x
            case Tag.FALSE:
                x = Constant.False
                try self.move()
                return x
            case Tag.ID:
                //            let s = self.look.toString()
                let id = top!.get(w: self.look)
                if id == nil {
                    try! error("\(self.look.toString()) undeclared")
                }
                try self.move()
                if self.look.tag != Int(Character("[").asciiValue!) {
                    return id
                } else {
                    return try self.offset(id!)
                }
            default:
                try! self.error("syntax error")
                return x
            }
        } catch let error {
            throw error
        }
    }
    
    func offset(_ a: Id) throws -> Access {
        
        do {
            var i: Expr
            var w: Expr
            var t1: Expr
            var t2: Expr
            var loc: Expr
            var type = a.type
            try match(t: Int(Character("[").asciiValue!))
            i = try self.bool()
            try match(t: Int(Character("]").asciiValue!))
            type = (type as! Array).of
            w = Constant(i: type!.width)
            t1 = Arith(tok: Token(t: Int(Character("*").asciiValue!)), x1: i, x2: w)
            loc = t1
            while self.look.tag == Int(Character("[").asciiValue!) {
                try match(t: Int(Character("[").asciiValue!))
                i = try self.bool()
                try match(t: Int(Character("]").asciiValue!))
                type = (type as! Array).of
                w = Constant(i: type!.width)
                t1 = Arith(tok: Token(t: Int(Character("*").asciiValue!)), x1: i, x2: w)
                t2 = Arith(tok: Token(t: Int(Character("+").asciiValue!)), x1: loc, x2: t1)
                loc = t2
            }
            return Access(a: a, i: loc, p: type)
        } catch let error {
            throw error
        }
    }
}
