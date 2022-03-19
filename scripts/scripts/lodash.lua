local _ = require('fun')

local exports = {}


-- Helpers (called by other functions)
local function nthArg (index)
	return function (...)
		local args = {...}
		return args[index]
	end
end
exports.nthArg = nthArg

local size = _.length
exports.size = size

local function reverse (array)
	local reversed = {}
	for i = size(array), 1, -1 do
		table.insert(reversed, array[i])
	end
	return reversed
end
exports.reverse = reverse

local function flip (func)
	return function (...)
		return func(table.unpack(reverse({...})))
	end
end
exports.flip = flip

local add = _.operator.add
exports.add = add

local every = flip(_.every)
exports.every = every

local some = flip(_.some)
exports.some = some

local identity = nthArg(1)
exports.identity = identity

local function isNil (value)
	return value == nil
end
exports.isNil = isNil

local function isEmpty (value)
	return isNil(value) or _.is_null(value)
end
exports.isEmpty = isEmpty

local function isNumber (value)
	return type(value) == 'number'
end
exports.isNumber = isNumber

local function isObject (value)
	return type(value) == 'table'
end
exports.isObject = isObject

local function isString (value)
	return type(value) == 'string'
end
exports.isString = isString

local function isArray (value)
	if not isObject(value) then
		return false
	elseif isEmpty(value) then
		return true
	end
	local gen, param, state = _.iter(value)
	return isNumber(state)
end
exports.isArray = isArray

local function drop (array, n)
	if isArray(array) then
		return _.totable(_.drop(n or 1, array))
	end
	return {}
end
exports.drop = drop

local head = function (array)
	if isArray(array) then
		return array[1]
	end
end
exports.head = head

local function castArray (...)
	local args = {...}
	local value = args[1]
	if isEmpty(args) then
		return {}
	elseif isArray(value) then
		return value
	else
		return {value}
	end
end
exports.castArray = castArray

local function isPlainObject (value)
	return isObject(value) and not isArray(value)
end
exports.isPlainObject = isPlainObject

local function indexOf (collection, value)
	if isArray(collection) then
		return _.index_of(value, collection)
	elseif isString(collection) then
		local start, _ = string.find(collection, value)
		return start
	end
end
exports.indexOf = indexOf

local function includes (collection, value)
	if isPlainObject(collection) then
		return indexOf(values(collection), value) ~= nil
	end
	return indexOf(collection, value) ~= nil
end
exports.includes = includes

local function map (collection, iteratee)
	return _.totable(_.map(iteratee or identity, collection))
end
exports.map = map

local function negate (func)
	return function (...)
		return not func(...)
	end
end
exports.negate = negate

local function random (...)
	local args = {...}
	local lower, upper
	local float = args[3] or false
	if size(args) == 1 then
		lower = 0
		upper = args[1]
	else
		lower = args[1] or 0
		upper = args[2] or 1
	end
	if float then
		return math.random(lower, upper - 1) + math.random()
	end
	return math.random(lower, upper)
end
exports.random = random

local function property (key)
	return function (object)
		return object[key]
	end
end
exports.property = property

local function propertyOf (object)
	return function (key)
		return object[key]
	end
end

local function rearg (func, indexes)
	return function (...)
		return func(table.unpack(map(indexes, propertyOf({...}))))
	end
end

local reduce = rearg(_.reduce, {2, 3, 1})
exports.reduce = reduce

local function flow (funcs)
	return function (...)
		return reduce(drop(funcs), function (result, func)
			return func(result)
		end, head(funcs)(...))
	end
end

local range = flow({_.range, _.totable})
exports.range = range

local function times (n, iteratee)
	return map(range(n), iteratee or identity)
end
exports.times = times

local function ary (func, n)
	return rearg(func, range(n))
end
exports.ary = ary

local function unary (func)
	return ary(func, 1)
end
exports.unary = unary

local tail = unary(drop)
exports.tail = tail

local function values (object)
	return map(object, nthArg(2))
end
exports.values = values

local function fromPairs (_pairs)
	return reduce(_pairs, function (result, pair)
		result[pair[1]] = pair[2]
		return result
	end, {})
end
exports.fromPairs = fromPairs

local function zip (...)
	local arrays = {...}
	return times(size(head(arrays)), function (index)
		return map(arrays, property(index))
	end)
end
exports.zip = zip

local function zipObject (keys, values)
	return fromPairs(zip(keys, values))
end
exports.zipObject = zipObject

local function mapKeys (object, iteratee)
	return zipObject(map(object, iteratee or identity), values(object))
end
exports.mapKeys = mapKeys

local function mapValues (object, iteratee)
	return zipObject(keys(object), map(object, iteratee or nthArg(2)))
end
exports.mapValues = mapValues

local function clone (value)
	if isArray(value) then
		return map(value)
	elseif isObject(value) then
		return mapKeys(value)
	end
	return value
end
exports.clone = clone

