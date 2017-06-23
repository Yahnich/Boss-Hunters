sylph_cyclone = sylph_cyclone or class({})

function sylph_cyclone:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_sylph_cyclone_buff", {duration = self:GetSpecialValueFor("duration")})
end

LinkLuaModifier( "modifier_sylph_cyclone_buff", "heroes/sylph/sylph_cyclone.lua", LUA_MODIFIER_MOTION_HORIZONTAL )
modifier_sylph_cyclone_buff = modifier_sylph_cyclone_buff or class({})

function modifier_sylph_cyclone_buff:OnCreated()
	EmitSoundOn("Ability.Windrun", self:GetParent())
	if IsServer() then self:StartIntervalThink(0) end
	self.radius = self:GetAbility():GetSpecialValueFor("effect_radius")
	self.damage_mult = self:GetAbility():GetSpecialValueFor("damage_mult")
	self.base_damage = self:GetAbility():GetSpecialValueFor("base_damage")
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
		local damage = knockback * self.damage_mult + self.base_damage * 0.0333
		ApplyDamage( {victim = unit, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self} )
		unit:SetAbsOrigin(unit:GetAbsOrigin() + direction * knockback)
	end
	ResolveNPCPositions(casterPos, self.radius + 500)
end

function modifier_sylph_cyclone_buff:GetEffectName()
	return "particles/heroes/sylph/sylph_cyclone.vpcf"
end