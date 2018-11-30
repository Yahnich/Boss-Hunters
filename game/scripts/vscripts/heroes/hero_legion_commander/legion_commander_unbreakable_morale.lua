legion_commander_unbreakable_morale = class({})

function legion_commander_unbreakable_morale:GetIntrinsicModifierName()
	return "modifier_legion_commander_unbreakable_morale_passive"
end

function legion_commander_unbreakable_morale:OnSpellStart()
	if IsServer() then
		local target = self:GetCursorTarget()
		local caster = self:GetCaster()
		EmitSoundOn("Hero_LegionCommander.PressTheAttack", target)
		if self:GetCaster():HasTalent("special_bonus_unique_legion_commander_unbreakable_morale_2") then
			for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( caster:GetAbsOrigin(), self:GetTrueCastRange() + 150 ) ) do
				if ally ~= target then
					self:UnbreakableMorale(ally)
				end
			end
		end
		self:UnbreakableMorale(target)
	end
end

function legion_commander_unbreakable_morale:UnbreakableMorale(target)
	target:Purge(false, true, false, true, true)
	target:AddNewModifier(self:GetCaster(), self, "modifier_legion_commander_unbreakable_morale_buff", {duration = self:GetTalentSpecialValueFor("duration")})
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

LinkLuaModifier( "modifier_legion_commander_unbreakable_morale_passive", "heroes/hero_legion_commander/legion_commander_unbreakable_morale" ,LUA_MODIFIER_MOTION_NONE )
modifier_legion_commander_unbreakable_morale_passive = class({})

function modifier_legion_commander_unbreakable_morale_passive:OnCreated()
	self.procChance = self:GetAbility():GetTalentSpecialValueFor("passive_chance")
end

function modifier_legion_commander_unbreakable_morale_passive:IsHidden()
	return true
end

function modifier_legion_commander_unbreakable_morale_passive:DeclareFunctions()
	funcs = {
				MODIFIER_EVENT_ON_ATTACK_LANDED
			}
	return funcs
end

function modifier_legion_commander_unbreakable_morale_passive:OnAttackLanded(params)
	if IsServer() then
		if params.target:GetTeam() == self:GetParent():GetTeam() and CalculateDistance(params.target, self:GetParent()) <= self:GetAbility():GetCastRange(self:GetParent():GetAbsOrigin(), params.target) and not self:GetParent():HasModifier("modifier_legion_commander_unbreakable_morale_passve_cooldown") and not params.target:HasModifier("modifier_legion_commander_unbreakable_morale_buff") then
			if RollPercentage(self.procChance) and self:GetParent():IsAlive() then
				self:GetAbility():UnbreakableMorale(params.target)
				EmitSoundOn("Hero_LegionCommander.PressTheAttack", params.target)
				self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_legion_commander_unbreakable_morale_passive_cooldown", {duration = self:GetAbility():GetTrueCooldown()})
			end
		end
	end
end

LinkLuaModifier( "modifier_legion_commander_unbreakable_morale_passive_cooldown", "heroes/hero_legion_commander/legion_commander_unbreakable_morale" ,LUA_MODIFIER_MOTION_NONE )
modifier_legion_commander_unbreakable_morale_passive_cooldown = class({})

function modifier_legion_commander_unbreakable_morale_passive_cooldown:IsDebuff()
	return true
end

LinkLuaModifier( "modifier_legion_commander_unbreakable_morale_buff", "heroes/hero_legion_commander/legion_commander_unbreakable_morale" ,LUA_MODIFIER_MOTION_NONE )
modifier_legion_commander_unbreakable_morale_buff = class({})

function modifier_legion_commander_unbreakable_morale_buff:OnCreated()
	self.hpRegen = self:GetAbility():GetTalentSpecialValueFor("hp_regen")
	self.attackSpeed = self:GetAbility():GetTalentSpecialValueFor("attack_speed")
end

function modifier_legion_commander_unbreakable_morale_buff:OnDestroy()
	if IsServer() then
		ParticleManager:DestroyParticle(self:GetParent().press, false)
		ParticleManager:ReleaseParticleIndex(self:GetParent().press)
		self:GetParent().press = nil
	end
end

function modifier_legion_commander_unbreakable_morale_buff:DeclareFunctions()
	funcs = {
				
				MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			}
	return funcs
end

function modifier_legion_commander_unbreakable_morale_buff:CheckState()
	if self:GetCaster():HasTalent("special_bonus_unique_legion_commander_unbreakable_morale_1") then
		return {[MODIFIER_STATE_ROOTED] = false,
				[MODIFIER_STATE_DISARMED] = false,
				[MODIFIER_STATE_SILENCED] = false,
				[MODIFIER_STATE_MUTED] = false,
				[MODIFIER_STATE_STUNNED] = false,
				[MODIFIER_STATE_HEXED] = false,
				[MODIFIER_STATE_FROZEN] = false,
				[MODIFIER_STATE_PASSIVES_DISABLED] = false}
	end
end

function modifier_legion_commander_unbreakable_morale_buff:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

function modifier_legion_commander_unbreakable_morale_buff:GetModifierAttackSpeedBonus()
	return self.attackSpeed
end

function modifier_legion_commander_unbreakable_morale_buff:GetModifierConstantHealthRegen()
	return self.hpRegen
end