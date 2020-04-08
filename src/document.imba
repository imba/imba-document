import {computeLineOffsets,getWellformedRange,getWellformedEdit,mergeSort,editIsFull,editIsIncremental} from './utils'

var documentCache = {}

export class Document

	static def create uri, languageId, version, content
		return self.new(uri,languageId,version,content)

	static def update document, changes, version
		document.update(changes,version)
		return document

	static def isFull e
		return e !== undefined && e !== null && typeof e.text === 'string' && e.range === undefined

	static def isIncremental e
		return !isFull(e) && (e.rangeLength === undefined or typeof e.rangeLength === 'number')

	def constructor uri, languageId, version, content
		uri = uri
		languageId = languageId
		version = version
		content = content
		cache = {}
		connection = null

	get lineCount
		lineOffsets.length

	get lineOffsets
		_lineOffsets ||= computeLineOffsets(content,yes)
	
	def getText range = null
		if range
			var start = offsetAt(range.start)
			var end = offsetAt(range.end)
			return content.substring(start, end)
		return content

	def getLineText line
		let start = lineOffsets[line]
		let end = lineOffsets[line + 1]
		return content.substring(start, end)
	
	def positionAt offset
		offset = Math.max(Math.min(offset, content.length), 0)
		var lineOffsets = lineOffsets
		var low = 0
		var high = lineOffsets.length
		if high === 0
			return { line: 0, character: offset }
		while low < high
			var mid = Math.floor((low + high) / 2)
			if lineOffsets[mid] > offset
				high = mid
			else
				low = mid + 1
		// low is the least x for which the line offset is larger than the current offset
		// or array.length if no line offset is larger than the current offset
		var line = low - 1
		return { line: line, character: (offset - lineOffsets[line]) }

	def offsetAt position
		if position.offset
			return position.offset

		var lineOffsets = lineOffsets
		if position.line >= lineOffsets.length
			return content.length
		elif position.line < 0
			return 0

		var lineOffset = lineOffsets[position.line]
		var nextLineOffset = (position.line + 1 < lineOffsets.length) ? lineOffsets[position.line + 1] : content.length
		return Math.max(Math.min(lineOffset + position.character, nextLineOffset), lineOffset)

	def overwrite body,newVersion
		version = newVersion or (version + 1)
		content = body
		_lineOffsets = null
		return self

	def update changes, version
		# what if it is a full updaate
		# handle specific smaller changes in an optimized fashion
		# many changes will be a single character etc
		for change,i in changes
			if editIsFull(change)
				overwrite(change.text,version)
				continue

			var range = getWellformedRange(change.range)
			var startOffset = offsetAt(range.start)
			var endOffset = offsetAt(range.end)
			change.range = range
			change.offset = startOffset
			change.length = endOffset - startOffset
			range.start.offset = startOffset
			range.end.offset = endOffset
			# console.log 'update',startOffset,endOffset,change.text,JSON.stringify(content)
			# content = content.substring(0, startOffset) + change.text + content.substring(endOffset, content.length)
			applyEdit(change,version,changes)

			var startLine = Math.max(range.start.line, 0)
			var endLine = Math.max(range.end.line, 0)
			var lineOffsets = _lineOffsets

			# many items has no line offset changes at all?

			var addedLineOffsets = computeLineOffsets(change.text, false, startOffset)

			if (endLine - startLine) === addedLineOffsets.length
				for added,k in addedLineOffsets
					lineOffsets[k + startLine + 1] = addedLineOffsets[i]
			else
				if addedLineOffsets.length < 10000
					lineOffsets.splice.apply(lineOffsets, [startLine + 1, endLine - startLine].concat(addedLineOffsets))
				else
					_lineOffsets = lineOffsets = lineOffsets.slice(0, startLine + 1).concat(addedLineOffsets, lineOffsets.slice(endLine + 1))

			var diff = change.text.length - (endOffset - startOffset)
			if diff !== 0
				let k = startLine + 1 + addedLineOffsets.length
				while k < lineOffsets.length
					lineOffsets[k] = lineOffsets[k] + diff
					k++
		
		updated(changes,version)

	def updated changes,version
		version = version
		self

	def applyEdit change, version, changes
		content = content.substring(0, change.range.start.offset) + change.text + content.substring(change.range.end.offset, content.length)
