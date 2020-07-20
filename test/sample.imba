export const body = `
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

export const body2 = `
const field = 'desc'
const one = [field,1,2], two = 'hello',[x,y] = [field,2],t = field
let [ha,hb] = [two,one]
let [ha,hb = one] = [1,2,3]
let item = api.load 1,field
let item = API.load(1,field)

export let item = 100
export stuff from './helo'
import \{X,y,test as something\} from './hello', test
import test from './hello'

/hello/

Math.random! > 0.5 ? true : false

console.Log

console.log 'hello'

if test
	yes

class test

class test
	def render
		yes

export class Hello < Other # hello
	
	def render
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