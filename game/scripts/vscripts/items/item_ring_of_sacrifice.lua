item_ring_of_sacrifice = class({})

function item_ring_of_sacrifice:OnSpellStart()
	local caster = self:GetCaster()

	EmitSoundOn("DOTA_Item.SoulRing.Activate", caster)

	ParticleManager:FireParticle("particles/items2_fx/soul_ring.vpcf", PATTACH_POINT_FOLLOW, caster)
	
	self:DealDamage( caster, caster, self:GetSpecialValueFor("health_loss"), {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NON_LETHAL } )
	local mana = self:GetSpecialValueFor("mana_gain")
	local manaDiff = math.max( mana - ( caster:GetMaxMana() - caster:GetMana() ), 0 )
	caster:AddNewModifier( caster, self, "modifier_item_ring_of_sacrifice_mana", {duration = self:GetSpecialValueFor("duration"), mana = manaDiff})
	caster:RestoreMana( mana )
end

function item_ring_of_sacrifice:GetIntrinsicModifierName()
	return "modifier_item_ring_of_sacrifice_passive"
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


modifier_item_ring_of_sacrifice_mana = class({})
LinkLuaModifier( "modifier_item_ring_of_sacrifice_mana", "items/item_ring_of_sacrifice.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_ring_of_sacrifice_mana:OnCreated(kv)
	self.mana = kv.mana
	self.manaGain = self:GetSpecialValueFor("mana_gain")
	if IsServer() then
		self:SetHasCustomTransmitterData( true )
	end
end

function modifier_item_ring_of_sacrifice_mana:OnRefresh(kv)
	if IsServer() then
		self:SetHasCustomTransmitterData( true )
	end
end

function modifier_item_ring_of_sacrifice_mana:OnRemoved(kv)
	if IsServer() and self.manaGain > 0 then
		self:GetParent():ReduceMana( self.manaGain )
	end
end

function modifier_item_ring_of_sacrifice_mana:DeclareFunctions()
	return {MODIFIER_PROPERTY_EXTRA_MANA_BONUS, MODIFIER_EVENT_ON_SPENT_MANA}
end

function modifier_item_ring_of_sacrifice_mana:OnSpentMana(params)
	if params.unit == self:GetParent() and self.manaGain > 0 and not self:GetParent().ringOfSacrificeHasBeenProcessed then
		self:GetParent().ringOfSacrificeHasBeenProcessed = true
		self.manaGain = self.manaGain - params.cost
		if self.mana > 0 then
			self.mana = math.max( self.mana - params.cost, 0 )
			self:ForceRefresh()
		end
		if self.manaGain < 0 then
			self:Destroy()
		end
		local parent = self:GetParent()
		Timers:CreateTimer( 
			function() parent.ringOfSacrificeHasBeenProcessed = false end 
		)
	end
end

function modifier_item_ring_of_sacrifice_mana:GetModifierExtraManaBonus()
	return self.mana
end

function itemBasicBaseClass:AddCustomTransmitterData( )
	return
	{
		mana = self.mana
	}
end

--------------------------------------------------------------------------------

function itemBasicBaseClass:HandleCustomTransmitterData( data )
	self.mana = data.mana
end

function modifier_item_ring_of_sacrifice_mana:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end