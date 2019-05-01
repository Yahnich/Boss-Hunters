item_frostfire_brand = class({})

function item_frostfire_brand:GetIntrinsicModifierName()
	return "modifier_item_frostfire_brand_stats"
end

function item_frostfire_brand:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_item_frostfire_brand") then
		return "custom/frostfire_brand"
	else
		return "custom/frostfire_brand_off"
	end
end

function item_frostfire_brand:OnToggle()
	if self:GetToggleState() then
		self:GetCaster():RemoveModifierByName("modifier_item_frostfire_brand")
	else
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_frostfire_brand", {})
	end
end

LinkLuaModifier( "modifier_item_frostfire_brand_stats", "items/item_frostfire_brand.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_item_frostfire_brand_stats = class(itemBaseClass)

function modifier_item_frostfire_brand_stats:OnCreated()
	self.damage = self:GetSpecialValueFor("bonus_damage")
	self.all = self:GetSpecialValueFor("bonus_all")
	if IsServer() then
		self:GetAbility():ToggleAbility()
	end
end

function modifier_item_frostfire_brand_stats:OnDestroy()
	if IsServer() and self:GetCaster():HasModifier("modifier_item_frostfire_brand") then
		self:GetAbility():ToggleAbility()
	end
end

function modifier_item_frostfire_brand_stats:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end

function modifier_item_frostfire_brand_stats:GetModifierPreAttack_BonusDamage()
	return self.damage
end

function modifier_item_frostfire_brand_stats:GetModifierBonusStats_Strength()
	return self.all
end

function modifier_item_frostfire_brand_stats:GetModifierBonusStats_Agility()
	return self.all
end

function modifier_item_frostfire_brand_stats:GetModifierBonusStats_Intellect()
	return self.all
end

function modifier_item_frostfire_brand_stats:IsHidden()
	return true
end


LinkLuaModifier( "modifier_item_frostfire_brand", "items/item_frostfire_brand.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_item_frostfire_brand = class(toggleModifierBaseClass)
function modifier_item_frostfire_brand:OnCreated()
	self.radius = self:GetSpecialValueFor("radius")
	self.maxRadius = self:GetSpecialValueFor("radius")
	self.minRadius = self:GetSpecialValueFor("min_radius")
	self.radiusDelta = self:GetSpecialValueFor("radius_change")
	if IsServer() then
		self.cumulativeDist = {}
		self.lastPos = self:GetCaster():GetAbsOrigin()
		self:StartIntervalThink(0.1)
		self.pFX = ParticleManager:CreateParticle("particles/items/item_frostfire_brand_radius.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControl( self.pFX, 1, Vector(self.radius,0,0) )
		self:AddEffect( self.pFX )
	end
end

function modifier_item_frostfire_brand:OnIntervalThink()
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

function modifier_item_frostfire_brand:OnDestroy()
	if IsServer() then
		for _, ally in ipairs( self:GetParent():FindEnemyUnitsInRadius( self:GetParent():GetAbsOrigin(), -1 ) ) do
			ally:RemoveModifierByName("modifier_frostfire_brand_debuff")
		end
	end
end

function modifier_item_frostfire_brand:IsAura()
	return true
end

function modifier_item_frostfire_brand:GetModifierAura()
	return "modifier_frostfire_brand_debuff"
end

function modifier_item_frostfire_brand:GetAuraRadius()
	return self.radius
end

function modifier_item_frostfire_brand:GetAuraDuration()
	return 0.5
end

function modifier_item_frostfire_brand:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_item_frostfire_brand:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_item_frostfire_brand:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_item_frostfire_brand:IsHidden()    
	return false
end

LinkLuaModifier( "modifier_frostfire_brand_debuff", "items/item_frostfire_brand.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_frostfire_brand_debuff = class({})

function modifier_frostfire_brand_debuff:OnCreated()
	self.slow = self:GetAbility():GetSpecialValueFor("slow")
	self.blind = self:GetAbility():GetSpecialValueFor("blind")
	if IsServer() then
		self:StartIntervalThink(1)
	end
end

function modifier_frostfire_brand_debuff:OnIntervalThink()
	local statOwner = self:GetCaster()
	if statOwner:IsIllusion() then
		statOwner = statOwner:GetOwnerEntity()
	end
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self:GetAbility():GetSpecialValueFor("base_damage") + statOwner:GetPrimaryStatValue() * self:GetAbility():GetSpecialValueFor("damage") / 100, {damage_type = DAMAGE_TYPE_MAGICAL})
end

function modifier_frostfire_brand_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			MODIFIER_PROPERTY_MISS_PERCENTAGE}
end

function modifier_frostfire_brand_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_frostfire_brand_debuff:GetModifierMiss_Percentage()
	return self.blind
end

function modifier_frostfire_brand_debuff:GetEffectName()
	return "particles/generic_gameplay/generic_slowed_cold.vpcf"
end