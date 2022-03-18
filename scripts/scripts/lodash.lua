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

local function drop (array, n)
	return _.totable(_.drop(n or 1, array))
end
exports.drop = drop

local every = flip(_.every)
exports.every = every

local some = flip(_.some)
exports.some = some

local head = _.head
exports.head = head

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

local function propertyOf (object)
	return function (index)
		return object[index]
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

local function values (object)
	return map(object, nthArg(2))
end
exports.values = values


-- Array
local function concat (...)
	return _.totable(_.chain(table.unpack(map({...}, castArray))))
end
exports.concat = concat

local dropWhile = flow({flip(_.drop_while), _.totable})
exports.dropWhile = dropWhile

local function join (array, separator)
	return table.concat(array, separator or ',')
end
exports.join = join

local function take (array, n)
	return _.totable(_.take(n or 1, array))
end
exports.take = take

local takeWhile = flow({flip(_.take_while), _.totable})
exports.takeWhile = takeWhile

local function uniq (array)
	return reduce(array, function (result, value)
		if not includes(result, value) then
			table.insert(result, value)
		end
		return result
	end, {})
end
exports.uniq = uniq

local function union (...)
	return uniq(concat(...))
end
exports.union = union


-- Collection
local function every (collection, iteratee)
	return _.every(iteratee or identity, collection)
end
exports.every = every

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


-- Util
local function ary (func, n)
	return rearg(func, range(n))
end
exports.ary = ary

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

local function times (n, iteratee)
	return map(range(n), iteratee or identity)
end
exports.times = times

local function unary (func)
	return ary(func, 1)
end
exports.unary = unary


-- Testing Area

return exports
