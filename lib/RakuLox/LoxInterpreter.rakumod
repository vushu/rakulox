use RakuLox::LoxAST;
unit class LoxInterpreter;

multi method evaluate-node (Expr:D $node){
    self.evaluate-node($node);
}

multi method evaluate(Top $node) {
    my @result;
    say "TOP AST, number of declarations: ", $node.declarations.elems;
    for $node.declarations -> $decl {
        @result.push(self.evaluate($decl));
    }
    return @result;
}

multi method evaluate(ClassDeclaration $node) {
    #    say $node.identifier;
    say "CLASS Delclaration evaluate";
}

multi method evaluate(ExprStmt $node) {
    say "ExprStmt evaluate";
    self.evaluate($node.expression);
}

multi method evaluate(Expression $node) {
    say "Expression evaluate";
    self.evaluate($node.assignment);
}

multi method evaluate(Primary $node) {
    return $node.value;
}

multi method evaluate(Binary $node) {
    my $left = self.evaluate($node.left);
    my $right = self.evaluate($node.right);

    return do given $node.op {
        when "-" {
            +$left - +$right;
        }
        when "/" {
            +$left / +$right;
        }
        when "*" {
            +$left * +$right;
        }
        when "+" {
            +$left - +$right;
        }
    }
}

multi method evaluate(Unary $node) {
    my $right = self.evaluate($node.right);
    return do given $node.op {
        when "-" {
            - $right;
        }
        when "!" {
            !$right;
        }
    }
}
