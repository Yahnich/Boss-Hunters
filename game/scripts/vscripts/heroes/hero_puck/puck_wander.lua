puck_wander = class({})

function puck_wander:GetAssociatedPrimaryAbilities()
	return "puck_faerie_orb"
end

function puck_wander:IsHiddenWhenStolen()
	return false
end

function puck_wander:OnUpgrade()
	self:SetActivated(false)
end

function puck_wander:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()

	local shifts = self:GetSpecialValueFor("shifts")
	local shift_duration = self:GetSpecialValueFor("shift_duration")
	local dim_shift = caster:FindAbilityByName("puck_dimension_shift")
	local no_destroy = self:GetSpecialValueFor("no_destroy")
	local heal_amount = self:GetSpecialValueFor("heal_amount")
	
	local illusoryOrb = caster:FindAbilityByName( self:GetAssociatedPrimaryAbilities() )
	illusoryOrb.orbProjectiles = illusoryOrb.orbProjectiles or {}
	local orb = nil
	local distance = 9999
	for projID, _ in pairs( illusoryOrb.orbProjectiles ) do
		if orb ~= projID and CalculateDistance(target, ProjectileManager:GetLinearProjectileLocation(projID)) < distance then
			orb = projID
			distance = CalculateDistance(target, ProjectileManager:GetLinearProjectileLocation(projID))
		end
	end
	if orb then
		EmitSoundOn("Hero_Puck.EtherealJaunt", caster)
		ProjectileManager:ProjectileDodge(caster)
		local position = ProjectileManager:GetLinearProjectileLocation(orb)
		FindClearSpaceForUnit(caster, position, true)
		if no_destroy == 0 then
			ProjectileManager:DestroyLinearProjectile(orb)
			illusoryOrb:OnOrbDestroyed(orb, position)
		end

		if heal_amount then
			caster:HealEvent(heal_amount, self, caster)
		end

		if shifts ~= 0 and dim_shift:IsTrained() then
			dim_shift:Shift(shift_duration)
		end
	end
end