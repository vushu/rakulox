class Expr {}
class Stmt {}

class Binary is Expr {
    has Expr $.left;
    has Expr $.right;
    has Str $.op;
}



class Top is Expr {
    has Stmt @.declarations is rw;
}

class Declaration is Expr {
    has Expr $.declaration;
    method new ($declaration) {
        self.bless(:$declaration);
    }
}

class Statement is Expr {
}

#Expression statement
class Expression is Stmt {
    has Expr $.expression

}

class ExprStmt is Expr {
    has Stmt $.expression;
    method new ($expression) {
        self.bless(:$expression)
    }
}

class Assign is Expr {
    has Str $.name;
    has Expr $.value;
}

class Unary is Expr {
    has Str $.op;
    has Expr $.right;
}

class ClassDeclaration is Expr {
    has Str $.identifier;
}

class VarDecl is Expr {
    has Str $.identifier;
    has Expr $.expression;
}

class Call is Expr {

}

class Grouping is Expr {
    has Expr $.expression;
}

class Literal is Expr {
    has $.value;
}


class Print is Stmt {
    has $.expression;
}

class While is Stmt {
    has Expr $.condition;
    has Stmt $.body;
}

class Block is Stmt {
    has @.statements;
}

class Var is Stmt {
    has Expr $.name;
    has Expr $.initializer;
}

class Variable is Expr {
    has Str $.name;
}

class Nothing is Expr {}



