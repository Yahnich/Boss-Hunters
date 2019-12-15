batrider_lasso = class({})
LinkLuaModifier("modifier_batrider_lasso", "heroes/hero_batrider/batrider_lasso", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_batrider_lasso_debuff", "heroes/hero_batrider/batrider_lasso", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_batrider_lasso_debuff_after", "heroes/hero_batrider/batrider_lasso", LUA_MODIFIER_MOTION_NONE)

function batrider_lasso:IsStealable()
    return true
end

function batrider_lasso:IsHiddenWhenStolen()
    return false
end

function batrider_lasso:GetAOERadius()
    return self:GetTalentSpecialValueFor("radius")
end

function batrider_lasso:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	local duration = self:GetTalentSpecialValueFor("duration")
	local radius = self:GetTalentSpecialValueFor("radius")

	local maxTargets = self:GetTalentSpecialValueFor("max_targets") - 1 --because the selected target counts too

	EmitSoundOn("Hero_Batrider.FlamingLasso.Cast", caster)
	if not target:TriggerSpellAbsorb(self) then
		caster:AddNewModifier(caster, self, "modifier_batrider_lasso", {Duration = duration})
		target:AddNewModifier(caster, self, "modifier_batrider_lasso_debuff", {Duration = duration})
	end

	local enemies = caster:FindEnemyUnitsInRadius(target:GetAbsOrigin(), radius)
	for _,enemy in pairs(enemies) do
		if enemy ~= target and maxTargets > 0 then
			if not enemy:TriggerSpellAbsorb(self) then
				enemy:AddNewModifier(caster, self, "modifier_batrider_lasso_debuff", {Duration = duration})
			end
			maxTargets = maxTargets - 1
		end
	end

	self:StartDelayedCooldown(duration)
end

modifier_batrider_lasso = class({})

function modifier_batrider_lasso:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
end

function modifier_batrider_lasso:GetOverrideAnimation()
	return ACT_DOTA_LASSO_LOOP
end

function modifier_batrider_lasso:IsDebuff()
	return false
end

modifier_batrider_lasso_debuff = class({})
function modifier_batrider_lasso_debuff:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local parent = self:GetParent()

		EmitSoundOn("Hero_Batrider.FlamingLasso.Loop", parent)

		self.damage = self:GetTalentSpecialValueFor("damage")
		self.maxDistance = self:GetTalentSpecialValueFor("drag_distance")

		self.tick = 1 + FrameTime()

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_batrider/batrider_flaming_lasso.vpcf", PATTACH_POINT_FOLLOW, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT_FOLLOW, "lasso_attack", caster:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 1, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)

		self:AttachEffect(nfx)

		self:StartIntervalThink(FrameTime())
	end
end

function modifier_batrider_lasso_debuff:OnRefresh(table)
	if IsServer() then
		self.damage = self:GetTalentSpecialValueFor("damage")
		self.maxDistance = self:GetTalentSpecialValueFor("drag_distance")
	end
end

function modifier_batrider_lasso_debuff:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()

	if self.tick >= 1 + FrameTime() then
		ParticleManager:FireParticle("particles/units/heroes/hero_batrider/batrider_flamebreak_debuff.vpcf", PATTACH_POINT, parent, {})

		if caster:HasTalent("special_bonus_unique_batrider_lasso_2") then
			local enemies = caster:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), parent:GetModelRadius())
			for _,enemy in pairs(enemies) do
				if enemy ~= parent and not enemy:HasModifier("modifier_batrider_lasso_debuff") then
					enemy:ApplyKnockBack(parent:GetAbsOrigin(), 0.25, 0.25, 200, 100, caster, self:GetAbility(), true)
				end
				self:GetAbility():DealDamage(caster, enemy, self.damage, {}, OVERHEAD_ALERT_MANA_LOSS)
			end
		else
			self:GetAbility():DealDamage(caster, parent, self.damage, {}, OVERHEAD_ALERT_MANA_LOSS)
		end

		self.tick = 0
	else
		self.tick = self.tick + FrameTime()
	end
	
	local distance = CalculateDistance(parent, caster)
	local direction = CalculateDirection(parent, caster)

	if distance >= self.maxDistance then 
		parent:SetAbsOrigin(GetGroundPosition(parent:GetAbsOrigin(), parent) - direction * caster:GetIdealSpeedNoSlows() * FrameTime())
	end
end

function modifier_batrider_lasso_debuff:OnRemoved()
	if IsServer() then
		StopSoundOn("Hero_Batrider.FlamingLasso.End", self:GetParent())

		if self:GetCaster():HasTalent("special_bonus_unique_batrider_lasso_1") then
			self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_batrider_lasso_debuff_after", {Duration = 3})
		end

		FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
	end
end

function modifier_batrider_lasso_debuff:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
			[MODIFIER_STATE_PROVIDES_VISION] = true,
			[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
			[MODIFIER_STATE_TETHERED] = true,
			[MODIFIER_STATE_INVISIBLE] = false}
end

function modifier_batrider_lasso_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
end

function modifier_batrider_lasso_debuff:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

function modifier_batrider_lasso_debuff:IsDebuff()
	return true
end

modifier_batrider_lasso_debuff_after = class({})
function modifier_batrider_lasso_debuff_after:OnCreated(table)
	if IsServer() then
		self.damage = self:GetTalentSpecialValueFor("damage")

		self:StartIntervalThink(1)
	end
end

function modifier_batrider_lasso_debuff_after:OnRefresh(table)
	if IsServer() then
		self.damage = self:GetTalentSpecialValueFor("damage")
	end
end

function modifier_batrider_lasso_debuff_after:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()

	self:GetAbility():DealDamage(caster, parent, self.damage, {}, OVERHEAD_ALERT_MANA_LOSS)
end

function modifier_batrider_lasso_debuff_after:CheckState()
	return {[MODIFIER_STATE_ROOTED] = true,
			[MODIFIER_STATE_INVISIBLE] = false}
end

function modifier_batrider_lasso_debuff_after:GetEffectName()
	return "particles/units/heroes/hero_ember_spirit/ember_spirit_searing_chains_debuff.vpcf"
end

function modifier_batrider_lasso_debuff_after:IsDebuff()
	return true
end