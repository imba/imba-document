import { ImbaDocument,lexer } from '../src/index'
import * as utils from '../src/utils'
import {M} from '../src/types'

# import sample from './docs/test.imba.raw'

window.LEXER = lexer
var sample2 = """
tag hello
	def render
		<self @event.one.two=10>
"""

import {body as sample} from './sample'
import {body as sampleTags} from './sample-tags'

# let rawtokens = lexer.tokenize(sample,lexer.getInitialState!,0)
# console.log 'rawtokens',rawtokens

lexer.stats = do
	let rows = []
	let statestats = []
	for own name,rules of lexer._lexer.tokenizer
		let state = {
			name: name
			time: 0
			count: 0
		}
		# rows.push(state)

		for rule in rules
			let s = rule.stats
			state.time += s.time
			state.count += s.count
			if s.count > 0
				let reg = rule.name.slice(rule.name.indexOf(': ') + 2)
				reg = reg.replace(/anyIdentifier/g,'id')
				# continue unless rule.string

				rows.push({
					state: name
					# rule: rule.regex
					raw: reg
					regex: rule.regex
					tot: Math.floor(s.time * 1000)
					avg: Math.floor((s.time * 100000) / s.count)
					count: s.count
					hits: s.hits
				})

	rows = rows.sort do(a,b) return b.tot - a.tot
	# console.table(rows.slice(0,100))
	console.table(rows)

class EditableEvent < CustomEvent

const replacements = {
	'&': '&amp;',
	'<': '&lt;',
	'>': '&gt;',
	'"': '&quot;',
	"'": '&#39;'
};

const typenames = {
	'[': 'square open'
	']': 'square close'
	'{': 'curly open'
	'}': 'curly close'
	'(': 'paren open'
	')': 'paren close'
}

def escape str
	str.replace(/[\&\<\>]/g) do(m) replacements[m]

def classify types
	types.join(' ').replace(/[\[\]\{\}\(\)]/g) do(m) typenames[m]

def highlight tokens
	let parts = []
	# console.log(tokens)
	let depth = 0
	let counter = 0
	let ids = []
	# tokens = analyze(tokens)

	for token in tokens
		let value = token.value
		let types = token.type.split('.')
		let [typ,subtyp] = types
		let mods = token.mods

		if token.var
			let id = ids.indexOf(token.var)
			if id == -1
				id = ids.push(token.var) - 1
			types.push('vref')
			types.push('var'+id)
			types.push(token.var.type + '-ref')
			mods |= token.var.mods
			# if token.var.token == token
			#	types.push('decl')

		if mods & M.Declaration
			types.push('decl')

		if mods & M.Root
			types.push('root')

		if mods & M.Local
			types.push('local')

		if subtyp == 'start' or subtyp == 'open'
			parts.push("<b class='{typ}'>")
			continue unless value

		if (subtyp == 'end' or subtyp == 'close') and !value
			parts.push('</b>')
			continue

		if typ == 'push'
			value = String(++depth)
			let kind = subtyp.indexOf('_') >= 0 ? 'group' : 'scope'
			let end = token.scope && token.scope.end
			parts.push("<div class='{kind}-{subtyp.split('_').pop!} _{subtyp} l{depth} o{token.offset} e{end && end.offset}'>")
			continue
		elif typ == 'pop'
			value = String(--depth)
			parts.push("</div>")
			continue

		if typ != 'white' and typ != 'line'
			value = "<i class='{classify types} o{token.offset}'>{escape(value or '')}</i>"
		elif typ == 'white' and value != '\n'
			value = "<i raw='{JSON.stringify(value)}'>{escape(value or '')}</i>"

		parts.push(value)

		if subtyp == 'end' or subtyp == 'close'
			parts.push('</b>')

	return parts.join('')


# let content = migrateLegacyDocument(sample.body)
# let original = ImbaDocument.tmp(sample)
let doc = new ImbaDocument('/source.imba','imba',1,sample)
# let outline
# = utils.fastExtractSymbols(sample)
# let fullOutline = utils.fastExtractSymbols(sample)
# let x = 1,y = 2
# console.log outline
# console.log 'parsed:',doc.parse!

tag outline-part

	<self[ff:mono fs:sm]>
		<[d:hflex]>
			<[pr:1 c:gray5]> data.kind
			<.name> data.name

		<[pl:4].children> for child in data.children
			<outline-part data=child owner=data>

