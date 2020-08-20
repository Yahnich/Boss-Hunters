abaddon_borrowed_time_ebf = class({})

function abaddon_borrowed_time_ebf:IsStealable()
	return true
end

function abaddon_borrowed_time_ebf:IsHiddenWhenStolen()
	return false
end

function abaddon_borrowed_time_ebf:GetIntrinsicModifierName()
	return "modifier_abaddon_borrowed_time_ebf_passive"
end

function abaddon_borrowed_time_ebf:Activate()
	local duration = self:GetTalentSpecialValueFor("duration")
	local caster = self:GetCaster()
	if caster:HasScepter() then duration = self:GetTalentSpecialValueFor("duration_scepter") end
	caster:Dispel(caster, true)
	EmitSoundOn("Hero_Abaddon.BorrowedTime", caster)
	caster:AddNewModifier(caster, self, "modifier_abaddon_borrowed_time_active", {duration = duration})
	self:SetCooldown()
	if caster:HasTalent("special_bonus_unique_abaddon_borrowed_time_1") then
		local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), -1)
		for _, enemy in ipairs( enemies ) do
			enemy:Taunt(self, caster, duration)
			enemy:AddNewModifier(caster, self, "modifier_abaddon_borrowed_time_talent", {duration = duration})
		end
	end
	if caster:HasTalent("special_bonus_unique_abaddon_borrowed_time_2") then
		caster:SetThreat(0)
	end
end

function abaddon_borrowed_time_ebf:OnSpellStart()
	self:Activate()
end

modifier_abaddon_borrowed_time_talent = class({})
LinkLuaModifier("modifier_abaddon_borrowed_time_talent", "heroes/hero_abaddon/abaddon_borrowed_time_ebf", LUA_MODIFIER_MOTION_NONE)

function modifier_abaddon_borrowed_time_talent:OnCreated()
	self.as = self:GetCaster():FindTalentValue("special_bonus_unique_abaddon_borrowed_time_1")
end

function modifier_abaddon_borrowed_time_talent:GetModifierAttackSpeedBonus()
	return self.as
end

modifier_abaddon_borrowed_time_ebf_passive = class({})
LinkLuaModifier("modifier_abaddon_borrowed_time_ebf_passive", "heroes/hero_abaddon/abaddon_borrowed_time_ebf", LUA_MODIFIER_MOTION_NONE)

function modifier_abaddon_borrowed_time_ebf_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_MIN_HEALTH, MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_abaddon_borrowed_time_ebf_passive:GetMinHealth(params)
	if self:GetAbility():IsCooldownReady() and self:GetParent():IsRealHero() then return 1 end
end

function modifier_abaddon_borrowed_time_ebf_passive:OnTakeDamage(params)
	if params.unit == self:GetParent() and self:GetAbility():IsCooldownReady() and self:GetParent():IsRealHero() then
		if params.damage > self:GetParent():GetHealth() then
			self:GetAbility():Activate()
		end
	end
end

function modifier_abaddon_borrowed_time_ebf_passive:IsHidden()
	return true
end

modifier_abaddon_borrowed_time_active = class({})
LinkLuaModifier("modifier_abaddon_borrowed_time_active", "heroes/hero_abaddon/abaddon_borrowed_time_ebf", LUA_MODIFIER_MOTION_NONE)

function modifier_abaddon_borrowed_time_active:OnCreated()
	self.aura_radius = self:GetTalentSpecialValueFor("redirect_range_scepter")
	self.ms = self:GetCaster():FindTalentValue("special_bonus_unique_abaddon_borrowed_time_2")
	if IsServer() then
		self:GetAbility():StartDelayedCooldown()
	end
end

function modifier_abaddon_borrowed_time_active:OnRefresh()
	self.aura_radius = self:GetTalentSpecialValueFor("redirect_range_scepter")
	if IsServer() then
		self:GetAbility():StartDelayedCooldown()
	end
end

function modifier_abaddon_borrowed_time_active:OnRemoved()
	if IsServer() then
		self:GetAbility():EndDelayedCooldown()
	end
end

function modifier_abaddon_borrowed_time_active:GetEffectName()
	return "particles/units/heroes/hero_abaddon/abaddon_borrowed_time.vpcf"
end

function modifier_abaddon_borrowed_time_active:GetStatusEffectName()
	return "particles/status_fx/status_effect_abaddon_borrowed_time.vpcf"
end

function modifier_abaddon_borrowed_time_active:StatusEffectPriority()
	return 10
end

function modifier_abaddon_borrowed_time_active:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_abaddon_borrowed_time_active:GetModifierIncomingDamage_Percentage(params)
	if params.damage < 0 then return end
	local parent = self:GetParent()
	parent:HealEvent( params.damage, self:GetAbility(), self:GetCaster() )
	ParticleManager:FireParticle("particles/units/heroes/hero_abaddon/abaddon_borrowed_time_heal.vpcf", PATTACH_POINT_FOLLOW, parent )
	return -999
end

function modifier_abaddon_borrowed_time_active:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

function modifier_abaddon_borrowed_time_active:IsAura()
	return self:GetCaster():HasScepter()
end

function modifier_abaddon_borrowed_time_active:GetModifierAura()
	return "modifier_abaddon_borrowed_time_ebf_scepter"
end

function modifier_abaddon_borrowed_time_active:GetAuraRadius()
	return self.aura_radius
end

function modifier_abaddon_borrowed_time_active:GetAuraEntityReject(entity)
	if entity == self:GetParent() then 
		return true
	else
		return false
	end
end

function modifier_abaddon_borrowed_time_active:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_abaddon_borrowed_time_active:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end


modifier_abaddon_borrowed_time_ebf_scepter = class({})
LinkLuaModifier("modifier_abaddon_borrowed_time_ebf_scepter", "heroes/hero_abaddon/abaddon_borrowed_time_ebf", LUA_MODIFIER_MOTION_NONE)

function modifier_abaddon_borrowed_time_ebf_scepter:OnCreated()
	self.redirect = self:GetTalentSpecialValueFor("redirect")
end

function modifier_abaddon_borrowed_time_ebf_scepter:OnRefresh()
	self.redirect = self:GetTalentSpecialValueFor("redirect")
end

function modifier_abaddon_borrowed_time_ebf_scepter:GetEffectName()
	return "particles/units/heroes/hero_abaddon/abaddon_borrowed_time.vpcf"
end


function modifier_abaddon_borrowed_time_ebf_scepter:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_abaddon_borrowed_time_ebf_scepter:GetModifierIncomingDamage_Percentage(params)
	if self:GetCaster():HasModifier("modifier_abaddon_borrowed_time_active") then
		ApplyDamage({victim = self:GetCaster(), attacker = params.attacker, damage = params.damage * (1 - self.redirect/100), damage_flags = params.damage_flags, ability = params.inflictor, damage_type = params.damage_type})
	end
	return self.redirect
end