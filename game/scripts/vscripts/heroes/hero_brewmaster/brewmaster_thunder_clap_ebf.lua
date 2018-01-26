brewmaster_thunder_clap_ebf = class({})

function brewmaster_thunder_clap_ebf:GetCastRange(target, position)
	return self:GetTalentSpecialValueFor("radius")
end

function brewmaster_thunder_clap_ebf:OnSpellStart()
	local caster = self:GetCaster()
	
	local radius = self:GetTalentSpecialValueFor("radius")
	local damage = self:GetTalentSpecialValueFor("damage")
	local duration = self:GetTalentSpecialValueFor("duration")
	
	ParticleManager:FireParticle("particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap.vpcf", PATTACH_ABSORIGIN, caster, {[1] = Vector(radius, 0, 0)})
	EmitSoundOn( "Hero_Brewmaster.ThunderClap", caster )
	
	local targets = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), radius)
	for _, target in ipairs(targets) do
		self:DealDamage(caster, target, damage)
		target:AddNewModifier(caster, self, "modifier_brewmaster_thunder_clap_ebf_debuff", {duration = duration})
		EmitSoundOn( "Hero_Brewmaster.ThunderClap.Target", target )
	end
	
	
	if caster:HasTalent("special_bonus_unique_brewmaster_2") then
		caster:AddNewModifier(caster, caster:FindAbilityByName("brewmaster_drunken_brawler_ebf"), "modifier_brewmaster_drunken_brawler_ebf_crit", {})
		caster:AddNewModifier(caster, caster:FindAbilityByName("brewmaster_drunken_brawler_ebf"), "modifier_brewmaster_drunken_brawler_ebf_evade", {})
	end
end

modifier_brewmaster_thunder_clap_ebf_debuff = class({})
LinkLuaModifier("modifier_brewmaster_thunder_clap_ebf_debuff", "heroes/hero_brewmaster/brewmaster_thunder_clap_ebf", LUA_MODIFIER_MOTION_NONE)

function modifier_brewmaster_thunder_clap_ebf_debuff:OnCreated()
	self.ms = self:GetTalentSpecialValueFor("movement_slow") * (-1)
	self.as = self:GetTalentSpecialValueFor("attack_speed_slow") * (-1)
end

function modifier_brewmaster_thunder_clap_ebf_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_brewmaster_thunder_clap_ebf_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

function modifier_brewmaster_thunder_clap_ebf_debuff:GetModifierAttackSpeedBonus_Constant()
	return self.as
end

function modifier_brewmaster_thunder_clap_ebf_debuff:GetEffectName()
	return "particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap_debuff.vpcf"
end

function modifier_brewmaster_thunder_clap_ebf_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_brewmaster_thunder_clap.vpcf"
end

function modifier_brewmaster_thunder_clap_ebf_debuff:StatusEffectPriority()
	return 2
end