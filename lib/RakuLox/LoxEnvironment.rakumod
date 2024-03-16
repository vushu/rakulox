unit class LoxEnvironment;

has %.values;
has LoxEnvironment $.enclosing;

multi method new(LoxEnvironment $enclosing) {
    self.bless(:$enclosing);
}

method define($name, $value){
    %.values{$name} = $value;
}

method get($name) {
    return %.values{$name} if %.values{$name}:exists;
    if $.enclosing {
        return $.enclosing.get($name);
    }

    die "Undefined variable $name.";
}

method assign($name, $value) {
    return %.values{$name} = $value if %.values{$name}:exists ;
    return $.enclosing.assign($name, $value) if $.enclosing;

    die "Undefined variable $name.";
}
