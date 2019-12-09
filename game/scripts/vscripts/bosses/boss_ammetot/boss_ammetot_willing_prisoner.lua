boss_ammetot_willing_prisoner = class({})

function boss_ammetot_willing_prisoner:OnAbilityPhaseStart()
	ParticleManager:FireTargetWarningParticle( self:GetCursorTarget() )
	ParticleManager:FireWarningParticle( self:GetCursorTarget():GetAbsOrigin(), self:GetSpecialValueFor("radius") )
	return true
end

function boss_ammetot_willing_prisoner:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	target:AddNewModifier( target, self, "modifier_boss_ammetot_willing_prisoner", {duration = self:GetSpecialValueFor("duration")} )
	EmitSoundOn( "Hero_Winter_Wyvern.WintersCurse.Cast", target )
	ParticleManager:FireParticle( "particles/units/heroes/hero_winter_wyvern/wyvern_winters_curse_ground.vpcf", PATTACH_POINT_FOLLOW, target )
	ParticleManager:FireParticle( "particles/units/heroes/hero_winter_wyvern/wyvern_winters_curse_start.vpcf", PATTACH_POINT_FOLLOW, target )
end


modifier_boss_ammetot_willing_prisoner = class({})
LinkLuaModifier( "modifier_boss_ammetot_willing_prisoner", "bosses/boss_ammetot/boss_ammetot_willing_prisoner", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_ammetot_willing_prisoner:OnCreated()
	self.radius = self:GetSpecialValueFor("radius")
	self.amp = self:GetSpecialValueFor("damage_amp")
end

function modifier_boss_ammetot_willing_prisoner:OnRefresh()
	self:OnCreated()
end

function modifier_boss_ammetot_willing_prisoner:IsAura()
	return true
end

function modifier_boss_ammetot_willing_prisoner:GetAuraRadius()
	return self.radius
end

function modifier_boss_ammetot_willing_prisoner:GetAuraDuration()
	return 0.5
end

function modifier_boss_ammetot_willing_prisoner:GetModifierAura()
	return "modifier_boss_ammetot_willing_prisoner_debuff"
end

function modifier_boss_ammetot_willing_prisoner:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_boss_ammetot_willing_prisoner:GetAuraEntityReject(entity)
	return self:GetParent() == entity
end

function modifier_boss_ammetot_willing_prisoner:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_boss_ammetot_willing_prisoner:CheckState()
	return {[MODIFIER_STATE_SPECIALLY_DENIABLE] = true}
end

function modifier_boss_ammetot_willing_prisoner:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_boss_ammetot_willing_prisoner:GetModifierIncomingDamage_Percentage()
	return self.amp
end

function modifier_boss_ammetot_willing_prisoner:IsDebuff()
	return true
end

function modifier_boss_ammetot_willing_prisoner:GetEffectName()
	return "particles/units/heroes/hero_winter_wyvern/wyvern_winters_curse_status.vpcf"
end

function modifier_boss_ammetot_willing_prisoner:GetStatusEffectName()
	return "particles/status_fx/status_effect_wyvern_curse_target.vpcf"
end

function modifier_boss_ammetot_willing_prisoner:StatusEffectPriority()
	return 10
end

modifier_boss_ammetot_willing_prisoner_debuff = class({})
LinkLuaModifier( "modifier_boss_ammetot_willing_prisoner_debuff", "bosses/boss_ammetot/boss_ammetot_willing_prisoner", LUA_MODIFIER_MOTION_NONE )

if IsServer() then
	function modifier_boss_ammetot_willing_prisoner_debuff:OnCreated()
		self:GetParent():SetForceAttackTargetAlly( self:GetCaster() )
		self:GetParent():SetAttacking( self:GetCaster() )
		self:GetParent():MoveToTargetToAttack( self:GetCaster() )
		self:StartIntervalThink( 0.25 )
		
		EmitSoundOn( "Hero_Winter_Wyvern.WintersCurse.Target", target )
	end
	
	function modifier_boss_ammetot_willing_prisoner_debuff:OnIntervalThink()
		self:GetParent():SetForceAttackTargetAlly( self:GetCaster() )
		self:GetParent():SetAttacking( self:GetCaster() )
		self:GetParent():MoveToTargetToAttack( self:GetCaster() )
	end

	function modifier_boss_ammetot_willing_prisoner_debuff:OnDestroy()
		self:GetParent():SetForceAttackTargetAlly( nil )
		self:GetParent():SetAttacking( nil ) 
		self:GetParent():MoveToTargetToAttack( nil )
	end
end

function modifier_boss_ammetot_willing_prisoner_debuff:IsDebuff()
	return true
end

function modifier_boss_ammetot_willing_prisoner_debuff:GetEffectName()
	return "particles/units/heroes/hero_winter_wyvern/wyvern_winters_curse_buff.vpcf"
end

function modifier_boss_ammetot_willing_prisoner_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_wyvern_curse_buff.vpcf"
end

function modifier_boss_ammetot_willing_prisoner_debuff:StatusEffectPriority()
	return 10
end