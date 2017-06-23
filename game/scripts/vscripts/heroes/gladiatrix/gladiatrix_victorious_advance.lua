gladiatrix_victorious_advance = class({})

function gladiatrix_victorious_advance:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function gladiatrix_victorious_advance:OnAbilityPhaseStart()
	if IsServer() then
		self.cast2 = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_odds_cast.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self:GetCaster())
			ParticleManager:SetParticleControlEnt(self.cast2, 1, self:GetCaster(), PATTACH_CUSTOMORIGIN_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
		self.cast = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_odds_cast.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self:GetCaster())
			ParticleManager:SetParticleControlEnt(self.cast, 1, self:GetCaster(), PATTACH_CUSTOMORIGIN_FOLLOW, "attach_attack2", self:GetCaster():GetAbsOrigin(), true)
	end
	EmitSoundOn("Hero_LegionCommander.Overwhelming.Cast",self:GetCaster())
	return true
end

function gladiatrix_victorious_advance:OnAbilityPhaseInterrupted()
	if IsServer() then
		ParticleManager:DestroyParticle(self.cast, false)
		ParticleManager:ReleaseParticleIndex(self.cast)
		ParticleManager:DestroyParticle(self.cast2, false)
		ParticleManager:ReleaseParticleIndex(self.cast2)
	end
end

function gladiatrix_victorious_advance:OnSpellStart()
	if IsServer() then
		ParticleManager:DestroyParticle(self.cast, false)
		ParticleManager:ReleaseParticleIndex(self.cast)
		ParticleManager:DestroyParticle(self.cast2, false)
		ParticleManager:ReleaseParticleIndex(self.cast2)
		local caster = self:GetCaster()
		local target = self:GetCursorPosition()
		EmitSoundOn("Hero_LegionCommander.Overwhelming.Location",self:GetCaster())
		local radius = self:GetSpecialValueFor("radius")
		local base_damage = self:GetSpecialValueFor("damage")
		local bonus_damage = self:GetSpecialValueFor("damage_per_unit")
		local duration = self:GetTalentSpecialValueFor("duration")
		local arrows = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_odds.vpcf", PATTACH_ABSORIGIN , caster)
				ParticleManager:SetParticleControl(arrows, 0, target)
				ParticleManager:SetParticleControl(arrows, 1, target)
				ParticleManager:SetParticleControl(arrows, 3, target)
				ParticleManager:SetParticleControl(arrows, 4, Vector(radius,0,0) )
				ParticleManager:SetParticleControl(arrows, 5, Vector(radius,0,0) )
				ParticleManager:SetParticleControl(arrows, 6, target)
				ParticleManager:SetParticleControl(arrows, 7, target)
				ParticleManager:SetParticleControl(arrows, 8, target)
		ParticleManager:ReleaseParticleIndex(arrows)
		local units = FindUnitsInRadius(caster:GetTeam(), target, nil, radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, 0, false)
		local damageToApply = 0
		local stacks = 1
		for _,unit in pairs(units) do -- check units
			if ((unit:IsHero() and unit:GetTeam() == caster:GetTeam()) or unit:GetTeam() ~= caster:GetTeam()) and unit ~= self:GetCaster() then
				damageToApply = damageToApply + bonus_damage
				stacks = stacks + 1
			end
		end
		for _,unit in pairs(units) do -- deal damage
			if unit:GetTeam() ~= caster:GetTeam() then
				ApplyDamage({victim = unit, attacker = caster, damage = damageToApply, damage_type = self:GetAbilityDamageType(), ability = self})
				EmitSoundOn("Hero_LegionCommander.Overwhelming.Creep",unit)
			else
				-- unit:AddNewModifier(caster, self, "modifier_gladiatrix_victorious_advance_buff_visual", {duration = duration})
				unit:AddNewModifier(caster, self, "modifier_gladiatrix_victorious_advance_buff_stacks", {duration = duration})
				unit:SetModifierStackCount("modifier_gladiatrix_victorious_advance_buff_stacks", caster, stacks)
				EmitSoundOn("Hero_LegionCommander.Overwhelming.Hero",unit)
			end
		end
		caster:AddNewModifier(caster, self, "modifier_gladiatrix_victorious_advance_buff_stacks", {duration = duration})
		caster:SetModifierStackCount("modifier_gladiatrix_victorious_advance_buff_stacks", caster, stacks)
	end
end

LinkLuaModifier( "modifier_gladiatrix_victorious_advance_buff_stacks", "heroes/gladiatrix/gladiatrix_victorious_advance.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_gladiatrix_victorious_advance_buff_stacks = class({})

function modifier_gladiatrix_victorious_advance_buff_stacks:OnCreated()
	self.armor_bonus = self:GetAbility():GetSpecialValueFor("bonus_armor")
	self.speed_bonus = self:GetAbility():GetSpecialValueFor("bonus_speed")
	if IsServer() then
		EmitSoundOn("Hero_LegionCommander.Overwhelming.Buff",self:GetParent())
	end
end

function modifier_gladiatrix_victorious_advance_buff_stacks:GetEffectName()
	return "particles/units/heroes/hero_legion_commander/legion_commander_odds_buff.vpcf"
end

function modifier_gladiatrix_victorious_advance_buff_stacks:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			}
	return funcs
end

function modifier_gladiatrix_victorious_advance_buff_stacks:GetModifierMoveSpeedBonus_Percentage()
	return self.speed_bonus * self:GetStackCount()
end

function modifier_gladiatrix_victorious_advance_buff_stacks:GetModifierPhysicalArmorBonus()
	return self.armor_bonus * self:GetStackCount()
end