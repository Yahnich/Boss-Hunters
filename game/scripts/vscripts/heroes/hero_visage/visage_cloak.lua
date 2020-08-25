visage_cloak = class({})

function visage_cloak:IsStealable()
    return false
end

function visage_cloak:IsHiddenWhenStolen()
    return false
end

function visage_cloak:CastFilterResultTarget(hTarget)
    if hTarget:HasModifier("modifier_visage_cloak_handle") then
    	return UF_FAIL_CUSTOM
    end
end

function visage_cloak:GetCustomCastErrorTarget(hTarget)
    if hTarget:HasModifier("modifier_visage_cloak_handle") then
    	return "Cannot target Visage or Familiars."
    end
end

function visage_cloak:GetBehavior()
    local caster = self.visage or self:GetCaster()
    if caster:HasTalent("special_bonus_unique_visage_cloak_2") then
    	return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
    end
    return DOTA_ABILITY_BEHAVIOR_PASSIVE
end

function visage_cloak:GetAbilityTargetTeam()
    local caster = self.visage or self:GetCaster()
    if caster:HasTalent("special_bonus_unique_visage_cloak_2") then
    	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
    end
end

function visage_cloak:GetAbilityTargetType()
    local caster = self.visage or self:GetCaster()
    if caster:HasTalent("special_bonus_unique_visage_cloak_2") then
    	return DOTA_UNIT_TARGET_ALL
    end
end

function visage_cloak:GetAbilityTargetFlags()
    local caster = self.visage or self:GetCaster()
    if caster:HasTalent("special_bonus_unique_visage_cloak_2") then
    	return DOTA_UNIT_TARGET_FLAG_NONE
    end
end

function visage_cloak:GetCastRange(vLocation, hTarget)
    local caster = self.visage or self:GetCaster()
    if caster:HasTalent("special_bonus_unique_visage_cloak_2") then
    	return 900
    end
end

function visage_cloak:GetCastAnimation()
    local caster = self.visage or self:GetCaster()
    if caster:HasTalent("special_bonus_unique_visage_cloak_2") then
    	return ACT_DOTA_CAST_ABILITY_4
    end
end

function visage_cloak:GetCastPoint()
    local caster = self.visage or self:GetCaster()
    if caster:HasTalent("special_bonus_unique_visage_cloak_2") then
    	return 0.2
    end
end

function visage_cloak:GetCooldown(iLevel)
    local caster = self.visage or self:GetCaster()
    if caster:HasTalent("special_bonus_unique_visage_cloak_2") then
    	return 20
    end
end

function visage_cloak:GetIntrinsicModifierName()
    return "modifier_visage_cloak_handle"
end

function visage_cloak:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
	local talentOwner = caster.visage or caster
	local layers = self:GetTalentSpecialValueFor("max_layers")
    target:AddNewModifier(caster, self, "modifier_visage_cloak", {}):SetStackCount(layers)
	if talentOwner:HasTalent("special_bonus_unique_visage_cloak_1") then
		target:AddNewModifier(caster, self, "modifier_visage_cloak_talent", {}):SetStackCount(layers)
	end
end

modifier_visage_cloak_handle = class({})
LinkLuaModifier( "modifier_visage_cloak_handle", "heroes/hero_visage/visage_cloak", LUA_MODIFIER_MOTION_NONE )

function modifier_visage_cloak_handle:OnCreated()
	self:OnRefresh()
end

function modifier_visage_cloak_handle:OnRefresh()
	self.recovery_time = self:GetTalentSpecialValueFor("recovery_time")
	self.max = self:GetTalentSpecialValueFor("max_layers")
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local talentOwner = caster.visage or parent
		parent:AddNewModifier(caster, self:GetAbility(), "modifier_visage_cloak", {})
		if talentOwner:HasTalent("special_bonus_unique_visage_cloak_1") then
			parent:AddNewModifier(caster, self:GetAbility(), "modifier_visage_cloak_talent", {})
		end
	end
end

function modifier_visage_cloak_handle:PrepareNewLayer(modifierName)
	local caster = self:GetCaster()
	local parent = self:GetParent()

	if parent:IsAlive() then
		local modifier = parent:FindModifierByName(modifierName)
		if modifier then
			modifier:SetDuration( self.recovery_time + 0.1, true )
		end
		Timers:CreateTimer( self.recovery_time, function()
			local modifier = parent:FindModifierByName(modifierName)
			if modifier then
				if modifier:GetStackCount() < self.max then
					modifier:IncrementStackCount()
				end
				if modifier:GetStackCount() == self.max then
					modifier:SetDuration( -1, true )
				end
			else
				parent:AddNewModifier( caster, self:GetAbility(), modifierName, {})
			end
		end)
	end
end

function modifier_visage_cloak_handle:IsHidden()
	return true
end

modifier_visage_cloak = class({})
LinkLuaModifier( "modifier_visage_cloak", "heroes/hero_visage/visage_cloak", LUA_MODIFIER_MOTION_NONE )

