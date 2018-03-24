item_warm_fire = class({})

function item_warm_fire:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_item_warm_fire") then
		return "custom/warm_fire"
	else
		return "custom/warm_fire_off"
	end
end

function item_warm_fire:OnToggle()
	if self:GetToggleState() then
		self:GetCaster():RemoveModifierByName("modifier_item_warm_fire")
	else
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_warm_fire", {})
	end
end

function item_warm_fire:GetIntrinsicModifierName()
	return "modifier_item_warm_fire"
end

LinkLuaModifier( "modifier_item_warm_fire", "items/item_warm_fire.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_item_warm_fire = class({})
function modifier_item_warm_fire:OnCreated()
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_item_warm_fire:OnDestroy()
	if IsServer() then
		for _, ally in ipairs( self:GetParent():FindEnemyUnitsInRadius( self:GetParent():GetAbsOrigin(), -1 ) ) do
			ally:RemoveModifierByName("modifier_warm_fire_debuff")
		end
	end
end

function modifier_item_warm_fire:IsAura()
	return true
end

function modifier_item_warm_fire:GetModifierAura()
	return "modifier_warm_fire_debuff"
end

function modifier_item_warm_fire:GetAuraRadius()
	return self.radius
end

function modifier_item_warm_fire:GetAuraDuration()
	return 0.5
end

function modifier_item_warm_fire:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_item_warm_fire:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_item_warm_fire:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

LinkLuaModifier( "modifier_warm_fire_debuff", "items/item_warm_fire.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_warm_fire_debuff = class({})

function modifier_warm_fire_debuff:OnCreated()
	if IsServer() then
		self.damage = self:GetAbility():GetSpecialValueFor("damage")
		self:StartIntervalThink(1)
	end
end

function modifier_warm_fire_debuff:OnRefresh()
	if IsServer() then
		self.damage = self:GetAbility():GetSpecialValueFor("damage")
	end
end

function modifier_warm_fire_debuff:OnIntervalThink()
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.damage, {damage_type = DAMAGE_TYPE_MAGICAL})
end

function modifier_warm_fire_debuff:GetEffectName()
	return "particles/units/heroes/hero_invoker/invoker_chaos_meteor_burn_debuff.vpcf"
end