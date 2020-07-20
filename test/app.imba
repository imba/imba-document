import { ImbaDocument } from '../src/index'
import * as utils from '../src/utils'

# import sample from './docs/test.imba.raw'
var sample2 = """
tag hello
	def render
		<self @event.one.two=10>
"""

import {body as sample} from './sample'
import {body as sampleTags} from './sample-tags'

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
	console.log(tokens)
	let depth = 0
	for token in tokens
		let value = token.value
		let types = token.type.split('.')
		let [typ,subtyp] = types

		if token.variable
			types.push('var')
			if token.variable.varscope
				types.push("scope_{token.variable.varscope.type}")
			if token.variable.modifiers
				types.push(...token.variable.modifiers)

		if typ == 'push'
			value = String(++depth)
		elif typ == 'pop'
			value = String(--depth)

		if typ != 'whitez' and typ != 'line'
			# console.log 'classes',types
			value = "<span class='{classify types}' data-offset={token.offset}>{escape(value or '')}</span>"

		if true
			yes
		elif types.indexOf('open') >= 0
			value
			value = "<span class='group'>{value}"

		elif types.indexOf('close') >= 0
			value = "{value}</span>"
		
		parts.push(value)
	return parts.join('')


# let content = migrateLegacyDocument(sample.body)
# let original = ImbaDocument.tmp(sample)
let doc = new ImbaDocument('/source.imba','imba',1,sample)
let outline = utils.fastExtractSymbols(sample)
let fullOutline = utils.fastExtractSymbols(sample)
let x = 1,y = 2

x
console.log outline

tag outline-part

	<self[ff:mono fs:sm]>
		<[d:hflex]>
			<[pr:1 c:gray5]> data.type
			<.name> data.name

		<[pl:4].children> for child in data.children
			<outline-part data=child owner=data>

tag app-root

	def reselected e\Event
		console.log 'selected?!',e
		setTimeout(&,20) do
			let sel = window.getSelection!
			let range = sel.getRangeAt(0)
			let off = range.cloneRange!
			off.setStart(document.querySelector('pre code'),0)
			let loc = off.toString!.length
			let ctx = doc.getContextAtOffset(loc)
			let {token,mode,scope} = ctx
			console.log token
			let stack = []
			let s = token.stack
			while s
				let str = s.state.replace(/\.\t*(?=\.|$)/,do(m) ".{m.length - 1}")
				stack.unshift(str.split('.').slice(0,2).join('.'))
				s = s.parent

			console.log stack.join(" -> ")

	def sendCustom
		let o = {detail: {one: 1}}
		var event = new EditableEvent('stuff',o)
		let res = dispatchEvent(event)
		console.log event,res

	def handleCustom e
		console.log 'handle',e
			
	def render
		<self.hbox.grow[ff:sans] :selectstart.reselected :stuff.handleCustom>
			# <button :click.sendCustom> "custom!"
			<pre> <code innerHTML=highlight(doc.getTokens!) contentEditable='true' spellcheck=false>
			<h2> "Quick outline"
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
	
	.variable td:underline dotted
	.invalid color: red
	.comment color: var(--comment)
	.regexp color:orange4
	.tag color: var(--tag)
	.type color: var(--type)
	.keyword,.argparam color: var(--keyword)
	.operator color: var(--operator)
	.property color: var(--property)
	.numeric,.number color: var(--numeric)
	.boolean color: var(--boolean)
	.null color: var(--null)
	.identifier color: var(--identifier)
	.variable color: var(--variable)
	.string color: var(--string)
	.propname color: var(--entity)
	.this,.self color: var(--this)
	.tag.open,.tag.close color: var(--tag-angle)
	.variable.scope_root color: var(--root-variable)
	.entity.name.class color: var(--entity)
	.entity c:green3
	.field c:blue3
	.unit c:red4
	.type c:purple5
	.identifier.uppercase c:teal3
	.identifier.let,.identifier.const,.identifier.param c:yellow3 bg:gray1/10
	.style c:purple2 .value:purple4 .property:pink4 .modifier:pink4
	.selector c:orange3
	.decorator c:blue5

	.push outline:1px solid green4 d:inline-block
	.pop outline:1px solid red4 d:inline-block

