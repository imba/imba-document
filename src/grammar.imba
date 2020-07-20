
const newline = String.fromCharCode(172)

# var eolpop = [/@newline/, token: '@rematch', next: '@pop']
var eolpop = [/^/, token: '@rematch', next: '@pop']

export var types =
	decl_class_name: 'entity.name.type.class'
	decl_tag_name: 'entity.name.type.class'
	decl_prop_name: 'entity.name.type.property'
	decl_def_name: 'entity.name.function'

const repop = { token: '@rematch', next: '@pop',_pop:'pop'}
const toodeep = {token: 'white.indent',next: '@illegal_indent.$S2\t'}

def denter indent,outdent,stay
	if indent == null
		indent = toodeep

	elif indent == 1
		indent = {next: '@$S1.$S2\t.$S3.$S4'}

	if outdent == -1
		outdent = repop
	if stay == -1
		stay = repop
	elif stay == 0
		stay = {}

	indent = Object.assign({token: 'white.indent'},indent or {})
	stay = Object.assign({token: 'white'},stay or {})
	outdent = Object.assign({ token: '@rematch', next: '@pop'},outdent or {})

	[/^(\t*)(?=[^\t\n@newline])/,{cases: {
		'$1==$S2\t': indent
		'$1==$S2': stay
		'@default': outdent
	}}]

def identifiers reg,o = {}
	let c = do Object.assign({},o,$1)
	[reg,cases: {
		'this': c(token: 'this')
		'self': c(token: 'self')
		'@keywords': c(token: 'keyword.$#')
		'$1~[A-Z]': c(token: "identifier.uppercase.$S5")
		'@default': c(token: "identifier.$S5")
	}]

