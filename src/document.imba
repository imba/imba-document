import {computeLineOffsets,getWellformedRange,getWellformedEdit,mergeSort,editIsFull,editIsIncremental} from './utils'
import { lexer, Token } from './lexer'
import * as util from './utils'
import { Root, Scope, Group } from './scope'
const newline = String.fromCharCode(172)

import {SemanticTokenTypes,SemanticTokenModifiers,M} from './types'

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

export class ImbaDocument

	static def tmp content
		new self('file://temporary.imba','imba',0,content)

	def constructor uri, languageId, version, content
		uri = uri
		languageId = languageId
		version = version
		content = content
		connection = null
		lineTokens = []
		head = seed = {type: 'eol', offset:0, state: lexer.getInitialState!}
		tokens = []

	def log ...params
		console.log(...params)

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
		head = seed
		tokens = []
		self


	def after token, match
		let idx = tokens.indexOf(token)
		if match
			while idx < tokens.length
				let tok = tokens[++idx]
				if tok && matchToken(tok,match)
					return tok
			return null
		return tokens[idx + 1]

	def matchToken token, match
		if match isa RegExp
			return token.type.match(match)
		elif typeof match == 'string'
			return token.type == match
		return false
	
	def before token, match, offset = 0
		let idx = tokens.indexOf(token) + offset
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
		return tokenAtOffset(offset)

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
		parse!
		tokens.filter do !!$1.var

	def getEncodedSemanticTokens
		let tokens = getSemanticTokens!
		let out = []
		let l = 0
		let o = 0
		for tok,i in tokens
			let pos = positionAt(tok.offset)
			let typ = SemanticTokenTypes.indexOf('variable')

			let mods = tok.mods
			let line = pos.line

			if tok.var
				mods |= tok.var.mods

			let dl = pos.line - l
			let chr = dl ? pos.character : (pos.character - o)
			out.push(dl,chr,tok.value.length,typ,mods)
			l = pos.line
			o = pos.character

		return out

	def tokenAtOffset offset
		let tok = tokens[0]
		while tok
			let next = tok.next
			if tok.offset >= offset
				return tok.prev 
			
			# jump through scopes
			if tok.end and tok.end.offset < offset
				# console.log 'jumping',tok.offset,tok.end.offset
				tok = tok.end
			else
				tok = next
		return tok

	def contextAtOffset offset
		ensureParsed!

		let pos = positionAt(offset)
		let tok = tokenAtOffset(offset)
		let linePos = lineOffsets[pos.line]
		let tokPos = offset - tok.offset
		let ctx = tok.context
		let tabs = util.prevToken(tok,"white.tabs")
		let indent = tabs ? tabs.value.length : 0
		let scope = ctx.scope
		let meta = {}

		if tok == tabs
			indent = tokPos

		while scope.indent > indent
			scope = scope.parent

		let out = {
			token: tok
			offset: offset
			position: pos
			linePos: linePos
			scope: scope
			indent: indent
			group: ctx
			mode: ''
			path: scope.path
			textBefore: content.slice(linePos,offset)
			textAfter: content.slice(offset,lineOffsets[pos.line + 1])
			before: {
				token: tok.value.slice(0,tokPos)
			}
			after: {
				token: tok.value.slice(tokPos)
			}
		}

		return out

	def varsAtOffset offset, globals? = no
		let tok = tokenAtOffset(offset)
		let vars = []
		let scope = tok.context.scope
		let names = {}

		while scope
			for item in Object.values(scope.varmap)
				continue if item.type == 'global' and !globals?
				continue if names[item.name]

				if item.offset < offset
					vars.push(item)
					names[item.name] = item

			scope = scope.parent
		return vars

	def getNavigationTree walker
		let outline = {
			children: []
		}
		let options = {
			entities: []
		}
		let all = []
		options.visit = do(item)
			if item.span
				item.span.start = positionAt(item.span.offset)
				item.span.end = positionAt(item.span.offset + item.span.length)

			all.push(item)

			if walker isa Function
				walker(item)
			
		ensureParsed!
		if seed.scope
			let res = seed.scope.outline(outline,options)
			return res

		return outline

	def getContextAtOffset offset, forwardLooking = no
		return contextAtOffset(offset)

		let pos = positionAt(offset)
		let token = getTokenAtOffset(offset,forwardLooking)
		let index = tokens.indexOf(token)
		let line = lineTokens[pos.line]
		let prev = tokens[index - 1]
		let next = tokens[index + 1]

		let tokenOffset = offset - token.offset

		let context = {
			offset: offset
			position: pos
			token: token
			line: line.lineContent
			textBefore: line.lineContent.slice(0,offset - line.offset)
			textAfter: line.lineContent.slice(offset - line.offset)
			mode: (token.stack ? token.stack.state : '').replace(/\.(\t+|\]|\}|\)|$)/g,'')
			scope: line.context
			css: {}
		}

		context.left = token.offset == offset ? prev : token
		let ltyp = context.left ? context.left.type : ''
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

		if ltyp == 'style.property.modifier.prefix' or ltyp == 'style.property.modifier'
			context.cssProperty = before(context.token,/style\.property\.name/)
			mode = 'css_modifier'

		if mode == 'css_selector'
			if ltyp == 'style.selector.element' and !context.textAfter
				context.css.property = 1
	
			if let end = after(context.token,/^style\.property|line/)
				let selafter = content.slice(offset,end.offset).replace(/(^\s+)|([\s\n]+$)/g,'')
				context.cssSelector = {after: selafter}

				if selafter == ''
					context.css.property = 1

		if mode == 'css_value'
			context.cssProperty = before(context.token,/style\.property\.name/)
			context.css.value = 1

			if let propstart = before(context.token,'style.property.operator',1)

				let vbefore = content.slice(propstart.offset,offset).replace(/^\s*\:\s*/,'')
				context.cssValue = {before: vbefore,index: vbefore.split(/\s+/g).length - 1}
				if context.cssValue.index > 0
					context.css.property = 1

			if ltyp.match(/value\.white/)
				context.css.property = 1
				# context.css.modifier = 1

		if ltyp.match(/(selector|property)\.modifier/)
			mode = 'css_modifier'
			context.css.modifier = 1

		if mode.match(/^css_/)
			context.css[mode.slice(4)] ||= yes
		
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
		
		context.css = null if Object.keys(context.css).length == 0
		return context
			

	def ensureParsed
		parse! if self.head.offset == 0
		return self

	def reparse
		invalidateFromLine(0)
		parse!

	def parse
		let head = seed

		if head != self.head
			return self.tokens

		let t0 = Date.now!
		let raw = content
		let lines = lineOffsets
		let tokens = []
		let prev = head
		let entity = null
		let scope = new Root(seed,null,'root')
		let log = console.log.bind(console)

		log = do yes

		try
			for line,i in lines
				let entityFlags = 0
				let next = lines[i+1]
				let str = raw.slice(line,next or raw.length)
				let lexed = lexer.tokenize(str,head.state,line)

				for tok,ti in lexed.tokens
					let types = tok.type.split('.')
					let value = tok.value
					let nextToken = lexed.tokens[ti + 1]
					let [typ,subtyp,sub2] = types

					tokens.push(tok)
					
					if prev
						prev.next = tok
						tok.prev = prev
						tok.context = scope

					if typ == 'operator'
						tok.op = tok.value.trim!

					if typ == 'keyword'
						if subtyp == 'static'
							entityFlags |= M.Static
						elif subtyp == 'export'
							entityFlags |= M.Export
					
					if typ == 'entity'
						tok.mods |= entityFlags
						entityFlags = 0

					if typ == 'push'
						let idx = subtyp.lastIndexOf('_')
						let ctor = idx >= 0 ? Group : Scope
						# log " ".repeat(sub2) + tok.type
						scope = tok.scope = new ctor(tok,scope,subtyp,types)
						ctor
					elif typ == 'pop'
						# log " ".repeat(sub2) + tok.type
						scope = scope.pop(tok)
					
					if typ == 'identifier'
						if subtyp == 'const' or subtyp == 'let' or subtyp == 'param'
							scope.declare(tok,subtyp)
						elif subtyp == 'key' and sub2 == 'param'
							scope.declare(tok,sub2)
						else
							scope.lookup(tok)
							# hardcoded fallback handling
							if prev && prev.op == '=' and tok.var
								let lft = prev.prev
								if lft && lft.var == tok.var
									if lft.mods & M.Declaration
										tok.var.dereference(tok)
									elif !nextToken or nextToken.match('br')
										lft.var.dereference(lft)

					prev = tok

				head = {state: lexed.endState, offset: (next or content.length)}
		catch e
			console.log 'parser crashed',e
			# console.log tokens
		
		# console.log 'parsed',tokens.length,Date.now! - t0
		self.head = head
		self.tokens = tokens
		return tokens


	# This is essentially the tokenizer
	def getTokens range
		parse!
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
	