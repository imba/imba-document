const eolpop = [/^/, token: '@rematch', next: '@pop']
const repop = { token: '@rematch', next: '@pop'}
const toodeep = {token: 'white.indent',next: '@>illegal_indent'}

def regexify array, pattern = '#'
	if typeof array == 'string'
		array = array.split(' ')

	let items = array.slice!.sort do $2.length - $1.length
	items = items.map do(item)
		let escaped = item.replace(/[.*+\-?^${}()|[\]\\]/g, '\\$&')
		pattern.replace('#',escaped)
	new RegExp('(?:' + items.join('|') + ')')


def denter indent,outdent,stay,reg
	if indent == null
		indent = toodeep

	elif indent == 1
		indent = {next: '@>'}
	elif typeof indent == 'string'
		indent = {next: indent}

	if outdent == -1
		outdent = repop
	if stay == -1
		stay = repop
	elif stay == 0
		stay = {}

	indent = Object.assign({token: 'white.tabs'},indent or {})
	stay = Object.assign({token: 'white.tabs'},stay or {})
	outdent = Object.assign({ token: '@rematch', next: '@pop'},outdent or {})

	reg ||= /^\t*(?=[^\t\n])/
	[reg,{cases: {
		'$#==$S2\t': indent
		'$#==$S2': stay
		'@default': outdent
	}}]

