alchemist_chymistry = class({})

function alchemist_chymistry:GetIntrinsicModifierName()
	return "modifier_alchemist_chymistry_passive"
end

modifier_alchemist_chymistry_passive = class({})
LinkLuaModifier( "modifier_alchemist_chymistry_passive", "heroes/hero_alchemist/alchemist_chymistry", LUA_MODIFIER_MOTION_NONE )

function modifier_alchemist_chymistry_passive:OnCreated()
	self:OnRefresh()
	if IsServer() then
		self.funcID = EventManager:SubscribeListener("boss_hunters_event_finished", function(args) self:OnEventFinished(args) end)
	end
	self:GetCaster().GetPrimaMateria = function() return self:GetStackCount() end
end

function modifier_alchemist_chymistry_passive:OnRefresh()
	self.minion_materia = self:GetSpecialValueFor("minion_materia")
	self.monster_materia = self:GetSpecialValueFor("monster_materia")
	self.boss_materia = self:GetSpecialValueFor("boss_materia")
	self.max_materia = self:GetSpecialValueFor("max_materia")
	self.round_end_conversion = self:GetSpecialValueFor("round_end_conversion") / 100
	self.materia_death_loss = self:GetSpecialValueFor("materia_death_loss") / 100
	self.materia_to_gold = self:GetSpecialValueFor("materia_to_gold")
	
	self.materia_status_amp = self:GetSpecialValueFor("materia_status_amp")
end

function modifier_alchemist_chymistry_passive:OnDestroy()
	if IsServer() then
		EventManager:UnsubscribeListener("boss_hunters_event_finished", self.funcID)
	end
	self:GetCaster().GetPrimaMateria = function() return 0 end
end

function modifier_alchemist_chymistry_passive:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH,
			MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE_STACKING }
end

function modifier_alchemist_chymistry_passive:OnDeath( params )
	local stacks = self:GetStackCount()
	local caster = self:GetCaster()
	if params.unit == caster then
		self:SetStackCount( math.floor( self:GetStackCount() * self.materia_death_loss ) )
		return 
	end
	if stacks == self.max_materia then return end
	if params.unit:FindAllModifiersByCaster( caster ) == 0 then return end
	local isConsideredMinion = params.unit:IsMinion() or ( params.unit:IsSameTeam( caster ) and (not params.unit:IsConsideredHero() or (params.unit:IsIllusion() and not params.unit:IsStrongIllusion())) )
	local isConsideredBoss = params.unit:IsBoss() or ( params.unit:IsSameTeam( caster ) and params.unit:IsRealHero() )
	local stackCount = TernaryOperator( self.minion_materia, isConsideredMinion, TernaryOperator( self.boss_materia, isConsideredBoss, self.monster_materia ) )
	self:SetStackCount( math.min( self.max_materia, stacks + stackCount ) )
end

function modifier_alchemist_chymistry_passive:OnEventFinished(args)
	local stacks = self:GetStackCount()
	local stacksConverted = math.floor( self:GetStackCount() * self.round_end_conversion )
	self:SetStackCount( stacks - stacksConverted )
	self:GetCaster():AddGold( stacksConverted * self.materia_to_gold )
end

function modifier_alchemist_chymistry_passive:GetModifierStatusAmplify_Percentage()
	return self.materia_status_amp * self:GetStackCount()
end

function modifier_alchemist_chymistry_passive:OnModifierApplied( params )
	-- if self.panacea_heal <= 0 then return end
	-- if self.panacea_damage <= 0 then return end
	-- local stacks = self:GetStackCount()
	-- if stacks == 0 then return end
	-- local caster = self:GetCaster()
	-- if caster ~= params.caster then return end
	-- if not ( params.ability and caster:HasAbility( params.ability:GetAbilityName() ) ) then return end
	-- if #params.target:FindAllModifiersByCaster( caster ) <= 1 then return end -- we just applied a modifier check if buffs are good
	-- local ability = self:GetAbility()
	-- if params.target:IsSameTeam( caster ) then
		-- local heal = (self.panacea_heal + (params.ability:GetCaster():GetLevel() - 1) * self.panacea_heal_level) * stacks
		-- params.target:HealEvent( heal, ability, caster )
	-- else
		-- local damage = (self.panacea_damage + (params.ability:GetCaster():GetLevel() - 1) * self.panacea_damage_level) * stacks
		-- ability:DealDamage( caster, params.target, damage, {damage_type = DAMAGE_TYPE_PURE} )
	-- end
