treant_overgrowth_bh = class({})

function treant_overgrowth_bh:GetBehavior()
	if self:GetCaster():HasTalent("special_bonus_unique_treant_overgrowth_1") then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET
	else
		return self.BaseClass.GetBehavior(self)
	end
end

function treant_overgrowth_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	caster:EmitSound("Hero_Treant.Overgrowth.Cast")
	
	local duration = self:GetSpecialValueFor("duration")
	if target then
		self:ApplyOverGrowth(target, duration)
	else
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), self:GetTrueCastRange() ) ) do
			self:ApplyOverGrowth(enemy, duration)
		end
	end
end

function treant_overgrowth_bh:ApplyOverGrowth(target, duration)
	local caster = self:GetCaster()
	
	ParticleManager:FireRopeParticle("particles/units/heroes/hero_treant/treant_overgrowth_trails.vpcf", PATTACH_POINT_FOLLOW, caster, target)
	target:EmitSound("Hero_Treant.Overgrowth.Target")
	if target:TriggerSpellAbsorb( self ) then return end
	local flDur = duration or self:GetSpecialValueFor("duration")
	target:AddNewModifier(caster, self, "modifier_treant_overgrowth_bh_root", {duration = flDur})
	
	if caster:HasTalent("special_bonus_unique_treant_overgrowth_2") then
		local seed = caster:FindAbilityByName("treant_leech_seed_bh")
		if seed then
			seed:ApplyLeechSeed(target)
		end
	end
end

modifier_treant_overgrowth_bh_root = class({})
LinkLuaModifier("modifier_treant_overgrowth_bh_root", "heroes/hero_treant_protector/treant_overgrowth_bh", LUA_MODIFIER_MOTION_NONE)

-- if IsServer() then
	-- function modifier_treant_overgrowth_bh_root:OnCreated()
		-- self:StartDelayedCooldown()
	-- end
	
	-- function modifier_treant_overgrowth_bh_root:OnRefresh()
		-- self:StartDelayedCooldown()
	-- end
	
	-- function modifier_treant_overgrowth_bh_root:OnDestroy()
		-- self:EndDelayedCooldown()
	-- end
-- end

function modifier_treant_overgrowth_bh_root:CheckState()
	return {[MODIFIER_STATE_ROOTED] = true,
			[MODIFIER_STATE_DISARMED] = true,
			[MODIFIER_STATE_INVISIBLE] = false}
end

function modifier_treant_overgrowth_bh_root:GetEffectName()
	return "particles/units/heroes/hero_treant/treant_overgrowth_vines.vpcf"
end