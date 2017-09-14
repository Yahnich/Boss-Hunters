ifrit_solar_jet = class({})

LinkLuaModifier( "modifier_ifrit_solar_jet_thinker", "heroes/ifrit/ifrit_solar_jet.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ifrit_solar_jet_fire_debuff", "heroes/ifrit/ifrit_solar_jet.lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function ifrit_solar_jet:GetAOERadius()
	return self:GetTalentSpecialValueFor( "area_of_effect" )
end

function ifrit_solar_jet:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_ifrit_kindled_soul_active") then
		return "custom/ifrit_solar_jet_kindled"
	else
		return "custom/ifrit_solar_jet"
	end
end

--------------------------------------------------------------------------------

function ifrit_solar_jet:OnSpellStart()
	self.area_of_effect = self:GetTalentSpecialValueFor( "area_of_effect" )
	self.delay_time = self:GetTalentSpecialValueFor( "delay_time" )
	
	local position = self:GetCursorPosition()
	local caster = self:GetCaster()
	self:CreateSolarJet(position)
	EmitSoundOnLocationForAllies( position, "Ability.PreLightStrikeArray", self:GetCaster() )
	if caster:HasModifier("modifier_ifrit_kindled_soul_active") then
		local strike_count = self:GetTalentSpecialValueFor( "kindled_count" )
		local delay = self.delay_time/strike_count
		Timers:CreateTimer(delay, function()
			self:UseResources(true, false, false)
			self:CreateSolarJet(position + RandomVector(self:GetTalentSpecialValueFor( "kindled_offset" )))
			strike_count = strike_count - 1
			if strike_count > 0 then return delay end
		end)
	end
end



function ifrit_solar_jet:CreateSolarJet(position)
	local caster = self:GetCaster()
	local vDirX = RandomVector(1):Normalized()
	local vDirY = Vector(vDirX.y, -vDirX.x)
	CreateModifierThinker( caster, self, "modifier_ifrit_solar_jet_thinker", {}, position, caster:GetTeamNumber(), false )
	if caster:HasTalent("ifrit_solar_jet_talent_1") then
		for i = 1, 2 do
			local newXPos = position + vDirX * self.area_of_effect * 1.25 * (-1)^i
			local newYPos = position + vDirY * self.area_of_effect * 1.25 * (-1)^i
			CreateModifierThinker( caster, self, "modifier_ifrit_solar_jet_thinker", {}, newXPos, caster:GetTeamNumber(), false )
			CreateModifierThinker( caster, self, "modifier_ifrit_solar_jet_thinker", {}, newYPos, caster:GetTeamNumber(), false )
		end
	end
end

modifier_ifrit_solar_jet_thinker = class({})

--------------------------------------------------------------------------------

function modifier_ifrit_solar_jet_thinker:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_ifrit_solar_jet_thinker:OnCreated( kv )
	self.area_of_effect = self:GetAbility():GetTalentSpecialValueFor( "area_of_effect" )
	self.damage = self:GetAbility():GetTalentSpecialValueFor( "damage" )
	self.stun_duration = self:GetAbility():GetTalentSpecialValueFor( "stun_duration" )
	self.delay_time = self:GetAbility():GetTalentSpecialValueFor( "delay_time" )
	self.dot_duration = self:GetAbility():GetTalentSpecialValueFor( "dot_duration" )
	if IsServer() then
		self:StartIntervalThink( self.delay_time )
		
		local nFXIndex = ParticleManager:CreateParticleForTeam( "particles/units/heroes/hero_lina/lina_spell_light_strike_array_ray_team.vpcf", PATTACH_WORLDORIGIN, self:GetCaster(), self:GetCaster():GetTeamNumber() )
		ParticleManager:SetParticleControl( nFXIndex, 0, self:GetParent():GetOrigin() )
		ParticleManager:SetParticleControl( nFXIndex, 1, Vector( self.area_of_effect, 1, 1 ) )
		ParticleManager:ReleaseParticleIndex( nFXIndex )
	end
end

--------------------------------------------------------------------------------

function modifier_ifrit_solar_jet_thinker:OnIntervalThink()
	if IsServer() then
		GridNav:DestroyTreesAroundPoint( self:GetParent():GetOrigin(), self.area_of_effect, false )
		local enemies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), self:GetParent(), self.area_of_effect, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
		if #enemies > 0 then
			for _,enemy in pairs(enemies) do
				if enemy ~= nil and ( not enemy:IsMagicImmune() ) and ( not enemy:IsInvulnerable() ) then
					self:GetCaster().selfImmolationDamageBonus = self:GetCaster().selfImmolationDamageBonus or 0
					ApplyDamage( {victim = enemy, attacker = self:GetCaster(), damage = self.damage + self:GetCaster().selfImmolationDamageBonus, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()} )
					enemy:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_stunned_generic", { duration = self.stun_duration } )
					enemy:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_ifrit_solar_jet_fire_debuff", { duration = self.dot_duration } )
				end
			end
		end

		local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf", PATTACH_WORLDORIGIN, nil )
		ParticleManager:SetParticleControl( nFXIndex, 0, self:GetParent():GetOrigin() )
		ParticleManager:SetParticleControl( nFXIndex, 1, Vector( self.area_of_effect, 1, 1 ) )
		ParticleManager:ReleaseParticleIndex( nFXIndex )

		EmitSoundOnLocationWithCaster( self:GetParent():GetOrigin(), "Ability.LightStrikeArray", self:GetCaster() )

		UTIL_Remove( self:GetParent() )
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


modifier_ifrit_solar_jet_fire_debuff = class({})

function modifier_ifrit_solar_jet_fire_debuff:OnCreated()
	self.damage_over_time = self:GetAbility():GetTalentSpecialValueFor("damage_over_time")
	self.tick_interval = 1
	if self:GetCaster():HasScepter() then self.damage_over_time = self.damage_over_time * 2 end
	if IsServer() then self:StartIntervalThink(self.tick_interval) end
end

function modifier_ifrit_solar_jet_fire_debuff:OnRefresh()
	self.damage_over_time = self:GetAbility():GetTalentSpecialValueFor("damage_over_time")
	if self:GetCaster():HasScepter() then self.damage_over_time = self.damage_over_time * 2 end
end

function modifier_ifrit_solar_jet_fire_debuff:OnIntervalThink()
	ApplyDamage( {victim = self:GetParent(), attacker = self:GetCaster(), damage = self.damage_over_time, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()} )
end

--------------------------------------------------------------------------------

function modifier_ifrit_solar_jet_fire_debuff:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_ifrit_solar_jet_fire_debuff:GetEffectName()
	return "particles/units/heroes/hero_jakiro/jakiro_liquid_fire_debuff.vpcf"
end


function modifier_ifrit_solar_jet_fire_debuff:IsFireDebuff()
	return true
end