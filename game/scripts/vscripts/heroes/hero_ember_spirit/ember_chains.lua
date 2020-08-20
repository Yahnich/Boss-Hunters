ember_chains = class({})
LinkLuaModifier("modifier_ember_chains", "heroes/hero_ember_spirit/ember_chains", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ember_chains_amp", "heroes/hero_ember_spirit/ember_chains", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ember_chains_slow", "heroes/hero_ember_spirit/ember_chains", LUA_MODIFIER_MOTION_NONE)

function ember_chains:IsStealable()
	return true
end

function ember_chains:IsHiddenWhenStolen()
	return false
end

function ember_chains:OnSpellStart()
	local caster = self:GetCaster()
	caster:StartGesture(ACT_DOTA_CAST_ABILITY_1)

	EmitSoundOn("Hero_EmberSpirit.SearingChains.Cast", caster)

	local duration = self:GetTalentSpecialValueFor("duration")
	local radius = self:GetTalentSpecialValueFor("radius")
	local position = caster:GetAbsOrigin()
	if caster:HasModifier("modifier_ember_fist") then
		local fist = caster:FindModifierByName("modifier_ember_fist"):GetAbility()
		if fist then
			radius = radius + fist:GetTalentSpecialValueFor("radius")
			position = fist:GetCursorPosition()
		end
	end
	local maxTargets = self:GetTalentSpecialValueFor("unit_count")
	local current = 0

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_searing_chains_cast.vpcf", PATTACH_POINT_FOLLOW, caster)
				ParticleManager:SetParticleControl(nfx, 0, position)
				ParticleManager:SetParticleControl(nfx, 1, Vector(radius, radius, radius))
				ParticleManager:ReleaseParticleIndex(nfx)

	local units = caster:FindEnemyUnitsInRadius( position, radius )
	if #units > 0 then
		for _,unit in pairs(units) do
			if unit:GetTeam() ~= caster:GetTeam() and not unit:IsInvulnerable() then
				if maxTargets > 0 or unit:IsMinion() then
					EmitSoundOn("Hero_EmberSpirit.SearingChains.Cast", unit)

					local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_searing_chains_start.vpcf", PATTACH_POINT, caster)
								ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT, "attach_hitloc", position, true)
								ParticleManager:SetParticleControlEnt(nfx, 1, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), true)
								ParticleManager:ReleaseParticleIndex(nfx)
					if not unit:TriggerSpellAbsorb(self) then
						---Talent 2------
						if caster:HasTalent("special_bonus_unique_ember_chains_2") then
							unit:AddNewModifier(caster, self, "modifier_ember_chains_slow", {Duration = duration})
						else
							unit:AddNewModifier(caster, self, "modifier_ember_chains", {Duration = duration})
						end

						---Talent 1------
						if caster:HasTalent("special_bonus_unique_ember_chains_1") then
							unit:AddNewModifier(caster, self, "modifier_ember_chains_amp", {Duration = duration})
						end
					end
					if not unit:IsMinion() then
						maxTargets = maxTargets - 1
					end
				end
			end
		end
	end
end

modifier_ember_chains_amp = class({})

function modifier_ember_chains_amp:OnCreated(table)
	self.damage = self:GetCaster():FindTalentValue("special_bonus_unique_ember_chains_1")
end

function modifier_ember_chains_amp:OnRefresh(table)
	self.damage = self:GetCaster():FindTalentValue("special_bonus_unique_ember_chains_1")
end

function modifier_ember_chains_amp:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }
    return funcs
end


function modifier_ember_chains_amp:GetModifierIncomingDamage_Percentage(params)
	if params.attacker == self:GetCaster() then
		return self.damage
	end
end

function modifier_ember_chains_amp:IsDebuff()
	return true
end

modifier_ember_chains = class({})

function modifier_ember_chains:OnCreated(table)
	if IsServer() then
		EmitSoundOn("Hero_EmberSpirit.SearingChains.Burn", self:GetParent())

		local tick_rate = self:GetTalentSpecialValueFor("tick_rate")
		self.damage = self:GetTalentSpecialValueFor("damage") * tick_rate

		self:StartIntervalThink(tick_rate)
	end
end

function modifier_ember_chains:OnRefresh(table)
	if IsServer() then
		local tick_rate = self:GetTalentSpecialValueFor("tick_rate")
		self.damage = self:GetTalentSpecialValueFor("damage") * tick_rate
	end
end

function modifier_ember_chains:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetParent()
		local ability = self:GetAbility()

		ability:DealDamage(caster, target, self.damage, {}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE)
	end
end

function modifier_ember_chains:CheckState()
	local state = { [MODIFIER_STATE_ROOTED] = true,
					[MODIFIER_STATE_INVISIBLE] = false}
	return state
end

function modifier_ember_chains:GetEffectName()
	return "particles/units/heroes/hero_ember_spirit/ember_spirit_searing_chains_debuff.vpcf"
end

function modifier_ember_chains:IsDebuff()
	return true
end

modifier_ember_chains_slow = class({})

function modifier_ember_chains_slow:OnCreated(table)
	self.slow = self:GetCaster():FindTalentValue("special_bonus_unique_ember_chains_2", "slow")
	
	if IsServer() then
		local tick_rate = self:GetTalentSpecialValueFor("tick_rate")
		self.damage = self:GetTalentSpecialValueFor("damage") * tick_rate

		self:StartIntervalThink(tick_rate)
	end
end

function modifier_ember_chains_slow:OnRefresh(table)
	self.slow = self:GetCaster():FindTalentValue("special_bonus_unique_ember_chains_2", "slow")
	
	if IsServer() then
		local tick_rate = self:GetTalentSpecialValueFor("tick_rate")
		self.damage = self:GetTalentSpecialValueFor("damage") * tick_rate
	end
end

function modifier_ember_chains_slow:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetParent()
		local ability = self:GetAbility()

		ability:DealDamage(caster, target, self.damage, {}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE)
	end
end

function modifier_ember_chains_slow:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
    return funcs
end

function modifier_ember_chains_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_ember_chains_slow:GetEffectName()
	return "particles/units/heroes/hero_ember_spirit/ember_spirit_searing_chains_debuff.vpcf"
end

function modifier_ember_chains_slow:IsDebuff()
	return true
end