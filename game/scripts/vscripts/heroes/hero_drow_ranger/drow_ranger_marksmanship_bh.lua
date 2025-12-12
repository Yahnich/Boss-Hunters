drow_ranger_marksmanship_bh = class({})

function drow_ranger_marksmanship_bh:GetIntrinsicModifierName()
	return "modifier_drow_ranger_marksmanship_bh_handler"
end

function drow_ranger_marksmanship_bh:OnProjectileHit( target, position )
	if target then
		local caster = self:GetCaster()
		caster:PerformAbilityAttack(target, true, self, (caster:GetAttackDamage() * self:GetSpecialValueFor("damage_reduction_scepter")/100) * (-1))
	end
end

modifier_drow_ranger_marksmanship_bh_handler = class({})
LinkLuaModifier("modifier_drow_ranger_marksmanship_bh_handler", "heroes/hero_drow_ranger/drow_ranger_marksmanship_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_drow_ranger_marksmanship_bh_handler:OnCreated()
	self:OnRefresh()
	if IsServer() then
		self:StartIntervalThink(0)
	end
end

function modifier_drow_ranger_marksmanship_bh_handler:OnRefresh()
	self:GetCaster().huntressMarkCooldown = self:GetSpecialValueFor("huntress_mark_cd")
	self:GetCaster().glacierArrowsManaCost = self:GetSpecialValueFor("glacier_arrows_mana_cost")
	self.radius = self:GetSpecialValueFor("radius")
	self.bonusAgility = self:GetSpecialValueFor("marksmanship_agility_bonus") / 100
end

function modifier_drow_ranger_marksmanship_bh_handler:OnIntervalThink()
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_drow_ranger_marksmanship_bh_agility") and caster:HasTalent("special_bonus_unique_drow_ranger_marksmanship_2") then
		AddFOWViewer(caster:GetTeamNumber(), caster:GetAbsOrigin(), caster:FindTalentValue("special_bonus_unique_drow_ranger_marksmanship_2"), 0.05, false)
	end
	local stacks = self:GetStackCount()
	if stacks ~= math.floor(caster:GetAgility() - stacks) * self.bonusAgility then
		self:SetStackCount( math.floor(caster:GetAgility() - stacks) * self.bonusAgility )
	end
end


function modifier_drow_ranger_marksmanship_bh_handler:IsAura()
	if IsServer() then
		local caster = self:GetCaster()
		local enemies = caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), self.radius )
		return caster:HasTalent("special_bonus_unique_drow_ranger_marksmanship_1") or #enemies <= 0
	end
end

function modifier_drow_ranger_marksmanship_bh_handler:GetModifierAura()
	return "modifier_drow_ranger_marksmanship_bh_agility"
end

function modifier_drow_ranger_marksmanship_bh_handler:GetAuraRadius()
	return self.radius
end

function modifier_drow_ranger_marksmanship_bh_handler:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_drow_ranger_marksmanship_bh_handler:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end


function modifier_drow_ranger_marksmanship_bh_handler:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_drow_ranger_marksmanship_bh_handler:OnAttackLanded(params)
	if params.attacker == self:GetParent() and not params.attacker.autoAttackFromAbilityState and params.attacker:HasScepter() then
		local caster = self:GetCaster()
		local count = self:GetSpecialValueFor("split_count_scepter")
		local radius = self:GetSpecialValueFor("scepter_range")

		for _, enemy in ipairs( params.attacker:FindEnemyUnitsInRadius( params.target:GetAbsOrigin(), radius ) ) do
			if enemy ~= params.target then
				if caster:FindAbilityByName("drow_ranger_glacier_arrows"):GetAutoCastState() then 
					local projTable = {
						EffectName = "particles/units/heroes/hero_drow/drow_frost_arrow.vpcf",
						Ability = caster:FindAbilityByName("drow_ranger_glacier_arrows"),
						Target = enemy,
						Source = params.target,
						bDodgeable = true,
						bProvidesVision = false,
						vSpawnOrigin = params.target:GetAbsOrigin(),
						iMoveSpeed = caster:GetProjectileSpeed(),
						iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
					}
					ProjectileManager:CreateTrackingProjectile( projTable )
				end
				local projTable = {
					EffectName = "particles/units/heroes/hero_drow/drow_base_attack.vpcf",
					Ability = self:GetAbility(),
					Target = enemy,
					Source = params.target,
					bDodgeable = true,
					bProvidesVision = false,
					vSpawnOrigin = params.target:GetAbsOrigin(),
					iMoveSpeed = caster:GetProjectileSpeed(),
					iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
				}
				ProjectileManager:CreateTrackingProjectile( projTable )
				count = count - 1
				if count == 0 then break end
			end
		end
		
	end
end

function modifier_drow_ranger_marksmanship_bh_handler:IsHidden()
	return true
end

modifier_drow_ranger_marksmanship_bh_agility = class({})
LinkLuaModifier("modifier_drow_ranger_marksmanship_bh_agility", "heroes/hero_drow_ranger/drow_ranger_marksmanship_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_drow_ranger_marksmanship_bh_agility:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS}
end

function modifier_drow_ranger_marksmanship_bh_agility:GetModifierBonusStats_Agility()
	return self:GetCaster():GetModifierStackCount( "modifier_drow_ranger_marksmanship_bh_handler", self:GetCaster() )
end

function modifier_drow_ranger_marksmanship_bh_agility:GetEffectName()
	return "particles/units/heroes/hero_drow/drow_marksmanship.vpcf"
end