tag app-root
	hlvar = null
	outline = null

	def reselected e\Event
		console.log 'selected?!',e
		setTimeout(&,20) do
			doc.parse!
			let sel = window.getSelection!
			let range = sel.getRangeAt(0)
			let off = range.cloneRange!
			off.setStart(document.querySelector('pre code'),0)
			let loc = off.toString!.length
			let token = doc.tokenAtOffset(loc)
			let ctx = doc.contextAtOffset(loc)
			# console.log 'got token',token,token.context

			if ctx
				for own k,v of ctx
					let t = typeof v
					if t == 'number'
						console.log k,v
					if t == 'string'
						console.log k,[v]
						
				console.log 'scope',ctx.scope
				console.log 'token',ctx.token
				# console.log ctx.scope.closest(/class|tag/)
				# console.log ctx.scope.path

			# return
			if token.var
				console.log 'variable',token.var

			console.log doc.varsAtOffset(loc,yes)

			if false
				console.group 'stack'
				# let ctx = doc.getContextAtOffset(loc)
				# let {token,mode,scope} = ctx
				# console.log token
				let stack = []
				let s = token.stack
				while s
					# let str = s.state.replace(/\.\t*(?=\.|$)/,do(m) ".{m.length - 1}")
					let [lexstate,indent = '',scope = '',flags = '',extra = ''] = s.state.split('.')
					# stack.unshift(str.split('.').slice(0,2).join('.'))
					stack.push("{lexstate}|{scope.slice(1)}({indent.length})")
					# stack.unshift(str)
					s = s.parent
				console.log stack[0] # .join(" -> ")
				console.log token.stack
				console.log stack.join(" -> ")

				console.log doc.getNavigationTree!
				
				console.groupEnd!
	
	def pointerover e
		let vref = null
		if let el = e.target.closest('.vref')
			vref = el.className.split(/\s+/g).find do (/var\d+/).test($1)
		
		if vref != hlvar
			if hlvar
				el.classList.remove('highlight') for el in getElementsByClassName(hlvar)
			if vref
				el.classList.add('highlight') for el in getElementsByClassName(vref)
			hlvar = vref

	def sendCustom
		let o = {detail: {one: 1}}
		var event = new EditableEvent('stuff',o)
		let res = dispatchEvent(event)
		console.log event,res

	def handleCustom e
		console.log 'handle',e
	
	def mount
		render!
		# doc.getTokens!
		$code.innerHTML = highlight(doc.parse!)
		# console.log 'tokens',doc.tokens
		console.log doc.getNavigationTree!
		console.log doc.getSemanticTokens!
		console.log doc.getEncodedSemanticTokens!
		outline = doc.getNavigationTree!
		# $code2.innerHTML = highlight(rawtokens.tokens)

	def profile times, prof = no
		let t = Date.now!
		console.log 'starting profile',times
		lexer._profile = prof
		console.profile('parse')
		while --times > 0
			doc.reparse!
		console.profileEnd('parse')
		console.log 'took',Date.now! - t
		lexer.stats!
		self
			
	def render
		<self.hbox.grow[ff:sans] @selectstart=reselected  @pointerover=pointerover>
			# <button :click.sendCustom> "custom!"
			<button @click=profile(1000,no)> 'profile'
			<button @click=profile(50,yes)> 'measure'
			<pre> <code$code contentEditable='true' spellcheck=false>
			# <pre> <code$code2 contentEditable='true' spellcheck=false>
			if outline
				<outline-part data=outline>
			# <pre> <code innerHTML=highlight(original.getTokens!) contentEditable='true' spellcheck=false>


global css @root
	--token: #E3E3E3;
	--identifier: #9dcbeb;
	--background: #282c34;
	--comment: #718096;
	--keyword: #e88376;
	--operator: #e88376;
	--numeric: #63b3ed;
	--boolean: #4299e1;
	--null: #4299e1;
	--entity: #8ab9ff;
	--variable: #e8e6cb;
	--string: #c6f6d5;
	--entity: #8ab9ff;
	--regexp: #e9e19b;
	--this: #63b3ed;
	--tag: #e9e19b;
	--tag-angle: #9d9755;
	--type: #718096;
	--property: #F7FAFC;
	--root-variable: #c5badc;

	--var-decl: blue3;
	tab-size: 4;

	i,b fw:500 font-style:normal

	*@focus
		outline: none

	body
		color: var(--token)
		background-color: var(--background)
		padding: 20px

	pre,code
		ff: 'Fira Code Light','Source Code Pro',monospace
		fw: bold
		fs: 13px/1.3
	
	pre div d:inline

	.variable td:underline dotted
	.invalid color: red
	.comment color: var(--comment)
	.regexp color:orange4
	i.tag color: var(--tag)
	.type color: var(--type)
	i.keyword,.argparam color: var(--keyword)
	.operator color: var(--operator)
	.property color: var(--property)
	.numeric,.number color: var(--numeric)
	.boolean color: var(--boolean)
	.null color: var(--null)
	.identifier color: var(--identifier)
	.variable color: var(--variable)
	.string color: var(--string)
	.path color: var(--string)
	.propname color: var(--entity)
	.this,.self color: var(--this)
	.tag.open,.tag.close color: var(--tag-angle)
	.variable.scope_root color: var(--root-variable)
	.entity.name.class color: var(--entity)
	.entity c:green3
	.field c:blue3
	.unit c:red4
	.type c:purple5
	.uppercase c:teal3
	.decl c:yellow2 .def:green3
	.style c:purple2 .value:purple4 .property:pink4 .modifier:pink4
	.selector c:orange3
	.decorator c:blue5
	.key c:blue3
	.vref c:yellow2/85 .root:indigo4
	# .vref.decl bdb:1px solid
	.operator.key-value c:blue3
	.push outline:1px solid green4 d:inline-block
	.pop outline:1px solid red4 d:inline-block
	.highlight bg:yellow3/20
	.scope bg:gray3/2

	.group-sel bg:yellow3/10 br:sm
	.group-prop > .group-name bg:black/10 br:sm

