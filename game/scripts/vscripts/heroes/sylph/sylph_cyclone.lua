sylph_cyclone = sylph_cyclone or class({})

function sylph_cyclone:OnSpellStart()
	local duration = self:GetTalentSpecialValueFor("duration")
	if self:GetCaster():HasTalent("sylph_cyclone_talent_1") then
		duration = duration + self:GetCaster():FindTalentValue("sylph_cyclone_talent_1")
	end
	print(duration)
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_sylph_cyclone_buff", {duration = duration})
end

LinkLuaModifier( "modifier_sylph_cyclone_buff", "heroes/sylph/sylph_cyclone.lua", LUA_MODIFIER_MOTION_NONE )
modifier_sylph_cyclone_buff = modifier_sylph_cyclone_buff or class({})

function modifier_sylph_cyclone_buff:OnCreated()
	EmitSoundOn("Ability.Windrun", self:GetParent())
	if IsServer() then self:StartIntervalThink(0) end
	self.radius = self:GetAbility():GetSpecialValueFor("effect_radius")
	self.base_damage = self:GetAbility():GetSpecialValueFor("damage")
end

function modifier_sylph_cyclone_buff:OnIntervalThink()
	if RollPercentage(1) then
		EmitSoundOn("Ability.Windrun", self:GetParent())
	end
	local casterPos = self:GetCaster():GetAbsOrigin()
	local units = FindUnitsInRadius(self:GetCaster():GetTeam(), casterPos, nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
	for _,unit in pairs(units) do
		local direction = (unit:GetAbsOrigin() - casterPos):Normalized()
		local knockback = self:GetCaster():GetIdealSpeed() * 0.0333 * 0.6
		local speedMult = self:GetCaster():GetIdealSpeed() / self:GetCaster():GetBaseMoveSpeed()
		local damage = speedMult * self.base_damage * 0.0333
		ApplyDamage( {victim = unit, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()} )
		if unit:HasMovementCapability() then
			unit:SetAbsOrigin(unit:GetAbsOrigin() + direction * knockback)
		end
	end
	ResolveNPCPositions(casterPos, self.radius + 500)
end

function modifier_sylph_cyclone_buff:GetEffectName()
	return "particles/heroes/sylph/sylph_cyclone.vpcf"
end

LinkLuaModifier( "modifier_sylph_cyclone_talent_1", "heroes/sylph/sylph_cyclone.lua", LUA_MODIFIER_MOTION_NONE )
modifier_sylph_cyclone_talent_1 = modifier_sylph_cyclone_talent_1 or class({})

function modifier_sylph_cyclone_talent_1:IsHidden()
	return true
end

function modifier_sylph_cyclone_talent_1:RemoveOnDeath()
	return false
end