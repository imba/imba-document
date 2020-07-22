export const body = `

css div
	fw:3 t:2
	fw:500
	# test
	b d:block
		ul fw:500
	bg:red3 .clear:red5
	fw:2
	section # something
		fw:1

test
`

export const bodyX = `

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