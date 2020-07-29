import * as util from './utils'
import {M} from './types'

export const Globals = {
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

export class Var
	def constructor token,typ,value = null, scope = null
		type = typ
		mods = 0
		token = token
		name = token.value
		value = value
		refs = []
		token.mods |= M.Declaration

		if scope and scope isa Root
			mods |= M.Root
		else
			mods |= M.Local

	get offset
		token.offset

	get loc
		[token.offset,token.value.length]

	def dereference tok
		let idx = refs.indexOf(tok)
		if idx >= 0
			tok.var = null
			refs.splice(idx,1)
		return self

	def reference tok
		refs.push(tok)
		tok.var = self
		return self
	
	def inspect
		if value
			value.inspect!
		else
			console.log "{type} {name}"

	def toJSON
		{
			kind: type
			name: name
			span: token.span
		}

	def outline ctx, o = {}
		if value
			return value.outline(ctx,o)
		else
			let obj = toJSON!
			o.visit(obj,self) if o.visit
			ctx.children.push(obj) if ctx.children
			return obj

export class Scope

	def constructor token, parent, type, parts = []
		start = token
		end = null
		type = type
		children = []
		entities = []
		refs = []
		varmap = Object.create(parent ? parent.varmap : {})

		if self isa Root
			for own key,val of Globals
				let tok = {value: key, offset: -1, mods: 0}
				varmap[key] = new Var(tok,'global',null,self)
				varmap[key].mods |= M.Global

		indent = parts[3] ? parts[3].length : 0

		token.scope = self
		self.parent = parent
		setup!
		return self

	def closest ref
		return self if match(ref)
		return parent ? parent.closest(ref) : null

	def match query
		if typeof query == 'string'
			return type.indexOf(query) >= 0
		elif query isa RegExp
			return query.test(type)
		return yes

	def setup
		if handler?
			varmap.e = new Var({value: 'e', offset: 0})
			# self.declare()
			# add virtual vars

		if class? or property?
			ident = token = util.prevToken(start,"entity.{type}")
			keyword = util.prevToken(start,"keyword.{type}")

			if ident && ident.type == 'entity.def.render'
				$name = 'render'
			if parent.class?
				parent.entities.push(self)
			elif ident
				if tag? and !ident.type.match(/\.local$/)
					parent.entities.push(self)
				else
					parent.declare(ident,'const',self)
	
	get path
		let par = parent ? parent.path : ''
		
		if property?
			let sep = static? ? '.' : '#'
			return parent ? "{parent.path}{sep}{name}" : name

		if class?
			return name

		return par

	get tag?
		!!type.match(/^tag/)

	get root?
		self isa Root
		
	get class?
		!!type.match(/^class/) or tag?
	
	get def?
		!!type.match(/def|get|set/)

	get static?
		ident && ident.mods & M.Static
	
	get handler?
		!!type.match(/handler/)

	get member?
		!!type.match(/def|get|set/)
	
	get property?
		!!type.match(/def|get|set/)

	get flow?
		!!type.match(/if|else|elif|unless|for|while|until/)

	get scope
		self

	get name
		$name or (ident ? ident.value : '')

	get variables
		entities.filter do $1 isa Var

	def visit
		self

	def pop end
		end = end
		end.start = start
		start.end = end
		visit!
		return parent

	def declare token, typ, value
		token.var = new Var(token,typ,value,self)
		entities.push(token.var)
		varmap[token.var.name] = token.var

	def lookup token
		if let variable = varmap[token.value]
			variable.reference(token)
			return variable # token.var
		return null

	def register token
		entities.push(token)

	def inspect
		# console.log "{ind}{type} {name}"
		let grp = "{type} {name}"
		console.group(grp)
		for entity in entities
			entity.inspect!
		console.groupEnd!

	def outline ctx, o = {}
		let item = {
			kind: type
			name: name
			children: []
			span: ident ? ident.span : start.span
		}

		ctx.children.push(item) if ctx
		
		if o.visit
			o.visit(item,self)

		for entity in entities
			entity.outline(item,o)

		return item

export class Root < Scope

export class Class < Scope

export class Method < Scope

export class Flow < Scope

export class Group
	def constructor token, parent, type, parts = []
		start = token
		end = null
		type = type
		token.scope = self
		self.parent = parent
		return self

	get scope
		parent.scope

	get varmap
		parent.varmap

	def pop end
		end = end
		end.start = start
		start.end = end
		return parent

	def declare ...params
		return parent.declare(...params)

	def lookup ...params
		return parent.lookup(...params)