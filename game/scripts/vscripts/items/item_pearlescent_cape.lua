item_pearlescent_cape = class({})

function item_pearlescent_cape:GetIntrinsicModifierName()
	return "modifier_item_pearlescent_cape_passive"
end

function item_pearlescent_cape:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	EmitSoundOn("Item.GlimmerCape.Activate", self:GetCursorTarget())

	ParticleManager:FireRopeParticle("particles/items3_fx/glimmer_cape_initial_flash.vpcf", PATTACH_POINT_FOLLOW, caster, target, {})
	target:HealEvent(self:GetSpecialValueFor("heal"), self, caster) 
	target:AddNewModifier(caster, self, "modifier_item_pearlescent_cape_active", {Duration = self:GetSpecialValueFor("invis_duration")})
	target:SetThreat(0)
end

item_pearlescent_cape_2 = class(item_pearlescent_cape)
item_pearlescent_cape_3 = class(item_pearlescent_cape)
item_pearlescent_cape_4 = class(item_pearlescent_cape)
item_pearlescent_cape_5 = class(item_pearlescent_cape)
item_pearlescent_cape_6 = class(item_pearlescent_cape)
item_pearlescent_cape_7 = class(item_pearlescent_cape)
item_pearlescent_cape_8 = class(item_pearlescent_cape)
item_pearlescent_cape_9 = class(item_pearlescent_cape)

modifier_item_pearlescent_cape_passive = class(itemBasicBaseClass)
LinkLuaModifier( "modifier_item_pearlescent_cape_passive", "items/item_pearlescent_cape.lua" ,LUA_MODIFIER_MOTION_NONE )
function modifier_item_pearlescent_cape_passive:OnCreatedSpecific()
	self.mr = self:GetSpecialValueFor("magic_resist")
end

function modifier_item_pearlescent_cape_passive:DeclareFunctions()
	local funcs = self:GetDefaultFunctions()
	table.insert( funcs, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS )
	return funcs
end

function modifier_item_pearlescent_cape_passive:GetModifierMagicalResistanceBonus(params)
	return self.mr
end

modifier_item_pearlescent_cape_active = class({})
LinkLuaModifier( "modifier_item_pearlescent_cape_active", "items/item_pearlescent_cape.lua" ,LUA_MODIFIER_MOTION_NONE )
function modifier_item_pearlescent_cape_active:OnCreated()
	self.fade_delay = self:GetSpecialValueFor("fade_delay")
	self.mr = self:GetSpecialValueFor("magic_resist_active")
end

function modifier_item_pearlescent_cape_active:OnRefresh()	
	self:OnCreated()
end

function modifier_item_pearlescent_cape_active:OnIntervalThink()
	self:DecrementStackCount()
	if self:GetStackCount() == 0 then
		self:StartIntervalThink( -1 )
	end
end

function modifier_item_pearlescent_cape_active:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
        MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_EVENT_ON_ABILITY_START,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
    }

    return funcs
end

function modifier_item_pearlescent_cape_active:CheckState()
	local state = { [MODIFIER_STATE_INVISIBLE] = self:GetStackCount() == 0,
					[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
	
	return state
end

function modifier_item_pearlescent_cape_active:OnAbilityStart(params)
	if IsServer() then
		if params.unit == self:GetParent() then
			self:SetStackCount(self.fade_delay * 10)
			self:StartIntervalThink( 0.1 )
		end
	end
end

function modifier_item_pearlescent_cape_active:OnAttack(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			self:SetStackCount(self.fade_delay * 10)
			self:StartIntervalThink( 0.1 )
		end
	end
end

function modifier_item_pearlescent_cape_active:GetModifierInvisibilityLevel()
	if self:GetStackCount() == 0 then
		return 1
	end
end

function modifier_item_pearlescent_cape_active:GetModifierMagicalResistanceBonus(params)
	return self.mr
end

function modifier_item_pearlescent_cape_active:GetEffectName()
	return "particles/items3_fx/glimmer_cape_initial_flash.vpcf"
end

function modifier_item_pearlescent_cape_active:IsDebuff()
	return false
end