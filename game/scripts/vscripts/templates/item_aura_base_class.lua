itemAuraBaseClass = class(persistentModifier)

function itemAuraBaseClass:SetupRuneSystem(modifier)
	-- find old modifier, -1 (slot unassigned) and not current item
	for _,modifier in ipairs( self:GetParent():FindAllModifiersByName( self:GetName() ) ) do
		ability = modifier:GetAbility()
		if ability:GetItemSlot() == -1 and ability ~= self:GetAbility() then
			self:GetAbility().itemData = table.copy( ability.itemData )
			modifier:Destroy()
			break
		end
	end
	self:GetAbility().itemData = self:GetAbility().itemData or self.itemData or {}
	if self:GetAbility():GetRuneSlots() > 0 then
		for i = 1, self:GetAbility():GetRuneSlots() do
			self:GetAbility().itemData[i] = self:GetAbility().itemData[i] or {}
		end
	end
	local modFuncs = {}
	for slot, rune in pairs( self:GetAbility().itemData ) do
		if  rune.funcs then
			for func, result in pairs( rune.funcs ) do
				modFuncs[func] = ( modFuncs[func] or 0 ) + result
			end
		end
	end
	for func, result in pairs( modFuncs ) do
		-- print( func, result, "end result" )
		self[func] = function() return result * (modifier or 100)/100 end
	end
	self:StoreRunesIntoModifier()
end

function itemAuraBaseClass:StoreRunesIntoModifier(data)
	self:GetAbility().itemData = data or self:GetAbility().itemData or self.itemData or {}
	self.itemData = table.copy( self:GetAbility().itemData )
end

function itemAuraBaseClass:OnCreatedSpecific()
end

function itemAuraBaseClass:GetStoneShareability()
	return 100
end

function itemAuraBaseClass:OnCreated()
	self:OnCreatedSpecific()
	if IsServer() then
		self:GetParent():HookInModifier( "GetModifierBaseCriticalChanceBonus", self )
		self:GetParent():HookInModifier( "GetModifierBaseCriticalDamageBonus", self )
		self:SetupRuneSystem( self:GetStoneShareability() )
		self:SetHasCustomTransmitterData( true )
		
	end
end

function itemAuraBaseClass:OnRefreshSpecific()
end

function itemAuraBaseClass:OnRefresh()
	self:OnRefreshSpecific()
	if IsServer() then
		self:GetParent():HookInModifier( "GetModifierBaseCriticalChanceBonus", self )
		self:GetParent():HookInModifier( "GetModifierBaseCriticalDamageBonus", self )
		self:SetHasCustomTransmitterData( true )
	end
end

function itemAuraBaseClass:OnDestroySpecific()
end

function itemAuraBaseClass:OnDestroy()
	self:OnDestroySpecific()
	if IsServer() then
		self:GetParent():HookOutModifier( "GetModifierBaseCriticalChanceBonus", self )
		self:GetParent():HookOutModifier( "GetModifierBaseCriticalDamageBonus", self )
		self:SetHasCustomTransmitterData( true )
	end
end

function itemAuraBaseClass:DeclareFunctions()
	local funcs = self:GetDefaultFunctions()
	return funcs
end

function itemAuraBaseClass:GetDefaultFunctions()
	return {
				MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS, 
				MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, 
				MODIFIER_PROPERTY_MANA_BONUS, 
				MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
				MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
				MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
				MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
				MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
				MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
				MODIFIER_PROPERTY_CAST_RANGE_BONUS,
				MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
				MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
				MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING 
			}
end 

function itemAuraBaseClass:AddCustomTransmitterData( )
	return
	{
		itemData = self:GetAbility().itemData
	}
end

--------------------------------------------------------------------------------

function itemAuraBaseClass:HandleCustomTransmitterData( data )
	if data.itemData == nil then return end
	-- reset functions
	-- print('------------------ RESET -------------')
	if self.itemData ~= nil then
		for slotIndex, info in pairs( self.itemData ) do
			-- print( slotIndex, info.rune_type )
			if info.funcs then
				for func, result in pairs( info.funcs ) do
					-- print( func, result )
					self[func] = function(self) return nil end
					-- print( 'result:', self[func]() )
				end
			end
		end
	end
	-- print('------------------ UPDATE -------------')
	-- update functions
	local funcs = {}
	for slot, rune in pairs( data.itemData ) do
		if  rune.funcs then
			for func, result in pairs( rune.funcs ) do
				funcs[func] = ( funcs[func] or 0 ) + result
			end
		end
	end
	for func, result in pairs( funcs ) do
		-- print( func, result, "end result" )
		if func == "GetModifierAttackRangeBonus" then
			self[func] = function() 
				output = result
				if not self:GetCaster():IsRangedAttacker() then
					output = output / 2
				end
				return output * (self:GetStoneShareability() / 100)
			end
		else
			self[func] = function() return result  * (self:GetStoneShareability() / 100) end
		end
		
	end
	self:StoreRunesIntoModifier(data.itemData)
end

function itemAuraBaseClass:IsHidden()
	return false
end

function itemAuraBaseClass:IsPurgable()
	return false
end

function itemAuraBaseClass:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_MULTIPLE
end