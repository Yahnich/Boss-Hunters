spectre_become_echo = class({})

function spectre_become_echo:Spawn()
	if IsClient() then return end
	self:SetActivated( true )
	self:SetLevel( 1 )
end

function spectre_become_echo:ProcsMagicStick()
	return false
end

function spectre_become_echo:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local distance = 999999
	local target
	
	for echo, _ in pairs( caster:GetEchoes() ) do
		if IsEntitySafe( echo ) then
			local calcDist = CalculateDistance( echo, position )
			if echo:IsAlive( ) and calcDist < distance then
				target = echo
				distance = calcDist
			end
		else
			caster:GetEchoes()[echo] = nil
		end
	end
	if target then
		local casterPosition = caster:GetAbsOrigin()
		local targetPosition = target:GetAbsOrigin()
		
		target:StartGesture( ACT_DOTA_TELEPORT_END )
		caster:StartGesture( ACT_DOTA_TELEPORT_END )
		
		target:StartGesture( ACT_DOTA_TELEPORT_END )
		caster:StartGesture( ACT_DOTA_TELEPORT_END )
		
		FindClearSpaceForUnit(caster, targetPosition, true)
		target:ForceKill( false )
	end
end