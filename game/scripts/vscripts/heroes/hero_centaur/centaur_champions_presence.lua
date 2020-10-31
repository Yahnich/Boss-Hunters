centaur_champions_presence = class({})

function centaur_champions_presence:IsStealable()
	return true
end

function centaur_champions_presence:IsHiddenWhenStolen()
	return false
end

function centaur_champions_presence:OnSpellStart()
	local caster = self:GetCaster()
	
	EmitSoundOn( "Hero_Centaur.Gore", caster )
	caster:AddNewModifier(caster, self, "modifier_centaur_champions_presence_buff", {duration = self:GetTalentSpecialValueFor("duration")})
	ParticleManager:FireParticle( "particles/units/heroes/hero_centaur/centaur_champions_presence_start.vpcf", PATTACH_POINT_FOLLOW, caster )
end

modifier_centaur_champions_presence_buff = class({})
LinkLuaModifier("modifier_centaur_champions_presence_buff", "heroes/hero_centaur/centaur_champions_presence", LUA_MODIFIER_MOTION_NONE)

function modifier_centaur_champions_presence_buff:OnCreated()
	self:OnRefresh()
end

function modifier_centaur_champions_presence_buff:OnRefresh()
	self.bonus_dmg = self:GetTalentSpecialValueFor("bonus_damage")
	self.spell_amp = self:GetTalentSpecialValueFor("bonus_spell_amp")
	self.health_regen = self:GetTalentSpecialValueFor("health_regen")
	self.threat_amp = self:GetTalentSpecialValueFor("bonus_threat_amp")
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_centaur_champions_presence_1")
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_centaur_champions_presence_2")
	if self.talent2 then
		self.threat_amp = -self.threat_amp
	end
	self.reduction = self:GetCaster():FindTalentValue("special_bonus_unique_centaur_champions_presence_1")
	self.self_reduction = self:GetCaster():FindTalentValue("special_bonus_unique_centaur_champions_presence_1", "value2")
	if IsServer() then
		self.warhide = self:GetCaster():FindAbilityByName("centaur_warchiefs_aegis")
	end
end

function modifier_centaur_champions_presence_buff:OnDestroy()
	if IsServer() then self:GetAbility():EndDelayedCooldown() end
end

function modifier_centaur_champions_presence_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
			MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
			MODIFIER_EVENT_ON_ATTACK_LANDED 
			}
end

function modifier_centaur_champions_presence_buff:GetModifierBaseDamageOutgoing_Percentage()
	return self.bonus_dmg
end

function modifier_centaur_champions_presence_buff:GetModifierSpellAmplify_Percentage()
	return self.spell_amp
end

function modifier_centaur_champions_presence_buff:GetModifierConstantHealthRegen()
	return self.health_regen
end

function modifier_centaur_champions_presence_buff:Bonus_ThreatGain()
	return self.threat_amp
end

function modifier_centaur_champions_presence_buff:GetModifierIncomingDamage_Percentage(params)
	if self.talent1 and params.damage > 0 then
		reduction = self.reduction
		if params.attacker == params.target then
			reduction = self.self_reduction
		end
		return reduction
	end
end

function modifier_centaur_champions_presence_buff:OnAttackLanded(params)
	if self.talent2 and self:GetParent() == params.attacker and self.warhide then
		self.warhide:ProcReturn(params.target)
	end
end

function modifier_centaur_champions_presence_buff:GetEffectName()
	return "particles/econ/events/ti6/radiance_owner_ti6.vpcf"
end