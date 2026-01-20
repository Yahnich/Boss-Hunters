BASE_BURN_DAMAGE = 50
BASE_POISON_DAMAGE = 50

modifier_keyword_debuff_burn = class({})
LinkLuaModifier( "modifier_keyword_debuff_burn", "libraries/keywords.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_keyword_debuff_burn:OnCreated( kv )
	if IsServer() then
		self._burnEntities = {}
		self._burnQueue = {}
		self:GetParent()._minimumBurn = self:GetParent()._minimumBurn or {}
		self:OnRefresh( kv )
		
		self:StartIntervalThink( 0.25 )
	end
	self:GetParent()._internalBurnModifier = self
end

function modifier_keyword_debuff_burn:OnRefresh( kv )
	if IsClient() then return end
	local stacks = tonumber( kv.stacks or 1 )
	if kv.unit then
		local burner = EntIndexToHScript( tonumber(kv.unit) )
		if burner then
			for i = 1, stacks do
				table.insert( self._burnQueue, tonumber(kv.unit) )
			end
			self._burnEntities[tonumber(kv.unit)] = (self._burnEntities[tonumber(kv.unit)] or 0) + stacks
		end
	end
	local minimumBurn = 0
	for modifier, active in pairs( self:GetParent()._minimumBurn or {} ) do
		if IsModifierSafe( modifier ) and modifier.GetModifierPropertyMinimumBurn then
			minimumBurn = minimumBurn + (modifier:GetModifierPropertyMinimumBurn() or 0)
		else
			self:GetParent()._minimumBurn[modifier] = nil
		end
	end
	self:SetStackCount( minimumBurn + #self._burnQueue )
end

function modifier_keyword_debuff_burn:OnIntervalThink()
	local parent = self:GetParent()
	local damageTable = {}
	for unitIndex, stacks in pairs( self._burnEntities ) do
		local unit = EntIndexToHScript( unitIndex )
		damageTable[unit] = stacks * BASE_BURN_DAMAGE
	end
	local minimumBurn = 0
	for modifier, active in pairs( self:GetParent()._minimumBurn or {} ) do
		if IsModifierSafe( modifier ) and modifier.GetModifierPropertyMinimumBurn then
			local modifierBurn = modifier:GetModifierPropertyMinimumBurn() or 0
			minimumBurn = minimumBurn + modifierBurn
			damageTable[modifier:GetCaster()] = modifierBurn * BASE_BURN_DAMAGE
		else
			self:GetParent()._minimumBurn[modifier] = nil
		end
	end
	for unit, damage in pairs( damageTable ) do
		unit._dummyBurnAbility = unit._dummyBurnAbility or unit:FindAbilityByName("ability_capture") or unit:AddAbility("ability_capture")
		unit._dummyBurnAbility._isBurnDamage = true
		unit._dummyBurnAbility:DealDamage( unit, parent, damage * unit:GetHeroPowerAmplification( ), {damage_type = DAMAGE_TYPE_MAGICAL}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE )
		unit._dummyBurnAbility._isBurnDamage = false
	end
	for i = 1, math.ceil(#self._burnQueue * 0.20) do
		self._burnEntities[self._burnQueue[1]] = self._burnEntities[self._burnQueue[1]] - 1
		table.remove( self._burnQueue, 1 )
	end
	
	self:SetStackCount( minimumBurn + #self._burnQueue )
	if self:GetStackCount() <= 0 then
		self:Destroy()
	end
end

function modifier_keyword_debuff_burn:OnDestroy()
	if IsServer() then
		local parent = self:GetParent()
		if parent._forceClearBurn then return end
		local burnTableCopy = table.copy( self._burnEntities )
		local burnQueCopy = table.copy( self._burnQueue )
		local currentBurn = self:GetStackCount()
		Timers:CreateTimer( function()
			local burn = parent:AddNewModifier( parent, nil, "modifier_keyword_debuff_burn", {} )
			-- assign copies to new burn modifier
			self._burnEntities = table.copy( burnTableCopy )
			self._burnQueue = table.copy( burnQueCopy )
			-- remove half
			parent:RemoveBurn( math.ceil( currentBurn * 0.5 ) )
		end)
	end
end

function modifier_keyword_debuff_burn:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOOLTIP }
end

function modifier_keyword_debuff_burn:OnTooltip()
	return self:GetStackCount() * BASE_BURN_DAMAGE
end

function modifier_keyword_debuff_burn:GetEffectName()
	return "particles/units/heroes/hero_huskar/huskar_burning_spear_debuff.vpcf"
end

function modifier_keyword_debuff_burn:GetTexture()
	return "monkey_king_strike_anniversary"
end

if IsClient() then
	function C_DOTA_BaseNPC:GetBurn( )
		if IsModifierSafe( self._internalBurnModifier ) then
			return self._internalBurnModifier:GetStackCount()
		else
			return 0
		end
	end
else
	function CDOTA_BaseNPC:AddBurn( caster, burn )
		if not self:IsAlive() then return end
		self:AddNewModifier( self, nil, "modifier_keyword_debuff_burn", {unit = caster:entindex(), stacks = burn} )
	end
	
	function CDOTA_BaseNPC:GetBurn( )
		if IsModifierSafe( self._internalBurnModifier ) then
			return self._internalBurnModifier:GetStackCount()
		else
			return 0
		end
	end
	
	function CDOTA_BaseNPC:GetBurnDamage( )
		if IsModifierSafe( self._internalBurnModifier ) then
			return self._internalBurnModifier:OnTooltip()
		else
			return 0
		end
	end
	
	function CDOTA_BaseNPC:GetBurnFromSource( source )
		if IsModifierSafe( self._internalBurnModifier ) then
			return self._internalBurnModifier._burnEntities[source:entindex()]
		else
			return 0
		end
	end
	
	function CDOTA_BaseNPC:RemoveBurn( burn )
		if IsModifierSafe( self._internalBurnModifier ) then
			if burn < self:GetBurn() then
				for i = 1, burn do
					self._internalBurnModifier._burnEntities[self._internalBurnModifier._burnQueue[1]] = self._internalBurnModifier._burnEntities[self._internalBurnModifier._burnQueue[1]] - 1
					table.remove( self._internalBurnModifier._burnQueue, 1 )
				end
			else
				self._forceClearBurn = true
				self._internalBurnModifier:Destroy()
				self._forceClearBurn = false
			end
		end
	end
end

modifier_keyword_debuff_poison = class({})
LinkLuaModifier( "modifier_keyword_debuff_poison", "libraries/keywords.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_keyword_debuff_poison:OnCreated( kv )
	if IsServer() then
		self._poisonEntities = {}
		self._poisonQueue = {}
		self._minimumPoison = {}
		self:OnRefresh( kv )
		
		self:StartIntervalThink( 3 )
	end
end

function modifier_keyword_debuff_poison:OnRefresh( kv )
	if IsClient() then return end
	local stacks = tonumber( kv.stacks or 1 )
	if kv.unit then
		local poisoner = EntIndexToHScript( tonumber(kv.unit) )
		if poisoner then
			for i = 1, stacks do
				table.insert( self._poisonQueue, tonumber(kv.unit) )
			end
			self._poisonEntities[tonumber(kv.unit)] = (self._poisonEntities[tonumber(kv.unit)] or 0) + stacks
		end
	end
	local minimumPoison = 0
	for entity, poison in ipairs( self._minimumPoison ) do
		minimumPoison = minimumPoison + poison
	end
	self:SetStackCount( minimumPoison + #self._poisonQueue )
end

function modifier_keyword_debuff_poison:OnIntervalThink()
	local parent = self:GetParent()
	for unitIndex, stacks in pairs( self._poisonEntities ) do
		local unit = EntIndexToHScript( unitIndex )
		local dummyAbility = unit:GetAbilityByIndex(0)
		dummyAbility._isPoisonDamage = true
		local damage = stacks * 50
		dummyAbility:DealDamage( unit, parent, damage * unit:GetHeroPowerAmplification( ), {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_HPLOSS}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE )
		dummyAbility._isPoisonDamage = false
	end
	
	local minimumPoison = 0
	for entity, poison in ipairs( self._minimumPoison ) do
		minimumPoison = minimumPoison + poison
	end
	
	self:SetStackCount( minimumPoison + #self._poisonQueue )
	if self:GetStackCount() <= 0 then
		self:Destroy()
	end
end

function modifier_keyword_debuff_poison:OnDestroy()
	if IsServer() then
		local parent = self:GetParent()
		if parent._forceClearPoison then return end
		local poisonTableCopy = table.copy( self._poisonEntities )
		local poisonQueCopy = table.copy( self._poisonQueue )
		local minimumPoisonTableCopy = table.copy( self._minimumPoison )
		local currentPoison = self:GetStackCount()
		Timers:CreateTimer( function()
			local poison = parent:AddNewModifier( parent, nil, "modifier_keyword_debuff_poison", {} )
			-- assign copies to new poison modifier
			self._poisonEntities = table.copy( poisonTableCopy )
			self._poisonQueue = table.copy( poisonQueCopy )
			self._minimumPoison = table.copy( minimumPoisonTableCopy )
			-- remove half
			parent:RemovePoison( math.ceil( currentPoison * 0.5 ) )
		end)
	end
end

function modifier_keyword_debuff_poison:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOOLTIP }
end

function modifier_keyword_debuff_poison:OnTooltip()
	return self:GetStackCount() * BASE_POISON_DAMAGE
end

function modifier_keyword_debuff_poison:GetEffectName()
	return "particles/units/heroes/hero_venomancer/venomancer_poison_debuff.vpcf"
end

if IsClient() then
else
	function CDOTA_BaseNPC:AddPoison( caster, poison )
		if not self:IsAlive() then return end
		self._internalPoisonModifier = self:AddNewModifier( self, nil, "modifier_keyword_debuff_poison", {unit = caster:entindex(), stacks = poison} )
	end
	
	function CDOTA_BaseNPC:GetPoison( )
		if IsModifierSafe( self._internalPoisonModifier ) then
			return self._internalPoisonModifier:GetStackCount()
		else
			return 0
		end
	end
	
	function CDOTA_BaseNPC:GetPoisonDamage( )
		if IsModifierSafe( self._internalPoisonModifier ) then
			return self._internalPoisonModifier:OnTooltip()
		else
			return 0
		end
	end
	
	function CDOTA_BaseNPC:GetPoisonFromSource( source )
		if IsModifierSafe( self._internalPoisonModifier ) then
			return self._internalPoisonModifier._burnEntities[source:entindex()]
		else
			return 0
		end
	end
	
	function CDOTA_BaseNPC:RemovePoison( poison )
		if IsModifierSafe( self._internalPoisonModifier ) then
			if poison < self:GetPoison() then
				for i = 1, poison do
					self._internalPoisonModifier._burnEntities[self._internalPoisonModifier._burnQueue[1]] = self._internalPoisonModifier._burnEntities[self._internalPoisonModifier._burnQueue[1]] - 1
					table.remove( self._internalPoisonModifier._burnQueue, 1 )
				end
			else
				self._forceClearPoison = true
				self._internalPoisonModifier:Destroy()
				self._forceClearPoison = false
			end
		end
	end
end