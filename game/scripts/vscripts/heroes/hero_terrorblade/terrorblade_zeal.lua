terrorblade_zeal = class({})

function terrorblade_zeal:GetIntrinsicModifierName()
	return "modifier_terrorblade_zeal_passive"
end

LinkLuaModifier( "modifier_terrorblade_zeal_passive", "lua_abilities/heroes/terrorblade.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_terrorblade_zeal_passive = class({})

function modifier_terrorblade_zeal_passive:OnCreated()
	self.healthregen = self:GetAbility():GetTalentSpecialValueFor("health_regen")
	self.attackspeed = self:GetAbility():GetTalentSpecialValueFor("attackspeed_bonus")
end

function modifier_terrorblade_zeal_passive:OnRefresh()
	self.healthregen = self:GetAbility():GetTalentSpecialValueFor("health_regen")
	self.attackspeed = self:GetAbility():GetTalentSpecialValueFor("attackspeed_bonus")
end

function modifier_terrorblade_zeal_passive:DeclareFunctions()
	funcs = {
				MODIFIER_EVENT_ON_DEATH,
				MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
				MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			}
	return funcs
end

function modifier_terrorblade_zeal_passive:OnDeath(params)
	if IsServer() then
		if params.unit == self:GetParent() then
			local radius = self:GetAbility():GetTalentSpecialValueFor("illusion_explosion_radius")
			local damage = self:GetAbility():GetTalentSpecialValueFor("illusion_explosion_damage")
			local owner = self:GetParent()
			if owner:IsRealHero() then
				damage = self:GetAbility():GetTalentSpecialValueFor("self_explosion_damage")
			end
			EmitSoundOn("Hero_Terrorblade.Sunder.Cast", owner)
			ParticleManager:FireParticle( "particles/units/heroes/hero_terrorblade/terrorblade_death.vpcf", PATTACH_POINT_FOLLOW, owner, {[15] = Vector(100,100,255),
																																		[16] =  Vector(radius,radius,radius) } )
			ParticleManager:CreateParticle("particles/units/heroes/hero_dragon_knight/dragon_knight_transform_blue.vpcf", PATTACH_POINT_FOLLOW, owner )
			local units = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
			for _,unit in pairs(units) do
				ApplyDamage({victim = unit, attacker = self:GetParent(), damage = damage, damage_type = self:GetAbility():GetAbilityDamageType(), ability = self:GetAbility()})
			end
		end
	end
end

function modifier_terrorblade_zeal_passive:IsHidden()
	return true
end

function modifier_terrorblade_zeal_passive:GetModifierConstantHealthRegen()
	return self.healthregen
end

function modifier_terrorblade_zeal_passive:GetModifierAttackSpeedBonus_Constant()
	return self.attackspeed
end
