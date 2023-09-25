class ASTNode {}

class Unary is ASTNode {
    has $.op;
    has Any $.right;
    method new ($op, $right) {
        self.bless(:$op,:$right);
    }
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

class ExprStmt is ASTNode {
    has ASTNode $.expression;
    method new ($expression) {
        self.bless(:$expression)
    }
}

class Expression is ASTNode {
    has ASTNode $.assignment;
}

#class Assignment is ASTNode {
#has ASTNode @.;
#method new ($expression) {
#self.bless(:$expression)
#}
#}


class ClassDeclaration is ASTNode {
    has Str $.identifier;

}

class VarDecl is ASTNode {
    has Str $.identifier;
    has ASTNode $.expression;
}

class LogicOr is ASTNode {
    has ASTNode $.right;
    has ASTNode $.left;
    has Str $.op;

}
