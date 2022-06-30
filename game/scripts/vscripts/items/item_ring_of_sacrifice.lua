item_ring_of_sacrifice = class({})

function item_ring_of_sacrifice:GetIntrinsicModifierName()
	return "modifier_item_ring_of_sacrifice_passive"
end

function item_ring_of_sacrifice:GetAbilityTextureName()
	if self.toggleModifier and not self.toggleModifier:IsNull() then
		return "soul_ring/ring_of_sacrifice_off"
	else
		return "soul_ring/ring_of_sacrifice_"..self:GetLevel()
	end
end

function item_ring_of_sacrifice:OnToggle()
	if self.toggleModifier and not self.toggleModifier:IsNull() then self.toggleModifier:Destroy() end
	if self:GetToggleState() then
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_ring_of_sacrifice_mana", {})
		if (self.lastToggle or 0) + 2 < GameRules:GetGameTime() then
			EmitSoundOn("DOTA_Item.SoulRing.Activate", self:GetCaster() )
			self.lastToggle = GameRules:GetGameTime()
		end
	end
end

item_ring_of_sacrifice_2 = class(item_ring_of_sacrifice)
item_ring_of_sacrifice_3 = class(item_ring_of_sacrifice)
item_ring_of_sacrifice_4 = class(item_ring_of_sacrifice)
item_ring_of_sacrifice_5 = class(item_ring_of_sacrifice)
item_ring_of_sacrifice_6 = class(item_ring_of_sacrifice)
item_ring_of_sacrifice_7 = class(item_ring_of_sacrifice)
item_ring_of_sacrifice_8 = class(item_ring_of_sacrifice)
item_ring_of_sacrifice_9 = class(item_ring_of_sacrifice)

modifier_item_ring_of_sacrifice_passive = class(itemBasicBaseClass)
LinkLuaModifier( "modifier_item_ring_of_sacrifice_passive", "items/item_ring_of_sacrifice.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_ring_of_sacrifice_passive:OnCreatedSpecific()
	if IsServer() then
		self:GetAbility():OnToggle()
	end
end

function modifier_item_ring_of_sacrifice_passive:OnRefreshSpecific()
	if IsServer() then
		self:GetAbility():OnToggle()
	end
end

function modifier_item_ring_of_sacrifice_passive:OnDestroySpecific()
	local ability = self:GetAbility()
	if IsServer() then
		if ability.toggleModifier and not ability.toggleModifier:IsNull() then ability.toggleModifier:Destroy() end
	end
end

modifier_item_ring_of_sacrifice_mana = class({})
LinkLuaModifier( "modifier_item_ring_of_sacrifice_mana", "items/item_ring_of_sacrifice.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_ring_of_sacrifice_mana:OnCreated()
	self:OnRefresh()
end

function modifier_item_ring_of_sacrifice_mana:OnRefresh()
	self.hp = self:GetSpecialValueFor("health_loss")
	self.manaGain = self:GetSpecialValueFor("mana_gain")
	
	local ability = self:GetAbility()
	if IsServer() then
		if ability.toggleModifier and not ability.toggleModifier:IsNull() then ability.toggleModifier:Destroy() end
		self:StartIntervalThink( 1 )
	end
	ability.toggleModifier = self
end

function modifier_item_ring_of_sacrifice_mana:OnIntervalThink()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	
	ParticleManager:FireParticle("particles/items2_fx/soul_ring.vpcf", PATTACH_POINT_FOLLOW, caster)
	
	if not ability or ability:IsNull() then 
		self:Destroy()
		return
	end
	
	ability:DealDamage( caster, caster, self.hp, {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS + DOTA_DAMAGE_FLAG_HPLOSS } )
	caster:RestoreMana( self.manaGain )
end
