drow_ranger_marksmanship = class({})

function drow_ranger_marksmanship:GetIntrinsicModifierName()
	return "modifier_drow_ranger_marksmanship_handler"
end

function drow_ranger_marksmanship:OnProjectileHit( target, position )
	if target then
		local caster = self:GetCaster()
		caster:PerformAbilityAttack(target, true, self, (caster:GetAttackDamage() * self:GetTalentSpecialValueFor("damage_reduction_scepter")/100) * (-1))
	end
end

modifier_drow_ranger_marksmanship_handler = class({})
LinkLuaModifier("modifier_drow_ranger_marksmanship_handler", "heroes/hero_drow_ranger/drow_ranger_marksmanship", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_drow_ranger_marksmanship_handler:OnCreated()
		self.radius = self:GetTalentSpecialValueFor("radius")
		self:StartIntervalThink(0)
	end
	
	function modifier_drow_ranger_marksmanship_handler:OnIntervalThink()
		local caster = self:GetCaster()
		if caster:HasModifier("modifier_drow_ranger_marksmanship_agility") and caster:HasTalent("special_bonus_unique_drow_ranger_marksmanship_2") then
			AddFOWViewer(caster:GetTeamNumber(), caster:GetAbsOrigin(), caster:FindTalentValue("special_bonus_unique_drow_ranger_marksmanship_2"), 0.05, false)
		end
		if not caster:HasTalent("special_bonus_unique_drow_ranger_marksmanship_1") then
			local enemies = caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), self.radius )
			if #enemies > 0 then
				caster:RemoveModifierByName("modifier_drow_ranger_marksmanship_agility")
			else
				caster:AddNewModifier(caster, self:GetAbility(), "modifier_drow_ranger_marksmanship_agility", {})
			end
		else
			caster:AddNewModifier(caster, self:GetAbility(), "modifier_drow_ranger_marksmanship_agility", {})
		end
	end
end

function modifier_drow_ranger_marksmanship_handler:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_drow_ranger_marksmanship_handler:OnAttackLanded(params)
	if params.attacker == self:GetParent() and not params.attacker.autoAttackFromAbilityState and params.attacker:HasScepter() then
		local caster = self:GetCaster()
		local count = self:GetTalentSpecialValueFor("split_count_scepter")
		local radius = self:GetTalentSpecialValueFor("scepter_range")

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

function modifier_drow_ranger_marksmanship_handler:IsHidden()
	return true
end

modifier_drow_ranger_marksmanship_agility = class({})
LinkLuaModifier("modifier_drow_ranger_marksmanship_agility", "heroes/hero_drow_ranger/drow_ranger_marksmanship", LUA_MODIFIER_MOTION_NONE)

function modifier_drow_ranger_marksmanship_agility:OnCreated()
	self.agility = self:GetTalentSpecialValueFor("marksmanship_agility_bonus")
end

function modifier_drow_ranger_marksmanship_agility:OnRefresh()
	self.agility = self:GetTalentSpecialValueFor("marksmanship_agility_bonus")
end

function modifier_drow_ranger_marksmanship_agility:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS}
end

function modifier_drow_ranger_marksmanship_agility:GetModifierBonusStats_Agility()
	return self.agility
end

function modifier_drow_ranger_marksmanship_agility:GetEffectName()
	return "particles/units/heroes/hero_drow/drow_marksmanship.vpcf"
end