local overArgs = function (func, transforms)
	transforms = castArray(transforms)
	return function (...)
		local args = {...}
		return func(table.unpack(times(size(args), function (index)
			if transforms[index] then
				return transforms[index](args[index])
			end
			return args[index]
		end)))
	end
end
exports.overArgs = overArgs


-- Array
local function concat (...)
	return _.totable(_.chain(table.unpack(map({...}, castArray))))
end
exports.concat = concat

local dropWhile = flow({flip(_.drop_while), _.totable})
exports.dropWhile = dropWhile

local function uniq (array)
	return reduce(array, function (result, value)
		if not includes(result, value) then
			table.insert(result, value)
		end
		return result
	end, {})
end
exports.uniq = uniq

local function intersection (...)
	local arrays = {...}
	local tailArrays = tail(arrays)
	return reduce(uniq(head(arrays)), function (result, value)
		if every(tailArrays, function (array) return includes(array, value) end) then
			table.insert(result, value)
		end
		return result
	end, {})
end
exports.intersection = intersection

local function join (array, separator)
	return table.concat(array, separator or ',')
end
exports.join = join

local function last (array)
	if isArray(array) then
		return array[size(array)]
	end
end
exports.last = last

local function take (array, n)
	if isArray(array) then
		return _.totable(_.take(n or 1, array))
	end
	return {}
end
exports.take = take

local function takeRight (array, n)
	return take(reverse(array), n)
end
exports.takeRight = takeRight

local takeWhile = flow({flip(_.take_while), _.totable})
exports.takeWhile = takeWhile

local function union (...)
	return uniq(concat(...))
end
exports.union = union

local function without (array, ...)
	local exclude = {...}
	return reduce(array, function (result, value)
		if not includes(exclude, value) then
			table.insert(result, value)
		end
		return result
	end, {})
end
exports.without = without


-- Collection
local function every (collection, iteratee)
	return _.every(iteratee or identity, collection)
end
exports.every = every

local filter = flow({flip(_.filter), _.totable})
exports.filter = filter

local function reject (collection, predicate)
	return filter(collection, negate(predicate))
end
exports.reject = reject

local function forEach (collection, iteratee)
	_.foreach(iteratee or identity, collection)
	return collection
end
exports.forEach = forEach

local function partition (collection, iteratee)
	local yes, no = _.partition(iteratee or identity, collection)
	return map({ yes, no }, _.totable);
end
exports.partition = partition

local function sample (collection, pop)
	if isPlainObject(collection) then
		collection = values(collection)
	end
	if isArray(collection) then
		if (pop) then
			return table.remove(collection, random(1, size(collection)))
		end
		return collection[random(1, size(collection))]
	end
end
exports.sample = sample

local function sampleSize (collection, n)
	if isPlainObject(collection) then
		collection = values(collection)
	else
		collection = clone(collection)
	end
	local length = size(collection)
	n = n or 1
	if n > length then
		n = length
	end
	return times(n, function () return sample(collection, true) end)
end
exports.sampleSize = sampleSize

local function sortBy (collection, iteratee)
	if isPlainObject(collection) then
		collection = values(collection)
	else
		collection = clone(collection)
	end
	if isString(iteratee) then
		local key = iteratee
		iteratee = overArgs(_.operator.lt, {property(key), property(key)})
	end
	table.sort(collection, iteratee or _.operator.lt)
	return collection
end
exports.sortBy = sortBy


-- Lang
local function isBoolean (value)
	return type(value) == 'boolean'
end
exports.isBoolean = isBoolean

local function isFunction (value)
	return type(value) == 'function'
end
exports.isFunction = isFunction

local toString = tostring
exports.toString = toString


-- Object
local function assign (...)
	return _.tomap(_.chain(...))
end
exports.assign = assign

local function keys (object)
	return map(object)
end
exports.keys = keys


-- Math
local max = _.max
exports.max = max

local min = _.min
exports.min = min


local function sum (array)
	return reduce(array, add, 0)
end
exports.sum = sum


-- String
local function endsWith (str, target)
	return target == '' or str:sub(-size(target)) == target
end
exports.endsWith = endsWith

local function startsWith (str, target)
	return str:sub(1, size(target)) == target
end
exports.startsWith = startsWith

local toLower = string.lower
exports.toLower = toLower

local toUpper = string.upper
exports.toUpper = toUpper


-- Util
local function constant (value)
	return function () return value end
end
exports.constant = constant

local function inspect (value, inner)
	if isArray(value) then
		return '[' .. join(map(value, function (val)
			return inspect(val, true)
		end), ', ') .. ']'
	elseif isObject(value) then
		local str = '{'
		local first = true
		forEach(value, function (key, val)
			if first then
				first = false
			else
				str = str .. ', '
			end
			str = str .. key .. ': ' .. inspect(val, true)
		end)
		return str .. '}'
	elseif inner and isString(value) then
		return '\'' .. value .. '\''
	else
		return toString(value)
	end
end
exports.inspect = inspect

local function noop () end
exports.noop = noop


-- Testing Area

return exports