export const states = {

	root: [
		[/^(\t+)(?=[^\t\n])/,{cases: {
			'$1==$S2\t': {token: 'white.indent',next: '@>illegal_indent'}
			'@default': 'white.indent'
		}}]
		'block_'
	]

	illegal_indent: [
		denter()
	]

	identifier_: [
		[/\$\w+\$/, 'identifier.env']
		[/\$\d+/, 'identifier.special']
		# [/(@constant)/, 'identifier.constant.$S4']
		[/@anyIdentifier([\?\!]?)/,cases: {
			'this': 'this'
			'self': 'self'
			'@keywords': 'keyword.$#'
			'$0~[A-Z].*': 'identifier.uppercase.$F'
			'@default': 'identifier.$F'
		}]
	]

	body: [
		[/^(\t+)(?=[^\t\n])/,{cases: {
			'$1==$S2\t': {token: 'white.indent',next: '@>illegal_indent'}
			'@default': 'white.indent'
		}}]
		'block_'
	]

	block_: [
		# 'common_'
		[/^(\t+)(?=[\r\n]|$)/,'white.tabs']
		'class_'
		'tagclass_'
		'var_'
		'func_'
		'import_'
		'flow_'
		'for_'
		'try_'
		'catch_'
		'while_'
		'css_'
		'tag_'
		'do_'
		
		'expr_'
		'common_'
	]

	_indent: [
		denter('@>_indent&indent',-1,0)
		'block_'
	]

	block: [
		denter('@>',-1,0)
		'block_'
	]
	bool_: [
		[/(true|false|yes|no|undefined|null)(?![\:\-\w\.\_])/,'boolean']
	]

	op_: [
		[/\s+\:\s+/,'operator.ternary']
		[/(@unspaced_ops)/,cases: {
			'@access': 'operator.access'
			'@default': 'operator'
		}]
		[/\&(?=[,\)])/,'operator.special.blockparam']
		[/(\s*)(@symbols)(\s*)/, cases: {
			'$2@operators': 'operator'
			'$2@math': 'operator.math'
			'$2@logic': 'operator.logic'
			'$2@access': 'operator.access'
			'@default': 'delimiter'
		}]
		[/\&\b/, 'operator']
	]

	keyword_: [
		[/new@B/,'keyword.new']
		[/and@B|or@B/, 'operator.flow']
	]

	return_: [
		[/return@B/,'keyword.new']
	]

	primitive_: [
		'string_'
		'number_'
		'regexp_'
		'bool_'
	]

	value_: [
		'primitive_'
		'keyword_'
		'implicit_call_'
		'parens_' # call will always capture?
		'key_'
		'access_'
		'identifier_'
		'array_'
		'object_'
	]

	expr_: [
		'comment_'
		'inline_var_'
		'return_'
		'value_'
		'tag_'
		'op_'
		'type_'
		'spread_'
	]

	attr_expr_: [
		'primitive_'
		'parens_'
		'access_'
		'identifier_'
		'array_'
		'object_'
		'tag_'
		'op_'
	]

	access_: [
		[/(\.\.?)(@anyIdentifier\??)/,cases: {
			'$2~[A-Z].*': ['operator.access','access.uppercase']
			'@default': ['operator.access','access']
		}]
	]

	call_: [
		[/\(/, '(', '@call_body']
	]

	key_: [
		[/(@anyIdentifier\??)(\:\s*)/,cases: {
			'@default': ['key','operator.assign.key-value']
		}]
	]

	implicit_call_: [
		[/(\.\.?)(@anyIdentifier\??)@implicitCall/,cases: {
			'$2~[A-Z].*': ['operator.access','access.uppercase','@implicit_call_body']
			'@default': ['operator.access','access','@implicit_call_body']
		}]
		[/(@anyIdentifier\??)@implicitCall/,cases: {
			'$2~[A-Z].*': ['identifier.uppercase','@implicit_call_body']
			'@default': ['identifier','@implicit_call_body']
		}]
	]

	implicit_call_body: [
		eolpop
		[/\)|\}|\]|\>/,'@rematch', '@pop']
		'arglist_'
	]

	arglist_: [
		'do_'
		'expr_'
		[/\s*\,\s*/,'delimiter.comma']
	]

	params_: [
		[/\[/, '[', '@array_body=param']
		[/\{/, '{', '@object_body=param']
		[/(@variable)/,'identifier.param']
		# [/(\s*\=\s*)(?=(for|while|until|if|unless)\s)/,'operator','@pop']
		'spread_'
		[/\s*\=\s*/,'operator','@var_value=']
		[/\s*\,\s*/,'separator']
	]

	object_: [
		[/\{/, '{', '@object_body']
	]

	parens_: [
		[/\(/, '(', '@parens_body']
	]

	parens_body: [
		# [/\)/, ')', '@pop']
		[/\)/, ')', '@pop']
		'arglist_'
	]

	array_: [
		[/\[/, '[', '@array_body']
	]

	array_body: [
		[/\]@implicitCall/, token: ']', switchTo: '@implicit_call_body=']
		[/\]/, ']', '@pop']
		'expr_'
		[',','delimiter']
	]

	object_body: [
		[/\}/, '}', '@pop']
		# [/(@anyIdentifier)(\s*:\s*)(@anyIdentifier)/, ['key','operator.assign.key-value','identifier.$F']]
		[/(@anyIdentifier)(\s*:\s*)/, ['key','operator.assign.key-value','@object_value']]
		[/(@anyIdentifier)/, 'identifier.$F']
		[/\[/, '[', '@object_dynamic_key=']
		[/\s*=\s*/,'operator.assign','@object_value=']
		[/:/,'operator.assign.key-value','@object_value=']
		[/\,/,'delimiter.comma']
		'expr_'
	]

	object_value: [
		eolpop
		# [/(?=,|\})/, 'delimiter', '@pop']
		[/,|\}|\]|\)/, '@rematch', '@pop']
		'expr_'
	]

	object_dynamic_key: [
		[']',']','@pop']
		'expr_'
	]

	comment_: [
		[/#(\s.+)?(\n|$)/, 'comment']
	]

	block_comment_: [
		[/###/, 'comment.start','@_block_comment']
	]

	_block_comment: [
		[/###/,'commend.end','@pop']
		[/\./,'comment']
	]

	# add try_start that accepts catch on the same line?
	try_: [
		[/try@B/,'keyword.try','@>_try']
	]

	catch_: [
		[/(catch)(\s+)(@anyIdentifier)/, ['keyword.$1','white','identifier.const','@>_catch']]
		[/catch@B/,'keyword.catch','@>_catch']
	]

	_catch: [
		denter('@>block',-1,0)
		'block_'
	]

	_try: [
		denter('@>block',-1,0)
		'block_'
	]

	do_: [
		# [/(do)(\()/,['keyword.do','(','@>_do_params&do']]
		[/do(?=\()/,'keyword.do','@>do_start&do']
		[/do@B/,'keyword.do','@>_do&do']
	]

	do_start: [
		denter(null,-1,-1)
		[/\(/,'(',switchTo: '@_do_params']
		[/./,'@rematch',switchTo:'@_do']
	]

	_do_params: [
		[/\)/,')',switchTo: '@_do']
		'params_'
	]

	_do: [
		denter(null,-1,0)
		'block_'
	]

	class_: [
		[/(export|extend)(?=\s+class )/,'keyword.$1']
		[/(class)(\s)(@anyIdentifier)/, ['keyword.$1','white.$1name','entity.$1','@class_start=']]
	]

	class_start: [
		# [/[\r\n]/,'@rematch',switchTo: '@>_class&class=']
		[/(\s+\<\s+)(@anyIdentifier)/,['keyword.extends','identifier.superclass']]
		[/#(\s.+)?$/, 'comment',switchTo: '@>_class&class=']
		[/^/,'@rematch',switchTo: '@>_class&class=']
		# denter({switchTo: '@>_class&class='},-1,-1) # should be no need for a denter here
	]

	tagclass_: [
		[/(export|extend)(?=\s+tag )/,'keyword.$#']
		[/(tag)(\s)(@constant)/, ['keyword.tag','white.tagname','entity.$1.local','@tagclass_start=']] # only when uppercase
		[/(tag)(\s)(@anyIdentifier)/, ['keyword.tag','white.tagname','entity.tag','@tagclass_start=']] # only when uppercase
	]

	tagclass_start: [
		[/(\s+\<\s+)(@anyIdentifier)/,['keyword.extends','identifier.superclass']]
		[/#(\s.+)?$/, 'comment']
		[/^/,'@rematch',switchTo: '@>_tagclass&tag=']
		denter({switchTo: '@>_tagclass&tag='},-1,-1)
	]

	import_: [
		[/(import)(?=\s+['"])/,'keyword.import','@>import_source']
		[/(import|export)@B/,'keyword.import','@>import_body']
	]

	import_body: [
		denter(null,-1,0)
		[/(\*)(\s+as\s+)(@esmIdentifier)/, ['keyword.star','keyword.as','identifier.const.import']]
		[/(@esmIdentifier)(\s+as\s+)(@esmIdentifier)/, ['alias','keyword.as','identifier.const.import']]
		[/from/, 'keyword.from',switchTo: '@import_source']
		[/\{/,'imports.open','@esm_specifiers/imports']
		[/(@esmIdentifier)/,'identifier.const.import']
	]

	esm_specifiers: [
		[/\}/, '$/.close', '@pop']
		[/(@esmIdentifier)(\s+as\s+)(@esmIdentifier)/, ['alias','keyword.as','identifier.const.$/']]
		[/(@esmIdentifier)/, 'identifier.const.$/']
		[/\s*\,\s*/,'delimiter.comma']
	]

	import_source: [
		denter(null,-1,0)
		[/["']/, 'start.path','@_path=$#']
	]
	_path: [
		[/[^"'\`\{\\]+/, 'path']
		[/@escapes/, 'path.escape']
		[/\./, 'path.escape.invalid']
		[/\{/, 'invalid']
		[/["'`]/, cases: { '$#==$F': { token: 'end.path', next: '@pop' }, '@default': 'path' }]
	]
	
	def_: [
		[/static(?=\s+(get|set|def) )/,'keyword.static'] # only in class and tagclass?
		[/(def|get|set)(\s)(@anyIdentifier)/, ['keyword.$1','white.entity','entity.$1.$3','@>def_params&$1/$1']]
		[/(def|get|set)(\s)(\[)/, ['keyword.$1','white','$$','@def_dynamic_name/$1']]
	]

	func_: [
		[/export(?=\s+(get|set|def) )/,'keyword.export'] # only in class and tagclass?
		[/(def)(\s)(@anyIdentifier)/, ['keyword.$1','white.entity','entity.$1.$3','@>def_params&$1/$1']]
	]
	
	flow_: [
		# [/(else)(?=\s|$)/, ['keyword.$1','@flow_start.$S2.flow.$S4']]
		[/(if|else|elif|unless)(?=\s|$)/, ['keyword.$1','@flow_start&$1']]
	]

	flow_start: [
		denter({switchTo: '@>_flow'},-1,-1)
		# denter({switchTo: '@>_flow&-body'},-1,-1)
		# denter('@>_flow&block',-1,-1)
		'expr_'
	]

	for_: [
		[/for@B/,'keyword.$#','@for_start&flow=let']
	]

	while_: [
		[/(while|until)@B/,'keyword.$#','@>while_body']
	]
	while_body: [
		denter(null,-1,0)
		'block_'
	]

	for_start: [
		denter({switchTo: '@>for_body'},-1,-1)
		[/\[/, '[', '@array_body']
		[/\{/, '{', '@object_body']
		[/(@variable)/,'identifier.$F']
		[/(\s*\,\s*)/,'separator']
		[/\s(in|of)@B/,'keyword',switchTo: '@for_source=']
	]
	for_source: [
		denter({switchTo: '@>for_body'},-1,-1)
		'expr_'
	]

	for_body: [
		denter(null,-1,0)
		'block_'
	]

	decorator_: [
		[/(\@@anyIdentifier)(\()/,['decorator','$2','@_decorator_params']]
		[/(\@@anyIdentifier)/,'decorator']
	]

	_decorator_params: [
		[/\)/,')','@pop']
		'params_'
	]

	field_: [
		[/static(?=\s+@anyIdentifier)/,'keyword.static']
		[/(@anyIdentifier\??)(?=$)/,'field']
		[/(@anyIdentifier\??)/,['field','@_field_1']]
	]

	_field_1: [
		denter(null,-1,-1)
		'type_'
		[/(\s*=\s*)/,['operator','@>_field_value']]
	]

	_field_value: [
		denter(null,-1,0)
		'block_' # sure?
	]

	var_: [
		[/((?:export )?)(const|let)(?=\s|$)/, ['keyword.export','keyword.$1','@_varblock=$2']] # $2_body.$S2.$2.$S4
	]

	inline_var_: [
		[/(const|let)(?=\s|$)/, ['keyword.$1','@inline_var_body=$1']]
	]

	string_: [
		[/"""/, 'string', '@_herestring="""']
		[/'''/, 'string', '@_herestring=\'\'\'']
		[/["'`]/, 'string.open','@_string=$#']
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
			'$F==\'': 'string'
			'@default': { token: 'string.bracket.open', next: '@interpolation_body' }
		}]
		[/["'`]/, cases: { '$#==$F': { token: 'string.close', next: '@pop' }, '@default': 'string' }]
		[/#/, 'string']
	]

	_herestring: [
		[/("""|''')/, { cases: { '$1==$S2': { token: 'string', next: '@pop' }, '@default': 'string' } }],
		[/[^#\\'"\{]+/, 'string'],
		[/['"]+/, 'string'],
		[/@escapes/, 'string.escape'],
		[/\./, 'string.escape.invalid'],
		[/\{/, { cases: { '$S2=="""': { token: 'string', next: '@interpolation_body' }, '@default': 'string' } }],
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
		'common_'
	]

	_tagclass: [
		'_class'
		[/(?=\<self)/,'entity.def.render','@>_def&def',]
		# self def
	]

	def_params: [
		# denter({switchTo: '@>_def'},-1,{switchTo: '@>_def'})
		[/\(/,'(','@def_parens']
		[/^/,'@rematch',switchTo:'@_def']
		[/do@B/,'keyword.do',switchTo:'@_def']
		'params_'
	]

	def_parens: [
		[/\)/,')','@pop']
		'params_'
	]

	def_dynamic_name: [
		[']',token: 'square.close',switchTo: '@def_params&$/']
		'expr_'
	]

	_def: [
		denter('@>_indent&indent',-1,0)
		'block_'
	]

	_flow: [
		denter(toodeep,-1,0)
		'block_'
	]

	_varblock: [
		denter(1,-1,-1)
		[/\[/, '[', '@array_body']
		[/\{/, '{', '@object_body']
		[/(@variable)/,'identifier.$F']
		[/\s*\,\s*/,'separator']
		[/(\s*\=\s*)(?=(for|while|until|if|unless)\s)/,'operator','@pop']
		[/(\s*\=\s*)/,'operator','@var_value=']
		'type_'
	]

	inline_var_body: [
		[/\[/, '[', '@array_body']
		[/\{/, '{', '@object_body']
		[/(@variable)/,'identifier.$F']
		[/(\s*\=\s*)/,'operator',switchTo: '@var_value=ident']
	]

	var_value: [
		[/(?=,|\))/, 'delimiter', '@pop']
		denter({switchTo: '@>block'},-1,-1)
		# denter({switchTo: 1},-1,-1)
		'do_'
		'expr_'
	]

	common_: [
		[/^(\t+)(?=\n|$)/,'white.tabs']
		'@whitespace'
	]

	spread_: [
		[/\.\.\./,'operator.spread']
	]

	type_: [
		[/\\/, '@rematch','@_type&-_type/0']
	]

	_type: [
		denter(null,-1,-1)
		[/\\/,'type.delim']
		[/\[/,'type','@/]']
		[/\(/,'type','@/)']
		[/\{/,'type','@/}']
		[/\</,'type','@/>']
		[/\,|\s/,{
			cases: {
				'$/==0': { token: '@rematch', next: '@pop' }
				'@default': 'type'
			}
		}]
		[/[\]\}\)\>]/,{
			cases: {
				'$#==$/': { token: 'type', next: '@pop' }
				'@default': { token: '@rematch', next: '@pop' }
			}
		}]
		[/[\w\-\$]+/,'type']
	]

	css_: [
		[/global(?=\s+css@B)/,'keyword.$#']
		[/css(?:\s+)?/, 'keyword.css','@>css_selector&rule-_sel']
	]

	sel_: [
		[/(\%)((?:@anyIdentifier)?)/,['style.selector.mixin.prefix','style.selector.mixin']]
		[/(\@)(\.{0,2}[\w\-]*)/,['style.selector.modifier.prefix','style.selector.modifier']]
		[/\.([\w\-]+)/,'style.selector.class-name']
		[/\#([\w\-]+)/,'style.selector.id']
		[/([\w\-]+)/,'style.selector.element']
		[/(>+|~|\+)/,'style.selector.operator']
		[/(\*+)/,'style.selector.element.any']
		[/(\$)((?:@anyIdentifier)?)/,['style.selector.reference.prefix','style.selector.reference']]
		[/\&/,'style.selector.context']
		[/\(/,'delimiter.selector.parens.open','@css_selector_parens']
		[/\[/,'delimiter.selector.attr.open','@css_selector_attr']
		[/\s+/,'white']
		[/,/,'style.selector.delimiter']
		[/#(\s.+)?\n?$/, 'comment']
	]

	css_props: [
		denter(null,-1,0)
		[/(?=@cssPropertyKey)/,'','@css_property&-_prop-_name']
		[/#(\s.+)?\n?$/, 'comment']
		[/(?=[\%\*\w\&\$\>\.\[\@\!]|\#[\w\-])/,'','@>css_selector&rule-_sel']
		[/\s+/, 'white']
	]

	css_selector: [
		denter({switchTo: '@css_props'},-1,{token:'@rematch',switchTo:'@css_props&_props'})
		[/(\}|\)|\])/,'@rematch', '@pop']
		[/(?=\s*@cssPropertyKey)/,'',switchTo:'@css_props&_props']
		[/\s*#\s/,'@rematch',switchTo:'@css_props&_props']
		'sel_'
	]

	css_inline: [
		[/\]/,'style.close','@pop']
		[/(?=@cssPropertyKey)/,'','@css_property&-_prop-_name']
	]

	css_selector_parens: [
		[/\)/, 'delimiter.selector.parens.close','@pop']
		'sel_'
	]

	css_selector_attr: [
		[/\]/, 'delimiter.selector.parens.close','@pop']
		'sel_'
	]

	css_property: [
		denter(null,-1,-1)
		[/(\d+)(@anyIdentifier)/, ['style.property.unit.number','style.property.unit.name']]
		[/((--|\$)@anyIdentifier)/, 'style.property.var']
		[/(-*@anyIdentifier)/, 'style.property.name']
		[/(\@+|\.+)(@anyIdentifier\-?)/, ['style.property.modifier.start','style.property.modifier']]
		[/\+(@anyIdentifier)/, 'style.property.scope']
		[/\s*([\:]\s*)(?=@br|$)/, 'style.property.operator',switchTo: '@>css_multiline_value&_value']
		[/\s*([\:]\s*)/, 'style.property.operator',switchTo: '@>css_value&_value']
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
		[/\(/, 'delimiter.style.parens.open', '@css_expressions']
		[/\{/, 'delimiter.style.curly.open', '@css_interpolation']
		[/(@anyIdentifier)/, 'style.value']
	]

	css_value: [
		denter({switchTo: '@>css_multiline_value'},-1,-1)
		[/@cssPropertyKey/, '@rematch', '@pop']
		[/;/, 'style.delimiter', '@pop']
		[/(\}|\)|\])/, '@rematch', '@pop']
		'css_value_'
	]

	css_multiline_value: [
		denter(null,-1,0)
		[/@cssPropertyKey/, 'invalid']
		'css_value_'
	]

	css_expressions: [
		[/\)/, 'delimiter.style.parens.close', '@pop']
		[/\(/, 'delimiter.style.parens.open', '@css_expressions']
		'css_value'
	]

	css_interpolation: [
		[/\}/, 'delimiter.style.curly.close', '@pop']
		'expr_'
	]

	expressions: [
		[/\,/, 'delimiter.comma']
	]

	whitespace: [
		[/[\r\n]+/, 'br']
		[/[ \t\r\n]+/, 'white']
	]

	tag_: [
		[/(<)(?=\.)/, 'tag.open','@_tag/flag'],
		[/(<)(?=\w|\{|\[|\%|\#|>)/,'tag.open','@_tag/name']
	]
	tag_content: [
		denter(null,-1,0)
		[/\)|\}\]/,'@rematch', '@pop']
		'common_'
		'flow_'
		'var_'
		'for_'
		'expr_'
		# dont support object keys directly here
	]

	tag_children: [

	]

	_tag: [
		
		[/\/>/,'tag.close','@pop']
		# [/>/,'tag.close',switchTo: '@tag_content=']
		[/>/,'tag.close','@pop']
		[/(\-?@tagIdentifier)(\:@anyIdentifier)?/,'tag.$/']
		[/(\-?\d+)/,'tag.$S3']
		[/(\%)(@anyIdentifier)/,['tag.mixin.prefix','tag.mixin']]
		[/(\#)(@anyIdentifier)/,['tag.id.prefix','tag.id']]

		[/\./,{ cases: {
			'$/==event': {token: 'tag.event-modifier.start', switchTo: '@/event-modifier'}
			'$/==event-modifier': {token: 'tag.event-modifier.start', switchTo: '@/event-modifier'}
			'$/==modifier': {token: 'tag.modifier.start', switchTo: '@/modifier'}
			'$/==rule': {token: 'tag.rule-modifier.start', switchTo: '@/rule-modifier'}
			'$/==rule-modifier': {token: 'tag.rule-modifier.start', switchTo: '@/rule-modifier'}
			'@default': {token: 'tag.flag.start', switchTo: '@/flag'}
		}}]

		[/(\$?@anyIdentifier)/,{ cases: {
			'$S3==name': 'tag.reference'
			'@default': 'tag.$/'
		}}]

		[/\{/,'tag.$/.braces.open', '@_tag_interpolation']
		[/\[/,'style.open', '@css_inline']
		[/(\s*\=\s*)/,'tag.operator.equals', '@_tag_value&-value']
		[/\:/,token: 'tag.event.start', switchTo: '@/event']
		'tag_event_'
		# [/\@/,token: 'tag.event.start', switchTo: '@/event']
		[/\{/,token: 'tag.$/.braces.open', next: '@_tag_interpolation/0']
		[/\(/,token: 'tag.parens.open.$/', next: '@_tag_parens/0']
		[/\s+/,token: 'white', switchTo: '@/attr']
		'comment_'
	]
	tag_event_: [
		# add an additional slot for name etc?
		[/(\@)(@anyIdentifierOpt)/,['tag.event.start','tag.event.name','@_tag_event/$2']]
	]
	
	_tag_part: [
		[/\)|\}|\]|\>/,'@rematch', '@pop']
	]
	_tag_event: [
		'_tag_part'
		[/\.(@anyIdentifierOpt)/,'tag.event.modifier']
		[/(\s*\=\s*)/,'tag.operator.equals', '@_tag_value&handler']
		[/\s+/,'@rematch','@pop']
	]
	
	_tag_interpolation: [
		[/\}/,'tag.$/.braces.close','@pop']
		'expr_'
		[/\)|\]/,'invalid']
	]

	_tag_parens: [
		[/\)/,'tag.parens.close.$/', '@pop']
		'arglist_'
		[/\]|\}/,'invalid']
	]

	_tag_value: [
		[/(?=(\/?\>|\s))/,'','@pop']
		'attr_expr_'
	]

	regexp_: [
		[/\/(?!\ )(?=([^\\\/]|\\.)+\/)/, { token: 'regexp.slash.open', bracket: '@open', next: '@_regexp'}]
		[/\/\/\//, { token: 'regexp.slash.open', bracket: '@open', next: '@_hereregexp'}]
	]
	
	_regexp: [
		[/(\{)(\d+(?:,\d*)?)(\})/, ['regexp.escape.control', 'regexp.escape.control', 'regexp.escape.control'] ],
		[/(\[)(\^?)(?=(?:[^\]\\\/]|\\.)+)/, ['regexp.escape.control',{ token: 'regexp.escape.control', next: '@_regexrange'}]],
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
		['///[igm]*','regexp', '@pop' ],
		[/\//, 'regexp'],
	]
}

# states are structured:
# 1 = the monarch state
# 2 = the current indentation (I)
# 3 = the current scope name/type (&)
# 4 = various flags (F)
# 5 = the monarch substate -- for identifiers++
def rewrite-state raw
	
	let state = ['$S1','$S2','$S3','$S4','$S5']

	if raw.match(/\@(pop|push|popall)/)
		return raw

	raw = raw.slice(1) if raw[0] == '@'

	if raw.indexOf('.') >= 0
		console.log 'return raw state',raw
		return raw

	raw = rewrite-token(raw)
	# if raw.match(/^[\w\$\.\-]+$/)
	#	return raw

	if raw[0] == '>'
		state[1] = '$S2\t'
		raw = raw.slice(1)

	for part in raw.split(/(?=[\/\&\=])/)
		if part[0] == '&'
			if part[1] == '-' or part[1] == '_'
				state[2] = '$S3' + part.slice(1)
			else
				state[2] = '$S3-' + part.slice(1)

		elif part[0] == '+'
			state[3] = '$S4-' + part.slice(1)
		elif part[0] == '='
			state[3] = part.slice(1)
		elif part[0] == '/'
			state[4] = part.slice(1)
		else
			state[0] = part
	return state.join('.')

def rewrite-token raw
	let orig = raw
	raw = raw.replace('$F','$S4')
	raw = raw.replace('$&','$S3')
	raw = raw.replace('$I','$S2')
	raw = raw.replace('$/','$S5')
	# if orig != raw
	#	console.log 'rewriting token',orig,raw
	return raw

def rewrite-actions actions,add
	if typeof actions == 'string' # and parts.indexOf('$') >= 0
		actions = {token: rewrite-token(actions)}

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
		let cases = {}
		for own k,v of actions.cases
			let newkey = rewrite-token(k)
			cases[newkey] = rewrite-actions(v)
		actions.cases = cases

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
				result.push(curr = {token: rewrite-token(action)})
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

export const grammar = {
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
		'|=?','~=?','^=?','=?','and','or'
	],
	logic: [
		'>', '<', '==', '<=', '>=', '!=', '&&', '||','===','!=='
	],
	ranges: ['..','...']
	dot: ['.']
	access: ['.','..']
	math: ['+', '-', '*', '/', '++', '--'],

	unspaced_ops: regexify('. .. + * / ++ --')

	# we include these common regular expressions
	symbols: /[=><!~?&%|+\-*\/\^,]+/,
	fallbackSymbols: /[=><!~?&%|+\-*\/\^\.,\:]+/,
	escapes: /\\(?:[abfnrtv\\"'$]|x[0-9A-Fa-f]{1,4}|u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8})/,
	postaccess: /(:(?=\w))?/
	ivar: /\@[a-zA-Z_]\w*/
	B: /(?=\s|$)/
	br:/[\r\n]+/
	constant: /[A-Z][\w\$]*@subIdentifer/
	className: /[A-Z][A-Za-z\d\-\_]*|[A-Za-z\d\-\_]+/
	methodName: /[A-Za-z\_][A-Za-z\d\-\_]*\=?/
	subIdentifer: /(?:\-*[\w\$]+)*/
	# id: /@anyIdentifierPre([\?\!]?)/
	identifier: /[a-z_]@subIdentifer/
	mixinIdentifier: /\%[a-z_]@subIdentifer/
	# anyIdentifier: /[A-Za-z_\$][\w\$]*@subIdentifer/
	anyIdentifier: /[A-Za-z_\$][\w\$]*(?:\-+[\w\$]+)*/
	anyIdentifierOpt: /(?:@anyIdentifier)?/
	# anyIdentifierPre: /([A-Za-z_\$])[\w\$]*(?:\-+[\w\$]+)*/
	esmIdentifier: /[\@\%]?[A-Za-z_\$]@subIdentifer/
	propertyPath: /(?:[A-Za-z_\$][A-Za-z\d\-\_\$]*\.)?(?:[A-Za-z_\$][A-Za-z\d\-\_\$]*)/
	tagNameIdentifier: /(?:[\w\-]+\:)?\w+(?:\-\w+)*/
	variable: /[\w\$]+(?:-[\w\$]*)*\??/
	varKeyword: /var|let|const/
	tagIdentifier: /-*[a-zA-Z][\w\-]*/
	implicitCall: /(?!\s(?:and|or)\s)(?=\s[\w\'\"\/\[\{])/ # not true for or etc
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