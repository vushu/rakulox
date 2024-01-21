role HighWaterErrorReport {
    method ws() {
        if self.pos > $*HIGHWATER {
            $*HIGHWATER = self.pos;
            $*LASTRULE = callframe(1).code.name;
        }
        callsame;
    }

    method error-water($target) {
        my $parsed = $target.substr(0, $*HIGHWATER).trim-trailing;
        my $line-no = $parsed.lines.elems;
        my $msg = "Cannot parse expression";
        $msg ~= "; error in rule $*LASTRULE" if $*LASTRULE;
        die "$msg at line $line-no";
    }

    method parse($target, |c) {
        my $*HIGHWATER = 0;
        my $*LASTRULE;
        my $match = callsame;
        self.error-water($target) unless $match;
        return $match;
    }
}

role FailGoalErrorReport {
    method FAILGOAL($goal) {
        my $cleaned = $goal.trim;
        self.fail-goal-error("No closing $cleaned");
    }
    method fail-goal-error($msg) {
        my $parsed = self.target.substr(0, self.pos)\
        .trim-trailing;
        my $context = $parsed.substr($parsed.chars - 10 max 0) ~ ' 👈' ~ self.target.substr($parsed.chars, 10);
        my $line-no = $parsed.lines.elems;
        my $error-msg = "Oh 💩 I cannot parse: $msg\nat line $line-no, around:" ~ $context;
        die $error-msg;
    }

}