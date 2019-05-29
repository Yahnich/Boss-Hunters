item_incandescance = class({})

function item_incandescance:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_item_incandescance") then
		return "item_radiance"
	else
		return "item_radiance_inactive"
	end
end

function item_incandescance:OnToggle()
	if not self:GetToggleState() then
		self:GetCaster():RemoveModifierByName("modifier_item_incandescance")
	else
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_incandescance", {})
	end
end

function item_incandescance:GetIntrinsicModifierName()
	return "modifier_item_incandescance"
end

LinkLuaModifier( "modifier_item_incandescance", "items/item_incandescance.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_item_incandescance = class(toggleModifierBaseClass)

function modifier_item_incandescance:OnCreated()
	self.radius = self:GetSpecialValueFor("radius")
	self.maxRadius = self:GetSpecialValueFor("radius")
	self.minRadius = self:GetSpecialValueFor("min_radius")
	self.radiusDelta = self:GetSpecialValueFor("radius_change")
	if IsServer() then
		self.cumulativeDist = {}
		self.lastPos = self:GetCaster():GetAbsOrigin()
		self:StartIntervalThink(0.1)
		self.pFX = ParticleManager:CreateParticle("particles/items/item_warm_fire_radius.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControl( self.pFX, 1, Vector(self.radius,0,0) )
		self:AddEffect( self.pFX )
	end
end

function modifier_item_incandescance:OnIntervalThink()
	table.insert(self.cumulativeDist, CalculateDistance( self.lastPos, self:GetCaster():GetAbsOrigin() ) )
	self.lastPos = self:GetCaster():GetAbsOrigin()
	if #self.cumulativeDist > 9 then
		table.remove(self.cumulativeDist, 1)
	end
	local distance = 0
	for id, amount in ipairs(self.cumulativeDist) do
		distance = distance + amount
	end
	if distance > 150 and self.minRadius < self.radius then
		self.radius = math.max( self.radius - self.radiusDelta * 0.1, self.minRadius )
		ParticleManager:SetParticleControl( self.pFX, 1, Vector(self.radius,0,0) )
	elseif distance < 150 and self.maxRadius > self.radius then
		self.radius = math.min( self.radius + self.radiusDelta * 0.1, self.maxRadius )
		ParticleManager:SetParticleControl( self.pFX, 1, Vector(self.radius,0,0) )
	end
end

function modifier_item_incandescance:OnDestroy()
	if IsServer() and self:GetAbility() then
		for _, ally in ipairs( self:GetParent():FindEnemyUnitsInRadius( self:GetParent():GetAbsOrigin(), -1 ) ) do
			ally:RemoveModifierByName("modifier_incandescance_debuff")
		end
		if self:GetAbility():GetToggleState() then
			self:GetAbility():OnToggle()
		end
	end
end

function modifier_item_incandescance:IsAura()
	return true
end

function modifier_item_incandescance:GetModifierAura()
	return "modifier_incandescance_debuff"
end

function modifier_item_incandescance:GetAuraRadius()
	return self.radius
end

function modifier_item_incandescance:GetAuraDuration()
	return 0.5
end

function modifier_item_incandescance:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_item_incandescance:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_item_incandescance:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_item_incandescance:IsHidden()    
	return true
end

LinkLuaModifier( "modifier_incandescance_debuff", "items/item_incandescance.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_incandescance_debuff = class({})

function modifier_incandescance_debuff:OnCreated()
	self.blind = self:GetAbility():GetSpecialValueFor("blind")
	if IsServer() then
		self.damage = self:GetAbility():GetSpecialValueFor("damage")
		self:StartIntervalThink(1)
	end
end

function modifier_incandescance_debuff:OnRefresh()
	self.blind = self:GetAbility():GetSpecialValueFor("blind")
	if IsServer() then
		self.damage = self:GetAbility():GetSpecialValueFor("damage")
	end
end

function modifier_incandescance_debuff:OnIntervalThink()
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.damage, {damage_type = DAMAGE_TYPE_MAGICAL})
end

function modifier_incandescance_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MISS_PERCENTAGE}
end

function modifier_incandescance_debuff:GetModifierMiss_Percentage()
	return self.blind
end

function modifier_incandescance_debuff:GetEffectName()
	return "particles/units/heroes/hero_invoker/invoker_chaos_meteor_burn_debuff.vpcf"
end