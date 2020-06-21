import {computeLineOffsets,getWellformedRange,getWellformedEdit,mergeSort,editIsFull,editIsIncremental} from './utils'
import { lexer, Token } from './lexer'

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
		token.modifiers ||= []
		map[token.value] = token
	
	def lookup name, deep = yes
		if name[name.length - 1] == '!'
			name = name.slice(0,-1)

		let res = map.hasOwnProperty(name) and map[name]
		if deep and !res and scope.parent
			return scope.parent.variables.lookup(name)
		if !scope.parent and !res and GlobalVars.hasOwnProperty(name)
			let tok = {value: name, varscope: scope, modifiers:['global'], type: 'variable.global'}
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


export class ImbaDocument

	static def tmp content
		self.new('file://temporary.imba','imba',0,content)

	def constructor uri, languageId, version, content
		uri = uri
		languageId = languageId
		version = version
		content = content
		connection = null

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

	get lineCount
		lineOffsets.length

	get lineOffsets
		_lineOffsets ||= computeLineOffsets(content,yes)
	
	def getText range = null
		if range
			var start = offsetAt(range.start)
			var end = offsetAt(range.end)
			return content.substring(start, end)
		return content

	def getLineText line
		let start = lineOffsets[line]
		let end = lineOffsets[line + 1]
		return content.substring(start, end)
	
	def positionAt offset
		offset = Math.max(Math.min(offset, content.length), 0)
		var lineOffsets = lineOffsets
		var low = 0
		var high = lineOffsets.length
		if high === 0
			return { line: 0, character: offset }
		while low < high
			var mid = Math.floor((low + high) / 2)
			if lineOffsets[mid] > offset
				high = mid
			else
				low = mid + 1
		// low is the least x for which the line offset is larger than the current offset
		// or array.length if no line offset is larger than the current offset
		var line = low - 1
		return { line: line, character: (offset - lineOffsets[line]) }

	def offsetAt position
		if position.offset
			return position.offset

		var lineOffsets = lineOffsets
		if position.line >= lineOffsets.length
			return content.length
		elif position.line < 0
			return 0

		var lineOffset = lineOffsets[position.line]
		var nextLineOffset = (position.line + 1 < lineOffsets.length) ? lineOffsets[position.line + 1] : content.length
		return Math.max(Math.min(lineOffset + position.character, nextLineOffset), lineOffset)

	def overwrite body,newVersion
		version = newVersion or (version + 1)
		content = body
		_lineOffsets = null
		invalidateFromLine(0)
		
		return self

	def update changes, version
		# what if it is a full updaate
		# handle specific smaller changes in an optimized fashion
		# many changes will be a single character etc
		for change,i in changes
			if editIsFull(change)
				overwrite(change.text,version)
				continue

			var range = getWellformedRange(change.range)
			var startOffset = offsetAt(range.start)
			var endOffset = offsetAt(range.end)
			change.range = range
			change.offset = startOffset
			change.length = endOffset - startOffset
			range.start.offset = startOffset
			range.end.offset = endOffset
			# console.log 'update',startOffset,endOffset,change.text,JSON.stringify(content)
			# content = content.substring(0, startOffset) + change.text + content.substring(endOffset, content.length)
			applyEdit(change,version,changes)

			var startLine = Math.max(range.start.line, 0)
			var endLine = Math.max(range.end.line, 0)
			var lineOffsets = self.lineOffsets
			# some bug with these line offsets here
			# many items has no line offset changes at all?

			var addedLineOffsets = computeLineOffsets(change.text, false, startOffset)

			if (endLine - startLine) === addedLineOffsets.length
				for added,k in addedLineOffsets
					lineOffsets[k + startLine + 1] = addedLineOffsets[i]
			else
				if addedLineOffsets.length < 10000
					lineOffsets.splice.apply(lineOffsets, [startLine + 1, endLine - startLine].concat(addedLineOffsets))
				else
					_lineOffsets = lineOffsets = lineOffsets.slice(0, startLine + 1).concat(addedLineOffsets, lineOffsets.slice(endLine + 1))

			var diff = change.text.length - (endOffset - startOffset)
			if diff !== 0
				let k = startLine + 1 + addedLineOffsets.length
				while k < lineOffsets.length
					lineOffsets[k] = lineOffsets[k] + diff
					k++
		
		updated(changes,version)

	def applyEdit change,version,changes
		# apply textual changes
		content = content.substring(0, change.range.start.offset) + change.text + content.substring(change.range.end.offset, content.length)

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
	

	def updated changes,version
		version = version
		self

	def invalidateFromLine line
		if head.line >= line
			let state = lineTokens[Math.max(line - 1,0)] or start
			if state
				tokens.length = state.index
				head = state
				state.context.reopen!
		self


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
			return null
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
			mode: (token.stack ? token.stack.state : '').replace(/\.(\t+|\]|\}|\)|$)/g,'')
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

		if mode == 'css_value'
			context.cssProperty = before(context.token,/style\.property\.name/)
		
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

		console.log 'get tokens',lineCount,codelines

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
				let typ = tok.type

				let match

				if match = tok.type.match(/keyword\.(class|def|set|get|prop|tag|if|for|while|do|elif|unless|try|catch|else)/)
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

				elif typ.match(/^identifier/) and typ != 'identifier.key'
					if let variable = scope.variables.lookup(tok.value)
						tok.variable = variable

						if lastVarRef and lastVarRef.variable == variable
							let between = code.slice(lastVarRef.offset + lastVarRef.value.length - offset,tok.offset - offset)
							# console.log 'same variable',lastVarRef,variable,tok,JSON.stringify(between),next
							if between.match(/^\s*\=\s*$/) and (!next or code.slice(to).match(/^\s*[\,\)]/) or next.type == 'newline')
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
		source = source.replace(/\?\./g,'..')

		source = source.replace(/def ([\w\-]+)\=/g,'set $1')

		source = source.replace(/do\s?\|([^\|]+)\|/g,'do($1)')

		source = source.replace(/(prop) ([\w\-]+) (.+)$/gm) do(m,typ,name,rest)
			let opts = {}
			rest.split(/,\s*/).map(do $1.split(/\:\s*/)).map(do opts[$1[0]] = $1[1] )
			let out = "{typ} {name}"

			if opts.watch and opts.watch[0].match(/[\'\"\:]/)
				out = "@watch({opts.watch}) {out}"
			elif opts.watch
				out = "@watch {out}"
			
			delete opts.watch
			
			if opts.default
				out = "{out} = {opts.default}"
				delete opts.default

			if Object.keys(opts).length
				console.log 'more prop values',m,opts
			return out

		let doc = ImbaDocument.tmp(source)
		let tokens = doc.getTokens!
		let ivarPrefix = ''

		for token,i in tokens

			let next = tokens[i + 1]
			let {value,type,offset} = token
			let end = offset + value.length
			if type == 'operator.dot.legacy'
				value = '.'
				next.access = true if next

			if type == 'operator.spread.legacy'
				value = '...'

			if type == 'identifier.tagname'
				if value.indexOf(':') >= 0
					value = value.replace(':','-')
			if type == 'identifier.def.propname' and value == 'initialize'
				value = 'constructor'
			
			if type == 'decorator' and !source.slice(end).match(/^\s(prop|def|get|set)/)
				value = ivarPrefix + value.slice(1)
			
			if type == 'property'
				if value[0] == '@'
					value = value.replace(/^\@/,ivarPrefix)
					token.access = yes
				elif value == 'len'
					value = 'length'
				elif (/^(\n|\s\:|\)|\,|\.)/).test(source.slice(end)) and !token.access
					if value[0] == value[0].toLowerCase!
						value = value + '!'

			if type == 'identifier' and !token.access and value[0] == value[0].toLowerCase! and value[0] != '_'
				if !token.variable and (/^(\n|\s\:|\)|\,|\.)/).test(source.slice(end)) and value != 'new'
					value = value + '!'

			token.value = value

		return tokens.map(do $1.value).join('')
	