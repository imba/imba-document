export const body = '''

export def matchToken token, match
	let typ = token.
	if match isa RegExp
		return typ.match(match)
	elif typeof match == 'string'
		return typ.indexOf(match) == 0 and (!typ[match.length] or typ[match.length] == '.')

let tsServiceOptions\\CompilerOptions = {one: 10}

import {
	one,
	two
} from "util"

export const Keywords = {
	\'and\': KeywordTypes.Keyword
	\'await\': KeywordTypes.Keyword
	\'begin\': KeywordTypes.Keyword
}
class MyArray < Array
	
	
	static def setup
		yes

	def again offset, test
		setTimeout
		test = test
		offset
		offset = offset.hello
		let resolver = do(key,value) value * 2

		a
		123
	
	def other(one,two)
		one + two

	def check one,two do [one,120]

	static def create
		
		self

def getContextAtOffset offset, forwardLooking = no
	return contextAtOffset(offset,forwardLooking)
	setTimeout
	let {a1,b1,b2:c1,b3:c2 = 20} = options

	{a1,b1 = 10,b2:c1} = options
	let {x:{u1,u2},y:[e1,e2]} = options


	let pos\\Something = positionAt(offset)
	let token = getTokenAtOffset(offset,forwardLooking)
	let index = tokens.indexOf(token)
	let line = lineTokens[pos.line]

	let context = {
		offset: offset
		position: pos
		token: token
		line: line.lineContent
		mode: (token.stack ? token.stack.state : '')
		again: pos ? token : index
		scope: line.context
		css: {}
	}
	
tag hello
	def other
		<div> for {item},i in files
			[item,test]
			<a.tab .on=(file==item)> item.name
		yes
	def render
		# <self.{code.flags} .{size} .multi=(files.length > 1) @pointerover.silence=pointerover>
		<self>
			<header[d:none ..multi:block]>
				<span[lh:1.2em ws:nowrap overflow:hidden text-overflow:ellipsis fs:{val[0]}]> "Quick brown fox"
				<div.tabs @click=console.log(e)> for item in files
					<a.tab .on=(file==item) @click=(file=item)> item.name

const x1 = {
	one: 1
	two: 2
	three: 3
}

const x2 =
	one: 1
	two: 2
	three: 3


class A
	def setup
		let x10 = (a && a(b))
		let x20 = (a and a(b))
		x20 = x20
		let x30 = x30
		let x40 = [x30,x40]
"test"

class TokenScope
	def constructor x1,{doc,parent,token,type,line}
		type = type
		indent = line.indent
		start = token.offset
		token = token
		end = null
		endIndex = null
		variables = new Variables(self)

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
		new TokenScope(doc: null, parent: self, token: token, type: type, line: line)
'''

export const bodyz = `
const f1 = 'desc'
import \{imp1,imp2,test as imp3\} from './hello'

let ary = ['single',"double",10]
tag hello
	def setup
		let x = 100
		if something
			
			let y = 100
			imp3(y)
			

		return x * 200

	<self>
		<div.one.two @click.stop> "Test"
		<button[d:inline] disabled>
		<ul[d:block] data=items tabindex=0 @click.self.stop>
			for item in items
				<li.item data=item>
			
css div
	fw:3
	fw:500
	b d:block
	ul fw:500

css fw:400
	fw:300
	fw:300

tag Something
	css fw:3
		fw:500

	def render
		yes

css div fw:400
	fw:500
	.again fw:30
		fw:10
		.test color:red
		test:
			shadow
			other

yes
css div
	fw:500
yes

export class Hello

	def render param
		[f1,n1]
		param = param

	def other
		[1,4,5,3].map do(item,i)
			if let diff = (item - i)
				i * 2 + diff
		yes

	get again
		[1,2,3]

	def setup
		def walk item
			item
			walk
		
		return self

tag Something2
	css div
		b d:block
		ul fw:500
			li fw:400
				color:red2
	def render
		<self>
			<div @click.prevent.something=log(e,e.test)>

`

export const body4 = `
const f1 = 'desc'
import \{imp1,imp2,test as imp3\} from './hello'

export class Hello

	def render param
		[f1,n1]
		param = param

	def other
		[1,4,5,3].map do(item,i)
			if let diff = (item - i)
				i * 2 + diff
		yes

	get again
		[1,2,3]

	def setup
		def walk item
			item
			walk
		
		return self

tag Something
	css div
		b d:block
		ul fw:500
			li fw:400
				color:red2
	def render
		<self>
			<div @click.prevent.something=log(e,e.test)>

tag testing-this
	<self>
		<div> <b> "yes!"
		<div.test .one.large child=(<ul> 'test') @click.prevent.ctrl=log> 'hello'
		<section[d:block .test:inline]>

class Other < Hello
	def again
		yes

tag hello < other

	css hello
		ff:sans
		color:blue4
		content: "hello"
		width: calc(100vw + 20%)
	
	static def test a,...test
		a + 10

	def render
		<self>
			<div>
			for [item,test],i in data
				<ul> item
				
			<div[height:\{h\}px] title="hello" data=[1,2,3]>
				<b data=/tester/ hello=one+2 again=10 test=log disabled hello=10>
				<b> "hello"
				<b> "again"
			<ul> <li> <again>
				<b> 'test'
			<div>
			<input/>
			<span> 'test'
			
		return
	
	def setup a,b,\{one,two = 20\}
		try
			something
		catch e
			yes
		
		do(item,i)
			item * i

		[1,2,3].map do(item,i)
			item * i
		yes

let el = <div.one.two title=something>
let other = <section> el

`

export const body2 = `
if true
	10
else
	5

const f1 = 'desc'
const c1 = [f1,1,2], c2 = 'hello',[c3,c4] = [f1,2],c5 = f1

let i1 = api.load 1,f1
let i2 = API.load(1,f1)

import \{imp1,imp2,test as imp3\} from './hello'

export class Hello < Other # hello

	def render param
		[i1,i2,n1]
		param = param
		yes

	def other
		[1,4,5,3].map do(item,i)
			if let diff = (item - i)
				i * 2 + diff
		yes
	def again
		[1,2,3]

tag hello < other

	one\\number = 10 # testing
	@watch other
	again\\number[] = [1,2,3,this.test]

	css hello
		ff:sans
		color:blue4
		content: "hello"
		width: calc(100vw + 20%)
	
	static def test a,...test
		a + 10

	def render
		<self>
			<div>
			for [item,test],i in data
				<ul> item
				
			<div[height:\{h\}px] title="hello" data=[1,2,3]>
				<b data=/tester/ hello=one+2 again=10 test=log disabled hello=10>
				<b> "hello"
				<b> "again"
			<ul> <li> <again>
				<b> 'test'
			<div>
			<input/>
			<span> 'test'
			
		return
	
	def setup a,b,\{one,two = 20\}
		try
			something
		catch e
			yes
		
		do(item,i)
			item * i

		[1,2,3].map do(item,i)
			item * i
		yes

let el = <div.one.two title=something>
let other = <section> el
`