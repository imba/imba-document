# import * as monarch from './monarch'

import {grammar} from './grammar'
import {compile} from './monarch/compile'

import {MonarchTokenizer} from './monarch/lexer'
export {Token} from './monarch/token'

var compiled = compile('imba',grammar)
export const lexer = MonarchTokenizer.new('imba',compiled)