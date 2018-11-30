boss_wk_reincarnation = class({})

function boss_wk_reincarnation:GetIntrinsicModifierName()
	return "modifier_boss_wk_reincarnation"
end

modifier_boss_wk_reincarnation = class({})
LinkLuaModifier("modifier_boss_wk_reincarnation", "bosses/boss_wk/boss_wk_reincarnation", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_wk_reincarnation:OnCreated()
	self.cd = self:GetSpecialValueFor("reincarnation_cd")
	self.delay = self:GetSpecialValueFor("reincarnation_delay")
	self.addedCD = self:GetSpecialValueFor("phase_bonus_cd")
	self.bonusCD = 0
	self.revives = 0
end

function modifier_boss_wk_reincarnation:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_MIN_HEALTH }
end

function modifier_boss_wk_reincarnation:OnTakeDamage(params)
	local parent = self:GetParent()
	if params.unit == parent and self:GetAbility():IsCooldownReady() and params.damage > parent:GetHealth() then
		self:GetAbility():StartCooldown( self.cd + self.bonusCD )
		parent:AddNewModifier(parent, self:GetAbility(), "modifier_boss_wk_reincarnation_enrage", {duration = self.cd + self.bonusCD}):SetStackCount( self.revives )
		self.bonusCD = self.bonusCD + self.addedCD
		parent:SetHealth( parent:GetMaxHealth() / 2 )
		parent:HealEvent( parent:GetMaxHealth(), source, parent )
		self.revives = self.revives + 1
	end
end

function modifier_boss_wk_reincarnation:GetMinHealth(params)
	if self:GetAbility():IsCooldownReady() then
		return 1
	end
end

function modifier_boss_wk_reincarnation:IsHidden()
	return true
end

function modifier_boss_wk_reincarnation:IsPurgable()
	return false
end

modifier_boss_wk_reincarnation_enrage = class({})
LinkLuaModifier("modifier_boss_wk_reincarnation_enrage", "bosses/boss_wk/boss_wk_reincarnation", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_wk_reincarnation_enrage:OnCreated()
	self.as = self:GetSpecialValueFor("enrage_as") + self:GetSpecialValueFor("revive_bonus_as") * self:GetStackCount()
	self.ms = self:GetSpecialValueFor("enrage_ms")
	self.radius = self:GetSpecialValueFor("enrage_radius")
	if IsServer() then
		self:GetParent():SwapAbilities("boss_wk_reincarnation", "boss_wk_hellfire_fury", false, true)
		
		local ghostFX = ParticleManager:CreateParticle("particles/units/heroes/hero_skeletonking/wraith_king_ghosts_ambient.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(ghostFX, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		self:AddEffect(ghostFX)
	end
end

function modifier_boss_wk_reincarnation_enrage:OnDestroy()
	if IsServer() then
		self:GetParent():SwapAbilities("boss_wk_reincarnation", "boss_wk_hellfire_fury", true, false)
	end
end

function modifier_boss_wk_reincarnation_enrage:IsAura()
	return true
end

function modifier_boss_wk_reincarnation_enrage:GetModifierAura()
	return "modifier_boss_wk_reincarnation_aura"
end

function modifier_boss_wk_reincarnation_enrage:GetAuraRadius()
	return self.radius
end

function modifier_boss_wk_reincarnation_enrage:GetAuraDuration()
	return 0.5
end

function modifier_boss_wk_reincarnation_enrage:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_boss_wk_reincarnation_enrage:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_boss_wk_reincarnation_enrage:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_boss_wk_reincarnation_enrage:DeclareFunctions()
	return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end

function modifier_boss_wk_reincarnation_enrage:GetModifierAttackSpeedBonus()
	return self.as
end

function modifier_boss_wk_reincarnation_enrage:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

function modifier_boss_wk_reincarnation_enrage:GetStatusEffectName()
	return "particles/status_fx/status_effect_wraithking_ghosts.vpcf"
end

function modifier_boss_wk_reincarnation_enrage:StatusEffectPriority()
	return 25
end

modifier_boss_wk_reincarnation_aura = class({})
LinkLuaModifier("modifier_boss_wk_reincarnation_aura", "bosses/boss_wk/boss_wk_reincarnation", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_wk_reincarnation_aura:OnCreated()
	self.dmg = self:GetSpecialValueFor("enrage_dmg") + self:GetSpecialValueFor("revive_bonus_dmg") * self:GetCaster():GetModifierStackCount("modifier_boss_wk_reincarnation_enrage", self:GetCaster())
	if IsServer() then self:StartIntervalThink(1) end
end

function modifier_boss_wk_reincarnation_aura:OnIntervalThink()
	self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), self.dmg, {damage_type = DAMAGE_TYPE_MAGICAL} )
end

function modifier_boss_wk_reincarnation_aura:GetEffectName()
	return "particles/econ/items/wraith_king/wraith_king_ti6_bracer/wraith_king_ti6_hellfireblast_debuff.vpcf"
end
