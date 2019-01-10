juggernaut_momentum_strike = class({})

function juggernaut_momentum_strike:GetIntrinsicModifierName()
	return "modifier_juggernaut_momentum_strike_passive"
end

function juggernaut_momentum_strike:OnToggle()
end

modifier_juggernaut_momentum_strike_passive = class({})
LinkLuaModifier("modifier_juggernaut_momentum_strike_passive", "heroes/hero_juggernaut/juggernaut_momentum_strike", LUA_MODIFIER_MOTION_NONE)

function modifier_juggernaut_momentum_strike_passive:OnCreated()
	self.crit_damage = self:GetTalentSpecialValueFor("critical_bonus")
	self.crit_chance = self:GetTalentSpecialValueFor("critical_chance")
	self.momentumHits = 0
	self.momentum_chance = self:GetTalentSpecialValueFor("crit_chance_momentum")
	
	local caster = self:GetCaster()
	if not caster.GetMomentum then 
		caster.GetMomentum = function( caster ) 
			return caster:GetModifierStackCount("modifier_juggernaut_momentum_strike_momentum", caster ) 
		end 
	end
	if not caster.SetMomentum then 
		caster.SetMomentum = function(caster, amount) 
			caster:SetModifierStackCount("modifier_juggernaut_momentum_strike_momentum", caster, amount ) 
			if IsServer() and amount == 0 then
				caster:RemoveModifierByName("modifier_juggernaut_momentum_strike_momentum")
			end
		end 
	end
	if not caster.AddMomentum then 
		caster.AddMomentum = function(caster, amount)
			if IsServer() then
				for i = 1, amount do
					caster:AddNewModifier(caster, caster:FindAbilityByName("juggernaut_momentum_strike"), "modifier_juggernaut_momentum_strike_momentum", {})
				end
			end
		end 
	end
	if not caster.AttemptDecrementMomentum then 
		caster.AttemptDecrementMomentum = function(caster, amount)
			local momentum = caster:GetMomentum()
			if momentum > amount then
				caster:SetModifierStackCount("modifier_juggernaut_momentum_strike_momentum", caster, momentum - amount )
				return true
			elseif momentum == amount then
				if IsServer() then
					caster:RemoveModifierByName("modifier_juggernaut_momentum_strike_momentum")
				end
				return true
			end
			return false
		end 
	end
end

function modifier_juggernaut_momentum_strike_passive:OnRefresh()
	self.crit_damage = self:GetTalentSpecialValueFor("critical_bonus")
	self.crit_chance = self:GetTalentSpecialValueFor("critical_chance")
	
	self.momentum_chance = self:GetTalentSpecialValueFor("crit_chance_momentum")
end

function modifier_juggernaut_momentum_strike_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE}
end

function modifier_juggernaut_momentum_strike_passive:GetModifierPreAttack_CriticalStrike(params)
	local caster = self:GetCaster()
	local roll = RollPercentage( self.crit_chance + caster:GetMomentum() * self.momentum_chance )
	if (caster:HasTalent("special_bonus_unique_juggernaut_momentum_strike_1") and self.momentumHits >= caster:FindTalentValue("special_bonus_unique_juggernaut_momentum_strike_1")) then
		self.momentumHits = 0
		if not caster:HasModifier("modifier_juggernaut_ronins_wind_movement") then caster:AddNewModifier(caster, self:GetAbility(), "modifier_juggernaut_momentum_strike_momentum", {}) end
	else
		self.momentumHits = self.momentumHits + 1
	end
	if roll then
		if not caster:HasModifier("modifier_juggernaut_ronins_wind_movement") then caster:AddNewModifier(caster, self:GetAbility(), "modifier_juggernaut_momentum_strike_momentum", {}) end
		if self:GetAbility():GetToggleState() and not caster:HasModifier("modifier_juggernaut_ronins_wind_movement") and not caster:HasModifier("modifier_juggernaut_dance_of_blades") then
			local target = params.target
			
			local direction = CalculateDirection(target, caster)
			local distance = CalculateDistance(target, caster)
			local newPosition = target:GetAbsOrigin() + direction * distance + RandomVector(50)
			local originalPosition = caster:GetAbsOrigin()
			if CalculateDistance(newPosition, target) ~= caster:GetAttackRange() then newPosition = target:GetAbsOrigin() + CalculateDirection(newPosition, target) * caster:GetAttackRange() end
			-- Set Juggernaut at random position
			caster:SetAbsOrigin(newPosition)
			FindClearSpaceForUnit(caster, newPosition, true)
			caster:SetForwardVector( CalculateDirection(target, caster) )
			-- Attack order
			order = 
			{
				UnitIndex = caster:entindex(),
				OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
				TargetIndex = target:entindex(),
				AbilityIndex = ability,
				Queue = true
			}
			ExecuteOrderFromTable(order)
			ParticleManager:FireParticle("particles/econ/items/juggernaut/bladekeeper_omnislash/dc_juggernaut_omni_slash_rope.vpcf", PATTACH_ABSORIGIN, caster, {[0] = originalPosition, [2] = originalPosition, [3] = newPosition})
			
		end
		EmitSoundOn("Hero_Juggernaut.BladeDance", caster)
		return self.crit_damage
	end
end

function modifier_juggernaut_momentum_strike_passive:IsHidden()
	return true
end

modifier_juggernaut_momentum_strike_momentum = class(toggleModifierBaseClass)
LinkLuaModifier("modifier_juggernaut_momentum_strike_momentum", "heroes/hero_juggernaut/juggernaut_momentum_strike", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_juggernaut_momentum_strike_momentum:OnCreated()
		self.max = self:GetTalentSpecialValueFor("max_momentum_stacks")
		if self:GetCaster():HasScepter() then self.max = self:GetTalentSpecialValueFor("scepter_max_momentum") end
		self:SetStackCount(1)
	end

	function modifier_juggernaut_momentum_strike_momentum:OnRefresh()
		self.max = self:GetTalentSpecialValueFor("max_momentum_stacks")
		if self:GetCaster():HasScepter() then self.max = self:GetTalentSpecialValueFor("scepter_max_momentum") end
		if self:GetStackCount() < self.max then self:IncrementStackCount() end
	end
end