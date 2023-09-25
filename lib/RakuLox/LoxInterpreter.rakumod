use RakuLox::LoxAST;
unit class LoxInterpreter;

multi method interpret-node (ASTNode:D $node){
    self.interpret-node($node);
}

multi method interpret(Top $node) {
    say "TOP AST, number of declarations: ", $node.declarations.elems;
    for $node.declarations -> $decl {
        self.interpret($decl);
    }
}

multi method interpret(ClassDeclaration $node) {
    #    say $node.identifier;
    say "CLASS Delclaration interpret";
}

multi method interpret(ExprStmt $node) {
    say "ExprStmt interpret";
    self.interpret($node.expression);
}

multi method interpret(Expression $node) {
    say "Expression interpret";
    self.interpret($node.assignment);
}

multi method interpret(Unary $node) {
    say "yup unary !!!!!";
}
