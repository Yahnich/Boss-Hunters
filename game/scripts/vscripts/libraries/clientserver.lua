if ClientServer == nil then
	print ( 'creating clienserver manager' )
	ClientServer = {}
	ClientServer.__index = ClientServer
	ClientServer.cursorData = {}
end

function ClientServer:new( o )
	o = o or {}
	setmetatable( o, ClientServer )
	return o
end

function ClientServer:Initialize()
	print("booted up clientserver")
	CustomGameEventManager:RegisterListener('bh_update_mouse_position', Context_Wrap( ClientServer, 'UpdatePlayerMousePosition'))
end

function ClientServer:UpdatePlayerMousePosition(userid, event)
	local pID = event.pID
	local pIDPos = Vector(event.x, event.y)
	ClientServer.cursorData[pID] = pIDPos
end


function ClientServer:RequestMousePosition( pID )
	return ClientServer.cursorData[pID]
end