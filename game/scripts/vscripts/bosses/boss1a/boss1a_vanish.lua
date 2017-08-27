boss1a_vanish = class({})

function boss1a_vanish:OnAbilityPhaseStart()
	ParticleManager:FireParticle( "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_recall_poof.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster() )
	return true
end

function boss1a_vanish:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_boss1a_vanish_fade", {duration = 2})
end

modifier_boss1a_vanish_fade = class({})
LinkLuaModifier("modifier_boss1a_vanish_fade", "bosses/boss1a/boss1a_vanish.lua", 0)

function modifier_boss1a_vanish_fade:OnDestroy()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_boss1a_vanish_invis", {duration = self:GetAbility():GetSpecialValueFor("duration")})
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_invisible", {duration = self:GetAbility():GetSpecialValueFor("duration")})
	end
end

function modifier_boss1a_vanish_fade:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL
	}

	return funcs
end

function modifier_boss1a_vanish_fade:GetModifierInvisibilityLevel( params )
	return 0.45
end

modifier_boss1a_vanish_invis = class({})
LinkLuaModifier("modifier_boss1a_vanish_invis", "bosses/boss1a/boss1a_vanish.lua", 0)

function modifier_boss1a_vanish_invis:OnCreated()
	self.damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
	self.ms = self:GetAbility():GetSpecialValueFor("movement_speed")
end

function modifier_boss1a_vanish_invis:OnDestroy()
	if IsServer() then self:GetParent():RemoveModifierByName("modifier_invisible") end
end

function modifier_boss1a_vanish_invis:CheckState()
	local state = {MODIFIER_STATE_INVISIBLE = true}

	return state
end

function modifier_boss1a_vanish_invis:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ABILITY_START,
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end

function modifier_boss1a_vanish_invis:GetModifierMoveSpeedBonus_Percentage( params )
	return self.ms
end


function modifier_boss1a_vanish_invis:OnAbilityStart( params )
	if params.unit == self:GetParent() then self:Destroy() end
end

function modifier_boss1a_vanish_invis:OnAttackLanded( params )
	if params.attacker == self:GetParent() then 
		local fxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_nyx_assassin/nyx_assassin_vendetta.vpcf", PATTACH_CUSTOMORIGIN, params.attacker )
		ParticleManager:SetParticleControl( fxIndex, 0, params.attacker:GetAbsOrigin() )
		ParticleManager:SetParticleControl( fxIndex, 1, params.target:GetAbsOrigin() )
		ParticleManager:ReleaseParticleIndex(fxIndex)
		StartSoundEvent( "Hero_NyxAssassin.Vendetta.Crit", params.target )
		self:Destroy() 
	end
end

function modifier_boss1a_vanish_invis:GetModifierProcAttack_BonusDamage_Physical( params )
	return self.damage
end