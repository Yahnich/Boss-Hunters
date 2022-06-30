itemBasicBaseClass = class(persistentModifier)

function itemBasicBaseClass:SetupRuneSystem(slotModifier)
	-- find old modifier, -1 (slot unassigned) and not current item
	if self.GetRuneModifier and self:GetRuneModifier() and self:GetRuneModifier() == 0 then return end
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
	local itemSource = self:GetAbility()
	local hasBeenCopied = false
	
	for _,modifier in ipairs( parent:FindAllModifiers( ) ) do
		local ability = modifier:GetAbility()
		if ability and ability:IsItem() and ability:GetItemSlot() == -1 and ability ~= itemSource then
			if not hasBeenCopied then
				itemSource.itemData = table.copy( ability.itemData )
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
	if not hasBeenCopied and parent.runeSlotSnapShot then
		print( "check snapShot to be sure" )
		for id, data in pairs( parent.runeSlotSnapShot ) do
			local itemInSameSlot = parent:GetItemInSlot( tonumber(id) )
			print( id, itemInSameSlot )
			if not itemInSameSlot or itemInSameSlot:entindex() ~= data.entindex then -- item was updated, make sure updated item's runes correspond to these
				itemSource.itemData = table.copy( data.runes )
			end
		end
	end
	-- clear snapshot
	parent.runeSlotSnapShot = nil
	
	itemSource.itemData = itemSource.itemData or self.itemData or {}
	if itemSource:GetRuneSlots() > 0 then
		for i = 1, itemSource:GetRuneSlots() do
			itemSource.itemData[i] = itemSource.itemData[i] or {}
		end
	end
	local modFuncs = {}
	for slot, rune in pairs( itemSource.itemData ) do
		if  rune.baseFuncs then
			rune.funcs = rune.funcs or {}
			for func, result in pairs( rune.baseFuncs ) do
				rune.funcs[func] = result * (self.stone_share or 100)/100
				modFuncs[func] = ( modFuncs[func] or 0 ) + rune.funcs[func]
			end
		end
	end
	for func, result in pairs( modFuncs ) do
		local endValue = result
		if self.GetRuneModifier and self:GetRuneModifier() then
			local multiplier = self:GetRuneModifier()/100
			if multiplier > 0 then
				endValue = math.floor(result * multiplier + 0.5)
			else
				endValue = math.floor(result * (1+multiplier) + 0.5)
			end
		end
		print( endValue, func )
		self[func] = function() return endValue end
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
	self.stone_share = self:GetSpecialValueFor("rune_scaling")
	if IsServer() then
		self:GetCaster():HookInModifier( "GetModifierBaseCriticalChanceBonus", self )
		self:GetCaster():HookInModifier( "GetModifierBaseCriticalDamageBonus", self )
		self:SetupRuneSystem( self.stone_share )
		self:SetHasCustomTransmitterData( true )
		self:SendBuffRefreshToClients()
		self:StoreRunesIntoModifier()
	end
end

function itemBasicBaseClass:OnRefreshSpecific()
end

function itemBasicBaseClass:OnRefresh()
	self:OnRefreshSpecific()
	self.stone_share = self:GetSpecialValueFor("rune_scaling")
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
	-- PrintAll(data.itemData )
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
			print( func, result, "updated shit" )
			self[func] = function() return result end
			print( self[func]() )
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