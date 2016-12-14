pudge_dismember_lua = class({})
LinkLuaModifier( "pudge_dismember", "lua_abilities/heroes/modifiers/pudge_dismember.lua" ,LUA_MODIFIER_MOTION_NONE )

--[[Author: Valve
	Date: 26.09.2015.]]
--------------------------------------------------------------------------------

function pudge_dismember_lua:GetConceptRecipientType()
	return DOTA_SPEECH_USER_ALL
end

--------------------------------------------------------------------------------

function pudge_dismember_lua:SpeakTrigger()
	return DOTA_ABILITY_SPEAK_CAST
end

--------------------------------------------------------------------------------

function pudge_dismember_lua:GetChannelTime()
	self.duration = self:GetTalentSpecialValueFor( "duration" )

	if IsServer() then
		if self.hVictim ~= nil then
			return self.duration
		end

		return 0.0
	end

	return self.duration
end

--------------------------------------------------------------------------------

function pudge_dismember_lua:OnAbilityPhaseStart()
	if IsServer() then
		self.hVictim = self:GetCursorTarget()
	end

	return true
end

--------------------------------------------------------------------------------

function pudge_dismember_lua:OnSpellStart()
	if self.hVictim == nil then
		return
	end

	if self.hVictim:TriggerSpellAbsorb( self ) then
		self.hVictim = nil
		self:GetCaster():Interrupt()
	else
		self.hVictim:AddNewModifier( self:GetCaster(), self,  "pudge_dismember", { duration = self.duration} )
		self.hVictim:Interrupt()
	end
end


--------------------------------------------------------------------------------

function pudge_dismember_lua:OnChannelFinish( bInterrupted )
	if self.hVictim ~= nil then
		self.hVictim:RemoveModifierByName("pudge_dismember" )
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

pudge_rot_lua = class({})
LinkLuaModifier( "modifier_rot_lua", "lua_abilities/heroes/modifiers/modifier_rot_lua.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_rot_death_lua", "lua_abilities/heroes/pudge.lua" ,LUA_MODIFIER_MOTION_NONE )

--[[Author: Valve
	Date: 26.09.2015.
	Applies the rot modifier on the caster depending on the toggle state]]
--------------------------------------------------------------------------------

function pudge_rot_lua:ProcsMagicStick()
	return false
end

--------------------------------------------------------------------------------

function pudge_rot_lua:GetIntrinsicModifierName()
	return	"modifier_rot_death_lua"
end

function pudge_rot_lua:OnHeroLevelUp()
	if not self:GetCaster():HasModifier("modifier_rot_death_lua") then
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_rot_death_lua", nil )
	end
end

--------------------------------------------------------------------------------

function pudge_rot_lua:OnToggle()
	-- Apply the rot modifier if the toggle is on
	if self:GetToggleState() then
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_rot_lua", nil )

		if not self:GetCaster():IsChanneling() then
			self:GetCaster():StartGesture( ACT_DOTA_CAST_ABILITY_ROT )
		end
	else
		-- Remove it if it is off
		local hRotBuff = self:GetCaster():FindModifierByName( "modifier_rot_lua" )
		if hRotBuff ~= nil then
			hRotBuff:Destroy()
		end
	end
end

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_rot_death_lua				
--------------------------------------------------------------------------------------------------------
if modifier_rot_death_lua == nil then modifier_rot_death_lua = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_rot_death_lua:IsPassive()
	return true
end

--------------------------------------------------------------------------------------------------------
function modifier_rot_death_lua:IsHidden()
	if self:GetAbility():GetLevel() == 0 then
		return true
	else return false end
end

function modifier_rot_death_lua:IsAura()
	if self:GetCaster():IsRealHero() then
		return true
	else return false end
end

function modifier_rot_death_lua:RemoveOnDeath()
	return false
end

function modifier_rot_death_lua:GetModifierAura()
	return "modifier_rot_death_lua_aura"
end

function modifier_rot_death_lua:GetAuraRadius()
	return 9999
end

function modifier_rot_death_lua:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS
end

function modifier_rot_death_lua:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_rot_death_lua:GetAuraSearchType()
	return DOTA_UNIT_TARGET_ALL
end

--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

LinkLuaModifier( "modifier_rot_death_lua_aura", "lua_abilities/heroes/pudge.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
--		Aura Modifier: modifier_rot_death_lua_aura		
--------------------------------------------------------------------------------------------------------
if modifier_rot_death_lua_aura == nil then modifier_rot_death_lua_aura = class({}) end

function modifier_rot_death_lua_aura:IsHidden()
	return true
end

function modifier_rot_death_lua_aura:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_DEATH,
  }
  return funcs
end

function modifier_rot_death_lua_aura:OnDeath(params)
	if IsServer() and params.unit:HasModifier("modifier_rot_death_lua_aura") and params.unit.Holdout_IsCore and not params.unit.triggered then
		local modifier = self:GetCaster():FindModifierByName("modifier_rot_death_lua")
		modifier:SetStackCount(modifier:GetStackCount() +1)
		params.unit.triggered = true
		print(modifier:GetStackCount())
	end
end