boss_legion_commander_bolster = class({})

function boss_legion_commander_bolster:OnSpellStart()
	if IsServer() then
		local target = self:GetCursorTarget()
		local caster = self:GetCaster()
		EmitSoundOn("Hero_LegionCommander.PressTheAttack", target)
		if self:GetCaster():HasTalent("special_bonus_unique_boss_legion_commander_bolster_2") then
			for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( caster:GetAbsOrigin(), self:GetTrueCastRange() + 150 ) ) do
				if ally ~= target then
					self:UnbreakableMorale(ally)
				end
			end
		end
		self:UnbreakableMorale(target)
	end
end

function boss_legion_commander_bolster:UnbreakableMorale(target)
	target:Purge(false, true, false, true, true)
	target:AddNewModifier(self:GetCaster(), self, "modifier_boss_legion_commander_bolster_buff", {duration = self:GetTalentSpecialValueFor("duration")})
	if target.press then
		ParticleManager:ClearParticle(target.press)
		target.press = nil
	end
	target.press = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_press.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
			ParticleManager:SetParticleControl(target.press, 0, target:GetAbsOrigin())
			ParticleManager:SetParticleControl(target.press, 1, target:GetAbsOrigin())
			ParticleManager:SetParticleControlEnt(target.press, 2, target, PATTACH_POINT_FOLLOW, "attach_attack1", target:GetAbsOrigin(), true)
			ParticleManager:SetParticleControl(target.press, 3, target:GetAbsOrigin())
end

LinkLuaModifier( "modifier_boss_legion_commander_bolster_buff", "bosses/boss_legion_commander/boss_legion_commander_bolster" ,LUA_MODIFIER_MOTION_NONE )
modifier_boss_legion_commander_bolster_buff = class({})

function modifier_boss_legion_commander_bolster_buff:OnCreated()
	self.hpRegen = self:GetAbility():GetTalentSpecialValueFor("hp_regen")
	self.attackSpeed = self:GetAbility():GetTalentSpecialValueFor("attack_speed")
end

function modifier_boss_legion_commander_bolster_buff:OnDestroy()
	if IsServer() then
		ParticleManager:DestroyParticle(self:GetParent().press, false)
		ParticleManager:ReleaseParticleIndex(self:GetParent().press)
		self:GetParent().press = nil
	end
end

function modifier_boss_legion_commander_bolster_buff:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
			}
	return funcs
end

function modifier_boss_legion_commander_bolster_buff:GetModifierAttackSpeedBonus()
	return self.attackSpeed
end

function modifier_boss_legion_commander_bolster_buff:GetModifierHealthRegenPercentage()
	return self.hpRegen
end