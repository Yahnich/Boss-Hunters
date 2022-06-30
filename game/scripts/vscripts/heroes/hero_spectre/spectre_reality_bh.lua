spectre_reality_bh = class({})


function spectre_reality_bh:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local distance = 999999
	local target
	for i = #self.livingIllusions, 1, -1 do
		local illusionIndex = self.livingIllusions[i]
		local illusion = EntIndexToHScript( illusionIndex )
		if not illusion or illusion:IsNull() or not illusion:IsAlive() then
			table.remove( self.livingIllusions, i )
		end
	end
	for _, illusionIndex in ipairs( self.livingIllusions ) do
		local illusion = EntIndexToHScript( illusionIndex )
		if illusion then
			local calcDist = CalculateDistance( illusion, position )
			if illusion:IsAlive( ) and calcDist < distance then
				target = illusion
				distance = calcDist
			end
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
		FindClearSpaceForUnit(target, casterPosition, true)
	else
		self:SetActivated( false )
	end
end