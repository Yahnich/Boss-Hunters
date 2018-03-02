legion_commander_victorious_advance = class({})

function legion_commander_victorious_advance:GetAOERadius()
	return self:GetTalentSpecialValueFor("radius")
end

function legion_commander_victorious_advance:OnAbilityPhaseStart()
	if IsServer() then
		self.cast2 = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_odds_cast.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self:GetCaster())
			ParticleManager:SetParticleControlEnt(self.cast2, 1, self:GetCaster(), PATTACH_CUSTOMORIGIN_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
		self.cast = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_odds_cast.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self:GetCaster())
			ParticleManager:SetParticleControlEnt(self.cast, 1, self:GetCaster(), PATTACH_CUSTOMORIGIN_FOLLOW, "attach_attack2", self:GetCaster():GetAbsOrigin(), true)
	end
	EmitSoundOn("Hero_LegionCommander.Overwhelming.Cast",self:GetCaster())
	return true
end

function legion_commander_victorious_advance:OnAbilityPhaseInterrupted()
	if IsServer() then
		ParticleManager:ClearParticle(self.cast)
		ParticleManager:ClearParticle(self.cast2)
	end
end

function legion_commander_victorious_advance:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorPosition()
		EmitSoundOn("Hero_LegionCommander.Overwhelming.Location",self:GetCaster())
		local radius = self:GetTalentSpecialValueFor("radius")
		local base_damage = self:GetTalentSpecialValueFor("damage")
		local bonus_damage = self:GetTalentSpecialValueFor("damage_per_unit")
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
		local stacks = 1
		for _,unit in pairs(units) do -- check units
			if ((unit:IsHero() and unit:GetTeam() == caster:GetTeam()) or unit:GetTeam() ~= caster:GetTeam()) and unit ~= self:GetCaster() then
				base_damage = base_damage + bonus_damage
				stacks = stacks + 1
			end
		end
		for _,unit in pairs(units) do -- deal damage
			if unit:GetTeam() ~= caster:GetTeam() then
				ApplyDamage({victim = unit, attacker = caster, damage = base_damage, damage_type = self:GetAbilityDamageType(), ability = self})
				EmitSoundOn("Hero_LegionCommander.Overwhelming.Creep",unit)
			else
				-- unit:AddNewModifier(caster, self, "modifier_legion_commander_victorious_advance_buff_visual", {duration = duration})
				unit:AddNewModifier(caster, self, "modifier_legion_commander_victorious_advance_buff_stacks", {duration = duration})
				unit:SetModifierStackCount("modifier_legion_commander_victorious_advance_buff_stacks", caster, stacks)
				EmitSoundOn("Hero_LegionCommander.Overwhelming.Hero",unit)
			end
		end
		caster:AddNewModifier(caster, self, "modifier_legion_commander_victorious_advance_buff_stacks", {duration = duration})
		caster:SetModifierStackCount("modifier_legion_commander_victorious_advance_buff_stacks", caster, stacks)
		
		ParticleManager:ClearParticle(self.cast)
		ParticleManager:ClearParticle(self.cast2)
	end
end

LinkLuaModifier( "modifier_legion_commander_victorious_advance_buff_stacks", "heroes/hero_legion_commander/legion_commander_victorious_advance" ,LUA_MODIFIER_MOTION_NONE )
modifier_legion_commander_victorious_advance_buff_stacks = class({})

function modifier_legion_commander_victorious_advance_buff_stacks:OnCreated()
	self.armor_bonus = self:GetAbility():GetTalentSpecialValueFor("bonus_armor")
	self.speed_bonus = self:GetAbility():GetTalentSpecialValueFor("bonus_speed")
	if IsServer() then
		EmitSoundOn("Hero_LegionCommander.Overwhelming.Buff",self:GetParent())
	end
end

function modifier_legion_commander_victorious_advance_buff_stacks:GetEffectName()
	return "particles/units/heroes/hero_legion_commander/legion_commander_odds_buff.vpcf"
end

function modifier_legion_commander_victorious_advance_buff_stacks:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			}
	return funcs
end

function modifier_legion_commander_victorious_advance_buff_stacks:GetModifierMoveSpeedBonus_Percentage()
	return self.speed_bonus * self:GetStackCount()
end

function modifier_legion_commander_victorious_advance_buff_stacks:GetModifierPhysicalArmorBonus()
	return self.armor_bonus * self:GetStackCount()
end