rattletrap_rocket_flare_ebf = class({})

function rattletrap_rocket_flare_ebf:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function rattletrap_rocket_flare_ebf:GetIntrinsicModifierName()
	return "modifier_rattletrap_rocket_flare_ebf_talent"
end

if IsServer() then
	function rattletrap_rocket_flare_ebf:OnSpellStart()
		local caster = self:GetCaster()
		local targetPos = self:GetCursorPosition()
		self:FireFlashbang(targetPos)
	end
	
	function rattletrap_rocket_flare_ebf:FireFlashbang(position)
		local dummy = self:CreateDummy(position)
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
		UTIL_Remove(target)
		for _, enemy in pairs(enemies) do
			enemy:AddNewModifier(caster, self, "modifier_rattletrap_rocket_flare_blind", {duration = duration})
			ApplyDamage({victim = enemy, attacker = caster, damage = self:GetTalentSpecialValueFor("damage"), damage_type = self:GetAbilityDamageType(), ability = self})
		end
	end
end

modifier_rattletrap_rocket_flare_blind = class({})
LinkLuaModifier( "modifier_rattletrap_rocket_flare_blind", "heroes/hero_rattletrap/rattletrap_rocket_flare_ebf" ,LUA_MODIFIER_MOTION_NONE )

function modifier_rattletrap_rocket_flare_blind:OnCreated()
	self.miss = self:GetAbility():GetTalentSpecialValueFor("blind")
end

function modifier_rattletrap_rocket_flare_blind:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_MISS_PERCENTAGE,
			}
	return funcs
end
function modifier_rattletrap_rocket_flare_blind:GetModifierMiss_Percentage()
	return self.miss
end

function modifier_rattletrap_rocket_flare_blind:GetEffectName()
	return "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_blinding_light_debuff.vpcf"
end

function modifier_rattletrap_rocket_flare_blind:GetStatusEffectName()
	return "particles/status_fx/status_effect_slardar_amp_damage.vpcf"
end

function modifier_rattletrap_rocket_flare_blind:StatusEffectPriority()
	return 8
end

modifier_rattletrap_rocket_flare_ebf_talent = class({})
LinkLuaModifier( "modifier_rattletrap_rocket_flare_ebf_talent", "heroes/hero_rattletrap/rattletrap_rocket_flare_ebf", LUA_MODIFIER_MOTION_NONE )

if IsServer() then
	function modifier_rattletrap_rocket_flare_ebf_talent:OnCreated()
		self.talent = false
		self:StartIntervalThink(1)
	end
	
	function modifier_rattletrap_rocket_flare_ebf_talent:OnIntervalThink()
		local caster = self:GetParent()
		local ability = self:GetAbility()
		if caster:IsAlive() and caster:HasTalent("special_bonus_unique_rattletrap_rocket_flare_ebf_1") then
			if not self.talent then
				self.talent = true
				self:StartIntervalThink( caster:FindTalentValue("special_bonus_unique_rattletrap_rocket_flare_ebf_1") )
			else
				for _, enemy in ipairs( caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), -1) ) do
					ability:FireFlashbang(enemy:GetAbsOrigin())
					return nil
				end
				ability:FireFlashbang( caster:GetAbsOrigin() + ActualRandomVector(3000, 500) )
			end
		end
	end
end

function modifier_rattletrap_rocket_flare_ebf_talent:IsHidden()
	return true
end