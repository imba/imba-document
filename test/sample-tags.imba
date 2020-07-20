export const body = `
[1,2,3]
const field = 'desc'
const one = [field,1,2], two = 'hello',[x,y] = [field,2],t = field
let [ha,hb] = [two,one]
let item = api.load 1,field
let item = API.load(1,field)
let a = x: b
let a = x + y, b = a * 10
let a = x y,b
let a = x[10] y,b
let a = x[10][20] y,b
let a = x[1 + 2] y,b
let \{a,b,c = field\} = object
let \{a: aa,b = 120,c: dd = field\} = object

["string",'string',"\{123\} string",Buffer,123.45,10px]
\{a:1,b:2,[field]:4\}
if true
	let x = 10
	x + a
else
	let x = 20
	x + a

global css test ff:sans
	bg:blue1 fs:10px .test:20px
	.other fw:500
	& .again fw:600
	bg:
		red2 again here
		testing this 20px,
		'test'
	grid-template-areas: 
		"left top right"
		"left bottom right"


let x = if true
	10
else
	20

let x2 =
	y2

let x1 = 10

let x =
	a1: 10
	b1: 22

let x = \{
	a2: 10
	b2: 20
\}
a[10] 'hello'
a 'hello'


class Two

	title
	description

	get item
		get hello
		self
	
	get [field]
		data[field]

	# def other
		yes

	def mult a,b
		a * b

	def [field2] a,b = 20
		hello
		return self

get hello

if true or false
	something

Math.if
	1
	2

if Math.test
	1
	2

class Three
	get data
		yes

class Test get
	yes
tag hello
	def render
		<self @event.one.two=10>
			<ul> <li>
				<b> 'test'
`