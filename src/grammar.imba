
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
		{ open: '{', close: '}', token: 'delimiter.curly' },
		{ open: '[', close: ']', token: 'delimiter.square' },
		{ open: '(', close: ')', token: 'delimiter.parenthesis' }
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
		'^=', '%=', '<<=', '>>=', '>>>=','..','...','||='
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
	constant: /[A-Z][A-Za-z\d\-\_]*/
	className: /[A-Z][A-Za-z\d\-\_]*|[A-Za-z\d\-\_]+/
	methodName: /[A-Za-z\_][A-Za-z\d\-\_]*\=?/
	identifier: /[a-z_][A-Za-z\d\-\_]*/
	anyIdentifier: /[A-Za-z_\$][A-Za-z\d\-\_\$]*/
	esmIdentifier: /\@?[A-Za-z_\$][A-Za-z\d\-\_\$]*/
	propertyPath: /(?:[A-Za-z_\$][A-Za-z\d\-\_\$]*\.)?(?:[A-Za-z_\$][A-Za-z\d\-\_\$]*)/
	tagNameIdentifier: /(?:[\w\-]+\:)?\w+(?:\-\w+)*/
	variable: /[\w\$]+(?:-[\w\$]*)*/
	varKeyword: /var|let|const/
	newline: RegExp.new(newline)
	tagIdentifier: /-*[a-zA-Z][\w\-]*/
	
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
			{ include: 'style_declaration' }
			{ include: 'identifiers' }
			{ include: 'tag_start' },
			{ include: 'string_start' }
			{ include: 'regexp_start' }
			{ include: 'object_start' }
			{ include: 'array_start' }
			{ include: 'parens_start' }
			{ include: 'number_with_unit' }
			{ include: 'number' }
			{ include: 'comments' }
			{ include: 'common' }
			{ include: 'operators' }
			{ include: 'decorator' }
			{ include: 'parens_start' }
		]

		parens_start: [
			[/\(/, 'delimiter.parens.open', '@parens']
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
			[/\)/, 'delimiter.parens.close', '@pop']
			{include: 'var_expr'}
			{include: 'expression'}
			[/\,/, 'delimiter']
		]

		statements: [
			{ include: 'var_statement' }
			{ include: 'forin_statement' }
			{ include: 'prop_statement' }
			{ include: 'def_statement' }
			{ include: 'css_statement' }
			{ include: '@class_statement' }
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
			[/for( own)? /, 'keyword.for', '@forin_var_decl.let']
		]

		def_statement: [
			[/(def|set|get)(\s)(@propertyPath\??)(\s)(?=\{|\w|\[|\.\.\.|\*)/, [{token: 'keyword.$1'},'white.propname',{token: 'identifier.$1.propname'},{token: 'white.params', next: '@implicit_params_decl.param'}]],
			[/(def|set|get)(\s)(@propertyPath\??)(\()/, [{token: 'keyword.$1'},'white.propname',{token: 'identifier.$1.propname'},{token: 'params.param.open', next: '@var_parens.param'}]],
			[/(def|set|get)(\s)(@propertyPath\??)/, [{token: 'keyword.$1'},'white.propname',{token: 'identifier.$1.propname'}]],
		]

		css_statement: [
			[/^(\t*)(css)(\s)/, ['white',{token: 'keyword.$2'},{token: 'white', next: '@indented_style_selector.$1\t'}]],
		]

		indented_style_body: [
			[/^(\t*)(?=[^\{\t]*&)/,{cases: {
				'$1==$S2': {token: 'white',next:'indented_style_selector.$1\t'}
				'@default': { token: '@rematch', next: '@pop' }
			}}]
			[/^(\t*)(?=[^\t\n@newline])/, {
				cases: {
					'$1==$S2': 'still-here',
					'@default': { token: '@rematch', next: '@pop' }
				}
			}]
			{include: 'style_properties'}
		]

		indented_style_selector: [
			[/\=/,{token: 'style.start-operator',switchTo: 'indented_style_body.$S2'}]
			[/\{/,{token: 'style.open',switchTo: 'style_properties.}'}]
			[/^/,{token: '@rematch', switchTo: '@indented_style_body.$S2'}]
			[/\:([\w\-]+)/,'style.selector.pseudostate']
			[/\.([\w\-]+)/,'style.selector.class-name']
			[/([\w\-]+)/,'style.selector.element']
			[/(>|~|\+)/,'style.selector.operator']
			[/\&/,'style.selector.context']
			[/[^\{\=]+/,'style.selector.name']
			# push into [ and (
		]

		class_statement: [
			[/(class)(\s)(@anyIdentifier)(\s)(\<)(\s)(@tagNameIdentifier)/, ['keyword.class','white.classname',types.decl_class_name,'white','operator.extends','white','entity.other.inherited-class']],
			[/(class)(\s)(@anyIdentifier)/, [{token: 'keyword.$1'},'white.classname',types.decl_class_name]],
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
			[/\,/,'delimiter']
		]

		import_statement: [
			[/(import)/,'keyword.import','@import_body.start']
		]

		object: [
			[/\{/, 'delimiter.bracket.open', '@object']
			[/\}/, 'delimiter.bracket.close', '@pop']
			[/(@identifier)/, 'identifier.key']
			{ include: 'common' }
			{ include: 'string_start' }
			{ include: 'comments' }
			[/:/,'delimiter.object.value','@object_value']
			[/\,/,'delimiter']
		]

		object_start: [
			[/\{/, 'delimiter.bracket.open', '@object']
		]

		array_start: [
			[/\[/, 'array.open', '@array']
		]

		array: [
			[/\]/, 'array.close', '@pop']
			[/\,/, 'delimiter']
			{include: 'expression'}
		]

		expressions: [
			[/\,/, 'delimiter']
			{include: 'expression'}
			
		]

		var_object: [
			[/\{/, 'object.open', '@var_object']
			[/\}/, 'object.close', '@pop']
			[/(@identifier)/, token: 'variable.$S2']
			{ include: 'common' }
			[/\,/,'delimiter']
		]

		var_array: [
			[/\{/, 'object.open', '@var_object']
			[/\}/, 'object.close', '@pop']
			[/\[/, 'array.open', '@var_array']
			[/\]/, 'array.close', '@pop']
			[/(@identifier)/, token: 'variable.$S2']
			{ include: 'common' }
			[/\,/,'delimiter']
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
			[/(@variable)/,token: 'variable.$S2']
			[/\s*(=)\s*/,'operator','@var_value']
			[/\{/,'object.open','@var_object.$S2']
			[/\[/,'array.open','@var_array.$S2']
			[/,/,'delimiter']
			[/(,)(@newline)/,['delimiter','newline']]
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
			

			[/\(/, { token: 'paren.open', next: '@parens' }],
			
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
			[/\d+[eE]([\-+]?\d+)?/, 'number.float'],
			[/\d+\.\d+([eE][\-+]?\d+)?/, 'number.float'],
			[/0[xX][0-9a-fA-F]+/, 'number.hex'],
			[/0[0-7]+(?!\d)/, 'number.octal'],
			[/\d+/, 'number'],
		],

		number_with_unit: [
			[/(\d+)([a-z]+|\%)/, ['number','unit']],
			[/(\d*\.\d+(?:[eE][\-+]?\d+)?)([a-z]+|\%)/, ['number.float','unit']]
		]
		
		operators: [
			{include: 'spread'}
			[/,/,'delimiter']
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
			[/\/\/(.+)$/, 'comment'],
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
			[/(<)(?=\w|\{|>)/,'tag.open','@tag.name']
		]

		tag: [
			[/>/,'tag.close','@pop']
			[/(\-?@tagIdentifier)(\:@anyIdentifier)?/,{token: 'tag.$S2'}]
			[/(\-?\d+)/,{token: 'tag.$S2'}]

			[/\.\(/,token: 'style.open.$S2', next: '@style_properties.)']

			[/(\$|\s)\(/,token: 'style.open.$S2', next: '@style_properties.)']

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

			[/\$?{/,{ cases: {
				'$S2==attr': {token: 'style.open', next: '@style_properties.}'}
				'@default': {token: 'tag.$S2.braces.open', next: '@tag_interpolation.$S2'}
			}}]

			[/\[/,{ cases: {
				'$S2==name': {token: 'tag.data.open', next: '@tag_data'}
				# '$S2==attr': {token: 'style.open', next: '@style_properties.]'}
				'@default': {token: 'tag.data.open', next: '@tag_data'}
			}}]
			
			[/(\s*\=\s*)/,token: 'tag.operator.equals', next: 'tag_value.$S2']
			[/\:/,token: 'tag.rule.start', switchTo: 'tag.rule']
			[/\@/,token: 'tag.event.start', switchTo: 'tag.event']
			[/\{/,token: 'tag.$S2.braces.open', next: '@tag_interpolation.$S2']
			[/\(/,token: 'tag.parens.open.$S2', next: '@tag_parens.$S2']
			
			[/\s+/,token: 'white', switchTo: 'tag.attr']
			{include: 'comments'}
			[/\@(@tagIdentifier)/,token: 'tag.reference']
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
			[/(?=(\>|\s))/, { token: '', next: '@pop' }],
			{include: 'tag_value_expression'}
		],

		style_declaration: [
			[/\.\{/,token: 'style.open.$S2', next: '@style_properties.}']
		]

		style_properties: [
			[/(\}|\)|\])/, { cases: {
					'$1==$S2': {token: 'style.close', next: '@pop'},
					'@default': 'invalid'
			}}],
			{ include: 'comments'}
			{ include: 'style_property'}
			[/([\:]\s*)/, 'style.property.operator','@style_value']
			[/\s+/, 'style.whitespace']
			[/[\;]/, 'style.delimiter']
		]

		style_property: [
			[/(@anyIdentifier)\|/, 'style.property.scope']
			[/(--@anyIdentifier)/, 'style.property.var']
			[/(-*@anyIdentifier)/, 'style.property.name']
			[/\@(@anyIdentifier)/, 'style.property.mixin']
			[/\.(@anyIdentifier)/, 'style.property.scope']
		]

		style_value: [
			eolpop,
			[/\s([\$\w\-]+(\.[\w\-]+)*[\:\=])/, token: '@rematch', next: '@pop'],
			[/[;\)\}\]]/, token: '@rematch', next: '@pop'],
			[/(xs|sm|md|lg|xl|\dxl)\b/, 'style.value.size'],
			[/(--@anyIdentifier)/, 'style.value.var']
			{ include: 'number_with_unit' }
			{ include: 'operators' }
			{ include: 'number' }
			{ include: 'string_start' }
			{ include: 'comments' }
			[/\(/, token: 'delimiter.style.parens.open', next: '@style_expressions.)']
			[/(@anyIdentifier)/, 'style.value']
		]

		style_expressions: [
			[/\)/, token: 'delimiter.style.parens.close', next: '@pop']
			[/\(/, token: 'delimiter.style.parens.open', next: '@style_expressions.)']
			{include: '@style_value'}
		]

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