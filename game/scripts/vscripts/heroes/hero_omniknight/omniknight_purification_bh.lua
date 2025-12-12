omniknight_purification_bh = class({})

function omniknight_purification_bh:GetAOERadius()
	return self:GetSpecialValueFor("search_radius")
end

function omniknight_purification_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	local damage = self:GetSpecialValueFor("damage")
	local heal = self:GetSpecialValueFor("heal")
	local search = self:GetSpecialValueFor("search_radius")
	local radius = self:GetSpecialValueFor("area_of_effect")
	
	if caster:IsSameTeam( target ) then
		target:HealEvent( heal, self, caster )
		target:Dispel( caster, true )
		if caster:HasTalent("special_bonus_unique_omniknight_purification_1") then
			target:AddNewModifier( caster, self, "modifier_omniknight_purification_talent_buff", {duration = caster:FindTalentValue("special_bonus_unique_omniknight_purification_1", "duration")} )
		end
	elseif not target:TriggerSpellAbsorb(self) then
		self:DealDamage( caster, target, damage )
		target:Dispel( caster, true )
		if caster:HasTalent("special_bonus_unique_omniknight_purification_2") then
			target:AddNewModifier( caster, self, "modifier_omniknight_purification_talent_debuff", {duration = caster:FindTalentValue("special_bonus_unique_omniknight_purification_2", "duration")} )
		end
	end
	EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "Hero_Omniknight.Purification", caster)
	ParticleManager:FireRopeParticle("particles/units/heroes/hero_omniknight/omniknight_purification_hit.vpcf", PATTACH_POINT_FOLLOW, caster, target)
end

modifier_omniknight_purification_talent_buff = class({})
LinkLuaModifier( "modifier_omniknight_purification_talent_buff", "heroes/hero_omniknight/omniknight_purification_bh",LUA_MODIFIER_MOTION_NONE )

function modifier_omniknight_purification_talent_buff:OnCreated()
	self.damage_resist = self:GetCaster():FindTalentValue("special_bonus_unique_omniknight_purification_1")
end

function modifier_omniknight_purification_talent_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_omniknight_purification_talent_buff:GetModifierIncomingDamage_Percentage()
	return self.damage_resist * (-1)
end

function modifier_omniknight_purification_talent_buff:GetEffectName()
	return "particles/units/heroes/hero_omniknight/omniknight_purification_buff.vpcf"
end

modifier_omniknight_purification_talent_debuff = class({})
LinkLuaModifier( "modifier_omniknight_purification_talent_debuff", "heroes/hero_omniknight/omniknight_purification_bh",LUA_MODIFIER_MOTION_NONE )

function modifier_omniknight_purification_talent_debuff:OnCreated()
	self.damage_amp = self:GetCaster():FindTalentValue("special_bonus_unique_omniknight_purification_2")
end

function modifier_omniknight_purification_talent_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_omniknight_purification_talent_debuff:GetModifierIncomingDamage_Percentage()
	return self.damage_amp
end

function modifier_omniknight_purification_talent_debuff:GetEffectName()
	return "particles/units/heroes/hero_omniknight/omniknight_purification_debuff.vpcf"
end