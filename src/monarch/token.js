var Token = (function () {
    function Token(offset, type, language) {
        this.offset = offset | 0;
        this.type = type;
        this.language = language;
        this.value = null;
        this.whitespace = null;
        this.stack = null;
    }
    Token.prototype.toString = function () {
        return this.value || '';
    };
    Token.prototype.match = function (val) {
        if (typeof val == 'string') {
            if (val.indexOf(' ') > 0) {
                val = val.split(' ');
            }
            else if (this.type.indexOf(val) >= 0) {
                return true;
            }
        }
        if (val instanceof Array) {
            for (var _i = 0, val_1 = val; _i < val_1.length; _i++) {
                var item = val_1[_i];
                if (this.type.indexOf(item) >= 0) {
                    return true;
                }
            }
        }
        if (val instanceof RegExp) {
            return val.test(this.type);
        }
        return false;
    };
    return Token;
}());
export { Token };
var TokenizationResult = (function () {
    function TokenizationResult(tokens, endState) {
        this.tokens = tokens;
        this.endState = endState;
    }
    return TokenizationResult;
}());
export { TokenizationResult };
