import * as util from './utils'

export class Entity

	static def for token
		let ent = new Entity(token)

	def constructor token,context,value = null
		token = token
		context = context
		value = value

		token.entity = this
		context.entities.push(self)

	get decl
		token

	get name
		token.value
	
	def inspect
		console.log "entity {token.type}"

export class Var
	def constructor token,typ,value = null
		type = typ
		token = token
		value = value
		refs = []

	get name
		token.value
	
	def inspect
		# console.log "{type} {name}"
		if value
			value.inspect!
		else
			console.log "{type} {name}"

export class Scope

	def constructor token, parent, type
		start = token
		end = null
		type = type
		children = []
		entities = []
		refs = []
		vars = Object.create(parent ? parent.vars : {})
		token.scope = self
		self.parent = parent
		setup!
		return self

	def setup
		if class? or def?
			ident = token = util.prevToken(start,"entity.{type}")
			keyword = util.prevToken(start,"keyword.{type}")
			# console.log "scope {type} {name}",ident,keyword
			if parent.class?
				parent.entities.push(self)
			elif ident
				if tag? and !ident.type.match(/\.local$/)
					parent.entities.push(self)
				else
					parent.declare(ident,'const',self)
	
	get tag?
		type.match(/^tag/)
		
	get class?
		type.match(/^class/) or tag?
	
	get def?
		type.match(/def|get|set/)

	get flow?
		type.match(/if|else|elif|unless|for|while|until/)

	get name
		ident ? ident.value : ''

	def visit
		self

	def pop end
		end = end
		end.start = start
		start.end = end
		visit!
		return parent

	def declare token, typ, value
		token.var = new Var(token,typ,value)
		entities.push(token.var)
		vars[token.var.name] = token.var

	def lookup token
		if let variable = vars[token.value]
			variable.refs.push(token)
			token.var = variable
			return token.var
		return null

	def register token
		entities.push(token)

	def inspect
		# console.log "{ind}{type} {name}"
		let grp = "{type} {name}"
		console.group(grp)
		for entity in entities
			entity.inspect!
		console.groupEnd(grp)

export class Root < Scope

export class Class < Scope

export class Method < Scope

export class Flow < Scope

export class Group
	def constructor token, parent, type
		start = token
		end = null
		type = type
		token.scope = self
		self.parent = parent
		return self

	get vars
		parent.vars

	def pop end
		end = end
		end.start = start
		start.end = end
		return parent

	def declare token, typ, value
		return parent.declare(...params)

	def lookup token
		return parent.lookup(...params)