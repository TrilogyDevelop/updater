local count = 0
local tasks = {}


function wait(time)
	coroutine.yield(time / 1000)
end

function newTask(f, halted, ...)
	assert(type(f) == "function", "function expected, got "..type(f))
	count = count + 1
	tasks[count] = {
		id = count,
		f = coroutine.create(f),
		wake_time = type(halted) == "number" and os.clock() + halted / 1000 or os.clock(),
		halted = type(halted) == "boolean" and halted or false,
		args = {...},

		isAlive = function(self)
			return tasks[self.id] ~= nil
		end,
		isHalted = function(self)
			return self.halted
		end,
		halt = function(self)
			self.halted = true
		end,
		resume = function(self)
			self.halted = false
		end,
		kill = function(self)
			tasks[self.id] = nil
		end,
		tick = function(self)
			if self.halted or self.wake_time > os.clock() then
				return
			elseif coroutine.status(self.f) == "dead" then
				self:kill()
				return
			end
			local resumed, result = coroutine.resume(self.f, table.unpack(self.args))
			if not resumed then
				error(result, 2)
			elseif result then
				self.wake_time = os.clock() + result
			end
		end
	}
	tasks[count]:tick()
	return tasks[count]
end

function clearTasks()
	tasks = {}
end

addEventHandler("onUpdate", function()
	for id, task in pairs(tasks) do
		task:tick()
	end
end)
