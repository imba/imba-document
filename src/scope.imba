export class Scope

	def constructor token, parent
		token.scope = self
		self.parent = parent
