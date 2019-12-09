wisp_tether_bh = class({})
LinkLuaModifier("modifier_wisp_tether_bh", "heroes/hero_wisp/wisp_tether_bh", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_wisp_tether_bh_target", "heroes/hero_wisp/wisp_tether_bh", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_wisp_tether_bh_motion", "heroes/hero_wisp/wisp_tether_bh", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_wisp_tether_bh_aghs", "heroes/hero_wisp/wisp_tether_bh", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_wisp_overcharge_bh", "heroes/hero_wisp/wisp_overcharge_bh", LUA_MODIFIER_MOTION_NONE)

function wisp_tether_bh:IsStealable()
    return true
end

function wisp_tether_bh:IsHiddenWhenStolen()
    return false
end

function wisp_tether_bh:CastFilterResultTarget(hTarget)
	if hTarget == self:GetCaster() then
		return UF_FAIL_CUSTOM
	else
		return UnitFilter( hTarget, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, self:GetCaster():GetTeamNumber() )
	end
end

function wisp_tether_bh:GetCustomCastErrorTarget(hTarget)
	if hTarget == self:GetCaster() then
		return "Ability Can't Target Self"
	end
end

function wisp_tether_bh:GetAbilityTextureName()
    if self:GetCaster():HasModifier("modifier_wisp_tether_bh") then
    	return "wisp_tether_break"
    end
    return "wisp_tether"
end

function wisp_tether_bh:GetBehavior()
    if self:GetCaster():HasModifier("modifier_wisp_tether_bh") then
    	return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    end
    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
end

function wisp_tether_bh:OnSpellStart()
	local caster = self:GetCaster()
	
	if caster:HasModifier("modifier_wisp_tether_bh") then
		caster:RemoveModifierByName("modifier_wisp_tether_bh")
		self:RefundManaCost()
	else
		local target = self:GetCursorTarget()

		caster:Stop()
		local pullDistance = self:GetTalentSpecialValueFor("pull_distance")
		if CalculateDistance(target, caster) > pullDistance * 2 then
			caster:AddNewModifier(caster, self, "modifier_wisp_tether_bh_motion", {Duration = 5})
		end

		EmitSoundOn("Hero_Wisp.Tether.Target", target)
		
		target:AddNewModifier(caster, self, "modifier_wisp_tether_bh_target", {})
		caster:AddNewModifier(caster, self, "modifier_wisp_tether_bh", {})
		self:EndCooldown()
	end
end

modifier_wisp_tether_bh = class({})

function modifier_wisp_tether_bh:OnCreated(table)
	self.bonus_ms = self:GetTalentSpecialValueFor("bonus_ms")
	if IsServer() then
		local caster = self:GetCaster()
		self.target = self:GetAbility():GetCursorTarget()
		self.range = self:GetTalentSpecialValueFor("break_distance") + caster:GetBonusCastRange()
		self.restoreMultiplier = self:GetTalentSpecialValueFor("restore_amp")/100

		EmitSoundOn("Hero_Wisp.Tether", caster)

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_wisp/wisp_tether.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 1, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", self.target:GetAbsOrigin(), true)

		self:AttachEffect(nfx)

		if caster:HasTalent("special_bonus_unique_wisp_tether_bh_2") then
			self.paralyzeDuration = caster:FindTalentValue("special_bonus_unique_wisp_tether_bh_2")
		end

		self:StartIntervalThink(0.05)
	end
end

function modifier_wisp_tether_bh:OnIntervalThink()
	local caster = self:GetCaster()
	local distance = CalculateDistance(self.target, self:GetCaster())
	if not self.target or not self.target:HasModifier("modifier_wisp_tether_bh_target") or ( distance >= self.range and not caster:HasModifier("modifier_wisp_tether_bh_motion") ) then
		self:Destroy()
		return
	end
	if caster:HasScepter() then
		if not self.target:HasScepter() and not self.target:HasModifier("modifier_wisp_tether_bh_aghs") then
			self.target:AddNewModifier(caster, self:GetAbility(), "modifier_wisp_tether_bh_aghs", {})
		end
	elseif self.target:HasModifier("modifier_wisp_tether_bh_aghs") then
		self.target:RemoveModifierByNameAndCaster("modifier_wisp_tether_bh_aghs", caster)
	end

	if caster:HasModifier("modifier_wisp_overcharge_bh") then
		if not self.target:HasModifier("modifier_wisp_overcharge_bh") then
			self.target:AddNewModifier(caster, caster:FindAbilityByName("wisp_overcharge_bh"), "modifier_wisp_overcharge_bh", {})
		end
	else
		self.target:RemoveModifierByName("modifier_wisp_overcharge_bh")
	end

	if caster:HasTalent("special_bonus_unique_wisp_tether_bh_2") then
		local enemies = caster:FindEnemyUnitsInLine(caster:GetAbsOrigin(), self.target:GetAbsOrigin(), 75, {})
		for _,enemy in pairs(enemies) do
			if not enemy:IsParalyzed() then
				enemy:Paralyze(self:GetAbility(), caster, self.paralyzeDuration)
			end
		end
	end
end

