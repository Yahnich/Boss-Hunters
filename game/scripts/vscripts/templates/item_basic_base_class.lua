itemBasicBaseClass = class(persistentModifier)

function itemBasicBaseClass:SetupRuneSystem(modifier)
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

function itemBasicBaseClass:StoreRunesIntoModifier(data)
	self:GetAbility().itemData = data or self:GetAbility().itemData or self.itemData or {}
	self.itemData = table.copy( self:GetAbility().itemData )
end

function itemBasicBaseClass:OnCreatedSpecific()
end

function itemBasicBaseClass:OnCreated()
	self:OnCreatedSpecific()
	if IsServer() then
		self:GetCaster():HookInModifier( "GetModifierBaseCriticalChanceBonus", self )
		self:GetCaster():HookInModifier( "GetModifierBaseCriticalDamageBonus", self )
		self:GetCaster():HookInModifier( "GetModifierAttackSpeedBonus", self )
		self:SetupRuneSystem(self.stone_share)
		self:SetHasCustomTransmitterData( true )
		
	end
end

function itemBasicBaseClass:OnRefreshSpecific()
end

function itemBasicBaseClass:OnRefresh()
	self:OnRefreshSpecific()
	if IsServer() then
		self:GetCaster():HookInModifier( "GetModifierBaseCriticalChanceBonus", self )
		self:GetCaster():HookInModifier( "GetModifierBaseCriticalDamageBonus", self )
		self:GetCaster():HookInModifier( "GetModifierAttackSpeedBonus", self )
		self:SetHasCustomTransmitterData( true )
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
		self:GetCaster():HookOutModifier( "GetModifierAttackSpeedBonus", self )
		self:SetHasCustomTransmitterData( true )
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
				MODIFIER_PROPERTY_CAST_RANGE_BONUS,
				MODIFIER_PROPERTY_ATTACK_RANGE_BONUS 
			}
end 

function itemBasicBaseClass:AddCustomTransmitterData( )
	return
	{
		itemData = self:GetAbility().itemData
	}
end

--------------------------------------------------------------------------------

function itemBasicBaseClass:HandleCustomTransmitterData( data )
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