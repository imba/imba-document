export function isFuzzyActionArr(what) {
    return (Array.isArray(what));
}
export function isFuzzyAction(what) {
    return !isFuzzyActionArr(what);
}
export function isString(what) {
    return (typeof what === 'string');
}
export function isIAction(what) {
    return !isString(what);
}
export function empty(s) {
    return (s ? false : true);
}
export function fixCase(lexer, str) {
    return (lexer.ignoreCase && str ? str.toLowerCase() : str);
}
export function sanitize(s) {
    return s.replace(/[&<>'"_]/g, '-');
}
export function log(lexer, msg) {
    console.log(lexer.languageId + ": " + msg);
}
export function createError(lexer, msg) {
    return new Error(lexer.languageId + ": " + msg);
}
export function substituteMatches(lexer, str, id, matches, state) {
    var re = /\$((\$)|(#)|(\d\d?)|[sS](\d\d?)|@(\w+))/g;
    var stateMatches = null;
    return str.replace(re, function (full, sub, dollar, hash, n, s, attr, ofs, total) {
        if (!empty(dollar)) {
            return '$';
        }
        if (!empty(hash)) {
            return fixCase(lexer, id);
        }
        if (!empty(n) && n < matches.length) {
            return fixCase(lexer, matches[n]);
        }
        if (!empty(attr) && lexer && typeof (lexer[attr]) === 'string') {
            return lexer[attr];
        }
        if (stateMatches === null) {
            stateMatches = state.split('.');
            stateMatches.unshift(state);
        }
        if (!empty(s) && s < stateMatches.length) {
            return fixCase(lexer, stateMatches[s]);
        }
        return '';
    });
}
export function findRules(lexer, inState) {
    var state = inState;
    while (state && state.length > 0) {
        var rules = lexer.tokenizer[state];
        if (rules) {
            return rules;
        }
        var idx = state.lastIndexOf('.');
        if (idx < 0) {
            state = null;
        }
        else {
            state = state.substr(0, idx);
        }
    }
    return null;
}
export function stateExists(lexer, inState) {
    var state = inState;
    while (state && state.length > 0) {
        var exist = lexer.stateNames[state];
        if (exist) {
            return true;
        }
        var idx = state.lastIndexOf('.');
        if (idx < 0) {
            state = null;
        }
        else {
            state = state.substr(0, idx);
        }
    }
    return false;
}
