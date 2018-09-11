terrorblade_zeal = class({})

function terrorblade_zeal:GetIntrinsicModifierName()
	return "modifier_terrorblade_zeal_passive"
end

LinkLuaModifier( "modifier_terrorblade_zeal_passive", "heroes/hero_terrorblade/terrorblade_zeal", LUA_MODIFIER_MOTION_NONE )
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
			local parent = self:GetParent()
			local owner = PlayerResource:GetSelectedHeroEntity( self:GetParent():GetPlayerID() )
			if parent:IsRealHero() then
				damage = self:GetAbility():GetTalentSpecialValueFor("self_explosion_damage")
				if parent:HasTalent("special_bonus_unique_terrorblade_zeal_2") then
					local conjure = parent:FindAbilityByName("terrorblade_conjure_image_bh")
					if conjure then
						for i = 1, parent:FindTalentValue("special_bonus_unique_terrorblade_zeal_2") do
							local image = conjure:CreateImage( )
							image:SetHealth( image:GetMaxHealth() )
						end
					end
				end
			end
			
			EmitSoundOn("Hero_Terrorblade.Sunder.Cast", parent)
			ParticleManager:FireParticle( "particles/units/heroes/hero_terrorblade/terrorblade_death.vpcf", PATTACH_WORLDORIGIN, parent, {[0] = parent:GetAbsOrigin(), [15] = Vector(100,100,255),
																																		[16] =  Vector(radius,radius,radius) } )
			ParticleManager:FireParticle("particles/units/heroes/hero_dragon_knight/dragon_knight_transform_blue.vpcf", PATTACH_WORLDORIGIN, parent, {[0] = parent:GetAbsOrigin()} )
			local units = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
			for _,unit in pairs(units) do
				ApplyDamage({victim = unit, attacker = owner, damage = damage, damage_type = self:GetAbility():GetAbilityDamageType(), ability = self:GetAbility()})
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