function modifier_visage_cloak:OnCreated()
	local caster = self:GetCaster()
	local parent = self:GetParent()

	self.instances = self:GetTalentSpecialValueFor("max_layers")
	self.block = self:GetTalentSpecialValueFor("reduction")
	if IsServer() then		
		self.nfx =  ParticleManager:CreateParticle("particles/units/heroes/hero_visage/visage_cloak_ambient.vpcf", PATTACH_ABSORIGIN, caster)
					ParticleManager:SetParticleAlwaysSimulate(self.nfx)
					ParticleManager:SetParticleControlEnt(self.nfx, 0, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(self.nfx, 1, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControl(self.nfx, 2, Vector(1,1,0))
					ParticleManager:SetParticleControl(self.nfx, 3, Vector(0,0,0))
					ParticleManager:SetParticleControl(self.nfx, 4, Vector(0,0,0))
					ParticleManager:SetParticleControl(self.nfx, 5, Vector(0,0,0))

		self:AddEffect(self.nfx)
	end
end

function modifier_visage_cloak:OnRefresh()
	local caster = self:GetCaster()
	local parent = self:GetParent()

	self.block = self:GetTalentSpecialValueFor("reduction")
	self.instances = self:GetTalentSpecialValueFor("max_layers")
	if IsServer() then
		self:SetStackCount(self.instances)
		if self:GetStackCount() > 0 then
			ParticleManager:SetParticleControl(self.nfx, 3, Vector(1,0,0))

			if self:GetStackCount() > 1 then
				ParticleManager:SetParticleControl(self.nfx, 4, Vector(1,0,0))

				if self:GetStackCount() > 2 then
					ParticleManager:SetParticleControl(self.nfx, 5, Vector(1,0,0))

				end
			end
		end
	end
end

function modifier_visage_cloak:OnStackCountChanged(iStackCount)
	local caster = self:GetCaster()
	local parent = self:GetParent()
		
	if self:GetStackCount() < iStackCount then
		if self:GetStackCount() < 4 then
			if self.nfx then
				ParticleManager:SetParticleControl(self.nfx, 5, Vector(0,0,0))
			end

			if self:GetStackCount() < 3 then
				if self.nfx then
					ParticleManager:SetParticleControl(self.nfx, 4, Vector(0,0,0))
				end

				if self:GetStackCount() < 2 then
					if self.nfx then
						ParticleManager:SetParticleControl(self.nfx, 3, Vector(0,0,0))
					end
				end
			end
		end
	end
end

function modifier_visage_cloak:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
			MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_visage_cloak:OnTakeDamage(params)
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local unit = params.unit
		
		if unit == parent then
			if self:GetStackCount() > 0 then
				if parent == caster then
					parent:FindModifierByName("modifier_visage_cloak_handle"):PrepareNewLayer(self:GetName())
				end
				self:DecrementStackCount()
			end
			if parent ~= caster and self:GetStackCount() == 0 then
				self:Destroy()
			end
		end
	end
end

function modifier_visage_cloak:GetModifierIncomingDamage_Percentage(params)
	return self.block * self:GetStackCount()
end

function modifier_visage_cloak:IsPurgable()
	return false
end

function modifier_visage_cloak:RemoveOnDeath()
	return false
end

function modifier_visage_cloak:DestroyOnExpire()
	return false
end

modifier_visage_cloak_talent = class({})
LinkLuaModifier( "modifier_visage_cloak_talent", "heroes/hero_visage/visage_cloak", LUA_MODIFIER_MOTION_NONE )

function modifier_visage_cloak_talent:OnCreated()
	self:OnRefresh()
end

function modifier_visage_cloak_talent:OnRefresh()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local talentOwner = parent.visage or parent
	self.instances = self:GetTalentSpecialValueFor("max_layers")
	self.spellAmp = talentOwner:FindTalentValue("special_bonus_unique_visage_cloak_1")
	self.grace_period = talentOwner:FindTalentValue("special_bonus_unique_visage_cloak_1", "grace_period")
	if IsServer() then
		self.lastAttackPeriod = GameRules:GetGameTime()
		self:SetStackCount(self.instances)
	end
end

function modifier_visage_cloak_talent:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE,
			MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end

function modifier_visage_cloak_talent:GetModifierSpellAmplify_Percentage()
	return self.spellAmp * self:GetStackCount()
end

function modifier_visage_cloak_talent:OnTakeDamage(params)
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local unit = params.attacker
		
		if unit == parent and params.inflictor and GameRules:GetGameTime() - self.lastAttackPeriod < self.grace_period then
			if self:GetStackCount() > 0 then
				if parent == caster then
					parent:FindModifierByName("modifier_visage_cloak_handle"):PrepareNewLayer(self:GetName())
				end
				self.lastAttackPeriod = GameRules:GetGameTime()
				self:DecrementStackCount()
			end
			if parent ~= caster and self:GetStackCount() == 0 then
				self:Destroy()
			end
		end
	end
end

function modifier_visage_cloak_talent:IsPurgable()
	return false
end

function modifier_visage_cloak_talent:RemoveOnDeath()
	return false
end

function modifier_visage_cloak_talent:DestroyOnExpire()
	return false
end