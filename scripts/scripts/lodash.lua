local fun = require('fun')
local _ = {}

-- Array
function _.concat (...)
	return fun.totable(fun.chain(table.unpack(_.map({...}, _.castArray))))
end

function _.drop (array, n)
	n = n or 1
	if _.isArray(array) and n > 0 then
		return _.slice(array, n + 1)
	end
	return {}
end

function _.dropRight (array, n)
	n = n or 1
	if _.isArray(array) and n > 0 then
		return _.slice(array, 1, -n)
	end
	return {}
end

function _.fromPairs (_pairs)
	return _.reduce(_pairs, function (result, pair)
		result[pair[1]] = pair[2]
		return result
	end, {})
end

function _.head (array)
	if _.isArray(array) then
		return array[1]
	end
end

function _.indexOf (collection, value)
	if _.isArray(collection) then
		return fun.index_of(value, collection)
	elseif _.isString(collection) then
		local start, _ = string.find(collection, value)
		return start
	end
end

function _.intersection (...)
	local arrays = {...}
	local tailArrays = _.tail(arrays)
	return _.reduce(_.uniq(_.head(arrays)), function (result, value)
		if _.every(tailArrays, function (array) return _.includes(array, value) end) then
			table.insert(result, value)
		end
		return result
	end, {})
end

function _.join (array, separator)
	return table.concat(array, separator or ',')
end

function _.last (array)
	if _.isArray(array) then
		return array[_.size(array)]
	end
end

function _.reverse (array)
	if not _.isEmpty(array) then
		return _.map(_.range(_.size(array), 1), _.propertyOf(array))
	end
	return array
end

function _.slice (array, start, stop)
	local endIndex = _.size(array) + 1
	local start = start or 1
	if start < 0 then
		start = endIndex + start
	end
	local stop = stop or endIndex
	if stop < 0 then
		stop = endIndex + stop
	elseif stop > endIndex then
		stop = endIndex
	end
	if stop <= start then
		return {}
	end
	return _.map(_.range(start, stop - 1), _.propertyOf(array))
end

function _.take (array, n)
	n = n or 1
	if _.isArray(array) and n > 0 then
		return _.slice(array, 1, n + 1)
	end
	return {}
end

function _.takeRight (array, n)
	n = n or 1
	if _.isArray(array) and n > 0 then
		return _.slice(array, -n)
	end
	return {}
end

function _.union (...)
	return _.uniq(_.concat(...))
end

function _.uniq (array)
	return _.reduce(array, function (result, value)
		if not _.includes(result, value) then
			table.insert(result, value)
		end
		return result
	end, {})
end

function _.without (array, ...)
	local exclude = {...}
	return _.reduce(array, function (result, value)
		if not _.includes(exclude, value) then
			table.insert(result, value)
		end
		return result
	end, {})
end

function _.zip (...)
	local arrays = {...}
	return _.times(_.size(_.head(arrays)), function (index)
		return _.map(arrays, _.property(index))
	end)
end

function _.zipObject (keys, values)
	return _.fromPairs(_.zip(keys, values))
end

-- Collection
function _.every (collection, iteratee)
	return fun.every(iteratee or _.identity, collection)
end

function _.forEach (collection, iteratee)
	fun.foreach(iteratee or _.identity, collection)
	return collection
end

function _.includes (collection, value)
	if _.isPlainObject(collection) then
		collection = _.values(collection)
	end
	return _.indexOf(collection, value) ~= nil
end

function _.map (collection, iteratee)
	return fun.totable(fun.map(iteratee or _.identity, collection))
end

function _.partition (collection, iteratee)
	local yes, no = fun.partition(iteratee or _.identity, collection)
	return _.map({ yes, no }, fun.totable);
end

function _.reject (collection, predicate)
	return _.filter(collection, _.negate(predicate))
end

function _.sample (collection, pop)
	if _.isPlainObject(collection) then
		collection = _.values(collection)
	end
	if _.isArray(collection) then
		if (pop) then
			return table.remove(collection, _.random(1, _.size(collection)))
		end
		return collection[_.random(1, _.size(collection))]
	end
end

function _.sampleSize (collection, n)
	if _.isPlainObject(collection) then
		collection = _.values(collection)
	else
		collection = _.clone(collection)
	end
	local length = _.size(collection)
	n = n or 1
	if n > length then
		n = length
	end
	return _.times(n, function () return _.sample(collection, true) end)
end

function _.sortBy (collection, iteratee)
	if _.isPlainObject(collection) then
		collection = _.values(collection)
	else
		collection = _.clone(collection)
	end
	if _.isString(iteratee) then
		local key = iteratee
		iteratee = _.overArgs(_.lt, {_.property(key), _.property(key)})
	end
	table.sort(collection, iteratee or _.lt)
	return collection
