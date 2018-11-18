visage_cloak = class({})
LinkLuaModifier( "modifier_visage_cloak_handle", "heroes/hero_visage/visage_cloak", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_visage_cloak", "heroes/hero_visage/visage_cloak", LUA_MODIFIER_MOTION_NONE )

function visage_cloak:IsStealable()
    return false
end

function visage_cloak:IsHiddenWhenStolen()
    return false
end

function visage_cloak:CastFilterResultTarget(hTarget)
    if hTarget == self:GetCaster() then
    	return UF_FAIL_CUSTOM
    end
end

function visage_cloak:GetCustomCastErrorTarget(hTarget)
    if hTarget == self:GetCaster() then
    	return "Cannot target self."
    end
end

function visage_cloak:GetBehavior()
    local caster = self:GetCaster()
    if caster:HasTalent("special_bonus_unique_visage_cloak_2") then
    	return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
    end
    return DOTA_ABILITY_BEHAVIOR_PASSIVE
end

function visage_cloak:GetAbilityTargetTeam()
    local caster = self:GetCaster()
    if caster:HasTalent("special_bonus_unique_visage_cloak_2") then
    	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
    end
end

function visage_cloak:GetAbilityTargetType()
    local caster = self:GetCaster()
    if caster:HasTalent("special_bonus_unique_visage_cloak_2") then
    	return DOTA_UNIT_TARGET_ALL
    end
end

function visage_cloak:GetAbilityTargetFlags()
    local caster = self:GetCaster()
    if caster:HasTalent("special_bonus_unique_visage_cloak_2") then
    	return DOTA_UNIT_TARGET_FLAG_NONE
    end
end

function visage_cloak:GetCastRange(vLocation, hTarget)
    local caster = self:GetCaster()
    if caster:HasTalent("special_bonus_unique_visage_cloak_2") then
    	return 900
    end
end

function visage_cloak:GetCastAnimation()
    local caster = self:GetCaster()
    if caster:HasTalent("special_bonus_unique_visage_cloak_2") then
    	return ACT_DOTA_CAST_ABILITY_4
    end
end

function visage_cloak:GetCastPoint()
    local caster = self:GetCaster()
    if caster:HasTalent("special_bonus_unique_visage_cloak_2") then
    	return 0.2
    end
end

function visage_cloak:GetCooldown(iLevel)
    local caster = self:GetCaster()
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


    for i=1,4 do
		target:AddNewModifier(caster, self, "modifier_visage_cloak", {}):IncrementStackCount()
	end
end

modifier_visage_cloak_handle = class({})

function modifier_visage_cloak_handle:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()

		for i=1,4 do
			caster:AddNewModifier(caster, self:GetAbility(), "modifier_visage_cloak", {}):IncrementStackCount()
		end
		
		self:StartIntervalThink(self:GetTalentSpecialValueFor("recovery_time"))
	end
end

function modifier_visage_cloak_handle:OnIntervalThink()
	local caster = self:GetCaster()

	if caster:IsAlive() then
		if caster:HasModifier("modifier_visage_cloak") then
			if caster:FindModifierByName("modifier_visage_cloak"):GetStackCount() < self:GetTalentSpecialValueFor("max_layers") then
				caster:AddNewModifier(caster, self:GetAbility(), "modifier_visage_cloak", {}):IncrementStackCount()
			end
		else
			caster:AddNewModifier(caster, self:GetAbility(), "modifier_visage_cloak", {}):IncrementStackCount()
		end
	end
	self:StartIntervalThink(self:GetTalentSpecialValueFor("recovery_time"))
end

function modifier_visage_cloak_handle:IsHidden()
	return true
end

modifier_visage_cloak = class({})

function modifier_visage_cloak:OnCreated()
	local caster = self:GetCaster()
	local parent = self:GetParent()

	self.instances = self:GetTalentSpecialValueFor("max_layers")
	self.block = self:GetTalentSpecialValueFor("reduction") * self:GetStackCount()
	if caster:HasTalent("special_bonus_unique_visage_cloak_1") then
		self.spellAmp = caster:FindTalentValue("special_bonus_unique_visage_cloak_1") * self:GetStackCount()
	end

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

	self.block = self:GetTalentSpecialValueFor("reduction") * self:GetStackCount()
	if caster:HasTalent("special_bonus_unique_visage_cloak_1") then
		self.spellAmp = caster:FindTalentValue("special_bonus_unique_visage_cloak_1") * self:GetStackCount()
	end

	if IsServer() then
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

	if caster:HasTalent("special_bonus_unique_visage_cloak_1") then
		self.spellAmp = caster:FindTalentValue("special_bonus_unique_visage_cloak_1") * self:GetStackCount()
	end
		
	if self:GetStackCount() < iStackCount then
		if self:GetStackCount() < 4 then
			if self.nfx then
				--[[ParticleManager:DestroyParticle(self.nfx, true)
				self.nfx =  ParticleManager:CreateParticle("particles/units/heroes/hero_visage/visage_cloak_ambient.vpcf", PATTACH_ABSORIGIN, caster)
							ParticleManager:SetParticleAlwaysSimulate(self.nfx)
							ParticleManager:SetParticleControlEnt(self.nfx, 0, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
							ParticleManager:SetParticleControlEnt(self.nfx, 1, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
							ParticleManager:SetParticleControl(self.nfx, 2, Vector(1,1,0))
							ParticleManager:SetParticleControl(self.nfx, 3, Vector(1,0,0))
							ParticleManager:SetParticleControl(self.nfx, 4, Vector(1,0,0))
							ParticleManager:SetParticleControl(self.nfx, 5, Vector(0,0,0))
				self:AddEffect(self.nfx)]]
				ParticleManager:SetParticleControl(self.nfx, 5, Vector(0,0,0))
			end

			if self:GetStackCount() < 3 then
				if self.nfx then
					--[[ParticleManager:DestroyParticle(self.nfx, true)
					self.nfx =  ParticleManager:CreateParticle("particles/units/heroes/hero_visage/visage_cloak_ambient.vpcf", PATTACH_ABSORIGIN, caster)
								ParticleManager:SetParticleAlwaysSimulate(self.nfx)
								ParticleManager:SetParticleControlEnt(self.nfx, 0, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
								ParticleManager:SetParticleControlEnt(self.nfx, 1, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
								ParticleManager:SetParticleControl(self.nfx, 2, Vector(1,1,0))
								ParticleManager:SetParticleControl(self.nfx, 3, Vector(1,0,0))
								ParticleManager:SetParticleControl(self.nfx, 4, Vector(0,0,0))
								ParticleManager:SetParticleControl(self.nfx, 5, Vector(0,0,0))
					self:AddEffect(self.nfx)]]
					ParticleManager:SetParticleControl(self.nfx, 4, Vector(0,0,0))
				end

				if self:GetStackCount() < 2 then
					if self.nfx then
						--[[ParticleManager:DestroyParticle(self.nfx, true)
						self.nfx =  ParticleManager:CreateParticle("particles/units/heroes/hero_visage/visage_cloak_ambient.vpcf", PATTACH_ABSORIGIN, caster)
									ParticleManager:SetParticleAlwaysSimulate(self.nfx)
									ParticleManager:SetParticleControlEnt(self.nfx, 0, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
									ParticleManager:SetParticleControlEnt(self.nfx, 1, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
									ParticleManager:SetParticleControl(self.nfx, 2, Vector(1,1,0))
									ParticleManager:SetParticleControl(self.nfx, 3, Vector(0,0,0))
									ParticleManager:SetParticleControl(self.nfx, 4, Vector(0,0,0))
									ParticleManager:SetParticleControl(self.nfx, 5, Vector(0,0,0))
						self:AddEffect(self.nfx)]]
						ParticleManager:SetParticleControl(self.nfx, 3, Vector(0,0,0))
					end
				end
			end
		end
	end
end

function modifier_visage_cloak:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
			MODIFIER_EVENT_ON_TAKEDAMAGE,
			MODIFIER_EVENT_ON_ABILITY_EXECUTED,
			MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end

function modifier_visage_cloak:GetModifierSpellAmplify_Percentage()
	return self.spellAmp
end

function modifier_visage_cloak:OnAbilityExecuted(params)
	if IsServer() then
		local caster = self:GetCaster()
		local unit = params.unit

		if unit == caster and caster:HasTalent("special_bonus_unique_visage_cloak_1") then
			if self:GetStackCount() > 1 then
				self:DecrementStackCount()
			else
				self:Destroy()
			end
		end
	end
end

function modifier_visage_cloak:OnTakeDamage(params)
	if IsServer() then
		local caster = self:GetCaster()
		local unit = params.unit
		
		if unit:GetTeam() == caster:GetTeam() then
			if self:GetStackCount() > 1 then
				self:DecrementStackCount()
			else
				self:Destroy()
			end
		end
	end
end

function modifier_visage_cloak:GetModifierIncomingDamage_Percentage(params)
	return -self.block
end