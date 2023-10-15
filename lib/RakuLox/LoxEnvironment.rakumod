unit class LoxEnvironment;

has %.values;

method define($name, $value){
    %.values{$name} = $value;
}

method get($name) {
    if %.values{$name}:exists {
        return %.values{$name};
    }
    else {
        die "Undefined variable $name.";
    }
}

method assign($name, $value) {
    if %.values{$name}:exists {
        %.values{$name} = $value;
        return;
    }
    die "Undefined variable $name.";
}
