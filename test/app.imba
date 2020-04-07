import { ImbaDocument } from '../src/index'

def highlight tokens
	let parts = []
	console.log(tokens)
	for token in tokens
		let value = token.value
		let types = token.type.split('.')
		let [typ,subtyp] = types
		

		if token.variable
			types = ['variable']

		if typ != 'white' and typ != 'line'
			value = "<span class='{types.join(' ')}'>{value}</span>"

		parts.push(value)
	return parts.join('')

let source = `

let top = 1

class Hello
	prop three = 3
	prop str = "hello"
	attr main-ref

	def constructor uri, languageId, version, content
		uri = uri
		languageId = languageId
		version = version
		content\\number = content
		cache = []

	get value
		1

	def render
		"string \{10\}"
		'string'
		true
	
	def again one, two
		let x = 1
		let [b,c] = [2,3]
		[one,two,three,x,b,c,top]
		self.test

	def more one, two
		for \{name,desc},i of global.items
			name + desc
		name = 'hello'
		let obj = \{
			one: 1
			two: 2
			three: 3
			'four': 4
		}
	
	def special one
		one = one
		let three = three
		let item = str.slice 1, two
		let fn = do(x,y) [x,y,one,two]
		x + y
		for item in items do yes
		return one > 2 ? 10 : "something"

	def render
		<self>
			<div.one.two §counter=three title=top> "hello"
`

let locs = []
while source.indexOf('§') >= 0
	let idx = source.indexOf('§')
	locs.push(idx)
	source = source.slice(0,idx) + source.slice(idx + 2)

console.log locs


let doc = ImbaDocument.new('file:///source.imba','imba',1,source)

console.log doc
for loc in locs
	let ctx = doc.getContextAtOffset(loc)
	console.log ctx

tag app-root
	def render
		<self.hbox.grow>
			<pre> <code innerHTML=highlight(doc.getTokens!)>

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
	tab-size: 4;
}

body {
	color: var(--token);
	background-color: var(--background);
	padding: 80px;
}

pre,code {
	font-family: 'Fira Code Light','Source Code Pro',monospace;
	font-size: 14px;
}

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

###