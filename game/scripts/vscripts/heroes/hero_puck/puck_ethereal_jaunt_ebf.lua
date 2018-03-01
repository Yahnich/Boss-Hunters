puck_ethereal_jaunt_ebf = class({})

function puck_ethereal_jaunt_ebf:GetAssociatedPrimaryAbilities()
	return "puck_illusory_orb_ebf"
end

function puck_ethereal_jaunt_ebf:IsHiddenWhenStolen()
	return false
end

function puck_ethereal_jaunt_ebf:OnUpgrade()
	self:SetActivated(false)
end

function puck_ethereal_jaunt_ebf:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	
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
		local position = ProjectileManager:GetLinearProjectileLocation(orb)
		FindClearSpaceForUnit(caster, position, true)
		ProjectileManager:DestroyLinearProjectile(orb)
		illusoryOrb:OnOrbDestroyed(orb, position)
	end
end