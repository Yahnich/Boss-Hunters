earthshaker_enchant_totem_ebf = class({})

function earthshaker_enchant_totem_ebf:IsStealable()
	return true
end

function earthshaker_enchant_totem_ebf:IsHiddenWhenStolen()
	return false
end

function earthshaker_enchant_totem_ebf:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_earthshaker_enchant_totem_ebf", {duration = 100 or self:GetTalentSpecialValueFor("duration")})
	
	EmitSoundOn("Hero_EarthShaker.Totem", caster)
end

modifier_earthshaker_enchant_totem_ebf = class({})
LinkLuaModifier("modifier_earthshaker_enchant_totem_ebf", "heroes/hero_earthshaker/earthshaker_enchant_totem_ebf", LUA_MODIFIER_MOTION_NONE)

function modifier_earthshaker_enchant_totem_ebf:OnCreated()
	self.amp = self:GetTalentSpecialValueFor("totem_damage_percentage")
	if IsServer() then
		local bFX = ParticleManager:CreateParticle("particles/units/heroes/hero_earthshaker/earthshaker_totem_buff.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControlEnt(bFX, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_totem", self:GetParent():GetAbsOrigin(), true)
		self:AddEffect(bFX)
	end
end

function modifier_earthshaker_enchant_totem_ebf:OnRefresh()
	self.amp = self:GetTalentSpecialValueFor("totem_damage_percentage")
	self.cdr = self:GetParent():FindTalentValue("special_bonus_unique_earthshaker_enchant_totem_ebf_1")
end

function modifier_earthshaker_enchant_totem_ebf:OnDestroy()
	if self:GetParent():HasTalent("special_bonus_unique_earthshaker_enchant_totem_ebf_1") and IsServer() then
		local aftershock = self:GetCaster():FindAbilityByName("earthshaker_aftershock_ebf")
		if aftershock then aftershock:Aftershock() end
	end
end

function modifier_earthshaker_enchant_totem_ebf:DeclareFunctions()
	return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE ,MODIFIER_EVENT_ON_ATTACK}
end

function modifier_earthshaker_enchant_totem_ebf:CheckState()
	return {[MODIFIER_STATE_CANNOT_MISS] = true}
end

function modifier_earthshaker_enchant_totem_ebf:OnAttack( params )
	if params.attacker == self:GetParent() then
		EmitSoundOn("Hero_EarthShaker.Totem.Attack", params.target)
		ParticleManager:FireParticle("particles/units/heroes/hero_earthshaker/earthshaker_totem_blur.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	end
end

function modifier_earthshaker_enchant_totem_ebf:GetModifierSpellAmplify_Percentage()
	return self.amp
end

function modifier_earthshaker_enchant_totem_ebf:GetCooldownReduction()
	return self.cdr
end

function modifier_earthshaker_enchant_totem_ebf:GetModifierBaseDamageOutgoing_Percentage()
	return self.amp
end

function modifier_earthshaker_enchant_totem_ebf:GetHeroEffectName()
	return "particles/units/heroes/hero_earthshaker/earthshaker_totem_hero_effect.vpcf"
end

function modifier_earthshaker_enchant_totem_ebf:HeroEffectPriority()
	return 3
end