end

function modifier_alchemist_chymistry_passive:GetModifierOverrideAbilitySpecial( params )
	-- if self._inquiringLevelSpecialValue then return end
	-- if params.ability_special_value == "panacea_heal" then
		-- return 1
	-- end
	-- if params.ability_special_value == "panacea_damage" then
		-- return 1
	-- end
	-- if self:GetStackCount() == 0 then return end
	-- if not self.alkahest_potency then return end
	-- if self.alkahest_potency <= 0 then return end
	-- if params.ability:GetAbilityName() == "alchemist_acid_bomb" 
	-- or params.ability:GetAbilityName() == "alchemist_volatile_brew" 
	-- or params.ability:GetAbilityName() == "alchemist_rage_injector" then
		-- local caster = params.ability:GetCaster()
		-- local specialValue = params.ability_special_value
		-- if not (string.match(specialValue, "duration") or string.match(specialValue, "brew") 
		-- or specialValue == "tick_rate" or specialValue == "freezes_cooldowns"
		-- or specialValue == "AbilityCastRange" or specialValue == "AbilityCastPoint" or specialValue == "AbilityManaCost") then -- amp anything except durations and flags
			-- return 1
		-- end
	-- end
end

function modifier_alchemist_chymistry_passive:GetModifierOverrideAbilitySpecialValue( params )
	-- if self._inquiringLevelSpecialValue then return end
	-- local specialValue = params.ability_special_value
	-- if params.ability_special_value == "panacea_heal" and self.panacea_heal_level then
		-- self._inquiringLevelSpecialValue = true
		-- local flBaseValue = params.ability:GetLevelSpecialValueFor( specialValue, params.ability_special_level )
		-- self._inquiringLevelSpecialValue = false
		-- if flBaseValue > 0 then
			-- return flBaseValue + (params.ability:GetCaster():GetLevel() - 1) * self.panacea_heal_level
		-- end
	-- end
	-- if params.ability_special_value == "panacea_damage" and self.panacea_damage_level then
		-- self._inquiringLevelSpecialValue = true
		-- local flBaseValue = params.ability:GetLevelSpecialValueFor( specialValue, params.ability_special_level )
		-- self._inquiringLevelSpecialValue = false
		-- if flBaseValue > 0 then
			-- return flBaseValue + (params.ability:GetCaster():GetLevel() - 1) * self.panacea_damage_level
		-- ends
	-- end
	-- if self:GetStackCount() == 0 then return end
	-- if not self.alkahest_potency then return end
	-- if self.alkahest_potency <= 0 then return end
	-- if params.ability:GetAbilityName() == "alchemist_acid_bomb" 
	-- or params.ability:GetAbilityName() == "alchemist_volatile_brew" 
	-- or params.ability:GetAbilityName() == "alchemist_rage_injector" then
		-- if not (string.match(specialValue, "duration") or string.match(specialValue, "brew") 
		-- or specialValue == "tick_rate" or specialValue == "freezes_cooldowns") then
			-- self._inquiringLevelSpecialValue = true
			-- local flBaseValue = params.ability:GetLevelSpecialValueFor( specialValue, params.ability_special_level )
			-- self._inquiringLevelSpecialValue = false
			-- if specialValue == "AbilityCooldown" then
				-- return flBaseValue / ( 1 + ( self.alkahest_potency * self:GetStackCount() ) )
			-- else
				-- return flBaseValue * ( 1 + ( self.alkahest_potency * self:GetStackCount() ) )
			-- end
		-- end
	-- end
end

function modifier_alchemist_chymistry_passive:IsHidden()
	return self:GetStackCount() == 0
end

function modifier_alchemist_chymistry_passive:IsPermanent()
	return true
end

function modifier_alchemist_chymistry_passive:IsPurgable()
	return false
end