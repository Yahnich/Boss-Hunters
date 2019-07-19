item_blade_of_dominion = class({})

function item_blade_of_dominion:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_item_blade_of_dominion") then
		return "custom/blade_of_dominion"
	else
		return "custom/blade_of_dominion_heal"
	end
end

function item_blade_of_dominion:OnToggle()
	if self:GetToggleState() then
		self:GetCaster():RemoveModifierByName("modifier_item_blade_of_dominion")
	else
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_blade_of_dominion", {})
	end
end

function item_blade_of_dominion:GetIntrinsicModifierName()
	return "modifier_item_blade_of_dominion_stats"
end


LinkLuaModifier( "modifier_item_blade_of_dominion_stats", "items/item_blade_of_dominion.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_item_blade_of_dominion_stats = class({})

function modifier_item_blade_of_dominion_stats:OnCreated()
	self.block = self:GetAbility():GetSpecialValueFor("damage_block")
	self.chance = self:GetAbility():GetSpecialValueFor("block_chance")
	self.hp_regen = self:GetAbility():GetSpecialValueFor("bonus_health_regen")
	self.spell_amp = self:GetAbility():GetSpecialValueFor("bonus_spell_amp")
	self.radius = self:GetSpecialValueFor("radius")
	self.maxRadius = self:GetSpecialValueFor("radius")
	self.minRadius = self:GetSpecialValueFor("min_radius")
	self.radiusDelta = self:GetSpecialValueFor("radius_change")
	if IsServer() then
		self:GetAbility():OnToggle()
		self.cumulativeDist = {}
		self.lastPos = self:GetCaster():GetAbsOrigin()
		self:StartIntervalThink(0.1)
		self.pFX = ParticleManager:CreateParticle("particles/items/item_blade_of_dominion_radius.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControl( self.pFX, 1, Vector(self.radius,0,0) )
		self:AddEffect( self.pFX )
	end
end

function modifier_item_blade_of_dominion_stats:OnIntervalThink()
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

function modifier_item_blade_of_dominion_stats:OnDestroy()
	if IsServer() then self:GetAbility():OnToggle() end
end

function modifier_item_blade_of_dominion_stats:DeclareFunctions()
	return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
			MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,}
end

function modifier_item_blade_of_dominion_stats:GetModifierConstantHealthRegen()
	return self.hp_regen
end

function modifier_item_blade_of_dominion_stats:GetModifierSpellAmplify_Percentage()
	return self.spell_amp
end

function modifier_item_blade_of_dominion_stats:GetModifierTotal_ConstantBlock(params)
	if RollPercentage(self.chance) and params.attacker ~= self:GetParent() then
		return self.block
	end
end

function modifier_item_blade_of_dominion_stats:IsHidden()
	return true
end

function modifier_item_blade_of_dominion_stats:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_blade_of_dominion_stats:IsAura()
	return true
end

function modifier_item_blade_of_dominion_stats:GetModifierAura()
	if self:GetCaster():HasModifier("modifier_item_blade_of_dominion") then
		return "modifier_blade_of_dominion_debuff"
	else
		return "modifier_blade_of_dominion_buff"
	end
end

function modifier_item_blade_of_dominion_stats:GetAuraRadius()
	return self.radius
end

function modifier_item_blade_of_dominion_stats:GetAuraDuration()
	return 0.5
end

function modifier_item_blade_of_dominion_stats:GetAuraSearchTeam()
	if self:GetCaster():HasModifier("modifier_item_blade_of_dominion") then
		return DOTA_UNIT_TARGET_TEAM_ENEMY
	else
		return DOTA_UNIT_TARGET_TEAM_FRIENDLY
	end
end

function modifier_item_blade_of_dominion_stats:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_item_blade_of_dominion_stats:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_item_blade_of_dominion_stats:IsHidden()    
	return true
end

LinkLuaModifier( "modifier_item_blade_of_dominion", "items/item_blade_of_dominion.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_item_blade_of_dominion = class(toggleModifierBaseClass)
function modifier_item_blade_of_dominion:OnCreated()
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_item_blade_of_dominion:OnDestroy()
	if IsServer() then
		for _, ally in ipairs( self:GetParent():FindEnemyUnitsInRadius( self:GetParent():GetAbsOrigin(), -1 ) ) do
			ally:RemoveModifierByName("modifier_blade_of_dominion_debuff")
		end
	end
end

function modifier_item_blade_of_dominion:IsHidden()    
	return true
end

LinkLuaModifier( "modifier_blade_of_dominion_debuff", "items/item_blade_of_dominion.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_blade_of_dominion_debuff = class({})

function modifier_blade_of_dominion_debuff:OnCreated()
	self.blind = self:GetAbility():GetSpecialValueFor("blind")
	if IsServer() then
		self.damage = self:GetAbility():GetSpecialValueFor("damage")
		self:StartIntervalThink(1)
	end
end

function modifier_blade_of_dominion_debuff:OnRefresh()
	self.blind = self:GetAbility():GetSpecialValueFor("blind")
	if IsServer() then
		self.damage = self:GetAbility():GetSpecialValueFor("damage")
	end
end

function modifier_blade_of_dominion_debuff:OnIntervalThink()
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.damage, {damage_type = DAMAGE_TYPE_MAGICAL})
end

function modifier_blade_of_dominion_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MISS_PERCENTAGE}
end

function modifier_blade_of_dominion_debuff:GetModifierMiss_Percentage()
	return self.blind
end

function modifier_blade_of_dominion_debuff:GetEffectName()
	return "particles/units/heroes/hero_invoker/invoker_chaos_meteor_burn_debuff.vpcf"
end


LinkLuaModifier( "modifier_blade_of_dominion_buff", "items/item_blade_of_dominion.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_blade_of_dominion_buff = class({})

function modifier_blade_of_dominion_buff:OnCreated()
	if IsServer() then
		self.heal = self:GetAbility():GetSpecialValueFor("heal_per_second")
		self.cost = self:GetAbility():GetSpecialValueFor("heal_mana_cost")
		self:StartIntervalThink(1)
	end
end

function modifier_blade_of_dominion_buff:OnRefresh()
	if IsServer() then
		self.heal = self:GetAbility():GetSpecialValueFor("heal_per_second")
		self.cost = self:GetAbility():GetSpecialValueFor("heal_mana_cost")
	end
end

function modifier_blade_of_dominion_buff:OnIntervalThink()
	local heal = self:GetParent():HealEvent( self.heal, self:GetAbility(), self:GetCaster() )
	if heal > 0 then self:GetCaster():SpendMana( self.cost, self:GetAbility()) end
end

function modifier_blade_of_dominion_buff:GetEffectName()
	return "particles/units/heroes/hero_invoker/invoker_chaos_meteor_burn_debuff.vpcf"
end