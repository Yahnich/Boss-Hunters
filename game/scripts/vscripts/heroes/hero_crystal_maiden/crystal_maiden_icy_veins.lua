crystal_maiden_icy_veins = class({})

function crystal_maiden_icy_veins:OnToggle()
	if self:GetToggleState() then
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_crystal_maiden_icy_veins", {} )
	else
		self:GetCaster():RemoveModifierByName( "modifier_crystal_maiden_icy_veins" )
	end
end

modifier_crystal_maiden_icy_veins = class({})
LinkLuaModifier("modifier_crystal_maiden_icy_veins", "heroes/hero_crystal_maiden/crystal_maiden_icy_veins", LUA_MODIFIER_MOTION_NONE)

function modifier_crystal_maiden_icy_veins:OnCreated()
	self.cdr = self:GetTalentSpecialValueFor("cdr") * 0.1
	self.cost = self:GetTalentSpecialValueFor("mana_cost") / 100
	if IsServer() then
		self:StartIntervalThink( 0.1 )
		local fx = ParticleManager:CreateParticle( "particles/alacrity_ice.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster() )
		ParticleManager:SetParticleControlEnt( fx, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true )
		self:AddEffect(fx)
	end
end

function modifier_crystal_maiden_icy_veins:OnIntervalThink()
	local caster = self:GetCaster()
	for i = 0, caster:GetAbilityCount() - 1 do
        local ability = caster:GetAbilityByIndex( i )
        if ability then
			ability:ModifyCooldown(-self.cdr)
        end
    end
	for i=0, 5, 1 do
		local current_item = caster:GetItemInSlot(i)
		if current_item ~= nil and current_item ~= item then
			current_item:ModifyCooldown(-self.cdr)
		end
	end
	caster:SpendMana( self.cost * caster:GetMaxMana(), self:GetAbility() )
end

function modifier_crystal_maiden_icy_veins:CheckState()
	return {[MODIFIER_STATE_STUNNED] = false,
			[MODIFIER_STATE_ROOTED] = false,
			[MODIFIER_STATE_UNSLOWABLE] = true,}
end

function modifier_crystal_maiden_icy_veins:GetEffectName()
	return "particles/units/heroes/hero_jakiro/jakiro_icepath_debuff.vpcf"
end