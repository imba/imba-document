
const newline = String.fromCharCode(172)

# var eolpop = [/@newline/, token: '@rematch', next: '@pop']
var eolpop = [/^/, token: '@rematch', next: '@pop']

export var types =
	decl_class_name: 'entity.name.type.class'
	decl_tag_name: 'entity.name.type.class'
	decl_prop_name: 'entity.name.type.property'
	decl_def_name: 'entity.name.function'

export var grammar = {
	defaultToken: 'invalid',
	ignoreCase: false,
	tokenPostfix: '',
	brackets: [
		{ open: '{', close: '}', token: 'bracket.curly' },
		{ open: '[', close: ']', token: 'bracket.square' },
		{ open: '(', close: ')', token: 'bracket.parenthesis' }
	],
	keywords: [
		'def', 'and', 'or', 'is', 'isnt', 'not', 'on', 'yes', '@', 'no', 'off',
		'true', 'false', 'null', 'this', 'self','as'
		'new', 'delete', 'typeof', 'in', 'instanceof',
		'return', 'throw', 'break', 'continue', 'debugger',
		'if', 'elif', 'else', 'switch', 'for', 'while', 'do', 'try', 'catch', 'finally',
		'class', 'extends', 'super',
		'undefined', 'then', 'unless', 'until', 'loop', 'of', 'by', 'when',
		'tag', 'prop', 'attr', 'export', 'import', 'extend',
		'var', 'let', 'const', 'require', 'isa', 'await'
	],
	boolean: ['true','false','yes','no','undefined']
	contextual_keywords: [
		'from', 'global', 'attr','prop'
	],
	operators: [
		'=', '!', '~', '?', ':','!!',
		'&', '|', '^', '%', '<<',
		'>>', '>>>', '+=', '-=', '*=', '/=', '&=', '|=', '?=',
		'^=', '%=', '<<=', '>>=', '>>>=','..','...','||=',`&&=`,'**=','**'
	],
	logic: [
		'>', '<', '==', '<=', '>=', '!=', '&&', '||','===','!=='
	],
	ranges: ['..','...'],
	dot: ['.'],
	math: [
		'+', '-', '*', '/', '++', '--'
	],

	# we include these common regular expressions
	symbols: /[=><!~?&%|+\-*\/\^\.,\:]+/,
	escapes: /\\(?:[abfnrtv\\"'$]|x[0-9A-Fa-f]{1,4}|u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8})/,
	postaccess: /(:(?=\w))?/
	ivar: /\@[a-zA-Z_]\w*/
	constant: /[A-Z][\w\$]*(?:\-[\w\$]+)*/
	className: /[A-Z][A-Za-z\d\-\_]*|[A-Za-z\d\-\_]+/
	methodName: /[A-Za-z\_][A-Za-z\d\-\_]*\=?/
	subIdentifer: /(?:\-*[\w\$]+)*/
	identifier: /[a-z_]@subIdentifer/
	mixinIdentifier: /\%[a-z_]@subIdentifer/
	anyIdentifier: /[A-Za-z_\$][\w\$]*@subIdentifer/
	anyIdentifierOpt: /(?:[A-Za-z_\$][\w\$]*@subIdentifer)?/
	esmIdentifier: /[\@\%]?[A-Za-z_\$]@subIdentifer/
	propertyPath: /(?:[A-Za-z_\$][A-Za-z\d\-\_\$]*\.)?(?:[A-Za-z_\$][A-Za-z\d\-\_\$]*)/
	tagNameIdentifier: /(?:[\w\-]+\:)?\w+(?:\-\w+)*/
	variable: /[\w\$]+(?:-[\w\$]*)*/
	varKeyword: /var|let|const/
	newline: RegExp.new(newline)
	tagIdentifier: /-*[a-zA-Z][\w\-]*/

	cssPropertyKey: /[\@\.]*[\w\-\$]+(?:[\@\.]+[\w\-\$]+)*(?:\s*\:)/
	cssVariable: /(?:--|\$)[\w\-\$]+/
	cssPropertyName: /[\w\-\$]+/
	cssModifier: /\@[\w\-\$]+/
	cssUpModifier: /\.\.[\w\-\$]+/
	cssIsModifier: /\.[\w\-\$]+/
	
	regEx: /\/(?!\/\/)(?:[^\/\\]|\\.)*\/[igm]*/,
	
	regexpctl: /[(){}\[\]\$\^|\-*+?\.]/,
	regexpesc: /\\(?:[bBdDfnrstvwWn0\\\/]|@regexpctl|c[A-Z]|x[0-9a-fA-F]{2}|u[0-9a-fA-F]{4})/,

	# The main tokenizer for our languages
	tokenizer: {
		root: [
			{ include: 'body' }
		],

		common: [
			{ include: '@whitespace' }
		]

		legacy_access: [
			[/(\:)(\@?@anyIdentifier)/, ['operator.dot.legacy','property']],
		]

		spread: [
			[/\.\.\./,'operator.spread']
			[/(\*)(?=[\w\$])/,'operator.spread.legacy']
		]

		expression: [
			{ include: 'legacy_access'}
			{ include: 'spread' }
			{ include: 'do' }
			{ include: 'implicit_call' }
			{ include: 'access' }
			{ include: 'object_key' }
			{ include: 'identifiers' }
			{ include: 'tag_start' },
			{ include: 'string_start' }
			{ include: 'regexp_start' }
			{ include: 'object_start' }
			{ include: 'array_start' }
			{ include: 'parens_start' }
			{ include: 'number' }
			{ include: 'comments' }
			{ include: 'common' }
			{ include: 'operators' }
			{ include: 'decorator' }
			{ include: 'parens_start' }
		]

		parens_start: [
			[/\(/, 'bracket.parenthesis.open', '@parens']
		]

		tag_value_expression: [
			{ include: 'legacy_access'}
			{ include: 'spread' }
			{ include: 'do' }
			{ include: 'access' }
			{ include: 'identifiers' }
			{ include: 'tag_start' },
			{ include: 'string_start' }
			{ include: 'regexp_start' }
			{ include: 'object_start' }
			{ include: 'array_start' }
			{ include: 'number' }
			{ include: 'comments' }
			{ include: 'common' }
			{ include: 'operators' }
			{ include: 'parens_start' }
		]

		expressable: [
			{include: 'catch'}
		]

		catch: [
			[/(catch)(\s)(@anyIdentifier)/, ['keyword.catch','white','variable.let']],
		]

		do: [
			[/(do)(\()/, [{token: 'keyword.$1'},{token: 'argparam.open', next: '@var_parens.argparam'}]],
		]

		implicit_call: [
			[/(\.)(\@?@anyIdentifier)(\s+)(?=\S)/, ['operator.dot','property',{token: 'white', next: '@implicit_params'}]],
		]

		access: [
			[/(\.)(\@?@anyIdentifier\?)/, ['operator.dot','property.predicate']],
			[/(\.)(\@?@anyIdentifier\!)/, ['operator.dot','property.invoke']],
			[/(\.)(\@?@anyIdentifier)/, ['operator.dot','property']],
		]

		decorator: [
			[/\@(@anyIdentifier)?/, 'decorator'],
		]

		implicit_params: [
			eolpop
			[/[\)\}\]]/, { token: '@rematch', next: '@pop' }]
			{include: 'expression'}
			[/\,/, 'delimiter']
		]

		object_key: [
			[/(@anyIdentifier)\??(\:)/, ['identifier.key','operator.assign.key']]
		]

		identifiers: [
			[/\$\w+\$/, 'identifier.env']
			[/\$\d+/, 'identifier.special']
			[/(@constant)/, 'identifier.constant']
			[/\$(@anyIdentifier)\??/, 'identifier.internal']
			[/(@anyIdentifier\?)/, 'identifier.predicate']
			[/(@anyIdentifier\!)/, 'identifier.invoke']
			[/(@identifier\??)/,cases: {
				'this': 'this',
				'self': 'self',
				'$1@boolean': {token: 'boolean.$1'},
				'$1@keywords': {token: 'keyword.$1'},
				'@default': 'identifier'
			}],
			[/(@anyIdentifier)/, 'identifier']
			{include: 'type_start'}
		]

		type_start: [
			[/\\/, 'type.start','@type.0']
		]

		type: [
			eolpop
			[/\[/,'type','@type.]']
			[/\(/,'type','@type.)']
			[/\{/,'type','@type.}']
			[/\</,'type','@type.>']
			[/\,|\s/,{
				cases: {
					'$S2==0': { token: '@rematch', next: '@pop' }
					'@default': 'type'
				}
			}]
			[/[\]\}\)\>]/,{
				cases: {
					'$1==$S2': { token: 'type', next: '@pop' }
					'@default': { token: '@rematch', next: '@pop' }
				}
			}]
			[/[\w\-\$]+/,'type']
		]

		parens: [
			[/\)/, 'bracket.parenthesis.close', '@pop']
			{include: 'var_expr'}
			{include: 'expression'}
			[/\,/, 'delimiter']
		]

		statements: [
			{ include: 'css_statement' }
			{ include: 'var_statement' }
			{ include: 'forin_statement' }
			{ include: 'prop_statement' }
			{ include: 'def_statement' }
			{ include: '@class_statement' }
			{ include: 'struct_statement' }
			{ include: 'tag_statement' }
			{ include: 'import_statement' }
			{ include: 'expressable'}
			{ include: 'expression'}
		]

		prop_statement: [
			[/(attr|prop)(\s)(@identifier)/, [{token: 'keyword.$1'},'white.propname',{token: 'identifier.propname'}]],
		]

		var_statement: [
			[/(@varKeyword)(?=\s)/, 'keyword.$1', '@var_decl.$1']
		]

		var_expr: [
			[/(@varKeyword)(?=\s)/, 'keyword.$1', '@single_var_decl.$1']
		]

		var_parens: [
			[/\)/, '$S2.close', '@pop']
			{include: 'var_decl'}
		]

		forin_statement: [
			[/for( own)? /, 'keyword.for', '@forin_var_decl.const']
		]

		def_statement: [
			[/(def|set|get)(\s)(@propertyPath\??)(\s)(?=\{|\w|\[|\.\.\.|\*)/, [{token: 'keyword.$1'},'white.propname',{token: 'identifier.$1.propname'},{token: 'white.params', next: '@implicit_params_decl.param'}]],
			[/(def|set|get)(\s)(@propertyPath\??)(\()/, [{token: 'keyword.$1'},'white.propname',{token: 'identifier.$1.propname'},{token: 'params.param.open', next: '@var_parens.param'}]],
			[/(def|set|get)(\s)(@propertyPath\??)/, [{token: 'keyword.$1'},'white.propname',{token: 'identifier.$1.propname'}]],
		]

		css_statement: [
			[/^(\t*)(local|global|export)(\s)(css)(?=\s|$)/, ['white',{token: 'keyword'},'white',{token: 'keyword.css', next: '@css_body.$1\t'}]],
			[/^(\t*)(css)(?=\s|$)/, ['white',{token: 'keyword.$2', next: '@css_body.$1\t'}]]
		]

		css_body: [
			[/^(\t*)(?=[^\t\n@newline])/,{cases: {
				'$1==$S2': {token: 'white',next:'css_body.$1\t'}
				'@default': { token: '@rematch', next: '@pop' }
			}}]
			{include: 'css_properties'}
		]

		css_selector: [
			# eolpop,
			# [/(\}|\)|\])/, { cases: {'$1==$S2': {token: '@rematch', next: '@pop'},'@default': 'invalid'}}],
			[/(\}|\)|\])/, {token: '@rematch', next: '@pop'}],
			[/@cssPropertyKey/,token: '@rematch',next:'@pop']
			[/(\%)((?:@anyIdentifier)?)/,['style.selector.mixin.prefix','style.selector.mixin']]
			[/(\@)(\.{0,2}[\w\-]*)/,['style.selector.modifier.prefix','style.selector.modifier']]
			[/\.([\w\-]+)/,'style.selector.class-name']
			[/\#([\w\-]+)/,'style.selector.id']
			[/([\w\-]+)/,'style.selector.element']
			[/(>+|~|\+)/,'style.selector.operator']
			[/(\*+)/,'style.selector.element.any']
			[/(\$)((?:@anyIdentifier)?)/,['style.selector.reference.prefix','style.selector.reference']]
			[/\&/,'style.selector.context']
			[/\(/,'delimiter.selector.parens.open','@css_selector_parens.)']
			[/\[/,'delimiter.selector.attr.open','@css_selector_attr.]']
			[/\s+/,'white']
			[/,/,'style.selector.delimiter']
			[/#(\s.+)?$/, 'comment']
			[/^/, token: '@rematch', next: '@pop']
		]
		css_selector_parens: [
			[/\)/, token: 'delimiter.selector.parens.close', next: '@pop']
			{include: '@css_selector'}
		]

		css_selector_attr: [
			[/\]/, token: 'delimiter.selector.parens.close', next: '@pop']
			{include: '@css_selector'}
		]

		css_properties: [
			[/(\}|\)|\])/, { cases: {
				'$1==$S2': {token: 'style.close', next: '@pop'},
				'@default': {token: 'invalid', next: '@pop'}
			}}],
			[/\s+/,'white']
			[/(?=@cssPropertyKey)/,token:'',next:'@css_property.$S2']
			[/(?=[\%\*\w\&\$\>\.\[\@\!]|\#[\w\-])/,token:'',next:'@css_selector.$S2']
			[/#(\s.+)?$/, 'comment']
		]

		css_property: [
			# [/(@anyIdentifier)(\.)/, ['style.property.scope','style.property.scope.delimiter']]
			[/(\d+)(@anyIdentifier)/, ['style.property.unit.number','style.property.unit.name']]
			[/((--|\$)@anyIdentifier)/, 'style.property.var']
			[/(-*@anyIdentifier)/, 'style.property.name']
			[/(\@+|\.+)(@anyIdentifier\-?)/, ['style.property.modifier.start','style.property.modifier']]
			# [/\@\@+(@anyIdentifier)/, 'style.property.scope.outer']
			# [/\@(@anyIdentifier)/, 'style.property.scope']
			# [/\.\.+(@anyIdentifier)/, 'style.property.scope.class.outer']
			# [/\.(@anyIdentifier)/, 'style.property.scope.class']
			[/\+(@anyIdentifier)/, 'style.property.scope']
			[/\s*([\:]\s*)/, token: 'style.property.operator',switchTo: '@css_value.$S2']
		]

		css_value: [
			eolpop,
			[/@cssPropertyKey/, token: '@rematch', next: '@pop'],
			[/;/, token: 'style.delimiter', next: '@pop'],
			[/(\}|\)|\])/, {token: '@rematch', next: '@pop'}],
			# [/(\}|\)|\])/, { cases: {'$1==$S2': {token: '@rematch', next: '@pop'}, '@default': 'invalid'}}],
			[/(x?xs|sm\-?|md\-?|lg|xl|\dxl)\b/, 'style.value.size'],
			[/\#[0-9a-fA-F]+/, 'style.value.color.hex'],
			[/((--|\$)@anyIdentifier)/, 'style.value.var']
			[/(@anyIdentifierOpt)(\@+|\.+)(@anyIdentifierOpt)/,['style.property.name','style.property.modifier.prefix','style.property.modifier']]
			# [/(@anyIdentifier)(\@+|\.+)(@anyIdentifierOpt)/,['style.property.name','style.property.modifier.prefix','style.property.modifier']]
			{ include: 'operators' }
			{ include: 'number' }
			{ include: 'string_start' }
			{ include: 'comments' }
			[/\s+/,'style.value.white']
			[/\(/, token: 'delimiter.style.parens.open', next: '@css_expressions.)']
			[/\{/, token: 'delimiter.style.curly.open', next: '@css_interpolation.}']
			[/(@anyIdentifier)/, 'style.value']
		]

		css_expressions: [
			[/\)/, token: 'delimiter.style.parens.close', next: '@pop']
			[/\(/, token: 'delimiter.style.parens.open', next: '@css_expressions.)']
			{include: '@css_value'}
		]

		css_interpolation: [
			[/\}/, token: 'delimiter.style.curly.close', next: '@pop']
			{include: '@expression'}
		]


		class_statement: [
			[/(class)(\s)(@anyIdentifier)(\s)(\<)(\s)(@tagNameIdentifier)/, ['keyword.class','white.classname',types.decl_class_name,'white','operator.extends','white','entity.other.inherited-class']],
			[/(class)(\s)(@anyIdentifier)/, [{token: 'keyword.$1'},'white.classname',types.decl_class_name]],
		]

		struct_statement: [
			# [/(struct)(\s)(@anyIdentifier)(\s)(\<)(\s)(@tagNameIdentifier)/, ['keyword.struct','white.classname',types.decl_class_name,'white','operator.extends','white','entity.other.inherited-class']],
			[/(struct)(\s)(@anyIdentifier)/, [{token: 'keyword.$1'},'white.classname',types.decl_class_name]],
		]
		
		tag_statement: [
			[/(tag)(\s)(@tagNameIdentifier)(\s)(\<)(\s)(@tagNameIdentifier)/, ['keyword.tag','white.tagname',types.decl_tag_name,'white','operator.extends','white','entity.other.inherited-tag']],
			[/(tag)(\s)(@tagNameIdentifier)/, [{token: 'keyword.$1'},'white.classname',types.decl_tag_name]],
		]

		import_body: [
			eolpop
			[/(\*)(\s+)(as)(\s+)(@esmIdentifier)/, ['keyword.star','white','keyword.as','white','variable.imports']],
			[/(@esmIdentifier)(\s+)(as)(\s+)(@esmIdentifier)/, ['alias','white','keyword.as','white','variable.imports']],
			[/from/, 'keyword.from'],
			[/\{/,'imports.open','@esm_specifiers.imports']
			[/(@esmIdentifier)/,'variable.imports'],
			{include: 'string_start'}
		]

		esm_specifiers: [
			[/\}/, '$S2.close', '@pop']
			[/(@esmIdentifier)(\s+)(as)(\s+)(@esmIdentifier)/, ['alias','white','keyword.as','white',{token: 'variable.$S2'}]]
			[/(@esmIdentifier)/, token: 'variable.$S2']
			[/\,/,'delimiter.comma']
		]

		import_statement: [
			[/(import)/,'keyword.import','@import_body.start']
		]

		object: [
			[/\{/, 'bracket.curly.open', '@object']
			[/\}/, 'bracket.curly.close', '@pop']
			[/(@identifier)/, 'identifier.key']
			[/\[/, 'bracket.square.open', '@object_dynamic_key']
			{ include: 'common' }
			{ include: 'string_start' }
			{ include: 'comments' }
			[/:/,'operator.assign.key','@object_value']
			[/\,/,'delimiter.comma']
		]

		object_dynamic_key: [
			[/\]/, 'bracket.square.close', '@pop']
			{include: 'expression'}
		]

		object_start: [
			[/\{/, 'bracket.curly.open', '@object']
		]

		array_start: [
			[/\[/, 'bracket.square.open', '@array']
		]

		array: [
			[/\]/, 'bracket.square.close', '@pop']
			[/\,/, 'delimiter']
			{include: 'expression'}
		]

		expressions: [
			[/\,/, 'delimiter.comma']
			{include: 'expression'}
			
		]

		var_object: [
			[/\{/, 'bracket.curly.open', '@var_object']
			[/\}/, 'delimiter.bracket.close', '@pop']
			[/(@constant)/, token: 'variable.$S2.constant']
			[/(@identifier)/, token: 'variable.$S2']
			[/\=/,'operator.eq','@object_value']
			{ include: 'common' }
			[/\,/,'delimiter.comma']
		]

		var_array: [
			[/\{/, 'bracket.curly.open', '@var_object']
			[/\}/, 'bracket.curly.close', '@pop']
			[/\[/, 'bracket.square.open', '@var_array']
			[/\]/, 'bracket.square.close', '@pop']
			[/(@constant)/, token: 'variable.$S2.constant']
			[/(@identifier)/, token: 'variable.$S2']
			{ include: 'common' }
			[/\,/,'delimiter.comma']
		]		

		object_value: [
			eolpop
			[/(?=,|\})/, 'delimiter', '@pop']
			{ include: 'expression' }
		]

		var_value: [
			eolpop
			[/(?=,|@newline|\))/, 'delimiter', '@pop']
			{ include: 'expression' }
		]

		var_decl: [
			eolpop
			[/(@constant)/, token: 'variable.$S2.constant']
			[/(@variable)/,token: 'variable.$S2']
			[/\s*(=)\s*(?=(for|while|until)\s)/,{token: 'operator', next: '@pop'}]
			[/\s*(=)\s*(?=new\s(@anyIdentifier)(\.@anyIdentifier)*\s+[^\,])/,{token: 'operator', next: '@pop'}]
			[/\s*(=)\s*/,'operator','@var_value']
			[/\{/,'bracket.curly.open','@var_object.$S2']
			[/\[/,'bracket.square.open','@var_array.$S2']
			[/(,)(@newline)/,['delimiter','newline']]
			[/,/,'delimiter.comma']
			[/@newline/, token: '@rematch', next: '@pop']
			[/(?=\n)/,'delimiter','@pop']
			{ include: 'spread' }
			{ include: 'common' }
			{ include: 'type_start' }
			{ include: 'comments' }
		]

		implicit_params_decl: [
			[/do(?=\s|@newline|$)/, token: 'keyword.blk', next: '@pop']
			{ include: 'var_decl' }
		]

		single_var_decl: [
			[/(?=[,\)\]\n]|@newline)/, 'delimiter', '@pop']
			{include: 'var_decl'}
		]

		forin_var_decl: [
			[/\s(in|of)/,'keyword','@pop']
			{include: 'var_decl'}
		]
		
		body: [
			{include: 'statements'}
			[/@newline/,'newline']
			[/(def|get|set)(?=\s)/, { token: 'keyword.$1', next: '@defstart.$1'}],
			[/(prop|attr)(?=\s)/, { token: 'keyword.$1', next: '@propstart.$1'}],

			[/([a-z]\w*)(:?(?!\w))/, {
				cases: {
					'$2': ['key.identifier','delimiter'],
					'this': 'this',
					'self': 'self',
					'$1@boolean': { token: 'boolean.$0' },
					'$1@keywords': { token: 'keyword.$0' },
					'$1@contextual_keywords': { token: 'identifier.$0' },
					'@default': ['identifier','delimiter']
				}
			}],
			[/\$\w+\$/, 'identifier.env'],
			[/\$\d+/, 'identifier.special'],
			[/\$[a-zA-Z_]\w*/, 'identifier.sys'],
			[/[A-Z][A-Za-z\d\-\_]*/, token: 'identifier.const'],
			[/[a-z_][A-Za-z\d\-\_]*/, token: 'identifier'],
			

			[/\(/, { token: 'bracket.parenthesis.open', next: '@parens' }],
			
			# whitespace
			{ include: '@whitespace' },
			{ include: '@comments' },

			[/(\:)([\@\w\-\_]+)/, ['symbol.start','symbol']],
			[/\$\d+/, 'entity.special.arg'],

			# regular expressions
			[/\/(?!\ )(?=([^\\\/]|\\.)+\/)/, { token: 'regexp.slash', bracket: '@open', next: '@regexp'}],

			# should drop this
			[/}/, { cases: {
						'$S2==interpolatedstring': { token: 'string.bracket.close', next: '@pop' },
						'@default': '@brackets' } }],
			[/[\{\}\(\)\[\]]/, '@brackets'],

			{ include: '@operators' },
			
			# numbers
			{ include: '@number' },
			# delimiter: after number because of .\d floats
			[/\,/, 'delimiter.comma'],
			[/\./, 'delimiter.dot']
		],
		js_comment: [
			[/###/, token: 'comment', next: '@pop', nextEmbedded: '@pop']
		]

		string_start: [
			[/"""/, 'string', '@herestring."""'],
			[/'''/, 'string', '@herestring.\'\'\''],
			[/"/, { token: 'string.open', next: '@string."' }],
			[/'/, { token: 'string.open', next: '@string.\'' }],
			[/\`/, { token: 'string.open', next: '@string.\`' }],
		],
		number: [
			[/0[xX][0-9a-fA-F_]+/, 'number.hex'],
			[/0[b][01_]+/, 'number.binary'],
			[/0[o][0-9_]+/, 'number.octal'],
			{ include: 'number_with_unit' }
			[/\d+[eE]([\-+]?\d+)?/, 'number.float'],
			[/\d[\d_]*\.\d[\d_]*([eE][\-+]?\d+)?/, 'number.float'],
			[/\d[\d_]*/, 'number.integer']
			[/0[0-7]+(?!\d)/, 'number.octal'],
			[/\d+/, 'number']
		],

		number_with_unit: [
			[/(\d+)([a-z]+|\%)/, ['number','unit']],
			[/(\d*\.\d+(?:[eE][\-+]?\d+)?)([a-z]+|\%)/, ['number.float','unit']]
		]
		
		operators: [
			{include: 'spread'}
			[/,/,'delimiter.comma']
			[/\&(?=[,\)])/,'operator.special.blockparam']
			[/@symbols/, { cases: {
				'@operators': 'operator',
				'@math': 'operator.math',
				'@logic': 'operator.logic',
				'@dot': 'operator.dot',
				'@default': 'delimiter'
			} }],
			[/\&\b/, 'operator']
		],
		whitespace: [
			[/[ \t\r\n]+/, 'white'],
		],

		comments: [
			[/###\s(css)/, {token: 'style.$1.open'}, '@style.$1'],
			[/###/, {token: 'comment.block.open'}, '@comment.block'],
			[/#(\s.+)?$/, 'comment'],
			[/\/\/([^\/].*)?$/, 'comment'],
		],

		comment: [
			[/[^#]+/, 'comment',]
			[/###/, {token: 'comment.$S2.close'}, '@pop']
			[/#/, 'comment']
		]

		style: [
			[/###/, {token: 'style.$S2.close'}, '@pop']
		]

		tag_start: [
			[/(<)(?=\.)/, 'tag.open','@tag.flag'],
			[/(<)(?=\.)/, 'tag.open','@tag.flag'],
			[/(<)(?=\w|\{|\[|\%|\#|>)/,'tag.open','@tag.name']
		]

		tag: [
			[/\/?>/,'tag.close','@pop']
			[/(\-?@tagIdentifier)(\:@anyIdentifier)?/,{token: 'tag.$S2'}]
			[/(\-?\d+)/,{token: 'tag.$S2'}]
			[/\.\(/,token: 'style.open.$S2', next: '@css_properties.)']
			[/(\%)(@anyIdentifier)/,['tag.mixin.prefix','tag.mixin']]
			[/(\#)(@anyIdentifier)/,['tag.id.prefix','tag.id']]

			[/\./,{ cases: {
				'$S2==event': {token: 'tag.event-modifier.start', switchTo: 'tag.event-modifier'}
				'$S2==event-modifier': {token: 'tag.event-modifier.start', switchTo: 'tag.event-modifier'}
				'$S2==modifier': {token: 'tag.modifier.start', switchTo: 'tag.modifier'}
				'$S2==rule': {token: 'tag.rule-modifier.start', switchTo: 'tag.rule-modifier'}
				'$S2==rule-modifier': {token: 'tag.rule-modifier.start', switchTo: 'tag.rule-modifier'}
				'@default': {token: 'tag.flag.start', switchTo: 'tag.flag'}
			}}]

			[/(\$?@anyIdentifier)/,{ cases: {
				'$S2==name': {token: 'tag.reference'}
				'@default': {token: 'tag.$S2'}
			}}]

			[/\{/,{token: 'tag.$S2.braces.open', next: '@tag_interpolation.$S2'}]
			[/\[/,token: 'style.open', next: '@css_properties.]']
			[/(\s*\=\s*)/,token: 'tag.operator.equals', next: 'tag_value.$S2']
			[/\:/,token: 'tag.event.start', switchTo: 'tag.event']
			[/\@/,token: 'tag.event.start', switchTo: 'tag.event']
			[/\{/,token: 'tag.$S2.braces.open', next: '@tag_interpolation.$S2']
			[/\(/,token: 'tag.parens.open.$S2', next: '@tag_parens.$S2']
			
			[/\s+/,token: 'white', switchTo: 'tag.attr']
			{include: 'comments'}
		]
		
		tag_interpolation: [
			[/\}/,token: 'tag.$S2.braces.close', next: '@pop']
			{include: 'expression'}
			[/\)|\]/,token: 'invalid']
		]

		tag_parens: [
			[/\)/,token: 'tag.parens.close.$S2', next: '@pop']
			{include: 'expression'}
			[/\]|\}/,token: 'invalid']
		]

		tag_data: [
			[/\]/,token: 'tag.data.close', next: '@pop']
			{include: 'expression'}
			[/\)|\]|\}/,token: 'invalid']
		]

		tag_singleton_ref: [
			[/\#(-*[a-zA-Z][\w\-]*)+/, 'tag.singleton.ref']
		],
		tag_value: [
			[/(?=(\/?\>|\s))/, { token: '', next: '@pop' }],
			{include: 'tag_value_expression'}
		],

		

		braces: [
			['}', { token: 'brace.close', next: '@pop' }],
			{ include: 'body' }
		],
		brackets: [
			[']', { token: 'bracket.close', next: '@pop' }],
			{ include: 'body' }
		],

		declstart: [
			[/^./, token: '@rematch', next: '@pop'],
			[/[A-Z][A-Za-z\d\-\_]*/, token: 'identifier.decl.$S2'],
			[/\./, token: 'delimiter.dot'],
			[/[a-z_][A-Za-z\d\-\_]*/, token: 'identifier.decl.$S2'],
			[/[ \t\<\>]+/, 'operator.inherits string']
		],

		defstart: [
			[/(self)\./, token: 'identifier.decl.def.self'],
			[/@methodName/, token: 'identifier.decl.def', next: '@pop'],
			[/^./, token: '@rematch', next: '@pop'],
		],

		propstart: [
			[/@identifier/, token: 'identifier.decl.$S2', next: '@pop'],
			[/^./, token: '@rematch', next: '@pop'],
		],
		
		string: [
			[/[^"'\`\{\\]+/, 'string'],
			[/@escapes/, 'string.escape'],
			[/\./, 'string.escape.invalid'],
			[/\{/, { cases: {
				'$S2=="': { token: 'string.bracket.open', next: 'root.interpolatedstring' },
				'$S2==\`': { token: 'string.bracket.open', next: 'root.interpolatedstring' },
				'@default': 'string'
			}}],
			[/["'`]/, { cases: { '$#==$S2': { token: 'string.close', next: '@pop' }, '@default': 'string' } }],
			[/#/, 'string']
		],
		herestring: [
			[/("""|''')/, { cases: { '$1==$S2': { token: 'string', next: '@pop' }, '@default': 'string' } }],
			[/[^#\\'"\{]+/, 'string'],
			[/['"]+/, 'string'],
			[/@escapes/, 'string.escape'],
			[/\./, 'string.escape.invalid'],
			[/\{/, { cases: { '$S2=="""': { token: 'string', next: 'root.interpolatedstring' }, '@default': 'string' } }],
			[/#/, 'string']
		],
		
		hereregexp: [
			[/[^\\\/#]/, 'regexp'],
			[/\\./, 'regexp'],
			[/#.*$/, 'comment'],
			['///[igm]*', { token: 'regexp', next: '@pop' }],
			[/\//, 'regexp'],
		],

		regexp_start: [
			[/\/(?!\ )(?=([^\\\/]|\\.)+\/)/, { token: 'regexp.slash.open', bracket: '@open', next: '@regexp'}]
			[/\/\/\//, { token: 'regexp.slash.open', bracket: '@open', next: '@hereregexp'}]
		]
		
		regexp: [
			[/(\{)(\d+(?:,\d*)?)(\})/, ['regexp.escape.control', 'regexp.escape.control', 'regexp.escape.control'] ],
			[/(\[)(\^?)(?=(?:[^\]\\\/]|\\.)+)/, ['regexp.escape.control',{ token: 'regexp.escape.control', next: '@regexrange'}]],
			[/(\()(\?:|\?=|\?!)/, ['regexp.escape.control','regexp.escape.control'] ],
			[/[()]/,        'regexp.escape.control'],
			[/@regexpctl/,  'regexp.escape.control'],
			[/[^\\\/]/,     'regexp' ],
			[/@regexpesc/,  'regexp.escape' ],
			[/\\:/,     'regexp.escape' ],
			[/\\\./,        'regexp.invalid' ],
			[/(\/)(\w+)/, [{ token: 'regexp.slash.close'},{token: 'regexp.flags', next: '@pop'}] ],
			['/', { token: 'regexp.slash.close', next: '@pop'}],
			[/./,        'regexp.invalid' ],
		],

		regexrange: [
			[/-/,     'regexp.escape.control'],
			[/\^/,    'regexp.invalid'],
			[/@regexpesc/, 'regexp.escape'],
			[/[^\]]/, 'regexp'],
			[/\]/,    'regexp.escape.control', '@pop'],
		],
	}
}