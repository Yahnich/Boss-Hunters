boss_warlock_fatal_bonds = class({})
LinkLuaModifier( "modifier_boss_warlock_fatal_bonds_primary", "bosses/boss_warlock/boss_warlock_fatal_bonds", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_boss_warlock_fatal_bonds_secondary", "bosses/boss_warlock/boss_warlock_fatal_bonds", LUA_MODIFIER_MOTION_NONE )

function boss_warlock_fatal_bonds:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	target:AddNewModifier(caster, self, "modifier_boss_warlock_fatal_bonds_primary", {Duration = self:GetSpecialValueFor("duration")})
end

modifier_boss_warlock_fatal_bonds_primary = class({})
function modifier_boss_warlock_fatal_bonds_primary:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()

		local maxTargets = self:GetSpecialValueFor("max_targets") - 1
		local currentTargets = 0

		local enemies = caster:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), FIND_UNITS_EVERYWHERE, {order = FIND_CLOSEST})
		for _,enemy in pairs(enemies) do
			if enemy:IsHero() and currentTargets < maxTargets and enemy ~= parent then
				if not enemy:TriggerSpellAbsorb(self) then
					local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_warlock/warlock_fatal_bonds_base.vpcf", PATTACH_POINT_FOLLOW, caster)
								ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
								ParticleManager:SetParticleControlEnt(nfx, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
					self:AttachEffect(nfx)

					enemy:AddNewModifier(caster, self, "modifier_boss_warlock_fatal_bonds_secondary", {Duration = self:GetSpecialValueFor("duration")})
				end
				currentTargets = currentTargets + 1
			end
		end
	end
end

function modifier_boss_warlock_fatal_bonds_primary:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function modifier_boss_warlock_fatal_bonds_primary:OnTakeDamage(params)
	if IsServer() then
		local parent = self:GetParent()
		local caster = self:GetCaster()
		if params.unit == parent and not HasBit( params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION ) then
			local damage = params.damage * self:GetSpecialValueFor("damage")/100
			local enemies = caster:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), FIND_UNITS_EVERYWHERE)
			for _,enemy in pairs(enemies) do
				if enemy:HasModifier("modifier_boss_warlock_fatal_bonds_secondary") then
					local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_warlock/warlock_fatal_bonds_hit.vpcf", PATTACH_POINT_FOLLOW, caster)
								ParticleManager:SetParticleControlEnt(nfx, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
								ParticleManager:SetParticleControlEnt(nfx, 1, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
								ParticleManager:ReleaseParticleIndex(nfx)
					self:GetAbility():DealDamage(caster, enemy, damage, {damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_REFLECTION}, OVERHEAD_ALERT_DAMAGE)
				end
			end
		end
	end
end

function modifier_boss_warlock_fatal_bonds_primary:OnRemoved()
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local enemies = caster:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), FIND_UNITS_EVERYWHERE)
		for _,enemy in pairs(enemies) do
			enemy:RemoveModifierByName("modifier_boss_warlock_fatal_bonds_secondary")
		end
	end
end

function modifier_boss_warlock_fatal_bonds_primary:GetEffectName()
	return "particles/units/heroes/hero_warlock/warlock_fatal_bonds_icon.vpcf"
end

function modifier_boss_warlock_fatal_bonds_primary:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_boss_warlock_fatal_bonds_primary:IsDebuff()
	return true
end

function modifier_boss_warlock_fatal_bonds_primary:IsPurgable()
	return true
end

modifier_boss_warlock_fatal_bonds_secondary = class({})

function modifier_boss_warlock_fatal_bonds_secondary:GetEffectName()
	return "particles/units/heroes/hero_warlock/warlock_fatal_bonds_icon.vpcf"
end

function modifier_boss_warlock_fatal_bonds_secondary:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_boss_warlock_fatal_bonds_secondary:IsDebuff()
	return true
end

function modifier_boss_warlock_fatal_bonds_secondary:IsPurgable()
	return true
end