boss_ammetot_illusion_of_inevitability = class({})

function boss_ammetot_illusion_of_inevitability:OnAbilityPhaseStart()
	ParticleManager:FireTargetWarningParticle( self:GetCursorTarget() )
	return true
end

function boss_ammetot_illusion_of_inevitability:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	EmitSoundOn( "Hero_DoomBringer.InfernalBlade.Target", target )
	ParticleManager:FireParticle( "particles/units/heroes/hero_doom_bringer/doom_infernal_blade_impact.vpcf", PATTACH_POINT_FOLLOW, target )
	if target:TriggerSpellAbsorb( self ) then return end
	target:AddNewModifier( caster, self, "modifier_boss_ammetot_illusion_of_inevitability", {duration = self:GetSpecialValueFor("duration")} )
end

modifier_boss_ammetot_illusion_of_inevitability = class({})
LinkLuaModifier( "modifier_boss_ammetot_illusion_of_inevitability", "bosses/boss_ammetot/boss_ammetot_illusion_of_inevitability", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_ammetot_illusion_of_inevitability:OnCreated()
	self.slow = self:GetSpecialValueFor("slow")
	self.damage = self:GetSpecialValueFor("damage") / 100
	if IsServer() then
		self:StartIntervalThink(0.99)
	end
end

function modifier_boss_ammetot_illusion_of_inevitability:OnRefresh()
	self:OnCreated()
end

function modifier_boss_ammetot_illusion_of_inevitability:OnIntervalThink()
	self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), self:GetParent():GetHealth() * self.damage, {damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION} )
end

function modifier_boss_ammetot_illusion_of_inevitability:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_boss_ammetot_illusion_of_inevitability:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_boss_ammetot_illusion_of_inevitability:GetEffectName()
	return "particles/units/heroes/hero_doom_bringer/doom_infernal_blade_debuff.vpcf"
end