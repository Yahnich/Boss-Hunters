slark_depth_shroud_bh = class({})

function slark_depth_shroud_bh:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function slark_depth_shroud_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	
	local duration = self:GetSpecialValueFor("duration")
	local radius = self:GetSpecialValueFor("radius")
	
	
	print( duration )
	local dummy = CreateModifierThinker( caster, self, "modifier_slark_depth_shroud_dummy", {duration = duration}, target, caster:GetTeam(), false )
	
	EmitSoundOnLocationWithCaster( target, "Hero_Slark.FishBait", caster )
	EmitSoundOnLocationWithCaster( target, "Hero_Slark.DarkPact.Cast.Immortal", caster )
	local FX = ParticleManager:FireParticle("particles/units/heroes/hero_slark/slark_shard_depth_shroud.vpcf", PATTACH_ABSORIGIN_FOLLOW, dummy, {[0] = {}, [1] = duration, [2] = radius})
end

modifier_slark_depth_shroud_dummy = class({})
LinkLuaModifier("modifier_slark_depth_shroud_dummy", "heroes/hero_slark/slark_depth_shroud_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_slark_depth_shroud_dummy:OnCreated()
	self:OnRefresh()
end

function modifier_slark_depth_shroud_dummy:OnRefresh()
	self.duration = self:GetSpecialValueFor("duration")
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_slark_depth_shroud_dummy:IsAura()
	return true
end

function modifier_slark_depth_shroud_dummy:GetModifierAura()
	return "modifier_slark_depth_shroud_dummy_aura"
end

function modifier_slark_depth_shroud_dummy:GetAuraRadius()
	return self.radius
end

function modifier_slark_depth_shroud_dummy:GetAuraDuration()
	return 0.5
end

function modifier_slark_depth_shroud_dummy:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_slark_depth_shroud_dummy:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_slark_depth_shroud_dummy:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_slark_depth_shroud_dummy:IsHidden()
	return true
end

modifier_slark_depth_shroud_dummy_aura = class({})
LinkLuaModifier("modifier_slark_depth_shroud_dummy_aura", "heroes/hero_slark/slark_depth_shroud_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_slark_depth_shroud_dummy_aura:OnCreated()
	self:OnRefresh(  )
end

function modifier_slark_depth_shroud_dummy_aura:OnRefresh()
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_slark_depth_shroud_1")
	self.talent1Chill = self:GetCaster():FindTalentValue( "special_bonus_unique_slark_depth_shroud_1" )
	self.talent1FrozenDmg = self:GetCaster():FindTalentValue( "special_bonus_unique_slark_depth_shroud_1", "value2" )
end

function modifier_slark_depth_shroud_dummy_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_INVISIBILITY_LEVEL, MODIFIER_EVENT_ON_ATTACK_LANDED }
end

function modifier_slark_depth_shroud_dummy_aura:GetModifierInvisibilityLevel()
	return 1
end

function modifier_slark_depth_shroud_dummy_aura:OnAttackLanded(params)
	if self.talent1 and params.attacker == self:GetCaster() then
		local ability = self:GetAbility()
		params.target:AddChill( ability, params.attacker, 1, self.talent1Chill)
		local damage = TernaryOperator( self.talent1FrozenDmg, params.target:IsFrozenGeneric(), params.target:GetChillCount() )
		ability:DealDamage( params.attacker, params.target, damage, {damage_type = DAMAGE_TYPE_PURE}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE )
	end
end

function modifier_slark_depth_shroud_dummy_aura:GetStatusEffectName()
	return "particles/status_fx/status_effect_slark_shadow_dance.vpcf"
end

function modifier_slark_depth_shroud_dummy_aura:StatusEffectPriority()
	return 50
end

function modifier_slark_depth_shroud_dummy_aura:CheckState()
	return {[MODIFIER_STATE_INVISIBLE] = true,
			[MODIFIER_STATE_UNTARGETABLE] = true,
			[MODIFIER_STATE_ATTACK_IMMUNE] = true,
			}
end