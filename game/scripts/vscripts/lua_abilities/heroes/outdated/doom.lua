function Devour_doom(keys)
    local modifierName = "iseating"
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local level = ability:GetLevel()-1
    local gold = ability:GetTalentSpecialValueFor("total_gold")
	if caster:HasTalent("special_bonus_unique_doom_2") then 
		gold = gold * caster:FindTalentValue("special_bonus_unique_doom_2")
	end
    local duration = ability:GetTalentSpecialValueFor("duration")
	
	local death = ability:GetTalentSpecialValueFor("death_perc")
    local kill_rand = math.random(100)
	local boss_curr = target:GetHealth()
	local boss_max = target:GetMaxHealth()
	local boss_perc = (boss_curr/boss_max)*100
	local mod_perc = death*(death/boss_perc) -- Scale chance up as HP goes down

    ability:ApplyDataDrivenModifier( caster, caster, modifierName, {duration = duration})
    target:SetModifierStackCount( modifierName, ability, 1)
    ability:StartCooldown(duration)
    local total_unit = 0
    for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
        if not unit:IsIllusion() then
            total_unit = total_unit + 1
        end
    end
    local gold_per_player = gold / total_unit
    for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
        if not unit:IsIllusion() then
            local totalgold = unit:GetGold() + gold_per_player
            unit:SetGold(0 , false)
            unit:SetGold(totalgold, true)
        end
    end
	if mod_perc >= kill_rand and boss_perc <= death  then
		local damage_table = {}
		damage_table.victim = target
		damage_table.attacker = caster
		damage_table.ability = ability
		damage_table.damage_type = DAMAGE_TYPE_PURE
		damage_table.damage = boss_curr +1
		ApplyDamage(damage_table)
	end
end

function DoomPurge( keys )
	local target = keys.target

	-- Purge
	local RemovePositiveBuffs = true
	local RemoveDebuffs = false
	local BuffsCreatedThisFrameOnly = false
	local RemoveStuns = false
	local RemoveExceptions = false
	target:Purge( RemovePositiveBuffs, RemoveDebuffs, BuffsCreatedThisFrameOnly, RemoveStuns, RemoveExceptions)
end


