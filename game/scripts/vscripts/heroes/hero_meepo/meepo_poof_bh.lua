meepo_poof_bh = class({})
LinkLuaModifier("modifier_meepo_poof_bh", "heroes/hero_meepo/meepo_poof_bh", LUA_MODIFIER_MOTION_NONE)

function meepo_poof_bh:IsStealable()
    return true
end

function meepo_poof_bh:IsHiddenWhenStolen()
    return false
end

function meepo_poof_bh:OnAbilityPhaseStart()
	local caster = self:GetCaster()

	EmitSoundOn("Hero_Meepo.Poof.Channel", caster)

	self.nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_meepo/meepo_poof_start.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControl(self.nfx, 0, caster:GetAbsOrigin())
				ParticleManager:SetParticleControl(self.nfx, 1, caster:GetAbsOrigin())
				
	return true
end

function meepo_poof_bh:OnAbilityPhaseInterrupted()
	StopSoundOn("Hero_Meepo.Poof.Channel", self:GetCaster())
    ParticleManager:ClearParticle(self.nfx)
end

function meepo_poof_bh:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local target = self:GetCursorTarget()

	local damage = self:GetSpecialValueFor("damage")
	local radius = self:GetSpecialValueFor("radius")

	if caster:HasTalent("special_bonus_unique_meepo_poof_bh_2") then
		damage = damage + caster:GetIntellect( false) * caster:FindTalentValue("special_bonus_unique_meepo_poof_bh_2")/100
	end

	StopSoundOn("Hero_Meepo.Poof.Channel", caster)
	ParticleManager:ClearParticle(self.nfx)

	EmitSoundOn("Hero_Meepo.Poof.End00", caster)

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_meepo/meepo_poof_end.vpcf", PATTACH_POINT, caster)
				--ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_ABSORIGIN, "attach_hitloc", caster:GetAbsOrigin(), true)
				ParticleManager:SetParticleControl(nfx, 0, caster:GetAbsOrigin())
				ParticleManager:SetParticleControl(nfx, 1, caster:GetAbsOrigin())
				ParticleManager:SetParticleControl(nfx, 2, Vector(radius, radius, radius))
				ParticleManager:ReleaseParticleIndex(nfx)

	local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), radius)
	for _,enemy in pairs(enemies) do
		if not enemy:TriggerSpellAbsorb(self) then
			if caster:HasTalent("special_bonus_unique_meepo_poof_bh_1") then
				caster:FindAbilityByName("meepo_earthbind_bh"):ThrowNet(enemy:GetAbsOrigin())
			end

			EmitSoundOn("Hero_Meepo.Poof.Damage", enemy)
			self:DealDamage(caster, enemy, damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
		end
	end

	if target and target:IsAlive() and target:GetUnitName() == caster:GetUnitName() then
		local nfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_meepo/meepo_poof_end.vpcf", PATTACH_POINT, caster)
					 --ParticleManager:SetParticleControlEnt(nfx2, 0, caster, PATTACH_ABSORIGIN, "attach_hitloc", caster:GetAbsOrigin(), true)
					 ParticleManager:SetParticleControl(nfx2, 0, caster:GetAbsOrigin())
					 ParticleManager:SetParticleControl(nfx2, 1, caster:GetAbsOrigin())
					 ParticleManager:SetParticleControl(nfx2, 2, Vector(radius, radius, radius))
					 ParticleManager:ReleaseParticleIndex(nfx2)
		FindClearSpaceForUnit(caster, target:GetAbsOrigin(), true)
		local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), radius)
		for _,enemy in pairs(enemies) do
			if not enemy:TriggerSpellAbsorb(self) then
				if caster:HasTalent("special_bonus_unique_meepo_poof_bh_1") then
					caster:FindAbilityByName("meepo_earthbind_bh"):ThrowNet(enemy:GetAbsOrigin())
				end

				EmitSoundOn("Hero_Meepo.Poof.Damage", enemy)

				self:DealDamage(caster, enemy, damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
			end
		end
	else
		local allies = caster:FindFriendlyUnitsInRadius(point, FIND_UNITS_EVERYWHERE, {order = FIND_CLOSEST})
		for _,ally in pairs(allies) do
			if ally:GetUnitName() == caster:GetUnitName() then
				local nfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_meepo/meepo_poof_end.vpcf", PATTACH_POINT, caster)
							 --ParticleManager:SetParticleControlEnt(nfx2, 0, caster, PATTACH_ABSORIGIN, "attach_hitloc", caster:GetAbsOrigin(), true)
							 ParticleManager:SetParticleControl(nfx2, 0, caster:GetAbsOrigin())
							 ParticleManager:SetParticleControl(nfx2, 1, caster:GetAbsOrigin())
							 ParticleManager:SetParticleControl(nfx2, 2, Vector(radius, radius, radius))
							 ParticleManager:ReleaseParticleIndex(nfx2)
				FindClearSpaceForUnit(caster, ally:GetAbsOrigin(), true)
				local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), radius)
				for _,enemy in pairs(enemies) do
					if not enemy:TriggerSpellAbsorb(self) then
						if caster:HasTalent("special_bonus_unique_meepo_poof_bh_1") then
							caster:FindAbilityByName("meepo_earthbind_bh"):ThrowNet(enemy:GetAbsOrigin())
						end

						EmitSoundOn("Hero_Meepo.Poof.Damage", enemy)

						self:DealDamage(caster, enemy, damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
					end
				end
				break
			end
		end
	end
end
