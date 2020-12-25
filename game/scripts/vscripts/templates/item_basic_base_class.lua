itemBasicBaseClass = class(persistentModifier)

function itemBasicBaseClass:SetupRuneSystem(slotModifier)
	-- find old modifier, -1 (slot unassigned) and not current item
	local parent = self:GetParent()
	-- local modifiersToLookUp = {}
	-- modifiersToLookUp[self:GetName()] = true
	-- local associatedModifierName
	-- if  self:GetAbility().GetAssociatedUpgradeModifier and self:GetAbility():GetAssociatedUpgradeModifier() then
		-- associatedModifierNames = self:GetAbility():GetAssociatedUpgradeModifier()
		-- if type(associatedModifierNames) == 'table' then
			-- for _,modifier in ipairs( associatedModifierNames ) do
				-- modifiersToLookUp[modifier] = true
			-- end
		-- else
			-- modifiersToLookUp[associatedModifierNames] = true
		-- end
	-- end
	local hasBeenCopied = false
	for _,modifier in ipairs( parent:FindAllModifiers( ) ) do
		local ability = modifier:GetAbility()
		if ability and ability:IsItem() and ability:GetItemSlot() == -1 and ability ~= self:GetAbility() then
			if not hasBeenCopied then
				self:GetAbility().itemData = table.copy( ability.itemData )
				modifier:Destroy()
				hasBeenCopied = true
			elseif ability:GetRuneSlots() > 0 then
				for i = 1, ability:GetRuneSlots() do
					local rune = ability.itemData[i] or {}
					if rune.rune_type then
						local item = FindItemInInventory( rune.rune_type )
						if item then
							item:SetCurrentCharges( item:GetCurrentCharges() + rune.rune_level )
						else
							item = parent:AddItemByName( rune.rune_type )
							if item then
								item:SetCurrentCharges( rune.rune_level )
							end
						end
					end
				end
			end
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
		self[func] = function() return result * (slotModifier or 100)/100 end
	end
end

function itemBasicBaseClass:StoreRunesIntoModifier(data)
	if self:GetAbility() then
		self:GetAbility().itemData = data or self:GetAbility().itemData or self.itemData or {}
		self.itemData = table.copy( self:GetAbility().itemData )
	end
end

function itemBasicBaseClass:OnCreatedSpecific()
end

function itemBasicBaseClass:OnCreated()
	self:OnCreatedSpecific()
	self:SetHasCustomTransmitterData( true )
	if IsServer() then
		self:GetCaster():HookInModifier( "GetModifierBaseCriticalChanceBonus", self )
		self:GetCaster():HookInModifier( "GetModifierBaseCriticalDamageBonus", self )
		self:SetupRuneSystem( self.stone_share )
		self:SendBuffRefreshToClients()
		self:StoreRunesIntoModifier()
	end
end

function itemBasicBaseClass:OnRefreshSpecific()
end

function itemBasicBaseClass:OnRefresh()
	self:OnRefreshSpecific()
	if IsServer() then
		self:GetCaster():HookInModifier( "GetModifierBaseCriticalChanceBonus", self )
		self:GetCaster():HookInModifier( "GetModifierBaseCriticalDamageBonus", self )
		self:SetHasCustomTransmitterData( true )
		self:SendBuffRefreshToClients()
		self:StoreRunesIntoModifier()
	end
end

function itemBasicBaseClass:OnDestroySpecific()
end

function itemBasicBaseClass:OnDestroy()
	self:OnDestroySpecific()
	if IsServer() then
		self:GetCaster():HookOutModifier( "GetModifierBaseCriticalChanceBonus", self )
		self:GetCaster():HookOutModifier( "GetModifierBaseCriticalDamageBonus", self )
		self:StoreRunesIntoModifier()
	end
end

function itemBasicBaseClass:DeclareFunctions()
	local funcs = self:GetDefaultFunctions()
	return funcs
end

function itemBasicBaseClass:GetDefaultFunctions()
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
				MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING,
				MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
				MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT 
			}
end 

function itemBasicBaseClass:AddCustomTransmitterData( )
	local clientData = MergeTables( { itemData = self:GetAbility().itemData }, {} )
	return clientData
end

--------------------------------------------------------------------------------

function itemBasicBaseClass:HandleCustomTransmitterData( data )
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
	if data.itemData == nil then return end
	PrintAll(data.itemData )
	-- reset functions
	-- print('------------------ RESET -------------')
	
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
				return output 
			end
		else
			self[func] = function() return result end
		end
		
	end
	self:StoreRunesIntoModifier(data.itemData)
end

function itemBasicBaseClass:IsHidden()
	return true
end

function itemBasicBaseClass:IsPurgable()
	return false
end

function itemBasicBaseClass:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_MULTIPLE
end