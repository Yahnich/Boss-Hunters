jakiro_elemental_convergence = class({})

function jakiro_elemental_convergence:GetIntrinsicModifierName()
	return "modifier_jakiro_elemental_convergence"
end

function jakiro_elemental_convergence:AddIceAttunement()
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_jakiro_elemental_convergence_convergence") then
		caster:RemoveModifierByName( "modifier_jakiro_elemental_convergence_convergence" )
		return
	end
	local ice = caster:AddNewModifier( caster, self, "modifier_jakiro_elemental_convergence_ice", {} )
	local fire = caster:FindModifierByName("modifier_jakiro_elemental_convergence_fire")
	local fireStacks = 0
	if fire then
		fireStacks = fire:GetStackCount()
	end
	local maxStacks = self:GetTalentSpecialValueFor("max_stacks")
	ice:IncrementStackCount()
	local iceStacks = ice:GetStackCount()
	if iceStacks >= maxStacks then -- check whether to trigger convergence
		if fireStacks == maxStacks and not self.preventConvergence then
			caster:RemoveModifierByName( "modifier_jakiro_elemental_convergence_fire" )
			caster:RemoveModifierByName( "modifier_jakiro_elemental_convergence_ice" )
			caster:AddNewModifier( caster, self, "modifier_jakiro_elemental_convergence_convergence", {} )
		else
			ice:SetStackCount(maxStacks)
		end
	end
end

function jakiro_elemental_convergence:AddFireAttunement()
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_jakiro_elemental_convergence_convergence") then
		caster:RemoveModifierByName( "modifier_jakiro_elemental_convergence_convergence" )
		return
	end
	local fire = caster:AddNewModifier( caster, self, "modifier_jakiro_elemental_convergence_fire", {} )
	local ice = caster:FindModifierByName("modifier_jakiro_elemental_convergence_ice")
	local iceStacks = 0
	if ice then
		iceStacks = ice:GetStackCount()
	end
	local maxStacks = self:GetTalentSpecialValueFor("max_stacks")
	fire:IncrementStackCount()
	local fireStacks = fire:GetStackCount()
	if fireStacks >= maxStacks then -- check whether to trigger convergence
		if iceStacks == maxStacks and not self.preventConvergence then
			caster:RemoveModifierByName( "modifier_jakiro_elemental_convergence_fire" )
			caster:RemoveModifierByName( "modifier_jakiro_elemental_convergence_ice" )
			caster:AddNewModifier( caster, self, "modifier_jakiro_elemental_convergence_convergence", {} )
		else
			fire:SetStackCount(maxStacks)
		end
	end
end

modifier_jakiro_elemental_convergence = class({})
LinkLuaModifier("modifier_jakiro_elemental_convergence", "heroes/hero_jakiro/jakiro_elemental_convergence", LUA_MODIFIER_MOTION_NONE)
function modifier_jakiro_elemental_convergence:OnCreated(table)
	self.max_stacks = self:GetTalentSpecialValueFor("max_stacks")
	self.damage_increase = self:GetTalentSpecialValueFor("damage_increase") / 100
	self.duration_increase = self:GetTalentSpecialValueFor("duration_increase") / 100
end

function modifier_jakiro_elemental_convergence:DeclareFunctions()
	return { MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL, 
			 MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE}
end

function modifier_jakiro_elemental_convergence:IsHidden()
	return true
end

modifier_jakiro_elemental_convergence_ice = class({})
LinkLuaModifier("modifier_jakiro_elemental_convergence_ice", "heroes/hero_jakiro/jakiro_elemental_convergence", LUA_MODIFIER_MOTION_NONE)

function modifier_jakiro_elemental_convergence_ice:GetTexture()
	return "custom/jakiro_elemental_convergence_ice"
end

modifier_jakiro_elemental_convergence_fire = class({})
LinkLuaModifier("modifier_jakiro_elemental_convergence_fire", "heroes/hero_jakiro/jakiro_elemental_convergence", LUA_MODIFIER_MOTION_NONE)

function modifier_jakiro_elemental_convergence_fire:GetTexture()
	return "custom/jakiro_elemental_convergence_fire"
end

modifier_jakiro_elemental_convergence_convergence = class({})
LinkLuaModifier("modifier_jakiro_elemental_convergence_convergence", "heroes/hero_jakiro/jakiro_elemental_convergence", LUA_MODIFIER_MOTION_NONE)

function modifier_jakiro_elemental_convergence_convergence:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		if caster:HasTalent("special_bonus_unique_jakiro_elemental_convergence_1") then
			local restore = caster:FindTalentValue("special_bonus_unique_jakiro_elemental_convergence_1", "value2")
			caster:HealEvent( restore, ability, caster )
			caster:RestoreMana( restore )
			for i = 0, caster:GetAbilityCount() - 1 do
				local abilityCd = caster:GetAbilityByIndex( i )
				if abilityCd and not abilityCd:IsCooldownReady() then
					abilityCd:ModifyCooldown( caster:FindTalentValue("special_bonus_unique_jakiro_elemental_convergence_1") )
				end
			end
		end
	end
end