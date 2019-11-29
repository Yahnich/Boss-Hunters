boss_durva_soul_barrier = class({})

function boss_durva_soul_barrier:GetIntrinsicModifierName()
	return "modifier_boss_durva_soul_barrier"
end

modifier_boss_durva_soul_barrier = class({})
LinkLuaModifier( "modifier_boss_durva_soul_barrier", "bosses/boss_durva/boss_durva_soul_barrier", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_durva_soul_barrier:OnCreated()
	self.reduction = self:GetSpecialValueFor("dmg_reduction")
	self.min = self:GetSpecialValueFor("min_reduction")
	self.max = self:GetSpecialValueFor("max_reduction")
	self:SetStackCount( self.reduction * 10 )
	if IsServer() then
		self:StartIntervalThink( 0.25 )
	end
end

function modifier_boss_durva_soul_barrier:OnRefresh()
	self:OnCreated()
end

function modifier_boss_durva_soul_barrier:OnIntervalThink()
	local maxHP = 0
	local currHP = 0
	for _, hero in ipairs( HeroList:GetActiveHeroes() ) do
		maxHP = maxHP + hero:GetMaxHealth()
		currHP = currHP + hero:GetHealth()
	end
	local hpPCT = ( currHP / maxHP ) * 100
	local stacks = math.floor( self.reduction * math.max(0, 1 - (100 - hpPCT) / (100 - self.min) ) * 10 ) / 10
	stacks = math.min( stacks, self.reduction ) * 10
	if self:GetStackCount() ~= stacks then self:SetStackCount( stacks ) end
end

function modifier_boss_durva_soul_barrier:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_boss_durva_soul_barrier:GetModifierIncomingDamage_Percentage()
	return -( self:GetStackCount() / 10 )
end

function modifier_boss_durva_soul_barrier:GetModifierStatusResistance()
	return -( self:GetStackCount() / 10 )
end

function modifier_boss_durva_soul_barrier:IsHidden()
	return true
end