import { lexer, Token } from './lexer'
import { Document } from './document'

const newline = String.fromCharCode(172)

const GlobalVars = {
	'global': 1
	'imba': 1
	'module': 1
	'window': 1
	'document': 1
	'exports': 1
	'console': 1
	'process': 1
	'parseInt': 1
	'parseFloat': 1
	'setTimeout': 1
	'setInterval': 1
	'setImmediate': 1
	'clearTimeout': 1
	'clearInterval': 1
	'clearImmediate': 1
	'globalThis': 1
	'isNaN': 1
	'isFinite': 1
	'__dirname': 1
	'__filename': 1
}

const ScopeTypes = {
	def:   {closure: yes, matcher: /(static)?\s*def ([\w\-\$]+\??)/}
	get:   {closure: yes, matcher: /(static)?\s*get ([\w\-\$]+\??)/}
	set:   {closure: yes, matcher: /(static)?\s*set ([\w\-\$]+\??)/}
	prop:  {closure: yes, matcher: /(static)?\s*prop ([\w\-\$]+\??)/}
	class: {closure: yes, matcher: /class ([\w\-]+)/ }
	tag:   {closure: yes, matcher: /tag ([\w\-]+)/ }
	do:    {closure: no}
	flow:  {closure: no}
	root:  {closure: yes}
	element: {closure: no}
	value: {closure: no}
	style: {closure: yes}
}

const TokenScopeTypes = {
	'tag.open': 'element',
	'tag.name.braces.open': 'value',
	'tag.flag.braces.open': 'value',
	'style.css.open': 'style'
}

const TokenPairs = {}

for pair in ['tag.name.braces','tag.data']
	TokenPairs[pair + '.open'] = TokenPairs[pair + '.close']

