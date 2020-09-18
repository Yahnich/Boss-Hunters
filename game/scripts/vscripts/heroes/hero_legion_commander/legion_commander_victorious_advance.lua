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
		local bonus_damage_minion = self:GetTalentSpecialValueFor("damage_per_minion")
		local base_movespeed = 0
		local movespeed = self:GetTalentSpecialValueFor("bonus_speed")
		local movespeed_minion = self:GetTalentSpecialValueFor("bonus_speed_minion")
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
		local talent2 = caster:HasTalent("special_bonus_unique_legion_commander_victorious_advance_2")
		local units = FindUnitsInRadius(caster:GetTeam(), target, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, 0, false)
		local stacks = 1
		for _,unit in pairs(units) do -- check units
			if unit:IsMinion() then
				base_damage = base_damage + bonus_damage_minion
				base_movespeed = base_movespeed + movespeed_minion
			else
				base_damage = base_damage + bonus_damage
				base_movespeed = base_movespeed + movespeed
			end
		end
		for _,unit in pairs(units) do -- deal damage
			if unit:GetTeam() ~= caster:GetTeam() then
				if not unit:TriggerSpellAbsorb( self ) then
					ApplyDamage({victim = unit, attacker = caster, damage = base_damage, damage_type = self:GetAbilityDamageType(), ability = self})
					if talent2 then
						unit:AddNewModifier(caster, self, "modifier_legion_commander_victorious_advance_debuff", {duration = duration})
					end
				end
				EmitSoundOn("Hero_LegionCommander.Overwhelming.Creep",unit)
			end
		end
		caster:AddNewModifier(caster, self, "modifier_legion_commander_victorious_advance_buff_stacks", {duration = duration, movespeed = base_movespeed})
		EmitSoundOn("Hero_LegionCommander.Overwhelming.Hero",caster)
		
		ParticleManager:ClearParticle(self.cast)
		ParticleManager:ClearParticle(self.cast2)
	end
end

LinkLuaModifier( "modifier_legion_commander_victorious_advance_debuff", "heroes/hero_legion_commander/legion_commander_victorious_advance" ,LUA_MODIFIER_MOTION_NONE )
modifier_legion_commander_victorious_advance_debuff = class({})

function modifier_legion_commander_victorious_advance_debuff:OnCreated()
	self:OnRefresh()
end

function modifier_legion_commander_victorious_advance_debuff:OnRefresh()
	self.as = self:GetCaster():FindTalentValue("special_bonus_unique_legion_commander_victorious_advance_2", "value")
	self.ms = self:GetCaster():FindTalentValue("special_bonus_unique_legion_commander_victorious_advance_2", "value2")
end

function modifier_legion_commander_victorious_advance_debuff:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
				MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT 
			}
	return funcs
end

function modifier_legion_commander_victorious_advance_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

function modifier_legion_commander_victorious_advance_debuff:GetModifierAttackSpeedBonus_Constant()
	return self.as
end

LinkLuaModifier( "modifier_legion_commander_victorious_advance_buff_stacks", "heroes/hero_legion_commander/legion_commander_victorious_advance" ,LUA_MODIFIER_MOTION_NONE )
modifier_legion_commander_victorious_advance_buff_stacks = class({})

function modifier_legion_commander_victorious_advance_buff_stacks:OnCreated(kv)
	self.movespeed = kv.movespeed
	if IsServer() then
		EmitSoundOn("Hero_LegionCommander.Overwhelming.Buff",self:GetParent())
		self:SetHasCustomTransmitterData( true )
	end
end

function modifier_legion_commander_victorious_advance_buff_stacks:OnRefresh(kv)
	self.movespeed = kv.movespeed
	if IsServer() then
		EmitSoundOn("Hero_LegionCommander.Overwhelming.Buff",self:GetParent())
		self:SetHasCustomTransmitterData( true )
	end
end

function modifier_legion_commander_victorious_advance_buff_stacks:GetEffectName()
	return "particles/units/heroes/hero_legion_commander/legion_commander_odds_buff.vpcf"
end

function modifier_legion_commander_victorious_advance_buff_stacks:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			}
	return funcs
end

function modifier_legion_commander_victorious_advance_buff_stacks:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed
end


function modifier_legion_commander_victorious_advance_buff_stacks:AddCustomTransmitterData( )
	return
	{
		movespeed = self.movespeed
	}
end

--------------------------------------------------------------------------------

function modifier_legion_commander_victorious_advance_buff_stacks:HandleCustomTransmitterData( data )
	self.movespeed = data.movespeed
end