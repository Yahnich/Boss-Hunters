puck_illusory_orb_ebf = class({})

function puck_illusory_orb_ebf:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	
	local speed = self:GetTalentSpecialValueFor("orb_speed")
	local velocity =  CalculateDirection( target, caster ) * speed
	self:CreateOrb(velocity)
	if caster:HasTalent("special_bonus_unique_puck_illusory_orb_1") then
		self:CreateOrb(-velocity)
	end
end

function puck_illusory_orb_ebf:CreateOrb(velocity)
	local distance = self:GetTalentSpecialValueFor("max_distance")
	local width = self:GetTalentSpecialValueFor("radius")
	local vision = self:GetTalentSpecialValueFor("orb_vision")
	self:FireLinearProjectile(FX, velocity, distance, width, {}, false, true, vision)
end

function puck_illusory_orb_ebf:OnProjectileHit( target, position )	
	local caster = self:GetCaster()
	local orbDamage = self:GetTalentSpecialValueFor("damage")
	local vRadius = self:GetTalentSpecialValueFor("radius")
	if target then
		self:DealDamage( caster, target, orbDamage )
	else
		AddFOWViewer ( caster:GetTeam(), position, vRadius, vDuration, false)
		if caster:HasTalent("special_bonus_unique_puck_illusory_orb_2") then
			for _, enemy in ipairs( caster:FindEnemyUnitsInRadius(position, vRadius * caster:FindTalentValue("special_bonus_unique_puck_illusory_orb_2")) ) do
				local damage = orbDamage * caster:FindTalentValue("special_bonus_unique_puck_illusory_orb_2", "damage") / 100
			end
		end
	end
end