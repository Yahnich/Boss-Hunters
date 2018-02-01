rattletrap_rocket_flare_ebf = class({})

function rattletrap_rocket_flare_ebf:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

if IsServer() then
	function rattletrap_rocket_flare_ebf:OnSpellStart()
		local caster = self:GetCaster()
		local casterPos = caster:GetAbsOrigin()
		local targetPos = self:GetCursorPosition()
		local duration = self:GetSpecialValueFor("duration")
		local dummy = CreateUnitByName("npc_dummy_unit", targetPos, false, nil, nil, caster:GetTeam())
		dummy:AddAbility("hide_hero"):SetLevel(1)
		local projectile = {
			Target = dummy,
			Source = self:GetCaster(),
			Ability = self,
			EffectName = "particles/units/heroes/hero_rattletrap/rattletrap_rocket_flare.vpcf",
			bDodgable = false,
			bProvidesVision = false,
			iMoveSpeed = 1800,
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
		}
		ProjectileManager:CreateTrackingProjectile(projectile)
		EmitSoundOn("Hero_Rattletrap.Rocket_Flare.Fire", self:GetCaster())
	end

	function rattletrap_rocket_flare_ebf:OnProjectileHit(target, position)
		local caster = self:GetCaster()
		local radius = self:GetTalentSpecialValueFor("radius")
		local duration = self:GetTalentSpecialValueFor("duration")
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
		EmitSoundOn("Hero_Rattletrap.Rocket_Flare.Explode", self:GetCaster())
		target:RemoveSelf()
		for _, enemy in pairs(enemies) do
			enemy:AddNewModifier(caster, self, "modifier_rocket_flare_blind", {duration = duration})
			ApplyDamage({victim = enemy, attacker = caster, damage = self:GetTalentSpecialValueFor("damage"), damage_type = self:GetAbilityDamageType(), ability = self})
		end
	end
end

LinkLuaModifier( "modifier_rocket_flare_blind", "lua_abilities/heroes/rattletrap.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_rocket_flare_blind = class({})

function modifier_rocket_flare_blind:OnCreated()
	self.miss = self:GetAbility():GetTalentSpecialValueFor("blind")
end

function modifier_rocket_flare_blind:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_MISS_PERCENTAGE,
			}
	return funcs
end
function modifier_rocket_flare_blind:GetModifierMiss_Percentage()
	return self.miss
end

function modifier_rocket_flare_blind:GetEffectName()
	return "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_blinding_light_debuff.vpcf"
end

function modifier_rocket_flare_blind:GetStatusEffectName()
	return "particles/status_fx/status_effect_slardar_amp_damage.vpcf"
end

function modifier_rocket_flare_blind:StatusEffectPriority()
	return 8
end