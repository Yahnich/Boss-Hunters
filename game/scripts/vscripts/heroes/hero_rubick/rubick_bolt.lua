rubick_bolt = class({})
LinkLuaModifier("modifier_rubick_bolt", "heroes/hero_rubick/rubick_bolt", LUA_MODIFIER_MOTION_NONE)

function rubick_bolt:IsStealable()
    return false
end

function rubick_bolt:IsHiddenWhenStolen()
    return false
end

function rubick_bolt:OnSpellStart()
	local caster = self:GetCaster()
	local previous_unit = self:GetCaster()
	local current_target = self:GetCursorTarget()

	local entities_damaged = {}

	local damage = self:GetTalentSpecialValueFor("damage")
	local radius = self:GetTalentSpecialValueFor("radius")
	local damage_reduc = self:GetTalentSpecialValueFor("damage_reduc")
	local jump_delay = self:GetTalentSpecialValueFor("jump_delay")
	local duration = self:GetTalentSpecialValueFor("duration")

	EmitSoundOn("Hero_Rubick.FadeBolt.Cast", self:GetCaster())

	-- Start bouncing with bounce delay
	Timers:CreateTimer(function()
		-- add entity in a table to not hit it twice!
		table.insert(entities_damaged, current_target)

		local enemies = caster:FindEnemyUnitsInRadius(current_target:GetAbsOrigin(), radius, {})

		-- if this jump is below the first one, increase damage
		if previous_unit ~= caster then
			local damage_increase = damage_reduc * (damage / 100)

			if caster:HasTalent("special_bonus_unique_rubick_bolt_2") then
				damage = damage + damage_increase
			else
				damage = damage - damage_increase
			end
		end

		if damage < self:GetTalentSpecialValueFor("damage")/10 then
			damage = self:GetTalentSpecialValueFor("damage")/10
		end

		-- play Fade Bolt particle
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_rubick/rubick_fade_bolt.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, current_target, PATTACH_POINT_FOLLOW, "attach_hitloc", current_target:GetAbsOrigin(), true)
					if previous_unit == caster then
						ParticleManager:SetParticleControlEnt(nfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_attack3", current_target:GetAbsOrigin(), true)
					else
						ParticleManager:SetParticleControlEnt(nfx, 1, previous_unit, PATTACH_POINT_FOLLOW, "attach_hitloc", previous_unit:GetAbsOrigin(), true)
					end

					ParticleManager:ReleaseParticleIndex(nfx)

		-- Play cast sound
		EmitSoundOn("Hero_Rubick.FadeBolt.Target", current_target)

		current_target.damaged_by_fade_bolt = true

		-- keep the last hero hit to play the particle for the next bounce
		previous_unit = current_target
		if not current_target:TriggerSpellAbsorb( self ) then
			current_target:AddNewModifier(caster, self, "modifier_rubick_bolt", {Duration = duration})
			self:DealDamage(caster, current_target, damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
		end
		-- Search for a unit
		for _, enemy in pairs(enemies) do
			if enemy ~= previous_unit and enemy.damaged_by_fade_bolt ~= true then
				-- update the new target
				current_target = enemy
				break
			end
		end

		-- If a new target was found, wait and jump again
		if previous_unit ~= current_target then
			return jump_delay
		else
			-- reset fade bolt hit counter
			for _, damaged in pairs(entities_damaged) do
				damaged.damaged_by_fade_bolt = false
			end

			return nil
		end
	end)
end

modifier_rubick_bolt = class({})
function modifier_rubick_bolt:OnCreated(table)
	if self:GetCaster():HasTalent("special_bonus_unique_rubick_bolt_1") then
		self.attribute = MODIFIER_ATTRIBUTE_MULTIPLE
	else
		self.attribute = MODIFIER_ATTRIBUTE_NONE
	end

	self.damage_reduc = self:GetTalentSpecialValueFor("damage_reduc")
end

function modifier_rubick_bolt:OnRefresh(table)
	if self:GetCaster():HasTalent("special_bonus_unique_rubick_bolt_1") then
		self.attribute = MODIFIER_ATTRIBUTE_MULTIPLE
	else
		self.attribute = MODIFIER_ATTRIBUTE_NONE
	end

	self.damage_reduc = self:GetTalentSpecialValueFor("damage_reduc")
end

function modifier_rubick_bolt:DeclareFunctions()
	local funcs = {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
	return funcs
end

function modifier_rubick_bolt:GetModifierPreAttack_BonusDamage()
	return -self.damage_reduc
end

function modifier_rubick_bolt:GetEffectName()
	return "particles/units/heroes/hero_rubick/rubick_fade_bolt_debuff.vpcf"
end

function modifier_rubick_bolt:IsDebuff()
	return true
end

function modifier_rubick_bolt:IsPurgable()
	return true
end

function modifier_rubick_bolt:GetAttributes()
	return self.attribute
end