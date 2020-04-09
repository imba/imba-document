import { ImbaDocument } from '../src/index'

import sample from './docs/test.imba.raw'

class EditableEvent < CustomEvent


def highlight tokens
	let parts = []
	console.log(tokens)
	for token in tokens
		let value = token.value
		let types = token.type.split('.')
		let [typ,subtyp] = types
		

		if token.variable
			types = ['variable']
			if token.variable.varscope
				types.push("scope_{token.variable.varscope.type}")

		if typ != 'white' and typ != 'line'
			value = "<span class='{types.join(' ')}'>{value}</span>"

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
let content = ImbaDocument.tmp(sample.body).migrateToImba2!
let doc = ImbaDocument.new('/source.imba','imba',1,content)

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
			console.log token,mode,scope

	def sendCustom
		let o = {detail: {one: 1}}
		var event = EditableEvent.new('stuff',o)
		let res = dispatchEvent(event)
		console.log event,res

	def handleCustom e
		console.log 'handle',e
			
	def render
		<self.hbox.grow :selectstart.reselected :stuff.handleCustom>
			<button :click.sendCustom> "custom!"
			<pre> <code innerHTML=highlight(doc.getTokens!) contentEditable='true' spellcheck=false>

### css

:root {
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
	--this: #63b3ed;
	--tag: #e9e19b;
	--tag-angle: #9d9755;
	--type: #718096;
	--property: #F7FAFC;
	--root-variable: #c5badc;
	tab-size: 4;
}

:focus {
	outline: none;
}

body {
	color: var(--token);
	background-color: var(--background);
	padding: 80px;
}

pre,code {
	font-family: 'Fira Code Light','Source Code Pro',monospace;
	font-size: 14px;
	font-weight: bold;
}
.invalid { color: red; }
.comment { color: var(--comment); }
.tag { color: var(--tag); }
.type { color: var(--type); }
.keyword,.argparam { color: var(--keyword); }
.operator { color: var(--operator); }
.property { color: var(--property); }
.numeric,.number { color: var(--numeric); }
.boolean { color: var(--boolean); }
.null { color: var(--null); }
.identifier { color: var(--identifier); }
.variable { color: var(--variable); }
.string { color: var(--string); }
.propname { color: var(--entity); }
.this,.self { color: var(--this); }
.tag.open,.tag.close { color: var(--tag-angle); }
.variable.scope_root { color: var(--root-variable); }

###