end

-- Function
function _.ary (func, n)
	return _.rearg(func, _.range(n))
end

function _.flip (func)
	return function (...)
		return func(table.unpack(_.reverse({...})))
	end
end

function _.negate (func)
	return function (...)
		return not func(...)
	end
end

function _.overArgs (func, transforms)
	transforms = _.castArray(transforms)
	return function (...)
		local args = {...}
		return func(table.unpack(_.times(_.size(args), function (index)
			if transforms[index] then
				return transforms[index](args[index])
			end
			return args[index]
		end)))
	end
end

function _.rearg (func, indexes)
	return function (...)
		return func(table.unpack(_.map(indexes, _.propertyOf({...}))))
	end
end

function _.unary (func)
	return _.ary(func, 1)
end

-- Lang
function _.castArray (...)
	local args = {...}
	local value = args[1]
	if _.isEmpty(args) then
		return {}
	elseif _.isArray(value) then
		return value
	else
		return {value}
	end
end

function _.clone (value)
	if _.isArray(value) then
		return _.map(value)
	elseif _.isObject(value) then
		return _.mapKeys(value)
	end
	return value
end

function _.isArray (value)
	if not _.isObject(value) then
		return false
	elseif _.isEmpty(value) then
		return true
	end
	local gen, param, state = fun.iter(value)
	return _.isNumber(state)
end

function _.isBoolean (value)
	return type(value) == 'boolean'
end

function _.isEmpty (value)
	return _.isNil(value) or fun.is_null(value)
end

function _.isFunction (value)
	return type(value) == 'function'
end

function _.isNil (value)
	return value == nil
end

function _.isNumber (value)
	return type(value) == 'number'
end

function _.isObject (value)
	return type(value) == 'table'
end

function _.isPlainObject (value)
	return _.isObject(value) and not _.isArray(value)
end

function _.isString (value)
	return type(value) == 'string'
end

-- Math
function _.sum (array)
	return _.reduce(array, _.add, 0)
end

-- Number
function _.random (...)
	local args = {...}
	local lower, upper
	local float = args[3] or false
	if _.size(args) == 1 then
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

-- Object
function _.assign (...)
	return fun.tomap(fun.chain(...))
end

function _.keys (object)
	return _.map(object)
end

function _.mapKeys (object, iteratee)
	return _.zipObject(_.map(object, iteratee or _.identity), _.values(object))
end

function _.mapValues (object, iteratee)
	return _.zipObject(_.keys(object), _.map(object, iteratee or _.nthArg(2)))
end

function _.values (object)
	return _.map(object, _.nthArg(2))
end

-- String
function _.endsWith (str, target)
	return target == '' or str:sub(-_.size(target)) == target
end

function _.startsWith (str, target)
	return str:sub(1, _.size(target)) == target
end

-- Util
function _.constant (value)
	return function () return value end
end

function _.flow (funcs)
	return function (...)
		return _.reduce(_.drop(funcs), function (result, func)
			return func(result)
		end, _.head(funcs)(...))
	end
end

function _.inspect (value, inner)
	if _.isArray(value) then
		return '[' .. _.join(_.map(value, function (val)
			return _.inspect(val, true)
		end), ', ') .. ']'
	elseif _.isObject(value) then
		local str = '{'
		local first = true
		_.forEach(value, function (key, val)
			if first then
				first = false
			else
				str = str .. ', '
			end
			str = str .. key .. ': ' .. _.inspect(val, true)
		end)
		return str .. '}'
	elseif inner and _.isString(value) then
		return '\'' .. value .. '\''
	else
		return _.toString(value)
	end
end

function _.noop () end

function _.nthArg (index)
	return function (...)
		local args = {...}
		return args[index]
	end
end

function _.property (key)
	return function (object)
		return object[key]
	end
end

function _.propertyOf (object)
	return function (key)
		return object[key]
	end
end

function _.range (start, stop, step)
	return fun.totable(fun.range(start or 0, stop, step))
end

function _.times (n, iteratee)
	return _.map(_.range(n), iteratee or _.identity)
end

_.add = fun.operator.add
_.dropWhile = _.flow({_.flip(fun.drop_while), fun.totable})
_.every = _.flip(fun.every)
_.filter = _.flow({_.flip(fun.filter), fun.totable})
_.identity = _.nthArg(1)
_.lt = fun.operator.lt
_.max = fun.max
_.min = fun.min
_.reduce = _.rearg(fun.reduce, {2, 3, 1})
_.size = fun.length
_.some = _.flip(fun.some)
_.tail = _.unary(_.drop)
_.takeWhile = _.flow({_.flip(fun.take_while), fun.totable})
_.toLower = string.lower
_.toString = tostring
_.toUpper = string.upper

return _
