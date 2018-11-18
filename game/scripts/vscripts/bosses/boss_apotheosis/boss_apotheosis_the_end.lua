boss_apotheosis_the_end = class({})

function boss_apotheosis_the_end:OnAbilityPhaseStart()
	ParticleManager:FireTargetWarningParticle(self:GetCursorTarget())
	return true
end

function boss_apotheosis_the_end:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	target:AddNewModifier( caster, self, "modifier_boss_apotheosis_the_end", {duration = self:GetSpecialValueFor("death_timer") + 0.1})
	ParticleManager:FireParticle("particles/bosses/boss_apotheosis/boss_apotheosis_the_end_effect.vpcf", PATTACH_POINT_FOLLOW, target, {[1] = Vector(900,1,1)})
	target:EmitSound("Hero_Necrolyte.ReapersScythe.Cast")
end

modifier_boss_apotheosis_the_end = class({})	
LinkLuaModifier( "modifier_boss_apotheosis_the_end", "bosses/boss_apotheosis/boss_apotheosis_the_end", LUA_MODIFIER_MOTION_NONE )

if IsServer() then
	function modifier_boss_apotheosis_the_end:OnCreated()
		self:StartIntervalThink( self:GetRemainingTime() - 0.1 )
	end
	
	function modifier_boss_apotheosis_the_end:OnIntervalThink()
		ParticleManager:FireParticle("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_prison_end.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
		self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), self:GetParent():GetMaxHealth() * 99, {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_HPLOSS} )
		self:GetParent():EmitSound("Hero_Necrolyte.ReapersScythe.Target")
	end
end

function modifier_boss_apotheosis_the_end:CheckState()
	return {[MODIFIER_STATE_SPECIALLY_DENIABLE] = true}
end

function modifier_boss_apotheosis_the_end:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK}
end

function modifier_boss_apotheosis_the_end:OnAttack(params)
	if params.target == self:GetParent() and params.attacker:IsSameTeam(params.target) then
		params.attacker:EmitSound("Hero_Necrolyte.ReapersScythe.Cast")
		ParticleManager:FireParticle("particles/bosses/boss_apotheosis/boss_apotheosis_the_end_effect.vpcf", PATTACH_POINT_FOLLOW, params.attacker)
		params.attacker:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_boss_apotheosis_the_end", {duration = self:GetSpecialValueFor("death_timer") + 0.1})
		self:Destroy()
	end
end

function modifier_boss_apotheosis_the_end:GetEffectName()
	return "particles/units/bosses/boss_apotheosis/boss_apotheosis_the_end_debufftrack_scroll.vpcf"
end

function modifier_boss_apotheosis_the_end:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_boss_apotheosis_the_end:GetStatusEffectName()
	return "particles/status_fx/status_effect_wraithking_ghosts.vpcf"
end

function modifier_boss_apotheosis_the_end:GetStatusEffectPriority()
	return 20
end

function modifier_boss_apotheosis_the_end:IsPurgable()
	return false
end