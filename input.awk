function is_set(scalar,     oldlint, isset){
    oldlint = LINT
    LINT = 0 # For warning about accessing an unset variable
    isset = (scalar != "" || scalar != 0)
    LINT = oldlint
    return isset
}
function envbool(str){
    return str in ENVIRON && ENVIRON[str] != "" && ENVIRON[str] != "0"
}
function envint(str, default_value, min, max, regex,     i){
    if (!is_set(regex)) {
        regex = "^-?[0-9]+$"
    }
	if (str in ENVIRON && ENVIRON[str] ~ regex) {
        i = int(ENVIRON[str])
        if (is_set(min) && i < min) {
            return min
        } else if (is_set(max) && i > max) {
            return max
        } else {
            return i
        }
	} else {
        return default_value
    }
}
function num(str){
    return (lang == "he") ? str : int(str)
}
