abaddon_nebulous = class({})

function abaddon_nebulous:IsStealable()
	return true
end

function abaddon_nebulous:IsHiddenWhenStolen()
	return false
end

function abaddon_nebulous:GetIntrinsicModifierName()
	return "modifier_abaddon_nebulous_passive"
end

function abaddon_nebulous:Activate()
	local duration = self:GetSpecialValueFor("duration")
	local caster = self:GetCaster()
	caster:Dispel(caster, true)
	
	EmitSoundOn("Hero_Abaddon.BorrowedTime", caster)
	caster:AddNewModifier(caster, self, "modifier_abaddon_nebulous_active", {duration = duration})
	self:SetCooldown()
end

function abaddon_nebulous:OnSpellStart()
	self:Activate()
end

modifier_abaddon_nebulous_passive = class({})
LinkLuaModifier("modifier_abaddon_nebulous_passive", "heroes/hero_abaddon/abaddon_nebulous", LUA_MODIFIER_MOTION_NONE)

function modifier_abaddon_nebulous_passive:OnCreatedate()
	self:OnRefresh()
end

function modifier_abaddon_nebulous_passive:OnRefresh()
	self.health_threshold = self:GetSpecialValueFor("health_threshold")
end

function modifier_abaddon_nebulous_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_MIN_HEALTH, MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_abaddon_nebulous_passive:GetMinHealth(params)
	if self:GetAbility():IsCooldownReady() and self:GetParent():IsRealHero() then return self:GetParent():GetMaxHealth() * self.health_threshold end
end

function modifier_abaddon_nebulous_passive:OnTakeDamage(params)
	if not params.unit:IsRealHero() then return end
	if params.unit ~= self:GetParent() then return end
	if not self:GetAbility():IsCooldownReady() then return end
	if (self:GetHealth() - params.damage) <= self:GetParent():GetMaxHealth() * self.health_threshold then
		self:GetAbility():Activate()
	end
end

function modifier_abaddon_nebulous_passive:IsHidden()
	return true
end

modifier_abaddon_nebulous_active = class({})
LinkLuaModifier("modifier_abaddon_nebulous_active", "heroes/hero_abaddon/abaddon_nebulous", LUA_MODIFIER_MOTION_NONE)

function modifier_abaddon_nebulous_active:OnCreated()
	self:OnRefresh()
end

function modifier_abaddon_nebulous_active:OnRefresh()
	if IsServer() then
		self:GetAbility():SetFrozenCooldown( true )
	end
end

function modifier_abaddon_nebulous_active:OnRemoved()
	if IsServer() then
		self:GetAbility():SetFrozenCooldown( false )
	end
end

function modifier_abaddon_nebulous_active:GetEffectName()
	return "particles/units/heroes/hero_abaddon/abaddon_borrowed_time.vpcf"
end

function modifier_abaddon_nebulous_active:GetStatusEffectName()
	return "particles/status_fx/status_effect_abaddon_borrowed_time.vpcf"
end

function modifier_abaddon_nebulous_active:StatusEffectPriority()
	return 10
end

function modifier_abaddon_nebulous_active:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_abaddon_nebulous_active:GetModifierIncomingDamage_Percentage(params)
	if params.damage < 0 then return end
	local parent = self:GetParent()
	parent:HealEvent( params.damage, self:GetAbility(), self:GetCaster(), {heal_type = HEAL_TYPE_REGEN} )
	ParticleManager:FireParticle("particles/units/heroes/hero_abaddon/abaddon_borrowed_time_heal.vpcf", PATTACH_POINT_FOLLOW, parent )
	return -999
end