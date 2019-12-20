boss_treant_overgrowth = class({})

function boss_treant_overgrowth:GetBehavior()
	if self:GetCaster():HasTalent("special_bonus_unique_treant_overgrowth_1") then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET
	else
		return self.BaseClass.GetBehavior(self)
	end
end

function boss_treant_overgrowth:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	caster:EmitSound("Hero_Treant.Overgrowth.Cast")
	
	local duration = self:GetSpecialValueFor("duration")
	self:ApplyOverGrowth(target, duration)
end

function boss_treant_overgrowth:ApplyOverGrowth(target, duration)
	local caster = self:GetCaster()
	
	ParticleManager:FireRopeParticle("particles/units/heroes/hero_treant/treant_overgrowth_trails.vpcf", PATTACH_POINT_FOLLOW, caster, target)
	target:EmitSound("Hero_Treant.Overgrowth.Target")
	if target:TriggerSpellAbsorb( self ) then return end
	local flDur = duration or self:GetSpecialValueFor("duration")
	target:AddNewModifier(caster, self, "modifier_boss_treant_overgrowth_root", {duration = duration})
end

modifier_boss_treant_overgrowth_root = class({})
LinkLuaModifier("modifier_boss_treant_overgrowth_root", "bosses/boss_treants/boss_treant_overgrowth", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_treant_overgrowth_root:CheckState()
	return {[MODIFIER_STATE_ROOTED] = true,
			[MODIFIER_STATE_DISARMED] = true,
			[MODIFIER_STATE_INVISIBLE] = false}
end

function modifier_boss_treant_overgrowth_root:GetEffectName()
	return "particles/units/heroes/hero_treant/treant_overgrowth_vines.vpcf"
end