wraith_bloodletter = class({})

function wraith_bloodletter:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	target:AddNewModifier(caster, self, "modifier_wraith_bloodletter_debuff", {duration = self:GetSpecialValueFor("duration")})
	caster:HealEvent(self:GetSpecialValueFor("heal"), self, caster)
	ParticleManager:FireParticle("particles/frostivus_gameplay/wraith_king_hellfire_eruption_explosion.vpcf", PATTACH_POINT_FOLLOW, caster, {[3] = caster:GetAbsOrigin()})
end

modifier_wraith_bloodletter_debuff = class({})
LinkLuaModifier("modifier_wraith_bloodletter_debuff", "heroes/wraith/wraith_bloodletter.lua", 0)

function modifier_wraith_bloodletter_debuff:OnCreated()
	self.as = self:GetSpecialValueFor("attackslow")
	self.ms = self:GetSpecialValueFor("moveslow")
	self.dot = self:GetSpecialValueFor("damage_over_time")
	if IsServer() then self:StartIntervalThink(1) end
end

function modifier_wraith_bloodletter_debuff:OnRefresh()
	self.as = self:GetSpecialValueFor("attackslow")
	self.ms = self:GetSpecialValueFor("moveslow")
	self.dot = self:GetSpecialValueFor("damage_over_time")
end

function modifier_wraith_bloodletter_debuff:OnIntervalThink()
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.dot)
	if self:GetCaster():HasTalent("wraith_bloodletter_talent_1") then
		local position = self:GetParent():GetAbsOrigin()
		local radius = self:GetSpecialValueFor("talent_radius")
		local poolFX = ParticleManager:CreateParticle("particles/heroes/justicar/justicar_sacred_ground.vpcf", PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(poolFX, 0, position)
		ParticleManager:SetParticleControl(poolFX, 1, Vector(radius, 0, 0) )
		ParticleManager:SetParticleControl(poolFX, 15, Vector(180,15,15) )
		local lifeTime = self:GetSpecialValueFor("talent_duration")
		local heal = self:GetSpecialValueFor("talent_heal")
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		Timers:CreateTimer(function()
			local allies = caster:FindFriendlyUnitsInRadius(position, radius)
			for _, ally in ipairs(allies) do
				ally:HealEvent(heal, ability, caster)
			end
			print(lifeTime)
			if lifeTime > 0 then
				lifeTime = lifeTime - 1
				return 1
			else
				ParticleManager:DestroyParticle(poolFX, false)
				ParticleManager:ReleaseParticleIndex(poolFX)
			end
		end)
	end
end

function modifier_wraith_bloodletter_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_wraith_bloodletter_debuff:GetModifierAttackSpeedBonus_Constant()
	return self.as
end

function modifier_wraith_bloodletter_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

function modifier_wraith_bloodletter_debuff:GetEffectName()
	return "particles/units/heroes/hero_life_stealer/life_stealer_open_wounds.vpcf"
end

function modifier_wraith_bloodletter_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_life_stealer_open_wounds.vpcf"
end

function modifier_wraith_bloodletter_debuff:StatusEffectPriority()
	return 5
end