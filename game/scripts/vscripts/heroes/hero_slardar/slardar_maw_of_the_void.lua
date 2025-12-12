slardar_maw_of_the_void = class({})

function slardar_maw_of_the_void:GetIntrinsicModifierName()
	return "modifier_slardar_maw_of_the_void_handler"
end

modifier_slardar_maw_of_the_void_handler = class({})
LinkLuaModifier( "modifier_slardar_maw_of_the_void_handler", "heroes/hero_slardar/slardar_maw_of_the_void", LUA_MODIFIER_MOTION_NONE )

function modifier_slardar_maw_of_the_void_handler:OnCreated()
	self.modifierList = {}
	self.armor_steal = self:GetSpecialValueFor("armor_steal") / 100
	self.minion_steal = self:GetSpecialValueFor("minion_steal") / 100
end

function modifier_slardar_maw_of_the_void_handler:OnRefresh()
	self.armor_steal = self:GetSpecialValueFor("armor_steal") / 100
	self.minion_steal = self:GetSpecialValueFor("minion_steal") / 100
end

function modifier_slardar_maw_of_the_void_handler:OnIntervalThink()
	local caster = self:GetCaster()
	local stacks = 0
	for enemy, active in pairs( self.modifierList ) do
		if not enemy:IsNull() then
			for _, modifier in ipairs( enemy:FindAllModifiers() ) do
				if modifier:GetCaster() and modifier:GetCaster() == caster then
					if modifier.GetModifierPhysicalArmorBonus then
						local armor = modifier:GetModifierPhysicalArmorBonus()
						if armor and armor < 0 then
							stacks = stacks + math.abs( armor ) * self.armor_steal
						end
					end
				end
			end
		else
			self.modifierList[enemy] = nil
		end
	end
	self:SetStackCount( math.floor(stacks * 10) )
end

function modifier_slardar_maw_of_the_void_handler:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_slardar_maw_of_the_void_handler:GetModifierPhysicalArmorBonus()
	return self:GetStackCount() / 10
end

function modifier_slardar_maw_of_the_void_handler:OnUnitModifierAdded(params)
	if params.caster == self:GetCaster() and not params.unit:IsSameTeam( params.caster ) then
		self.modifierList[params.unit] = true
		self:StartIntervalThink( 0.25 )
	end
end

function modifier_slardar_maw_of_the_void_handler:IsHidden()
	return true
end