export var states = {

	root: [
		['','','@body.']
	]

	illegal_indent: [
		denter()
	]

	identifier_: [
		[/\$\w+\$/, 'identifier.env']
		[/\$\d+/, 'identifier.special']
		# [/(@constant)/, 'identifier.constant.$S4']
		[/@anyIdentifierPre([\?\!]?)/,cases: {
			'this': 'this',
			'self': 'self',
			'@keywords': {token: 'keyword.$#'},
			'$1~[A-Z].*': {token: 'identifier.uppercase.$S5'}
			'@default': {token: 'identifier.$S5'}
		}]
	]

	body: [
		[/^(\t+)(?=[^\t\n@newline])/,{cases: {
			'$1==$S2\t': {token: 'white.indent',next: '@illegal_indent.$S2\t', log: "indent!!$S0|"}
			'@default': { token: 'white.indent' }
		}}]
		'block_'
	]

	block_: [
		'common_'
		'class_'
		'tagclass_'
		'var_'
		'import_'
		'flow_'
		'for_'
		'try_'
		'catch_'
		'while_'
		'css_'
		'do_'
		'expr_'
	]

	block: [
		denter('@block.$S2\t.$S3.$S4',-1,0)
		'block_'
	]

	bool_: [
		[/(true|false|yes|no|undefined|null)(?![\:\-\w\.\_])/,'boolean']
	]

	op_: [
		[/\&(?=[,\)])/,'operator.special.blockparam']
		[/@symbols/, { cases: {
			'@operators': 'operator'
			'@math': 'operator.math'
			'@logic': 'operator.logic'
			'@dot': 'operator.dot'
			'@default': 'delimiter'
		} }]
		[/\&\b/, 'operator']
	]

	value_: [
		'string_'
		'number_'
		'regexp_'
		'bool_'
		'implicit_call_'
		'call_'
		'access_'
		'identifier_'
		'array_'
		'object_'
		'parens_'
	]

	expr_: [
		'inline_var_'
		'value_'
		'comment_'
		'tag_'
		'op_'
		'type_'
		'spread_'
	]
	
	attr_expr_: [
		'string_'
		'number_'
		'regexp_'
		'bool_'
		'call_'
		'access_'
		'identifier_'
		'array_'
		'object_'
		'parens_'
		'comment_'
		'tag_'
		'op_'
	]

	access_: [
		[/(\.)(@anyIdentifier\??)/,cases: {
			'$2~[A-Z].*': ['operator.dot','access.uppercase']
			'@default': ['operator.dot','access']
		}]
	]

	call_: [
		[/\(/, '$#', '@call_body.$S2.$1.$S4']
	]

	implicit_call_: [
		[/(\.)(@anyIdentifier\??)@implicitCall/,cases: {
			'$2~[A-Z].*': ['operator.dot','access.uppercase','@implicit_call_body.$S2']
			'@default': ['operator.dot','access','@implicit_call_body.$S2']
		}]
		[/(@anyIdentifier\??)@implicitCall/,cases: {
			'$2~[A-Z].*': ['identifier.uppercase.$S5','@implicit_call_body.$S2']
			'@default': ['identifier.$S5','@implicit_call_body.$S2']
		}]
	]

	call_body: [
		[/\)/, '$#', '@pop']
		'arglist_'
	]
	implicit_call_body: [
		eolpop
		'arglist_'
	]

	arglist_: [
		'do_'
		'expr_'
		[/\s*\,\s*/,'delimiter.comma']
	]

	# not for 
	implicit_call2_: [
		[/@anyIdentifierPre([\?\!]?)/]
	]

	params_: [
		[/\[/, '$#', '@array_body.$S2.param.$S4.param']
		[/\{/, '$#', '@object_body.$S2.param.$S4.param']
		[/(@variable)/,token: 'identifier.param']
		# [/(\s*\=\s*)(?=(for|while|until|if|unless)\s)/,'operator','@pop']
		[/(\s*\=\s*)/,'operator','@var_value.$S2.$S3.$S4']
		[/\s*\,\s*/,'separator']
	]

	object_: [
		[/\{/, '$#', '@object_body.$S2.$1.$S4']
	]

	parens_: [
		[/\(/, '$#', '@parens_body.$S2.$1.$S4']
	]

	parens_body: [
		[/\)/, '$#', '@pop']
		'arglist_'
	]

	array_: [
		[/\[/, '$#', '@array_body.$S2.$1.$S4']
	]

	array_body: [
		[/\]@implicitCall/, token: '$#', switchTo: '@implicit_call_body.$S2.$1.$S4']
		[/\]/, '$#', '@pop']
		'expr_'
		[',','delimiter']
	]

	object_body: [
		[/\}/, '$#', '@pop']
		[/(@anyIdentifier)(\s*:\s*)(@anyIdentifier)/, ['identifier.key','operator.assign.key','identifier.key.$S5']]
		[/(@identifier)/, 'identifier.key.$S5']
		[/\[/, '$#', '@object_dynamic_key.$S2.$S3.$S4']
		[/\s*=\s*/,'operator.assign.key','@object_value.$S2.$S3.$S4']
		[/:/,'operator.assign.key','@object_value.$S2.$S3.$S4']
		[/\,/,'delimiter.comma']
		'expr_'
	]

	object_value: [
		eolpop
		[/(?=,|\})/, 'delimiter', '@pop']
		'expr_'
	]

	object_dynamic_key: [
		# [']',token: '$$',switchTo: '@$S3_params.$S2.$S3.$S4']
		[']','$#','@pop']
		'expr_'
	]

	comment_: [
		[/#(\s.+)?$/, 'comment']
	]

	block_comment_: [
		[/###/, 'comment.start','@_block_comment.$S2']
	]

	_block_comment: [
		[/###/,'commend.end','@pop']
		[/\./,'comment']
	]

	# add try_start that accepts catch on the same line?
	try_: [
		[/try@B/,'keyword.try','@_try.$S2\t']
	]

	catch_: [
		[/(catch)(\s+)(@anyIdentifier)/, ['keyword.$1','white','identifier.const','@_catch.$S2\t']]
		[/catch@B/,'keyword.catch','@_catch.$S2\t']
	]

	_catch: [
		denter('@block.$S2\t.$S3.$S4',-1,0)
		'block_'
	]

	_try: [
		denter('@block.$S2\t.$S3.$S4',-1,0)
		'block_'
	]

	do_: [
		[/(do)(\()/,['keyword.do','$2','@_do_params.$S2\t']]
		[/do@B/,'keyword.$#','@_do.$S2\t']
	]

	_do_params: [
		[/\)/,'$#',switchTo: '@_do.$S2']
		'params_'
	]

	_do: [
		denter(null,-1,0)
		'block_'
	]

	class_: [
		[/(export|extend)(?=\s+class )/,'keyword.$#']
		[/(class)(\s)(@anyIdentifier)/, ['keyword.$1','white.$1name','const.$1','@class_start.$S2.$1.$S4']]
	]

	class_start: [
		[/(\s+\<\s+)(@anyIdentifier)/,['keyword.extends','identifier.superclass']]
		[/#(\s.+)?$/, 'comment']
		denter({switchTo: '@_class.$S2\t.$S3.$S4'},-1,-1)
	]

	tagclass_: [
		[/(export|extend)(?=\s+tag )/,'keyword.$#']
		[/(tag)(\s)(@anyIdentifier)/, ['keyword.tag','white.tagname','const.$1','@tagclass_start.$S2.$1.$S4']]
	]

	tagclass_start: [
		[/(\s+\<\s+)(@anyIdentifier)/,['keyword.extends','identifier.superclass']]
		[/#(\s.+)?$/, 'comment']
		denter({switchTo: '@_tagclass.$S2\t.$S3.$S4'},-1,-1)
	]

	import_: [
		[/(import)(?=\s+['"])/,'keyword.import','@import_source.$S2.$1']
		[/(import|export)@B/,'keyword.import','@import_body.$S2.$1']
	]

	import_body: [
		eolpop # use denter
		[/(\*)(\s+as\s+)(@esmIdentifier)/, ['keyword.star','keyword.as','identifier.const.import']]
		[/(@esmIdentifier)(\s+as\s+)(@esmIdentifier)/, ['alias','keyword.as','identifier.const.import']]
		[/from/, 'keyword.from',switchTo: '@import_source.$S2']
		[/\{/,'imports.open','@esm_specifiers.$S2.imports']
		[/(@esmIdentifier)/,'identifier.const.import']
	]

	esm_specifiers: [
		[/\}/, '$S2.close', '@pop']
		[/(@esmIdentifier)(\s+as\s+)(@esmIdentifier)/, ['alias','keyword.as',{token: 'identifier.const.import'}]]
		[/(@esmIdentifier)/, token: 'identifier.const.$S2']
		[/\s*\,\s*/,'delimiter.comma']
	]

	import_source: [
		denter(null,-1,-1)
		'string_'
	]

	css_: [
		[/global(?=\s+css )/,'keyword.$#']
		[/(css)@B/, ['keyword.$1','@_css.$S2\t.$1.$S4']]
	]

	css_start: [
		denter({switchTo: '@_css.$S2\t.$S3.$S4'},-1,-1)
	]

	_css: [
		denter(null,-1,0)
		[/\s+/,'white']
		[/(?=@cssPropertyKey)/,token:'',next:'@css_property.$S2']
		[/(?=[\%\*\w\&\$\>\.\[\@\!]|\#[\w\-])/,token:'',next:'@css_selector.$S2']
		[/#(\s.+)?$/, 'comment']
		'expr_'
	]

	css_inline: [
		[/\]/,'style.close','@pop']
		[/(?=@cssPropertyKey)/,token:'',next:'@css_property.$S2']
	]
	
	def_: [
		[/static(?=\s+(get|set|def) )/,'keyword.$#']
		[/(def|get|set)(\s)(@anyIdentifier)/, ['keyword.$1','white','entity.$$','@$1_params.$S2.$1.$S4']]
		[/(def|get|set)(\s)(\[)/, ['keyword.$1','white','$$','@def_dynamic_name.$S2.$1.$S4']]
	]
	
	flow_: [
		# [/(else)(?=\s|$)/, ['keyword.$1','@flow_start.$S2.flow.$S4']]
		[/(if|else|elif|unless)(?=\s|$|@newline)/, ['keyword.$1','@flow_start.$S2.flow.$S4']]
	]

	for_: [
		[/for@B/,'keyword.$#','@for_start.$S2.let']
	]

	while_: [
		[/(while|until)@B/,'keyword.$#','@while_body.$S2\t']
	]
	while_body: [
		denter(null,-1,0)
		'block_'
	]

	for_start: [
		denter({switchTo: '@for_body.$S2\t..$S4'},-1,-1)
		[/\[/, '$#', '@array_body.$S2.$1.$S4.$S3']
		[/\{/, '$#', '@object_body.$S2.$1.$S4.$S3']
		[/(@variable)/,token: 'identifier.$S3']
		[/(\s*\,\s*)/,token: 'separator']
		[/\s(in|of)@B/,'keyword',switchTo: '@for_source.$S2..$S4']
	]
	for_source: [
		denter({switchTo: '@for_body.$S2\t.$S3.$S4'},-1,-1)
		'expr_'
	]

	for_body: [
		denter(null,-1,0)
		'block_'
	]

	decorator_: [
		[/(\@@anyIdentifier)(\()/,['decorator','$2','@_decorator_params.$S2']]
		[/(\@@anyIdentifier)/,'decorator']
	]

	_decorator_params: [
		[/\)/,'$#','@pop']
		'params_'
	]

	field_: [
		[/static(?=\s+@anyIdentifier)/,'keyword.static']
		[/(@anyIdentifier\??)(?=@newline|$)/,'field']
		[/(@anyIdentifier\??)/,['field','@_field_1.$S2.0']]
	]

	_field_1: [
		denter(null,-1,-1)
		'type_'
		[/(\s*=\s*)/,['operator.assign','@_field_value.$S2\t.0']]
	]

	_field_value: [
		denter(null,-1,0)
		'block_' # sure?
	]

	var_: [
		[/((?:export )?)(const|let)(?=\s|$)/, ['keyword.export','keyword.$1','@$2_body.$S2.$2.$S4']]
	]

	inline_var_: [
		[/(const|let)(?=\s|$)/, ['keyword.$1','@inline_var_body.$S2.$1.$S4']]
	]

	string_: [
		[/"""/, 'string', '@_herestring.$S2."""']
		[/'''/, 'string', '@_herestring.$S2.\'\'\'']
		[/"/, 'string.open','@_string.$S2.".$S4']
		[/'/, 'string.open','@_string.$S2.\'.$S4']
		[/\`/,'string.open','@_string.$S2.\`.$S4']
	]

	number_: [
		[/0[xX][0-9a-fA-F_]+/, 'number.hex']
		[/0[b][01_]+/, 'number.binary']
		[/0[o][0-9_]+/, 'number.octal']
		[/(\d+)([a-z]+|\%)/, ['number','unit']]
		[/(\d*\.\d+(?:[eE][\-+]?\d+)?)([a-z]+|\%)/, ['number.float','unit']]
		[/\d+[eE]([\-+]?\d+)?/, 'number.float']
		[/\d[\d_]*\.\d[\d_]*([eE][\-+]?\d+)?/, 'number.float']
		[/\d[\d_]*/, 'number.integer']
		[/0[0-7]+(?!\d)/, 'number.octal']
		[/\d+/, 'number']
	]

	_string: [
		[/[^"'\`\{\\]+/, 'string']
		[/@escapes/, 'string.escape']
		[/\./, 'string.escape.invalid']
		[/\{/, cases: {
			'$S3==\'': 'string'
			'@default': { token: 'string.bracket.open', next: '@interpolation_body.$S2.$S3.$S4' }
		}]
		[/["'`]/, { cases: { '$#==$S3': { token: 'string.close', next: '@pop' }, '@default': 'string' } }]
		[/#/, 'string']
	]

	_herestring: [
		[/("""|''')/, { cases: { '$1==$S2': { token: 'string', next: '@pop' }, '@default': 'string' } }],
		[/[^#\\'"\{]+/, 'string'],
		[/['"]+/, 'string'],
		[/@escapes/, 'string.escape'],
		[/\./, 'string.escape.invalid'],
		[/\{/, { cases: { '$S2=="""': { token: 'string', next: '@interpolation_body.$S2.$S3.$S4' }, '@default': 'string' } }],
		[/#/, 'string']
	]

	interpolation_body: [
		[/\}/, { cases: {
			'@default': {token: 'string.bracket.close', next: '@pop'}
		}}]
		'value_'
	]

	_class: [
		denter(toodeep,-1,0)
		'css_'
		'def_'
		'comment_'
		'field_'
		'decorator_'
	]

	_tagclass: [
		'_class'
		
	]

	def_params: [
		denter({switchTo: '@_$S3.$S2\t.$S3.$S4'},-1,-1)
		[/\[/, '$#', '@array_body.$S2.param.$S4.param']
		[/\{/, '$#', '@object_body.$S2.param.$S4.param']
		[/(@variable)/,token: 'identifier.param']
		'spread_'
		# [/(\s*\=\s*)(?=(for|while|until|if|unless)\s)/,'operator','@pop']
		[/(\s*\=\s*)/,'operator','@var_value.$S2.$S3.$S4']
		[/\s*\,\s*/,'separator']
	]

	def_dynamic_name: [
		[']',token: 'square.close',switchTo: '@$S3_params.$S2.$S3.$S4']
		'expr_'
	]

	_def: [
		denter(toodeep,-1,0)
		'block_'
	]

	get_params: [
		'def_params'
	]

	_get: [
		[/(one)/,'keyword']
		'_def'
	]

	set_params: [
		'def_params'
	]

	_set: [
		'_def'
	]

	flow_start: [
		denter({switchTo: '@$S3_body.$S2\t.$S3.$S4'},-1,-1)
		'expr_'
	]

	flow_body: [
		denter(toodeep,-1,0)
		'block_'
	]

	var_body: [
		denter(1,-1,-1)
		[/\[/, '$#', '@array_body.$S2.$1.$S4.$S3']
		[/\{/, '$#', '@object_body.$S2.$1.$S4.$S3']
		[/(@variable)/,token: 'identifier.$S3']
		[/(\s*\,\s*)/,token: 'separator']
		[/(\s*\=\s*)(?=(for|while|until|if|unless)\s)/,'operator','@pop']
		[/(\s*\=\s*)/,'operator','@var_value.$S2.$S3.$S4']
		# [/(\s+)(?=\w\[\'\"])/,'white','@pop']
	]

	inline_var_body: [
		[/\[/, '$#', '@array_body.$S2.$1.$S4.$S3']
		[/\{/, '$#', '@object_body.$S2.$1.$S4.$S3']
		[/(@variable)/,token: 'identifier.$S3']
		[/(\s*\=\s*)/,'operator',switchTo: '@var_value.$S2.$S3.$S4']
	]

	const_body: ['var_body']
	let_body: ['var_body']

	var_value: [
		[/(?=,|\))/, 'delimiter', '@pop']
		# eolpop
		# [/(?=,|@newline|\))/, 'delimiter', '@pop']
		denter({switchTo: '@block.$S2\t.$S3.$S4'},-1,-1)
		# denter({switchTo: 1},-1,-1)
		'expr_'
	]

	common_: [
		'@whitespace'
	]

	spread_: [
		[/\.\.\./,'operator.spread']
	]

	type_: [
		[/\\/, 'type.start','@_type.$S2.0']
	]

	_type: [
		denter(null,-1,-1)
		[/\[/,'type.$#','@_type.$S2.]']
		[/\(/,'type','@_type.$S2.)']
		[/\{/,'type','@_type.$S2.}']
		[/\</,'type','@_type.$S2.>']
		[/\,|\s/,{
			cases: {
				'$S3==0': { token: '@rematch', next: '@pop' }
				'@default': 'type'
			}
		}]
		[/[\]\}\)\>]/,{
			cases: {
				'$#==$S3': { token: 'type', next: '@pop' }
				'@default': { token: '@rematch', next: '@pop' }
			}
		}]
		[/[\w\-\$]+/,'type']
	]

	css_selector: [
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
		[/\(/,'delimiter.selector.parens.open','@css_selector_parens.$S2.)']
		[/\[/,'delimiter.selector.attr.open','@css_selector_attr.$S2.]']
		[/\s+/,'white']
		[/,/,'style.selector.delimiter']
		[/#(\s.+)?$/, 'comment']
		[/^/, token: '@rematch', next: '@pop']
	]
	css_selector_parens: [
		[/\)/, 'delimiter.selector.parens.close','@pop']
		'@css_selector'
	]

	css_selector_attr: [
		[/\]/, 'delimiter.selector.parens.close','@pop']
		'@css_selector'
	]

	css_property: [
		[/(\d+)(@anyIdentifier)/, ['style.property.unit.number','style.property.unit.name']]
		[/((--|\$)@anyIdentifier)/, 'style.property.var']
		[/(-*@anyIdentifier)/, 'style.property.name']
		[/(\@+|\.+)(@anyIdentifier\-?)/, ['style.property.modifier.start','style.property.modifier']]
		[/\+(@anyIdentifier)/, 'style.property.scope']
		[/\s*([\:]\s*)/, token: 'style.property.operator',switchTo: '@css_value.$S2.$S3.$S4']
	]

	css_value_: [
		[/(x?xs|sm\-?|md\-?|lg|xl|\dxl)\b/, 'style.value.size'],
		[/\#[0-9a-fA-F]+/, 'style.value.color.hex'],
		[/((--|\$)@anyIdentifier)/, 'style.value.var']
		[/(@anyIdentifierOpt)(\@+|\.+)(@anyIdentifierOpt)/,['style.property.name','style.property.modifier.prefix','style.property.modifier']]
		'op_'
		'string_'
		'number_'
		'comment_'
		[/\s+/,'style.value.white']
		[/\(/, token: 'delimiter.style.parens.open', next: '@css_expressions.$S2.)']
		[/\{/, token: 'delimiter.style.curly.open', next: '@css_interpolation.$S2.}']
		[/(@anyIdentifier)/, 'style.value']
	]

	css_value: [
		denter({switchTo: '@css_multiline_value.$S2\t.$S3.$S4'},-1,-1)
		[/@cssPropertyKey/, token: '@rematch', next: '@pop']
		[/;/, token: 'style.delimiter', next: '@pop']
		[/(\}|\)|\])/, {token: '@rematch', next: '@pop'}]
		'css_value_'
	]

	css_multiline_value: [
		denter(null,-1,0)
		[/@cssPropertyKey/, 'invalid']
		'css_value_'
	]

	css_expressions: [
		[/\)/, token: 'delimiter.style.parens.close', next: '@pop']
		[/\(/, token: 'delimiter.style.parens.open', next: '@css_expressions.$S2.)']
		'css_value'
		# {include: '@css_value'}
	]

	css_interpolation: [
		[/\}/, token: 'delimiter.style.curly.close', next: '@pop']
		'expr_'
	]

	expressions: [
		[/\,/, 'delimiter.comma']
	]

	whitespace: [
		[/[ \t\r\n]+/, 'white'],
	]

	tag_: [
		[/(<)(?=\.)/, 'tag.open','@_tag.$S2.flag'],
		[/(<)(?=\.)/, 'tag.open','@_tag.$S2.flag'],
		[/(<)(?=\w|\{|\[|\%|\#|>)/,'tag.open','@_tag.$S2.name']
	]
	tag_content: [
		denter(null,-1,0)
		'common_'
		'flow_'
		'var_'
		'for_'
		'expr_'
		# dont support object keys directly here
	]

	_tag: [
		
		[/\/>/,'tag.close','@pop']
		[/>/,'tag.close',switchTo: '@tag_content.$S2\t..$S4']
		[/(\-?@tagIdentifier)(\:@anyIdentifier)?/,'tag.$S3.$#']
		[/(\-?\d+)/,'tag.$S3']
		[/(\%)(@anyIdentifier)/,['tag.mixin.prefix','tag.mixin']]
		[/(\#)(@anyIdentifier)/,['tag.id.prefix','tag.id']]

		[/\./,{ cases: {
			'$S3==event': {token: 'tag.event-modifier.start', switchTo: '@_tag.$S2.event-modifier'}
			'$S3==event-modifier': {token: 'tag.event-modifier.start', switchTo: '@_tag.$S2.event-modifier'}
			'$S3==modifier': {token: 'tag.modifier.start', switchTo: '@_tag.$S2.modifier'}
			'$S3==rule': {token: 'tag.rule-modifier.start', switchTo: '@_tag.$S2.rule-modifier'}
			'$S3==rule-modifier': {token: 'tag.rule-modifier.start', switchTo: '@_tag.$S2.rule-modifier'}
			'@default': {token: 'tag.flag.start', switchTo: '@_tag.$S2.flag'}
		}}]

		[/(\$?@anyIdentifier)/,{ cases: {
			'$S3==name': {token: 'tag.reference'}
			'@default': {token: 'tag.$S3'}
		}}]

		[/\{/,'tag.$S3.braces.open', '@_tag_interpolation.$S2.$S3']
		[/\[/,'style.open', '@css_inline.$S2.]']
		[/(\s*\=\s*)/,'tag.operator.equals', '@_tag_value.$S2.$S3']
		[/\:/,token: 'tag.event.start', switchTo: '@_tag.$S2.event']
		[/\@/,token: 'tag.event.start', switchTo: '@_tag.$S2.event']
		[/\{/,token: 'tag.$S3.braces.open', next: '@_tag_interpolation.$S2.$S3']
		[/\(/,token: 'tag.parens.open.$S3', next: '@_tag_parens.$S2.$S3']
		[/\s+/,token: 'white', switchTo: '@_tag.$S2.attr']
		'comment_'
	]
	
	_tag_interpolation: [
		[/\}/,'tag.$S3.braces.close','@pop']
		'expr_'
		[/\)|\]/,'invalid']
	]

	_tag_parens: [
		[/\)/,'tag.parens.close.$S3', '@pop']
		'arglist_'
		[/\]|\}/,token: 'invalid']
	]

	_tag_value: [
		[/(?=(\/?\>|\s))/,'','@pop']
		'attr_expr_'
	]

	regexp_: [
		[/\/(?!\ )(?=([^\\\/]|\\.)+\/)/, { token: 'regexp.slash.open', bracket: '@open', next: '@_regexp.$S2'}]
		[/\/\/\//, { token: 'regexp.slash.open', bracket: '@open', next: '@_hereregexp.$S2'}]
	]
	
	_regexp: [
		[/(\{)(\d+(?:,\d*)?)(\})/, ['regexp.escape.control', 'regexp.escape.control', 'regexp.escape.control'] ],
		[/(\[)(\^?)(?=(?:[^\]\\\/]|\\.)+)/, ['regexp.escape.control',{ token: 'regexp.escape.control', next: '@_regexrange.$S2'}]],
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
	]

	_regexrange: [
		[/-/,     'regexp.escape.control'],
		[/\^/,    'regexp.invalid'],
		[/@regexpesc/, 'regexp.escape'],
		[/[^\]]/, 'regexp'],
		[/\]/,    'regexp.escape.control', '@pop'],
	]

	_hereregexp: [
		[/[^\\\/#]/, 'regexp'],
		[/\\./, 'regexp'],
		[/#.*$/, 'comment'],
		['///[igm]*', { token: 'regexp', next: '@pop' }],
		[/\//, 'regexp'],
	]
}

# states are structured:
# 1 = the monarch state
# 2 = the current indentation
# 3 = the current scope name/type
# 4 = the monarch substate -- for identifiers++
# 5 = various flags
def rewrite-state raw
	let state = ['$S1','$S2','$S3','$S4','$S5']

	if raw.match(/\@(pop|push|popall)/)
		return raw

	raw = raw.slice(1) if raw[0] == '@'

	if raw.match(/^[\w\$\.\-]+$/)
		return raw

	if raw[0] == '>'
		state[1] = '$S2\t'
		raw = raw.slice(1)

	for part in raw.split(/(?=[\/\&\=])/)
		if part[0] == '&'
			state[2] = part.slice(1)
		elif part[0] == '+'
			state[3] = '$S3-' + part.slice(1)
		elif part[0] == '='
			state[3] = part.slice(1)
		elif part[0] == '/'
			state[4] = part.slice(1)
		else
			state[0] = part
	return state.join('.')

console.log rewrite-state('+let')
console.log rewrite-state('>+let&class')

def rewrite-actions actions,add
	if typeof actions == 'string' # and parts.indexOf('$') >= 0
		actions = {token: actions}

	if actions and actions.token != undefined
		if typeof add == 'string'
			actions.next = add
		elif add
			Object.assign(actions,add)

		if actions.next
			actions.next = rewrite-state(actions.next)
		if actions.switchTo
			actions.switchTo = rewrite-state(actions.switchTo)

	elif actions and actions.cases
		# console.log 'found cases to transform!!'
		for own k,v of actions.cases
			actions.cases[k] = rewrite-actions(v,actions.cases)

	elif actions isa Array
		let result = []
		let curr = null
		for action,i in actions
			if action[0] == '@' and i == actions.length - 1 and curr
				action = {next: action}

			if typeof action == 'object'
				if action.token != undefined or action.cases
					result.push(curr = Object.assign({},action))
				else
					Object.assign(curr,action)
			elif typeof action == 'string'
				result.push(curr = {token: action})
		actions = result

	if actions isa Array
		for action,i in actions
			if action.token && action.token.indexOf('$$') >= 0
				action.token = action.token.replace('$$','$' + (i + 1))
			if action.next
				action.next = rewrite-state(action.next)
			if action.switchTo
				action.switchTo = rewrite-state(action.switchTo)

	return actions

def rewrite-rule owner, key
	let rule = owner[key]
	

for own key,rules of states
	for rule,i in rules
		if typeof rule == 'string'
			rules[i] = {include: rule}
		elif rule[1] isa Array
			rule[1] = rewrite-actions(rule[1])
		elif rule isa Array
			rule.splice(1,2,rewrite-actions(rule[1],rule[2]))

		continue

console.log 'new states',states
window.SS = states

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
	boolean: ['true','false','yes','no','undefined','null']
	contextual_keywords: [
		'from', 'global', 'attr','prop'
	],
	operators: [
		'=', '!', '~', '?', ':','!!','??',
		'&', '|', '^', '%', '<<','!&',
		'>>', '>>>', '+=', '-=', '*=', '/=', '&=', '|=', '?=',
		'^=', '%=', '~=', '<<=', '>>=', '>>>=','..','...','||=',`&&=`,'**=','**',
		'|=?','~=?','^=?','=?'
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
	B: /(?=\s|@newline|$)/
	constant: /[A-Z][\w\$]*@subIdentifer/
	className: /[A-Z][A-Za-z\d\-\_]*|[A-Za-z\d\-\_]+/
	methodName: /[A-Za-z\_][A-Za-z\d\-\_]*\=?/
	subIdentifer: /(?:\-*[\w\$]+)*/
	id: /@anyIdentifierPre([\?\!]?)/
	identifier: /[a-z_]@subIdentifer/
	mixinIdentifier: /\%[a-z_]@subIdentifer/
	anyIdentifier: /[A-Za-z_\$][\w\$]*@subIdentifer/
	anyIdentifierOpt: /(?:[A-Za-z_\$][\w\$]*@subIdentifer)?/
	anyIdentifierPre: /([A-Za-z_\$])[\w\$]*@subIdentifer/
	esmIdentifier: /[\@\%]?[A-Za-z_\$]@subIdentifer/
	propertyPath: /(?:[A-Za-z_\$][A-Za-z\d\-\_\$]*\.)?(?:[A-Za-z_\$][A-Za-z\d\-\_\$]*)/
	tagNameIdentifier: /(?:[\w\-]+\:)?\w+(?:\-\w+)*/
	variable: /[\w\$]+(?:-[\w\$]*)*\??/
	varKeyword: /var|let|const/
	newline: new RegExp(newline)
	tagIdentifier: /-*[a-zA-Z][\w\-]*/
	implicitCall: /(?=\s[\w\'\"\/\[\{])/ # not true for or etc
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
	tokenizer: states
}