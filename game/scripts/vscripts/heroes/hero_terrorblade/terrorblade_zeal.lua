terrorblade_zeal = class({})

function terrorblade_zeal:GetIntrinsicModifierName()
	return "modifier_terrorblade_zeal_passive"
end

function terrorblade_zeal:GetBehavior()
	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET
	end
	return DOTA_ABILITY_BEHAVIOR_PASSIVE
end

function terrorblade_zeal:GetCooldown( iLvl )
	if self:GetCaster():HasScepter() then return self:GetTalentSpecialValueFor("scepter_cd") end
end

function terrorblade_zeal:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier( caster, self, "modifier_terrorblade_zeal_scepter", {duration = self:GetTalentSpecialValueFor("scepter_duration")})
	
	local radius = self:GetTalentSpecialValueFor("illusion_explosion_radius")
	local damage = self:GetTalentSpecialValueFor("self_explosion_damage")
	
	EmitSoundOn("Hero_Terrorblade.Sunder.Cast", caster)
	ParticleManager:FireParticle( "particles/units/heroes/hero_terrorblade/terrorblade_death.vpcf", PATTACH_WORLDORIGIN, caster, {[0] = caster:GetAbsOrigin(), [15] = Vector(100,100,255),
																																[16] =  Vector(radius,radius,radius) } )
	for _,unit in pairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), radius ) ) do
		self:DealDamage( caster, unit, damage )
	end
end

LinkLuaModifier( "modifier_terrorblade_zeal_passive", "heroes/hero_terrorblade/terrorblade_zeal", LUA_MODIFIER_MOTION_NONE )
modifier_terrorblade_zeal_passive = class({})

function modifier_terrorblade_zeal_passive:OnCreated()
	self.healthregen = self:GetAbility():GetTalentSpecialValueFor("health_regen")
	self.attackspeed = self:GetAbility():GetTalentSpecialValueFor("attackspeed_bonus")
	self.increase = 1 + self:GetAbility():GetTalentSpecialValueFor("scepter_increase") / 100
end

function modifier_terrorblade_zeal_passive:OnRefresh()
	self.healthregen = self:GetAbility():GetTalentSpecialValueFor("health_regen")
	self.attackspeed = self:GetAbility():GetTalentSpecialValueFor("attackspeed_bonus")
	self.increase = 1 + self:GetAbility():GetTalentSpecialValueFor("scepter_increase") / 100
end

function modifier_terrorblade_zeal_passive:DeclareFunctions()
	funcs = {
				MODIFIER_EVENT_ON_DEATH,
				MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
				MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
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
						local images = conjure:CreateImage( nil, nil, nil, nil, parent:FindTalentValue("special_bonus_unique_terrorblade_zeal_2") )
						for i = 1, #images do
							images[i]:SetHealth( images[i]:GetMaxHealth() )
						end
					end
				end
			end
			
			EmitSoundOn("Hero_Terrorblade.Sunder.Cast", parent)
			ParticleManager:FireParticle( "particles/units/heroes/hero_terrorblade/terrorblade_death.vpcf", PATTACH_WORLDORIGIN, parent, {[0] = parent:GetAbsOrigin(), [15] = Vector(100,100,255),
																																		[16] =  Vector(radius,radius,radius) } )
			local units = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
			for _,unit in pairs(units) do
				ApplyDamage({victim = unit, attacker = owner, damage = damage, damage_type = self:GetAbility():GetAbilityDamageType(), ability = self:GetAbility()})
			end
		end
	end
end


function modifier_terrorblade_zeal_passive:GetModifierConstantHealthRegen()
	local regen = self.healthregen
	if self:GetParent():HasModifier("modifier_terrorblade_zeal_scepter") then
		regen = regen * self.increase
	end
	return regen
end

function modifier_terrorblade_zeal_passive:GetModifierAttackSpeedBonus_Constant()
	local as = self.attackspeed
	if self:GetParent():HasModifier("modifier_terrorblade_zeal_scepter") then
		as = as * self.increase
	end
	return as
end

function modifier_terrorblade_zeal_passive:IsHidden()
	return true
end

modifier_terrorblade_zeal_scepter = class({})
LinkLuaModifier( "modifier_terrorblade_zeal_scepter", "heroes/hero_terrorblade/terrorblade_zeal", LUA_MODIFIER_MOTION_NONE )