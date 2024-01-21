class ASTNode {}

class Binary is ASTNode {
    has ASTNode $.left;
    has ASTNode $.right;
    has Str $.op;
}



class Top is ASTNode {
    has ASTNode @.declarations is rw;
}

class Declaration is ASTNode {
    has ASTNode $.declaration;
    method new ($declaration) {
        self.bless(:$declaration);
    }
}

class Statement is ASTNode {
}

#Expression statement
class Expression is ASTNode {
    has ASTNode $.expression

}

class ExprStmt is ASTNode {
    has ASTNode $.expression;
    method new ($expression) {
        self.bless(:$expression)
    }
}

class Assign is ASTNode {
    has Str $.name;
    has ASTNode $.value;
}

class Unary is ASTNode {
    has Str $.op;
    has ASTNode $.right;
}

class ClassDeclaration is ASTNode {
    has Str $.identifier;
}

class VarDecl is ASTNode {
    has Str $.identifier;
    has ASTNode $.expression;
}

class Call is ASTNode {

}

class Grouping is ASTNode {
    has ASTNode $.expression;
}

class Literal is ASTNode {
    has $.value;
}


class Print is ASTNode {
    has $.expression;
}

class While is ASTNode {
    has ASTNode $.condition;
    has ASTNode $.body;
}

class Block is ASTNode {
    has @.statements;
}

class Var is ASTNode {
    has Str $.name;
    has ASTNode $.initializer;
}

class Variable is ASTNode {
    has Str $.name;
}

class IfStmt is ASTNode {
    has ASTNode $.condition;
    has ASTNode $.then-branch;
    has ASTNode $.else-branch;
}

class Nothing is ASTNode {}