function DamageTick( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetTalentSpecialValueFor("damage")
	local duration = ability:GetTalentSpecialValueFor("duration")
	if not ability.duration then 
		ability.duration = 0 -- ignore first damage tick
	else
		ability.duration = ability.duration + 1
	end
	ApplyDamage({ victim = target, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType(), ability = ability })
	if ability.duration >= duration then 
		target:RemoveModifierByName("modifier_doom_datadriven")
		ability.duration = nil -- this makes sure the first tick doens't count
	end
end

-- Stops the sound from playing
function StopSound( keys )
	local target = keys.target
	local sound = keys.sound

	StopSoundEvent(sound, target)
end

doom_scorched_earth_ebf = class({})

function doom_scorched_earth_ebf:OnSpellStart()
	if IsServer() then
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_doom_scorched_earth_aura", {duration = self:GetSpecialValueFor("duration")})
		if self:GetCaster():HasTalent("special_bonus_unique_doom_4") and not self:GetCaster():HasModifier("modifier_doom_scorched_earth_talent") then
			self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_doom_scorched_earth_talent", {})
		end
	end
end

LinkLuaModifier( "modifier_doom_scorched_earth_aura", "lua_abilities/heroes/doom.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_doom_scorched_earth_aura = class({})

function modifier_doom_scorched_earth_aura:OnCreated()
	self.aura_radius = self:GetAbility():GetSpecialValueFor("radius")
	if IsServer() then
		EmitSoundOn("Hero_DoomBringer.ScorchedEarthAura", self:GetParent())
		self.FXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_doom_bringer/doom_scorched_earth.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
			ParticleManager:SetParticleControl( self.FXIndex, 1, Vector(self.aura_radius, 0, 0) )
	end
end

function modifier_doom_scorched_earth_aura:OnDestroy()
	if IsServer() then
		StopSoundOn("Hero_DoomBringer.ScorchedEarthAura", self:GetParent())
		ParticleManager:DestroyParticle(self.FXIndex, false)
		ParticleManager:ReleaseParticleIndex(self.FXIndex)
	end
end

--------------------------------------------------------------------------------

function modifier_doom_scorched_earth_aura:IsAura()
	return true
end

--------------------------------------------------------------------------------

function modifier_doom_scorched_earth_aura:GetModifierAura(params)
	if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then
		return "modifier_doom_scorched_earth_buff"
	else
		return "modifier_doom_scorched_earth_debuff"
	end
end

--------------------------------------------------------------------------------

function modifier_doom_scorched_earth_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_BOTH
end

--------------------------------------------------------------------------------

function modifier_doom_scorched_earth_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

--------------------------------------------------------------------------------

function modifier_doom_scorched_earth_aura:GetAuraRadius()
	return self.aura_radius
end

--------------------------------------------------------------------------------
function modifier_doom_scorched_earth_aura:IsPurgable()
    return false
end

LinkLuaModifier( "modifier_doom_scorched_earth_talent", "lua_abilities/heroes/doom.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_doom_scorched_earth_talent = class({})

function modifier_doom_scorched_earth_talent:IsHidden()
	return true
end

function modifier_doom_scorched_earth_talent:RemoveOnDeath()
	return false
end


LinkLuaModifier( "modifier_doom_scorched_earth_buff", "lua_abilities/heroes/doom.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_doom_scorched_earth_buff = class({})

function modifier_doom_scorched_earth_buff:OnCreated()
	self.healthregen = self:GetAbility():GetSpecialValueFor("damage_per_second")
	self.movespeed = self:GetAbility():GetSpecialValueFor("bonus_movement_speed_pct")
	
	if self:GetCaster():HasModifier("modifier_doom_scorched_earth_talent") then
		if IsServer() then
			self.healthregen = self:GetAbility():GetTalentSpecialValueFor("damage_per_second")
			SendClientSync("scorched_earth_talent", self.healthregen)
		else
			self.healthregen = nil
		end
	end
	if self:GetParent():GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
		self.healthregen = 0
		self.movespeed = self.movespeed * -1
		self.damage = self:GetAbility():GetTalentSpecialValueFor("damage_per_second")
		if IsServer() then
			ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = self.damage, damage_type = self:GetAbility():GetAbilityDamageType(), ability = self:GetAbility()})
			self:StartIntervalThink(1)
		end
	end
end

function modifier_doom_scorched_earth_buff:OnIntervalThink()
	ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = self.damage, damage_type = self:GetAbility():GetAbilityDamageType(), ability = self:GetAbility()})
end

function modifier_doom_scorched_earth_buff:IsBuff()
	if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then
		return true
	else
		return false
	end
end

function modifier_doom_scorched_earth_buff:IsHidden()
	if self:GetParent() == self:GetCaster() then
		return true
	else
		return false
	end
end

function modifier_doom_scorched_earth_buff:IsDebuff()
	if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then
		return false
	else
		return true
	end
end

function modifier_doom_scorched_earth_buff:GetEffectName()	
	if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then
		return "particles/units/heroes/hero_doom_bringer/doom_bringer_scorched_earth_buff.vpcf"
	else
		return "particles/units/heroes/hero_doom_bringer/doom_bringer_scorched_earth_debuff.vpcf"
	end
end

function modifier_doom_scorched_earth_buff:OnRefresh()
	self.healthregen = self:GetAbility():GetSpecialValueFor("damage_per_second")
end

function modifier_doom_scorched_earth_buff:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
			}
	return funcs
end

function modifier_doom_scorched_earth_buff:GetModifierConstantHealthRegen()
	if IsServer() and not CustomNetTables:GetTableValue( "syncing_purposes", "scorched_earth_talent") then
		SendClientSync("scorched_earth_talent", self.healthregen)
	end
	self.healthregen = self.healthregen or CustomNetTables:GetTableValue( "syncing_purposes", "scorched_earth_talent").value
	return self.healthregen
end

function modifier_doom_scorched_earth_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed
end