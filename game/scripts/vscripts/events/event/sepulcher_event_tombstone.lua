local function StartEvent()
	print("event: tombstone")
end

local funcs = {
	["StartEvent"] = StartEvent
}

return funcs