brewmaster_thunder_clap_bh = class({})

function brewmaster_thunder_clap_bh:IsStealable()
	return true
end

function brewmaster_thunder_clap_bh:IsHiddenWhenStolen()
	return false
end

function brewmaster_thunder_clap_bh:GetCastRange(target, position)
	return self:GetTalentSpecialValueFor("radius")
end

function brewmaster_thunder_clap_bh:OnSpellStart()
	local caster = self:GetCaster()
	
	local radius = self:GetTalentSpecialValueFor("radius")
	local damage = self:GetTalentSpecialValueFor("damage")
	local duration = self:GetTalentSpecialValueFor("duration")
	
	ParticleManager:FireParticle("particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap.vpcf", PATTACH_ABSORIGIN, caster, {[1] = Vector(radius, 0, 0)})
	EmitSoundOn( "Hero_Brewmaster.ThunderClap", caster )
	
	local stunDur = caster:FindTalentValue("special_bonus_unique_brewmaster_thunder_clap_1")
	local targets = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), radius)
	for _, target in ipairs(targets) do
		if not target:TriggerSpellAbsorb( self ) then
			self:DealDamage(caster, target, damage)
			target:AddNewModifier(caster, self, "modifier_brewmaster_thunder_clap_bh_debuff", {duration = duration})
			if caster:HasTalent("special_bonus_unique_brewmaster_thunder_clap_1") then
				self:Stun(target, stunDur)
			end
		end
		EmitSoundOn( "Hero_Brewmaster.ThunderClap.Target", target )
	end
end

modifier_brewmaster_thunder_clap_bh_debuff = class({})
LinkLuaModifier("modifier_brewmaster_thunder_clap_bh_debuff", "heroes/hero_brewmaster/brewmaster_thunder_clap_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_brewmaster_thunder_clap_bh_debuff:OnCreated()
	self.ms = self:GetTalentSpecialValueFor("movement_slow") * (-1)
	self.as = self:GetTalentSpecialValueFor("attack_speed_slow") * (-1)
end

function modifier_brewmaster_thunder_clap_bh_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			}
end

function modifier_brewmaster_thunder_clap_bh_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

function modifier_brewmaster_thunder_clap_bh_debuff:GetModifierAttackSpeedBonus()
	return self.as
end

function modifier_brewmaster_thunder_clap_bh_debuff:GetEffectName()
	return "particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap_debuff.vpcf"
end

function modifier_brewmaster_thunder_clap_bh_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_brewmaster_thunder_clap.vpcf"
end

function modifier_brewmaster_thunder_clap_bh_debuff:StatusEffectPriority()
	return 2
end