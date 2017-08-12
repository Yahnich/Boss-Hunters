guardian_glorious_shield = class({})

function guardian_glorious_shield:GetAOERadius()
	return self:GetTalentSpecialValueFor("cone_radius")
end

function guardian_glorious_shield:OnSpellStart()
	local caster = self:GetCaster()
	
	local radius = self:GetTalentSpecialValueFor("cone_radius")
	local fwPos = self:GetCaster:GetForwardVector() * radius
	
	local targets = caster:FindEnemyUnitsInRadius(fwPos, radius, {})
	local damage = self:GetTalentSpecialValueFor("damage")
	local duration = self:GetTalentSpecialValueFor("duration")
	for _, target in ipairs(targets) do
		self:DealDamage(caster, target, damage)
		target:AddNewModifier(caster, self, "modifier_guardian_glorious_shield_debuff", {duration = duration})
	end
	
	EmitSoundOn("Hero_Sven.GreatCleave.ti7", caster)
	local shieldFX = ParticleManager:CreateParticle("particles/heroes/guardian/guardian_glorious_shield.vpcf", PATTACH_POINT_FOLLOW, caster)
	ParticleManager:SetParticleControl(shieldFX, 1, fwPos)
end

modifier_guardian_glorious_shield_debuff = class({})
LinkLuaModifier("modifier_guardian_glorious_shield_debuff", "heroes/guardian/guardian_glorious_shield.lua", 0)

function modifier_guardian_glorious_shield_debuff:OnCreated()
	self.miss = self:GetAbility():GetTalentSpecialValueFor("miss_chance")
	self.amp = self:GetCaster():FindTalentValue("guardian_glorious_shield_talent_1")
end

function modifier_guardian_glorious_shield_debuff:OnRefresh()
	self.miss = self:GetAbility():GetTalentSpecialValueFor("miss_chance")
	self.amp = self:GetCaster():FindTalentValue("guardian_glorious_shield_talent_1")
end

function modifier_guardian_glorious_shield_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_MISS_PERCENTAGE 
	}
	return funcs
end


function modifier_guardian_glorious_shield_debuff:GetModifierIncomingDamage_Percentage(params)
	return self.amp
end

function modifier_guardian_glorious_shield_debuff:GetModifierMiss_Percentage()
	return self.miss
end