use lib 'lib';

use RakuLox::LoxGrammar;
use RakuLox::LoxActions;
use RakuLox::LoxInterpreter;

sub MAIN($code) {
    say "input: ", $code;
    my $parser = LoxGrammar.new;
    my $actions = LoxActions.new;
    my @statements = $parser.parse($code, :actions($actions)).made;
    my @results = LoxInterpreter.interpret(@statements);
    for @results -> $res {
        say $res;
    }

}