const TokenContextRules = [
	[/(def|set) [\w\$]+[\s\(]/,'params']
	[/(class) ([\w\-\:]+) <\s?([\w\-]*)$/,'superclass']
	[/(tag) ([\w\-\:]+) <\s?([\w\-]*)$/,'supertag']
	[/(def|set|get|prop|attr|class|tag) ([\w\-]*)$/,'naming']
	[/\<([\w\-\:]*)$/,'tagname']
	[/\\([\w\-\:]*)$/,'type']
	# [/\.([\w\-\$]*)$/,'access']
]

class Variables
	def constructor scope
		scope = scope
		tokens = []
		map = {}
	
	def add token
		tokens.push(token)
		token.variable = token
		token.varscope = scope
		map[token.value] = token
	
	def lookup name, deep = yes
		let res = map[name]
		if deep and !res and scope.parent
			return scope.parent.variables.lookup(name)
		if !scope.parent and !res and GlobalVars[name]
			let tok = {value: name, varscope: scope, type: 'variable.global'}
			return map[name] = tok.variable = tok
		return res

class TokenScope
	def constructor {doc,parent,token,type,line}
		type = type
		indent = line.indent
		start = token.offset
		token = token
		end = null
		endIndex = null
		variables = Variables.new(self)

		if token.type.match(/(\w+)\.open/)
			pair = token.type.replace('open','close')

		if let m = (meta.matcher and line.lineContent.match(meta.matcher))
			name = m[m.length - 1]
			for mod in m.slice(1,-1)
				self[mod] = true if mod
		

		parent = parent
		return self
	
	get meta
		ScopeTypes[type] or ScopeTypes.flow

	def sub token,type,line
		TokenScope.new(doc: null, parent: self, token: token, type: type, line: line)

	get chain
		let items = [self]
		let scope = self
		while scope = scope.parent
			items.unshift(scope)
		return items
	
	def closest match = null
		let scope = self
		while scope
			let typ = scope.meta
			if typeof match == 'string'
				return scope if typ[match] or scope.type == match
			scope = scope.parent
		return null

	def reopen
		end = null
		endIndex = null
		parent.reopen! if parent
		self

	get closure
		closest('closure')
		
	def toJSON
		{type: type, start: start, end: end}


export class ImbaDocument < Document
	def constructor ...params
		super(...params)

		lineTokens = []
		tokens = []
		rootScope = TokenScope.new(doc: self, token: {offset: 0, type: 'root'}, type: 'root', line: {indent: -1}, parent: null)
		head = start = {
			index: 0
			line: 0
			offset: 0
			type: 'line'
			state: lexer.getInitialState!
			context: rootScope
			match: Token.prototype.match
		}

	def invalidateFromLine line
		if head.line >= line
			let state = lineTokens[Math.max(line - 1,0)] or start
			if state
				tokens.length = state.index
				head = state
				state.context.reopen!
		self

	def applyEdit change,version,changes
		super

		let line = change.range.start.line
		let caret = change.range.start.character + 1
		invalidateFromLine(line)
		if changes.length == 1 and change.text == '<'
			let text = getLineText(line)
			let matcher = text.slice(0,caret) + '§' + text.slice(caret)

			if matcher.match(/(^\t*|[\=\>]\s+)\<\§(?!\s*\>)/)
				if connection
					connection.sendNotification('closeAngleBracket',{uri: uri})
		return
	
	def overwrite
		super
		invalidateFromLine(0)

	def after token
		let idx = tokens.indexOf(token)
		return tokens[idx + 1]

	def matchToken token, match
		if match isa RegExp
			return token.type.match(match)
		elif typeof match == 'string'
			return token.type == match
		return false
	
	def before token, match, flat
		let idx = tokens.indexOf(token)
		if match
			while idx > 0
				let tok = tokens[--idx]
				if matchToken(tok,match)
					return tok
		return tokens[idx - 1]

	def getTokenRange token
		{start: positionAt(token.offset), end: positionAt(token.offset + token.value.length)}

	def getTokensInScope scope
		let start = tokens.indexOf(scope.token)
		let end = scope.endIndex or tokens.length
		let i = start
		let parts = []
		while i < end
			let tok = tokens[i++]
			if tok.scope and tok.scope != scope
				parts.push(tok.scope)
				i = tok.scope.endIndex + 1
			else
				parts.push(tok)
		return parts


	def getTokenAtOffset offset,forwardLooking = no
		let pos = positionAt(offset)
		getTokens(pos) # ensure that we have tokenized all the way here
		let line = lineTokens[pos.line]
		let idx = line.index
		let token
		let prev
		# find the token
		while token = tokens[idx++]
			if forwardLooking and token.offset == offset
				return token

			break if token.offset >= offset
			prev = token
		return prev or token

	def getSemanticTokens
		getTokens!
		tokens.filter do !!$1.variable

	def getContextAtOffset offset, forwardLooking = no
		let pos = positionAt(offset)
		let token = getTokenAtOffset(offset,forwardLooking)
		let index = tokens.indexOf(token)
		let line = lineTokens[pos.line]
		let prev = tokens[index - 1]
		let next = tokens[index + 1]

		let context = {
			offset: offset
			position: pos
			token: token
			line: line.lineContent
			textBefore: line.lineContent.slice(0,offset - line.offset)
			textAfter: line.lineContent.slice(offset - line.offset)
			mode: token.stack ? token.stack.state : ''
			scope: line.context
		}

		# context.tokenBefore = offset >= token.offset

		let scope = context.scope
		let mode = context.mode
		let indent = context.indent = context.textBefore.match(/^\t*/)[0].length

		let m
		if m = token.type.match(/regexp|string|comment|decorator/)
			mode = m[0]
			context.nested = yes
		elif mode.match(/style/) or mode.match(/tag\.(\w+)/)
			yes
		else
			while scope.indent >= indent and !scope.pair
				scope = scope.parent

			if mode.match(/(\.(var|let|const|param))/)
				mode = 'varname'
			elif m = token.type.match(/white\.(\w+)/)
				mode = m[1]
			else
				for rule in TokenContextRules
					if context.textBefore.match(rule[0])
						break mode = rule[1]
		
		if mode == 'string' and context.textBefore.match(/import |from |require(\(|\s)/)
			mode = 'filepath'

		let vars = context.vars = []
		
		// Start from the first scope and collect variables up to this token
		if let start = line.context.closure # line.scopes[line.scopes.length - 1]
			let i = Math.max(tokens.indexOf(start.token),0)
			while i <= index
				let tok = tokens[i++]
				if let scop = tok.scope
					if scop.endIndex != null and scop.endIndex < index
						i = scop.endIndex
						continue
					scope = scop

				if tok.type.match(/variable/)
					vars.push(tok)
		
		if !context.nested
			while scope.indent >= indent and !scope.pair and (scope.start < line.offset)
				scope = scope.parent


		if let elscope = scope.closest('element')
			let parts = getTokensInScope(elscope)
			let tagName = ''
			let tagNameStart
			let tagNameEnd
			for part in parts
				if part.type == 'tag.name'
					tagName += part.value
					tagNameStart ||= part
					tagNameEnd = part
				if part.token and part.token.type == 'tag.name.braces.open'
					tagName += '*'
					tagNameStart ||= part.token
					tagNameEnd = part.token

			elscope.name = tagName
			
			
		if scope.type == 'element'
			# not inside anywhere special?
			context.tagName = after(scope.token)
		
		context.scope = scope
		context.mode = mode
		context.tag = scope.closest('element')
		context.tagScope = scope.closest('tag')
		context.classScope = scope.closest('class')

		if context.tag and context.tag.name == 'self'
			if scope.closest('tag')
				context.tag.name = scope.closest('tag').name
		
		if context.mode.match(/^(var_value|object_value|root)/)
			if context.textBefore.match(/([^\.]\.\.|[^\.]\.)([\w\-\$]*)$/) 
				context.mode = 'access'
			yes
		return context
		

	# This is essentially the tokenizer
	def getTokens range
		var codelines = content.split('\n')

		var tokens = tokens
		var t = Date.now!
		var toLine = range ? range.line : (lineCount - 1)
		var added = 0
		var lineCount = lineCount

		while head.line <= toLine
			let i = head.line
			let offset = head.offset
			let code = codelines[head.line]

			let indent = 0
			while code[indent] === '\t'
				indent++

			let lineToken = lineTokens[i] = {
				offset: offset
				state: head.state
				stack: head.state.stack
				line: i
				indent: indent
				type: 'line'
				meta: head.state.stack
				lineContent: code
				match: Token.prototype.match
				value: i ? '\n' : ''
				index: tokens.length
				context: head.context
			}

			let scope = head.context

			if (code[indent] or i == lineCount) and !lineToken.stack.state.match(/string|regexp/)
				# Need to track parens etc as well
				while scope
					if scope.indent >= indent and !scope.pair
						scope.end = offset
						scope.endIndex = lineToken.index
						scope = scope.parent
					else
						break

			tokens.push(lineToken)

			let lexed = lexer.tokenize(code + newline,head.state,offset)
			let lastVarRef = null

			for tok,i in lexed.tokens
				continue if tok.type == 'newline'
				# continue if tok.type == 'lookahead.imba'
				let next = lexed.tokens[i + 1]
				let to = next ? (next.offset - offset) : 1000000

				let match

				if match = tok.type.match(/keyword\.(class|def|set|get|prop|tag|if|for|while|do|elif|unless)/)
					tok.scope = scope = scope.sub(tok,match[1],lineToken)
				elif TokenScopeTypes[tok.type]
					tok.scope = scope = scope.sub(tok,TokenScopeTypes[tok.type],lineToken)
				elif tok.type == scope.pair
					scope.end = tok.offset
					scope.endIndex = tokens.length
					scope = scope.parent

				if tok.type.match(/^variable/)
					scope.variables.add(tok)
					lastVarRef = tok

				elif tok.type == 'identifier'
					if let variable = scope.variables.lookup(tok.value)
						tok.variable = variable

						if lastVarRef and lastVarRef.variable == variable
							let between = code.slice(lastVarRef.offset + lastVarRef.value.length - offset,tok.offset - offset)
							if between.match(/^\s*\=\s*$/) and (!next or code.slice(to).match(/^\s*[\,\)]/))
								if lastVarRef == variable
									tok.variable = null
								else
									lastVarRef.variable = null
						
						lastVarRef = tok

				tokens.push(tok)
				added++

			head.context = scope
			head.line++
			head.offset += code.length + 1
			head.state = lexed.endState
			[]

		var elapsed = Date.now! - t
		return tokens


	def migrateToImba2
		let source = self.content
		source = source.replace(/\bdef self\./g,'static def ')
		source = source.replace(/\b(var|let|const) def /g,'def ')

		# convert tag.@dom and dom.@tag

		let doc = ImbaDocument.new('','imba',0,source)
		let tokens = doc.getTokens!

		for token,i in tokens
			let next = tokens[i + 1]
			let {value,type,offset} = token
			let end = offset + value.length
			if type == 'operator.dot.legacy'
				value = '.'
				next.access = true if next

			if type == 'operator.spread.legacy'
				value = '...'
			
			if type == 'decorator'
				value = '_' + value.slice(1)
			
			if type == 'property'
				if value[0] == '@'
					value = value.replace(/^\@/,'_')
				elif (/^(\n|\s\:|\)|\,|\.)/).test(source.slice(end)) and !token.access
					if value[0] == value[0].toLowerCase!
						value = value + '!'


			if type == 'identifier' and value[0] == value[0].toLowerCase! and value[0] != '_'
				if !token.variable and (/^(\n|\s\:|\)|\,|\.)/).test(source.slice(end))
					value = value + '!'

			token.value = value

		return tokens.map(do $1.value).join('')
	