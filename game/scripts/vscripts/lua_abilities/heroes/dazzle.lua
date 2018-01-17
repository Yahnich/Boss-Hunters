dazzle_weave_ebf = class({})

function dazzle_weave_ebf:OnSpellStart()
	local caster = self:GetCaster()
	local targetPos = self:GetCursorPosition()
	
	local radius = self:GetTalentSpecialValueFor("radius")
	local duration = self:GetTalentSpecialValueFor("duration")
	
	EmitSoundOnLocationWithCaster(targetPos, "Hero_Dazzle.Weave", self:GetCaster())
	ParticleManager:FireParticle("particles/units/heroes/hero_dazzle/dazzle_weave.vpcf", PATTACH_WORLDORIGIN, caster, {[0] = targetPos, [1] = Vector(radius,0 ,0 )})
	
	for _, target in ipairs( caster:FindAllUnitsInRadius(targetPos, radius) ) do
		target:AddNewModifier(caster, self, "modifier_dazzle_weave_ebf", {duration = duration})
	end
end

modifier_dazzle_weave_ebf = class({})
LinkLuaModifier("modifier_dazzle_weave_ebf", "lua_abilities/heroes/dazzle", 0)

function modifier_dazzle_weave_ebf:OnCreated()
	self.armor_per_tick = self:GetTalentSpecialValueFor("armor_per_second")
	self.armor = 0
	self:StartIntervalThink(0.1)
end

function modifier_dazzle_weave_ebf:OnIntervalThink()
	self.armor = self.armor + self.armor_per_tick*0.1
end

function modifier_dazzle_weave_ebf:IsDebuff()
	return ( not self:GetParent():IsSameTeam( self:GetCaster() ) )
end

function modifier_dazzle_weave_ebf:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_dazzle_weave_ebf:GetModifierPhysicalArmorBonus()
	if self:GetParent():IsSameTeam( self:GetCaster() ) then
		return self.armor
	else
		return self.armor * -0.5
	end
end

function modifier_dazzle_weave_ebf:GetStatusEffectName()
	return "particles/status_fx/status_effect_armor_dazzle.vpcf"
end

function modifier_dazzle_weave_ebf:StatusEffectPriority()
	return 3
end

function modifier_dazzle_weave_ebf:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end