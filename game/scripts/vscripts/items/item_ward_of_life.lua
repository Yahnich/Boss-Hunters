item_ward_of_life = class({})

LinkLuaModifier( "modifier_item_ward_of_life", "items/item_ward_of_life.lua", LUA_MODIFIER_MOTION_NONE )
function item_ward_of_life:GetIntrinsicModifierName()
	return "modifier_item_ward_of_life"
end

function item_ward_of_life:OnSpellStart()
	local caster = self:GetCaster()
	local healPct = self:GetSpecialValueFor("heal") / 100
	local minRestore = self:GetSpecialValueFor("min_heal")
	for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( caster:GetAbsOrigin(), self:GetSpecialValueFor("radius") ) ) do
		ParticleManager:FireParticle("particles/items2_fx/mekanism_recipient.vpcf", PATTACH_POINT_FOLLOW, ally)
		EmitSoundOn("DOTA_Item.Mekansm.Target", ally)
		ally:HealEvent( math.max(minRestore, healPct * ally:GetMaxHealth()), self, caster)
	end
	ParticleManager:FireParticle("particles/items2_fx/mekanism.vpcf", PATTACH_POINT_FOLLOW, caster)
	EmitSoundOn("DOTA_Item.Mekansm.Activate", caster)
end

modifier_item_ward_of_life = class({})
function modifier_item_ward_of_life:OnCreated()
	self.block = self:GetAbility():GetSpecialValueFor("damage_block")
	self.chance = self:GetAbility():GetSpecialValueFor("block_chance")
	self.hp_regen = self:GetAbility():GetSpecialValueFor("bonus_health_regen")
	self.hp = self:GetAbility():GetSpecialValueFor("bonus_hp")
	self.str = self:GetAbility():GetSpecialValueFor("bonus_str")
	self.agi = self:GetAbility():GetSpecialValueFor("bonus_agi")
	self.int = self:GetAbility():GetSpecialValueFor("bonus_int")
	
	self.trigger = self:GetAbility():GetSpecialValueFor("max_hp_trigger")
	self.duration = self:GetAbility():GetSpecialValueFor("buff_duration")
	self.cd = self:GetAbility():GetSpecialValueFor("internal_cooldown")
end

function modifier_item_ward_of_life:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
			MODIFIER_PROPERTY_HEALTH_BONUS}
end


function modifier_item_ward_of_life:GetModifierBonusStats_Strength()
	return self.str
end

function modifier_item_ward_of_life:GetModifierBonusStats_Agility()
	return self.agi
end

function modifier_item_ward_of_life:GetModifierBonusStats_Intellect()
	return self.int
end

function modifier_item_ward_of_life:GetModifierHealthBonus()
	return self.hp
end

function modifier_item_ward_of_life:GetModifierConstantHealthRegen()
	return self.hp_regen
end

function modifier_item_ward_of_life:GetModifierTotal_ConstantBlock(params)
	local trigger = self:GetParent():GetMaxHealth() * self.trigger / 100
	if not self:GetParent():HasModifier("modifier_item_ward_of_life_cd") and self:GetParent():GetHealth() - params.damage <= trigger then
		self:GetParent():AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_item_ward_of_life_cd", {duration = self.cd * self:GetParent():GetCooldownReduction()} )
		self:GetParent():AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_item_ward_of_life_protection", {duration = self.duration } )
		local difference = trigger - ( self:GetParent():GetHealth() - params.damage )
		return difference
	end
	if self:GetParent():HasModifier("modifier_item_ward_of_life_protection") and self:GetParent():GetHealth() - params.damage <= trigger then
		local difference = trigger - ( self:GetParent():GetHealth() - params.damage )
		return difference
	end
	if RollPercentage(self.chance) and params.attacker ~= self:GetParent() then
		return self.block
	end
end

function modifier_item_ward_of_life:IsHidden()
	return true
end

function modifier_item_ward_of_life:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

modifier_item_ward_of_life_cd = class({})
LinkLuaModifier( "modifier_item_ward_of_life_cd", "items/item_ward_of_life.lua", LUA_MODIFIER_MOTION_NONE )

if IsServer() then
	function modifier_item_ward_of_life_cd:OnCreated()
		self:GetAbility():StartDelayedCooldown()
	end
	
	function modifier_item_ward_of_life_cd:OnDestroy()
		self:GetAbility():EndDelayedCooldown()
	end
end

function modifier_item_ward_of_life_cd:IsPurgable()
	return false
end

function modifier_item_ward_of_life_cd:IsPurgeException()
	return false
end

function modifier_item_ward_of_life_cd:RemoveOnDeath()
	return false
end

function modifier_item_ward_of_life_cd:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_item_ward_of_life_cd:IsDebuff()
	return true
end

modifier_item_ward_of_life_protection = class(modifier_item_ward_of_life_cd)
LinkLuaModifier( "modifier_item_ward_of_life_protection", "items/item_ward_of_life.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_item_ward_of_life_protection:IsDebuff()
	return false
end
