export def computeLineOffsets text, isAtLineStart, textOffset
	if textOffset === undefined
		textOffset = 0

	var result = isAtLineStart ? [textOffset] : []
	var i = 0
	while i < text.length
		var ch = text.charCodeAt(i)
		if ch === 13 || ch === 10
			if ch === 13 && (i + 1 < text.length) && text.charCodeAt(i + 1) === 10
				i++
			result.push(textOffset + i + 1)
		i++
	return result

export def getWellformedRange range
	var start = range.start
	var end = range.end
	if start.line > end.line || start.line === end.line && start.character > end.character
		return { start: end, end: start }
	return range

export def getWellformedEdit textEdit
	var range = getWellformedRange(textEdit.range)
	if range !== textEdit.range
		return { newText: textEdit.newText, range: range }
	return textEdit

export def mergeSort data, compare
	if data.length <= 1
		return data
	var p = (data.length / 2) | 0
	var left = data.slice(0, p)
	var right = data.slice(p)
	mergeSort(left, compare)
	mergeSort(right, compare)
	var leftIdx = 0
	var rightIdx = 0
	var i = 0
	while leftIdx < left.length && rightIdx < right.length
		var ret = compare(left[leftIdx], right[rightIdx])
		if ret <= 0
			// smaller_equal -> take left to preserve order
			data[i++] = left[leftIdx++]
		else
			// greater -> take right
			data[i++] = right[rightIdx++]

	while (leftIdx < left.length)
		data[i++] = left[leftIdx++]

	while (rightIdx < right.length)
		data[i++] = right[rightIdx++]

	return data

export def editIsFull e
		return e !== undefined && e !== null && typeof e.text === 'string' && e.range === undefined

export def editIsIncremental e
	return !editIsFull(e) && (e.rangeLength === undefined or typeof e.rangeLength === 'number')
