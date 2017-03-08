function RocketDamage(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	ApplyDamage({victim = target, attacker = caster, damage = ability:GetAbilityDamage(), damage_type = ability:GetAbilityDamageType(), ability = ability})
end

function SupportRocketProcCheck(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	if ability:IsCooldownReady() then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_supporting_rockets_proc", {})
		ability:StartCooldown(ability:GetTrueCooldown())
	end
end

function SupportDOT(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	ApplyDamage({victim = target, attacker = caster, damage = ability:GetAbilityDamage()/ability:GetTalentSpecialValueFor("dot_duration"), damage_type = ability:GetAbilityDamageType(), ability = ability})
end


gyrocopter_flak_cannon_ebf = class({})

if IsServer() then
	function gyrocopter_flak_cannon_ebf:OnSpellStart()
		local flak = self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_gyrocopter_flak_cannon_active", {duration = self:GetDuration()})
		flak:SetStackCount( self:GetTalentSpecialValueFor("max_attacks") )
	end
	
	function gyrocopter_flak_cannon_ebf:OnProjectileHit(target, position)
		self.disableLoop = true
		self:GetCaster():PerformAttack(target, true, true, true, false, false, false, true)
	end
end

LinkLuaModifier( "modifier_gyrocopter_flak_cannon_active", "lua_abilities/heroes/gyrocopter.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_gyrocopter_flak_cannon_active = class({})

function modifier_gyrocopter_flak_cannon_active:DeclareFunctions()
	funcs = {
				MODIFIER_EVENT_ON_ATTACK_LANDED,
				MODIFIER_EVENT_ON_ATTACK_START
			}
	return funcs
end

function modifier_gyrocopter_flak_cannon_active:OnAttackStart(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			self:GetAbility().disableLoop = false
		end
	end
end

function modifier_gyrocopter_flak_cannon_active:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			if self:GetAbility().disableLoop then return end
			local units = FindUnitsInRadius(self:GetParent():GetTeam(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetTalentSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
			for _,unit in pairs(units) do
				local projectile = {
					Target = unit,
					Source = self:GetParent(),
					Ability = self:GetAbility(),
					EffectName = self:GetParent():GetProjectileModel(),
					bDodgable = true,
					bProvidesVision = false,
					iMoveSpeed = self:GetParent():GetProjectileSpeed(),
					iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
				}
				ProjectileManager:CreateTrackingProjectile(projectile)
			end
			self:DecrementStackCount()
			if self:GetStackCount() < 1 then self:Destroy() end
		end
	end
end