function Reflection( event )
	print("Reflection Start")

	----- Conjure Image  of the target -----
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local unit_name = target:GetUnitName()
	local origin = target:GetAbsOrigin() + RandomVector(100)
	local duration = ability:GetTalentSpecialValueFor( "illusion_duration")
	local outgoingDamage = ability:GetTalentSpecialValueFor( "illusion_outgoing_damage")

	-- handle_UnitOwner needs to be nil, else it will crash the game.
	local illusion = CreateUnitByName(unit_name, origin, true, caster, nil, caster:GetTeamNumber())

	-- Set the unit as an illusion
	-- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle
	illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = 0 })
	illusion:AddNewModifier(caster, ability, "modifier_terrorblade_conjureimage", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = 0 })
	
	-- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
	illusion:MakeIllusion()

	-- Apply Invulnerability modifier
	ability:ApplyDataDrivenModifier(caster, illusion, "modifier_reflection_invulnerability", nil)

	-- Force Illusion to attack Target
	illusion:SetForceAttackTarget(target)

	-- Emit the sound, so the destroy sound is played after it dies
	illusion:EmitSound("Hero_Terrorblade.Reflection")

end

--[[Author: Noya
	Date: 11.01.2015.
	Shows the Cast Particle, which for TB is originated between each weapon, in here both bodies are linked because not every hero has 2 weapon attach points
]]
function ReflectionCast( event )

	local caster = event.caster
	local target = event.target
	local particleName = "particles/units/heroes/hero_terrorblade/terrorblade_reflection_cast.vpcf"

	local particle = ParticleManager:CreateParticle( particleName, PATTACH_POINT_FOLLOW, caster )
	ParticleManager:SetParticleControl(particle, 3, Vector(1,0,0))
	
	ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
end

terrorblade_zeal = class({})

function terrorblade_zeal:GetIntrinsicModifierName()
	return "modifier_terrorblade_zeal_passive"
end

LinkLuaModifier( "modifier_terrorblade_zeal_passive", "lua_abilities/heroes/terrorblade.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_terrorblade_zeal_passive = class({})

function modifier_terrorblade_zeal_passive:OnCreated()
	self.healthregen = self:GetAbility():GetSpecialValueFor("health_regen")
	self.attackspeed = self:GetAbility():GetSpecialValueFor("attackspeed_bonus")
end

function modifier_terrorblade_zeal_passive:OnRefresh()
	self.healthregen = self:GetAbility():GetSpecialValueFor("health_regen")
	self.attackspeed = self:GetAbility():GetSpecialValueFor("attackspeed_bonus")
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
			local multiplier = 1
			if self:GetParent():HasTalent("special_bonus_unique_terrorblade") then multiplier = 1 + self:GetParent():FindTalentValue("special_bonus_unique_terrorblade")/100 end
			local radius = self:GetAbility():GetTalentSpecialValueFor("illusion_explosion_radius") * multiplier
			local damage = self:GetAbility():GetTalentSpecialValueFor("illusion_explosion_damage") * multiplier
			local owner = self:GetParent()
			if owner:IsIllusion() then owner = owner:GetOwnerEntity() end
			EmitSoundOn("Hero_Terrorblade.Sunder.Cast", owner)
			local residu = ParticleManager:CreateParticle( "particles/units/heroes/hero_terrorblade/terrorblade_death.vpcf", PATTACH_WORLDORIGIN, owner )
				ParticleManager:SetParticleControl(residu, 0, self:GetParent():GetAbsOrigin())				
				ParticleManager:SetParticleControl(residu, 1, self:GetParent():GetAbsOrigin())
				ParticleManager:SetParticleControl(residu, 15, Vector(100,100,255))	
				ParticleManager:SetParticleControl(residu, 16, Vector(radius,radius,radius))	
			local poof = ParticleManager:CreateParticle("particles/units/heroes/hero_dragon_knight/dragon_knight_transform_blue.vpcf", PATTACH_WORLDORIGIN, owner)
				ParticleManager:SetParticleControl(poof, 0, self:GetParent():GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(residu)
			ParticleManager:ReleaseParticleIndex(poof)
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