function modifier_wisp_tether_bh:DeclareFunctions()
	local funcs = {	MODIFIER_EVENT_ON_HEAL_RECEIVED,
					MODIFIER_EVENT_ON_MANA_GAINED,
					MODIFIER_EVENT_ON_DEATH,
					MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
	return funcs
end

function modifier_wisp_tether_bh:OnHealReceived(params)
	if IsServer() then
		local parent = self:GetParent()
		if params.unit == parent then
			local heal = params.gain

			if self.target and self.target:IsAlive() then
				local amount = heal * self.restoreMultiplier
				self.target:HealEvent(amount, self:GetAbility(), parent, false)
			end
		end
	end
end

function modifier_wisp_tether_bh:OnManaGained(params)
	if IsServer() then
		local parent = self:GetParent()
		if params.unit == parent then
			local mana = params.gain

			if self.target and self.target:IsAlive() then
				local amount = mana * self.restoreMultiplier
				self.target:GiveMana(amount)
			end
		end
	end
end

function modifier_wisp_tether_bh:OnDeath(params)
	if IsServer() then
		local parent = self:GetParent()
		if params.unit == self.target or params.unit == parent then
			if params.unit then
				params.unit:RemoveModifierByName("modifier_wisp_tether_bh_target")
				self:Destroy()
			end
		end
	end
end

function modifier_wisp_tether_bh:OnRemoved()
	if IsServer() then
		local parent = self:GetParent()
		StopSoundOn("Hero_Wisp.Tether", parent)
		EmitSoundOn("Hero_Wisp.Tether.Stop", parent)
		
		if self.target and self.target:IsAlive() then
			self.target:RemoveModifierByNameAndCaster("modifier_wisp_tether_bh_target", self:GetCaster())
		end
	end
end

function modifier_wisp_tether_bh:GetModifierMoveSpeedBonus_Percentage()
	return self.bonus_ms
end

function modifier_wisp_tether_bh:IsDebuff()
	return false
end

function modifier_wisp_tether_bh:IsPurgable()
	return false
end

function modifier_wisp_tether_bh:IsPurgeException()
	return false
end

modifier_wisp_tether_bh_target = class({})
function modifier_wisp_tether_bh_target:OnCreated(table)
	self.bonus_ms = self:GetTalentSpecialValueFor("bonus_ms")
end

function modifier_wisp_tether_bh_target:OnRemoved()
	if IsServer() and self:GetParent() ~= self:GetCaster() then
		self:GetParent():RemoveModifierByNameAndCaster("modifier_wisp_overcharge_bh", self:GetCaster())
	end
end

function modifier_wisp_tether_bh_target:DeclareFunctions()
	local funcs = { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
					MODIFIER_EVENT_ON_ATTACK}
	return funcs
end

function modifier_wisp_tether_bh_target:GetModifierMoveSpeedBonus_Percentage()
	return self.bonus_ms
end

function modifier_wisp_tether_bh_target:OnAttack(params)
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local attacker = params.attacker
		local target = params.target

		if caster:HasTalent("special_bonus_unique_wisp_tether_bh_1") then
			if parent == attacker then
				caster:PerformGenericAttack(target, false, 0, false, false)
			end
		end
	end
end

function modifier_wisp_tether_bh_target:IsDebuff()
	return false
end

function modifier_wisp_tether_bh_target:IsPurgable()
	return false
end

function modifier_wisp_tether_bh_target:IsPurgeException()
	return false
end

modifier_wisp_tether_bh_motion = class({})
function modifier_wisp_tether_bh_motion:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		self.target = self:GetAbility():GetCursorTarget()

		self.direction = CalculateDirection(self.target, caster)

		self.speed = 1000 * FrameTime()

		self.maxDistance = self:GetTalentSpecialValueFor("pull_distance")

		self.currentDistance = 0

		self:StartIntervalThink(FrameTime())
	end
end

function modifier_wisp_tether_bh_motion:OnIntervalThink()
	local caster = self:GetCaster()

	if caster:HasModifier("modifier_wisp_tether_bh") or caster:HasModifier("modifier_wisp_transfer") then
		local pos = GetGroundPosition(caster:GetAbsOrigin(), caster)

		self.direction = CalculateDirection(self.target, caster)

		local velocity = self.direction * self.speed

		if self.currentDistance < self.maxDistance then
			caster:SetAbsOrigin(pos + velocity)
			self.currentDistance = self.currentDistance + self.speed
		else
			ResolveNPCPositions( pos, caster:GetHullRadius() * 2 ) 
			self:Destroy()
		end
	else
		self:Destroy()
	end
end

function modifier_wisp_tether_bh_motion:IsHidden()
	return true
end

function modifier_wisp_tether_bh_motion:IsPurgable()
	return false
end

function modifier_wisp_tether_bh_motion:IsPurgeException()
	return false
end

modifier_wisp_tether_bh_aghs = class({})

if IsServer() then
	function modifier_wisp_tether_bh_aghs:OnCreated()
		local caster = self:GetCaster()
		for i = 0, caster:GetAbilityCount() - 1 do
			local ability = caster:GetAbilityByIndex( i )
			if ability and ability.OnInventoryContentsChanged then
				ability:OnInventoryContentsChanged()
			end
		end
	end
	
	function modifier_wisp_tether_bh_aghs:OnDestroy()
		local caster = self:GetCaster()
		for i = 0, caster:GetAbilityCount() - 1 do
			local ability = caster:GetAbilityByIndex( i )
			if ability and ability.OnInventoryContentsChanged then
				ability:OnInventoryContentsChanged()
			end
		end
	end
end

function modifier_wisp_tether_bh_aghs:GetTexture()
	return "item_ultimate_scepter"
end

function modifier_wisp_tether_bh_aghs:DeclareFunctions()
	local funcs = {MODIFIER_PROPERTY_IS_SCEPTER}
	return funcs
end

function modifier_wisp_tether_bh_aghs:GetModifierScepter()
	return 1
end

function modifier_wisp_tether_bh_aghs:IsDebuff()
	return false
end

function modifier_wisp_tether_bh_aghs:IsPurgable()
	return false
end

function modifier_wisp_tether_bh_aghs:IsPurgeException()
	return false
end