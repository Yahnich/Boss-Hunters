boss_ammetot_restless_warden = class({})

function boss_ammetot_restless_warden:OnSpellStart()
	local caster = self:GetCaster()
	
	caster:AddNewModifier( caster, self, "modifier_boss_ammetot_restless_warden", {duration = self:GetSpecialValueFor("duration")} )
	EmitSoundOn( "Hero_TrollWarlord.BattleTrance.Cast", caster )
	ParticleManager:FireParticle( "particles/units/heroes/hero_troll_warlord/troll_warlord_battletrance_cast.vpcf", PATTACH_POINT_FOLLOW, caster )
end

modifier_boss_ammetot_restless_warden = class({})
LinkLuaModifier( "modifier_boss_ammetot_restless_warden", "bosses/boss_ammetot/boss_ammetot_restless_warden", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_ammetot_restless_warden:OnCreated()
	self.reduction = self:GetSpecialValueFor("reduction")
	self.as = self:GetSpecialValueFor("as")
end

function modifier_boss_ammetot_restless_warden:OnRefresh()
	self:OnCreated()
end

function modifier_boss_ammetot_restless_warden:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, 
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_boss_ammetot_restless_warden:GetModifierAttackSpeedBonus_Constant()
	return self.as
end

function modifier_boss_ammetot_restless_warden:GetModifierIncomingDamage_Percentage()
	return self.reduction
end

function modifier_boss_ammetot_restless_warden:GetEffectName()
	return "particles/units/heroes/hero_troll_warlord/troll_warlord_battletrance_buff.vpcf"
end

function modifier_boss_ammetot_restless_warden:GetStatusEffectName()
	return "particles/status_fx/status_effect_repel.vpcf"
end

function modifier_boss_ammetot_restless_warden:StatusEffectPriority()
	return 10
end