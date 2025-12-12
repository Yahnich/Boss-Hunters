faceless_erase_timeline = class({})
LinkLuaModifier( "modifier_faceless_erase_timeline_handle", "heroes/hero_faceless_void/faceless_erase_timeline.lua",LUA_MODIFIER_MOTION_NONE )

function faceless_erase_timeline:GetIntrinsicModifierName()
	return "modifier_faceless_erase_timeline_handle"
end

function faceless_erase_timeline:IsStealable()
	return false
end

modifier_faceless_erase_timeline_handle = class({}) 
function modifier_faceless_erase_timeline_handle:IsPurgable()  return false end
function modifier_faceless_erase_timeline_handle:IsDebuff()    return false end
function modifier_faceless_erase_timeline_handle:IsHidden()    return true end

function modifier_faceless_erase_timeline_handle:OnCreated()
   self:OnRefresh()
end

function modifier_faceless_erase_timeline_handle:OnRefresh()
    self.chance = self:GetSpecialValueFor("chance")
	print( self.chance )
end
function modifier_faceless_erase_timeline_handle:DeclareFunctions()
	return { MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK, MODIFIER_PROPERTY_ABSORB_SPELL }
end

function modifier_faceless_erase_timeline_handle:GetModifierTotal_ConstantBlock(params)
	local ability = self:GetAbility()
	local caster = self:GetCaster()
	if params.attacker == self:GetParent() then return end
	if self:GetParent():GetHealth() > 0 
	and self:GetParent():IsRealHero() then
		if self:RollPRNG( self.chance ) then
			ParticleManager:FireParticle("particles/units/heroes/hero_faceless_void/faceless_void_backtrack.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
			return params.damage
		end
	end
end

function modifier_faceless_erase_timeline_handle:GetAbsorbSpell(params)
	if params.ability:GetCaster():GetTeam() ~= self:GetParent():GetTeam() and self:RollPRNG( self.chance ) then
		ParticleManager:FireParticle("particles/units/heroes/hero_faceless_void/faceless_void_backtrack.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
		return 1
	end
end