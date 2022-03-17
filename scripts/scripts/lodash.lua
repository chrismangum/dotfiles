local _ = require('fun')

local exports = {}


-- Helpers (called by other functions)
local function nthArg (index)
	return function (...)
		local arg = {...}
		return arg[index]
	end
end
exports.nthArg = nthArg

local add = _.operator.add
exports.add = add

local function drop (array, n)
	return _.totable(_.drop(n or 1, array))
end
exports.drop = drop

local head = _.head
exports.head = head

local identity = nthArg(1)
exports.identity = identity

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
		local args = {...}
		return func(table.unpack(map(indexes, propertyOf(args))))
	end
end

local reduce = rearg(_.reduce, {2, 3, 1})
exports.reduce = reduce

local size = _.length
exports.size = size

local function flow (funcs)
	return function (...)
		return reduce(drop(funcs), function (result, func)
			return func(result)
		end, head(funcs)(...))
	end
end

local range = flow({_.range, _.totable})
exports.range = range

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
		local arg = {...}
		return func(table.unpack(reverse(arg)))
	end
end
exports.flip = flip


-- Array
local dropWhile = flow({flip(_.drop_while), _.totable})
exports.dropWhile = dropWhile

local indexOf = flip(_.index_of)
exports.indexOf = indexOf

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
local function isNumber (value)
	return type(value) == 'number'
end
exports.isNumber = isNumber

local function isString (value)
	return type(value) == 'string'
end
exports.isString = isString

local toString = tostring
exports.toString = toString


-- Math
local function sum (array)
	return reduce(array, add, 0)
end
exports.sum = sum

-- Object
local function keys (object)
	return map(object)
end
exports.keys = keys

local function values (object)
	return map(object, nthArg(2))
end
exports.values = values


-- String
local function endsWith (str, target)
	return target == '' or str:sub(-size(target)) == target
end
exports.endsWith = endsWith

local function isEmpty (value)
	return isNil(value) or _.is_null(value)
end
exports.isEmpty = isEmpty

local function isNil (value)
	return value == nil
end
exports.isNil = isNil

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
	if type(value) == 'table' then
		local str = ''
		local isMap = false
		forEach(value, function (key, val)
			if not isNil(val) then
				isMap = true
				if size(str) == 0 then
					str = '{'
				else
					str = str .. ', '
				end
				str = str .. key .. ': ' .. inspect(val, true)
			else
				if size(str) == 0 then
					str = '['
				else
					str = str .. ', '
				end
				str = str .. inspect(key, true)
			end
		end)
		if isMap then
			return str .. '}'
		else
			return str .. ']'
		end
	elseif inner and isString(value) then
		return '\'' .. value .. '\''
	else
		return toString(value)
	end
end
exports.inspect = inspect

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
