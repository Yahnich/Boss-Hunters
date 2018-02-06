doom_apocalypse = class({})

LinkLuaModifier( "modifier_doom_apocalypse", "heroes/hero_doom/doom_apocalypse.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_doom_apocalypse_talent", "heroes/hero_doom/doom_apocalypse.lua" ,LUA_MODIFIER_MOTION_NONE )

function doom_apocalypse:GetBehavior()
	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_DIRECTIONAL
	else
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
	end
end

function doom_apocalypse:OnSpellStart()
	self.doomDamage = self:GetTalentSpecialValueFor( "damage" )
	self.doomDuration = self:GetTalentSpecialValueFor("duration")
	local doomModifier = "modifier_doom_apocalypse"
	if self:GetCaster():HasTalent("special_bonus_unique_doom_apocalypse_2") then doomModifier = "modifier_doom_apocalypse_talent" end
	local hTarget = self:GetCursorTarget()
	EmitSoundOn( "Hero_DoomBringer.LvlDeath", self:GetCaster())
	if self:GetCaster():HasScepter() then
		EmitSoundOn( "Hero_Nevermore.Shadowraze", self:GetCaster())
		if hTarget == nil or ( hTarget ~= nil and ( not hTarget:TriggerSpellAbsorb( self ) ) ) then
			local vTargetPosition = nil
			if hTarget ~= nil then 
				vTargetPosition = hTarget:GetOrigin()
			else
				vTargetPosition = self:GetCursorPosition()
			end
			local direction = CalculateDirection( vTargetPosition, self:GetCaster() )
			local location = self:GetCaster():GetAbsOrigin() + direction * 150
			local strikes = math.floor(self:GetTrueCastRange() / 150)
			for i=1, strikes,1 do
                self:ApplyAOE({particles = "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze.vpcf",
							   location = GetGroundPosition(location, self:GetCaster()),
							   radius = 250,
							   damage = self.doomDamage,
							   damage_type = self:GetAbilityDamageType(), 
							   modifier = doomModifier, 
							   duration = self.doomDuration,
							   magic_immune = true})
                location = location + direction * 150
            end
		end
	else
		hTarget:AddNewModifier( self:GetCaster(), self, doomModifier, { duration = self.doomDuration } )
	end
end

function doom_apocalypse:GetCastRange( hTarget, vLocation )
	if self:GetCaster():HasScepter() then
		return 1000
	else
		return 550
	end
end

modifier_doom_apocalypse = class({})

--------------------------------------------------------------------------------

function modifier_doom_apocalypse:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_doom_apocalypse:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function modifier_doom_apocalypse:OnCreated( kv )
	self.duration = self:GetAbility():GetSpecialValueFor( "duration" )
	EmitSoundOn( "Hero_DoomBringer.Doom", self:GetParent())
	if IsServer() then
		self.damage = self:GetAbility():GetTalentSpecialValueFor( "damage" )
		self:OnIntervalThink()
		self:StartIntervalThink( 1 )
	end
end

function modifier_doom_apocalypse:GetEffectName()
	return "particles/units/heroes/hero_doom_bringer/doom_bringer_doom.vpcf"
end

function modifier_doom_apocalypse:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end


function modifier_doom_apocalypse:GetStatusEffectName()
	return "particles/status_fx/status_effect_doom.vpcf" 	   
end

--------------------------------------------------------------------------------

function modifier_doom_apocalypse:OnDestroy()
	StopSoundOn("Hero_DoomBringer.Doom", self:GetParent())
end

function modifier_doom_apocalypse:RemoveOnDeath()
	return true
end


--------------------------------------------------------------------------------

function modifier_doom_apocalypse:OnIntervalThink()
	if IsServer() then
		ApplyDamage({ victim = self:GetParent(), attacker = self:GetCaster(), damage = self.damage, damage_type = self:GetAbility():GetAbilityDamageType(), ability = self:GetAbility() })
		if not self:GetParent():IsAlive() then
			StopSoundOn("Hero_DoomBringer.Doom", self:GetParent())
		end
	end
end

function modifier_doom_apocalypse:CheckState()
	local state = {
		[MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_PASSIVES_DISABLED] = true,
	}

	return state
end

modifier_doom_apocalypse_talent = class(modifier_doom_apocalypse)

function modifier_doom_apocalypse_talent:CheckState()
	local state = {
		[MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_PASSIVES_DISABLED] = true,
		[MODIFIER_STATE_DISARMED] = true,
	}

	return state
end