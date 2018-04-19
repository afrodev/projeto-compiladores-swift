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
    private var look: Token!
    var top: Env?
    var used: Int = 0
    
    init(lexer: Lexer) {
        self.lexer = lexer
        self.move()
    }
    
    func move() {
        self.look = self.lexer.scan()
    }
    
    func error(_ s: String) throws {
        throw "near line \(Lexer.line): \(s)"
    }
    
    func match(t: Int)  {
        if self.look!.tag == t {
            self.move()
        } else {
            do {
                try self.error("syntax error")
            } catch { }
        }
    }
    
    func program() {
        let s:Stmt = self.block()
        let begin: Int = s.newLabel()
        let after: Int = s.newLabel()
        s.emitLabel(i: begin)
        s.gen(b: begin, a: after)
        s.emitLabel(i: after)
    }
    
    func block() -> Stmt {
        match(t: Int(Character("{").asciiValue!))
        let savedEnv = self.top
        self.top = Env(n: top!)
        self.decls()
        let s = self.stmts()
        
        match(t: Int(Character("}").asciiValue!))
        self.top = savedEnv
        return s
    }
    
    func decls() {
        while self.look!.tag == Tag.BASIC {
            let p = self.type()
            let tok = self.look
            match(t: Tag.ID)
            match(t: Int(Character(";").asciiValue!))
            let id = Id(id: tok as! Word, p: p, b: used)
            top?.put(w: tok!, i: id)
            used = used + p.width
        }
    }
    
    func type() -> Type {
        let p = self.look as! Type
        match(t: Tag.BASIC)
        if self.look!.tag != Int(Character("[").asciiValue!) {
            return p
        } else {
            return self.dims(p)
        }
    }
    
    func dims(_ p: Type) -> Type {
        var param = p
        match(t: Int(Character("[").asciiValue!))
        let tok = self.look!
        match(t: Tag.NUM)
        match(t: Int(Character("]").asciiValue!))
        if self.look!.tag == Int(Character("[").asciiValue!) {
            param = dims(param)
        }
        return Array(sz: tok.tag.hashValue, p: param)
    }
    
    func stmts() -> Stmt {
        if self.look.tag == Int(Character("}").asciiValue!) {
            return Stmt.Null
        } else {
            return Seq(s1: self.stmt(), s2: self.stmts())
        }
    }
    
    func stmt() -> Stmt {
        var x: Expr
        //        var s: Stmt
        var s1: Stmt
        var s2: Stmt
        var savedStmt: Stmt
        
        switch self.look.tag {
        case Int(Character(";").asciiValue!):
            self.move()
            return Stmt.Null
            
        case Tag.IF:
            match(t: Tag.IF)
            match(t: Int(Character("(").asciiValue!))
            x = self.bool()
            match(t: Int(Character(")").asciiValue!))
            s1 = self.stmt()
            if self.look.tag != Tag.ELSE {
                return If(x: x, s: s1)
            }
            match(t: Tag.ELSE)
            s2 = self.stmt()
            return Else(x: x, s1: s1, s2: s2)
            
        case Tag.WHILE:
            var whilenode = While()
            savedStmt = Stmt.Enclosing
            Stmt.Enclosing = whilenode
            match(t: Tag.WHILE)
            match(t: Int(Character("(").asciiValue!))
            x = self.bool()
            match(t: Int(Character(")").asciiValue!))
            s1 = self.stmt()
            whilenode = While(x: x, s: s1)
            Stmt.Enclosing = savedStmt
            return whilenode
            
        case Tag.DO:
            var donode = Do()
            savedStmt = Stmt.Enclosing
            Stmt.Enclosing = donode
            match(t: Tag.DO)
            s1 = self.stmt()
            match(t: Tag.WHILE)
            match(t: Int(Character("(").asciiValue!))
            x = self.bool()
            match(t: Int(Character(")").asciiValue!))
            match(t: Int(Character(";").asciiValue!))
            donode = Do(s: s1, x: x)
            Stmt.Enclosing = savedStmt
            return donode
            
        case Tag.BREAK:
            match(t: Tag.BREAK)
            match(t: Int(Character(";").asciiValue!))
            return Break()
            
        case Int(Character("{").asciiValue!):
            return self.block()
            
        default:
            return self.assign()
        }
    }
    
    func assign() -> Stmt {
        var stmt = Stmt()
        let t = self.look!
        match(t: Tag.ID)
        let id = top?.get(w: t)
        if id == nil {
            try! self.error("\(t.toString()) undeclared")
        }
        if self.look.tag == Int(Character("=").asciiValue!) {
            self.move()
            stmt = Set(i: id!, x: self.bool())
        } else {
            let x: Access = self.offset(id!)
            match(t: Int(Character("=").asciiValue!))
            stmt = SetElem(x: x, y: self.bool())
        }
        match(t: Int(Character(";").asciiValue!))
        return stmt
    }
    
    func bool() -> Expr {
        var x = self.join()
        while self.look.tag == Tag.OR {
            let tok = self.look!
            self.move()
            x = Or(tok: tok, x1: x, x2: self.join())
        }
        return x
    }
    
    func join() -> Expr {
        var x = self.equality()
        while self.look.tag == Tag.AND {
            let tok = self.look!
            self.move()
            x = Rel(tok: tok, x1: x, x2: self.equality())
        }
        return x
    }
    
    func equality() -> Expr {
        var x  = self.rel()
        while self.look.tag == Tag.EQ || self.look.tag == Tag.NE {
            let tok = self.look!
            self.move()
            x = Rel(tok: tok, x1: x, x2: self.rel())
        }
        return x
    }
    
    func rel() -> Expr {
        let x = self.expr()
        switch self.look.tag {
        case Int(Character("<").asciiValue!), Tag.LE, Tag.GE, Int(Character(">").asciiValue!):
            let tok = self.look!
            self.move()
            return Rel(tok: tok, x1: x, x2: self.expr())
            
        default:
            return x
        }
    }
    
    func expr() -> Expr {
        var x = self.term()
        while self.look.tag == Int(Character("+").asciiValue!) ||
            self.look.tag == Int(Character("-").asciiValue!) {
                let tok = self.look!
                self.move()
                x = Arith(tok: tok, x1: x, x2: self.term())
        }
        return x
    }
    
    func term() -> Expr {
        var x = self.unary()
        while self.look.tag == Int(Character("*").asciiValue!) ||
            self.look.tag == Int(Character("/").asciiValue!) {
                let tok = self.look!
                self.move()
                x = Arith(tok: tok, x1: x, x2: self.unary())
        }
        return x
    }
    
    func unary() -> Expr {
        if self.look.tag == Int(Character("-").asciiValue!) {
            self.move()
            return Unary(tok: Word.minus, x: self.unary())
        } else if self.look.tag == Int(Character("!").asciiValue!) {
            let tok = self.look!
            self.move()
            return Not(tok: tok, x1: self.unary(), x2: self.unary())
        } else {
            return self.factor()!
        }
    }
    
    func factor() -> Expr? {
        var x: Expr?
        switch self.look.tag {
        case Int(Character("(").asciiValue!):
            self.move()
            x = self.bool()
            match(t: Int(Character(")").asciiValue!))
            return x
        case Tag.NUM:
            x = Constant(tok: self.look, p: Type.Int)
            self.move()
            return x
        case Tag.REAL:
            x = Constant(tok: self.look, p: Type.Float)
            self.move()
            return x
        case Tag.TRUE:
            x = Constant.True
            self.move()
            return x
        case Tag.FALSE:
            x = Constant.False
            self.move()
            return x
        case Tag.ID:
            //            let s = self.look.toString()
            let id = top!.get(w: self.look)
            if id == nil {
                try! error("\(self.look.toString()) undeclared")
            }
            self.move()
            if self.look.tag != Int(Character("[").asciiValue!) {
                return id
            } else {
                return self.offset(id!)
            }
        default:
            try! self.error("syntax error")
            return x
        }
    }
    
    func offset(_ a: Id) -> Access {
        var i: Expr
        var w: Expr
        var t1: Expr
        var t2: Expr
        var loc: Expr
        var type = a.type
        match(t: Int(Character("[").asciiValue!))
        i = self.bool()
        match(t: Int(Character("]").asciiValue!))
        type = (type as! Array).of
        w = Constant(i: type!.width)
        t1 = Arith(tok: Token(t: Int(Character("*").asciiValue!)), x1: i, x2: w)
        loc = t1
        while self.look.tag == Int(Character("[").asciiValue!) {
            match(t: Int(Character("[").asciiValue!))
            i = self.bool()
            match(t: Int(Character("]").asciiValue!))
            type = (type as! Array).of
            w = Constant(i: type!.width)
            t1 = Arith(tok: Token(t: Int(Character("*").asciiValue!)), x1: i, x2: w)
            t2 = Arith(tok: Token(t: Int(Character("+").asciiValue!)), x1: loc, x2: t1)
            loc = t2
        }
        return Access(a: a, i: loc, p: type)
    }
}
