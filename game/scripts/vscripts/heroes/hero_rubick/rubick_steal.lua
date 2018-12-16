-------------------------------------------
--			SPELL STEAL
-------------------------------------------
--Thanks imba 
rubick_steal = rubick_steal or class({})
LinkLuaModifier("rubick_steal", "heroes/hero_rubick/rubick_steal", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_rubick_steal", "heroes/hero_rubick/rubick_steal", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_rubick_spellsteal_hidden", "heroes/hero_rubick/rubick_steal", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_rubick_spellsteal_hidden", "heroes/hero_rubick/rubick_steal", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_rubick_spellsteal_spell_amp", "heroes/hero_rubick/rubick_steal", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_rubick_spellsteal_movespeed", "heroes/hero_rubick/rubick_steal", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
-- Passive Modifier
--------------------------------------------------------------------------------
function rubick_steal:OnHeroCalculateStatBonus()
	if not self:GetCaster():HasModifier("modifier_rubick_spellsteal_hidden") then
		self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_rubick_spellsteal_hidden",	{})
	end
end

--Cooldown, removed with Scepter
function rubick_steal:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
    local caster = self:GetCaster()
    if caster:HasScepter() then cooldown = 0 end
    return cooldown
end

--------------------------------------------------------------------------------
-- Ability Cast Filter
--------------------------------------------------------------------------------
function rubick_steal:CastFilterResultTarget( hTarget )
	if IsServer() then
		if hTarget == self:GetCaster() then
			self.failState = "caster"
			return UF_FAIL_CUSTOM
		end
		if self:GetLastSpell( hTarget ) == nil then
			self.failState = "nevercast"
			return UF_FAIL_CUSTOM
		end
	end

	local nResult = UnitFilter(
		hTarget,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_NONE,
		self:GetCaster():GetTeamNumber()
	)

	if nResult ~= UF_SUCCESS then
		return nResult
	end

	return UF_SUCCESS
end

function rubick_steal:GetCustomCastErrorTarget( hTarget )
	if self.failState then
		local fail = self.failState
		self.failState = nil
		if fail == "nevercast" then
			return "Target never casted an ability"
		elseif fail == "caster" then
			return "Cannot target self"
		end
	end
	
	return ""
end
--------------------------------------------------------------------------------
-- Ability Start
--------------------------------------------------------------------------------

rubick_steal.stolenSpell = nil
function rubick_steal:OnSpellStart()
	-- unit identifier
	self.spell_target = self:GetCursorTarget()

	-- Cancel if blocked
	if self.spell_target:TriggerSpellAbsorb( self ) then
		return
	end

	-- Get last used spell
	self.stolenSpell = {}
	self.stolenSpell.stolenFrom = self:GetLastSpell( self.spell_target ).handle:GetUnitName()
	self.stolenSpell.primarySpell = self:GetLastSpell( self.spell_target ).primarySpell
	self.stolenSpell.secondarySpell = self:GetLastSpell( self.spell_target ).secondarySpell
	-- load data
	local projectile_name = "particles/units/heroes/hero_rubick/rubick_spell_steal.vpcf"
	local projectile_speed = 900

	-- Create Projectile
	local info = {
		Target = self:GetCaster(),
		Source = self.spell_target,
		Ability = self,	
		EffectName = projectile_name,
		iMoveSpeed = projectile_speed,
		vSourceLoc = self.spell_target:GetAbsOrigin(),                -- Optional (HOW)
		bDrawsOnMinimap = false,                          -- Optional
		bDodgeable = false,                                -- Optional
		bVisibleToEnemies = true,                         -- Optional
		bReplaceExisting = false,                         -- Optional
	}
	projectile = ProjectileManager:CreateTrackingProjectile(info)

	-- Play effects
	local sound_cast = "Hero_Rubick.SpellSteal.Cast"
	EmitSoundOn( sound_cast, self:GetCaster() )
	local sound_target = "Hero_Rubick.SpellSteal.Target"
	EmitSoundOn( sound_target, self.spell_target )

	if self:GetCaster():HasTalent("special_bonus_unique_rubick_steal_2") then
		self.spell_target:AddNewModifier(self:GetCaster(), self, "modifier_rubick_spellsteal_movespeed", {Duration = 15})
	end

	-- need to remove it to send the right spell amp stolen with aghanim
	if self:GetCaster():HasModifier("modifier_rubick_steal") then
		self:GetCaster():RemoveModifierByName("modifier_rubick_steal")
	end
end

function rubick_steal:OnProjectileHit( target, location )
	local caster = self:GetCaster()
	-- Add ability
	self:SetStolenSpell( self.stolenSpell )
	self.stolenSpell = nil

	-- Add modifier
	target:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_rubick_steal", -- modifier name
		{} -- kv
	)

	if caster:HasTalent("special_bonus_unique_rubick_steal_1") then
		local spell_amp = self.spell_target:GetSpellAmplification(false)/2 * 100
		target:AddNewModifier(caster, self, "modifier_rubick_spellsteal_spell_amp", {Duration = 10}):SetStackCount(spell_amp)
	end

	local sound_cast = "Hero_Rubick.SpellSteal.Complete"
	EmitSoundOn( sound_cast, target )
end
--------------------------------------------------------------------------------
-- Helper: Heroes Data
--------------------------------------------------------------------------------
rubick_steal.heroesData = {}
function rubick_steal:SetLastSpell( hHero, hSpell )
	local primary_ability = nil
	local secondary_ability = nil
	local secondary = nil
	local primary = nil
	primary_ability = hSpell:GetAssociatedPrimaryAbilities()
	secondary_ability = hSpell:GetAssociatedSecondaryAbilities()

	-- check if there is primary or secondary linked ability

	if primary_ability ~= nil then
		primary = hHero:FindAbilityByName(primary_ability)
		secondary = hSpell
	else
		primary = hSpell
	end
	if secondary_ability ~= nil then
		secondary = hHero:FindAbilityByName(secondary_ability)
	end

	-- find hero in list
	local heroData = nil
	for _,data in pairs(rubick_steal.heroesData) do
		if data.handle == hHero then
			heroData = data
			break
		end
	end

	-- store data
	if heroData then
		heroData.primarySpell = primary
		heroData.secondarySpell = secondary
	else
		local newData = {}
		newData.handle = hHero
		newData.primarySpell = primary
		newData.secondarySpell = secondary
		table.insert( rubick_steal.heroesData, newData )
	end
	--self:PrintStatus()
	-- self:PrintStatus()
end
function rubick_steal:GetLastSpell(hHero)
	-- find hero in list
	local heroData = nil
	for _,data in pairs(rubick_steal.heroesData) do
		if data.handle==hHero then
			heroData = data
			break
		end
	end

	if heroData then
		return heroData
	end

	return nil
end

function rubick_steal:PrintStatus()
	print("Heroes and spells:")
	for _,heroData in pairs(rubick_steal.heroesData) do
		if heroData.primarySpell ~= nil then
			print( heroData.handle:GetUnitName(), heroData.handle, heroData.primarySpell:GetAbilityName(), heroData.primarySpell )
		end
		if heroData.secondarySpell ~= nil then
			print( heroData.handle:GetUnitName(), heroData.handle, heroData.secondarySpell:GetAbilityName(), heroData.secondarySpell )
		end
	end
end
--------------------------------------------------------------------------------
-- Helper: Current spell
--------------------------------------------------------------------------------
rubick_steal.CurrentPrimarySpell = nil
rubick_steal.CurrentSecondarySpell = nil
rubick_steal.CurrentSpellOwner = nil
rubick_steal.slot1 = "rubick_empty1"
rubick_steal.slot2 = "rubick_empty2"
-- Add new stolen spell
function rubick_steal:SetStolenSpell( spellData )
	local primarySpell = spellData.primarySpell
	local secondarySpell = spellData.secondarySpell
	-- Forget previous one
	self:ForgetSpell()

	print("Stolen spell: "..primarySpell:GetAbilityName())

	if secondarySpell then
		print("Stolen secondary spell: "..secondarySpell:GetAbilityName())
	end

	-- Add new spell
	if not primarySpell:IsNull() then
		self.CurrentPrimarySpell = self:GetCaster():AddAbility( primarySpell:GetAbilityName() )
		self.CurrentPrimarySpell:SetLevel( primarySpell:GetLevel() )
		self.CurrentPrimarySpell:SetStolen( true )
		self:GetCaster():SwapAbilities( self.slot1, self.CurrentPrimarySpell:GetAbilityName(), false, true )
	end

	if secondarySpell~=nil and not secondarySpell:IsNull() then
		self.CurrentSecondarySpell = self:GetCaster():AddAbility( secondarySpell:GetAbilityName() )
		self.CurrentSecondarySpell:SetLevel( secondarySpell:GetLevel() )
		self.CurrentSecondarySpell:SetStolen( true )
		self:GetCaster():SwapAbilities( self.slot2, self.CurrentSecondarySpell:GetAbilityName(), false, true )
	end

	self.CurrentSpellOwner = spellData.stolenFrom
end
-- Remove currently stolen spell
function rubick_steal:ForgetSpell()
	if self.CurrentSpellOwner ~= nil then
		for i = 0, self:GetCaster():GetModifierCount() -1 do
			if string.find(self:GetCaster():GetModifierNameByIndex(i),string.gsub(self.CurrentSpellOwner, "npc_dota_hero_","")) then
				self:GetCaster():RemoveModifierByName(self:GetCaster():GetModifierNameByIndex(i))
			end	
		end
	end
	if self.CurrentPrimarySpell~=nil and not self.CurrentPrimarySpell:IsNull() then
		--print("forgetting primary")
		self:GetCaster():SwapAbilities( self.slot1, self.CurrentPrimarySpell:GetAbilityName(), true, false )
		self:GetCaster():RemoveAbility( self.CurrentPrimarySpell:GetAbilityName() )
		if self.CurrentSecondarySpell~=nil and not self.CurrentSecondarySpell:IsNull() then
			--print("forgetting secondary")
			self:GetCaster():SwapAbilities( self.slot2, self.CurrentSecondarySpell:GetAbilityName(), true, false )
			self:GetCaster():RemoveAbility( self.CurrentSecondarySpell:GetAbilityName() )
		end

		--GetAbility	
		self.CurrentPrimarySpell = nil
		self.CurrentSecondarySpell = nil
		self.CurrentSpellOwner = nil
	end
end
--------------------------------------------------------------------------------
-- Ability Considerations
--------------------------------------------------------------------------------
function rubick_steal:AbilityConsiderations()
	-- Scepter
	local bScepter = caster:HasScepter()

	-- Linken & Lotus
	local bBlocked = target:TriggerSpellAbsorb( self )

	-- Break
	local bBroken = caster:PassivesDisabled()

	-- Advanced Status
	local bInvulnerable = target:IsInvulnerable()
	local bInvisible = target:IsInvisible()
	local bHexed = target:IsHexed()
	local bMagicImmune = target:IsMagicImmune()

	-- Illusion Copy
	local bIllusion = target:IsIllusion()
end
-------------------------------------------
--	modifier_rubick_spellsteal_hidden
-------------------------------------------
modifier_rubick_spellsteal_hidden = class({})

function modifier_rubick_spellsteal_hidden:IsHidden() return true end

function modifier_rubick_spellsteal_hidden:IsDebuff() return false end

function modifier_rubick_spellsteal_hidden:IsPurgable() return false end

function modifier_rubick_spellsteal_hidden:RemoveOnDeath() return false end

function modifier_rubick_spellsteal_hidden:OnCreated( kv ) end

function modifier_rubick_spellsteal_hidden:OnRefresh( kv ) end

function modifier_rubick_spellsteal_hidden:OnDestroy() end

function modifier_rubick_spellsteal_hidden:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
	}
	return funcs
end

function modifier_rubick_spellsteal_hidden:OnAbilityFullyCast( params )
	if IsServer() then
		if params.unit == self:GetParent() 
		or params.ability:IsItem() 
		or params.unit:IsIllusion() 
		or not params.ability:IsStealable() then
			return
		end
		
		self:GetAbility():SetLastSpell( params.unit, params.ability )
	end
end

-------------------------------------------
--	modifier_rubick_steal
-------------------------------------------
modifier_rubick_steal = class({})

function modifier_rubick_steal:IsHidden() return true end
function modifier_rubick_steal:IsDebuff()	return false end
function modifier_rubick_steal:IsPurgable() return false end

function modifier_rubick_steal:OnDestroy( kv ) 
	self:GetAbility():ForgetSpell() 
end

-------------------------------------------
--	modifier_rubick_spellsteal_spell_amp
-------------------------------------------
modifier_rubick_spellsteal_spell_amp = class({})

function modifier_rubick_spellsteal_spell_amp:IsDebuff()   return false end
function modifier_rubick_spellsteal_spell_amp:IsPurgable() return true end

function modifier_rubick_spellsteal_spell_amp:OnCreated(table)
	self.stolen_spell_amp = self:GetStackCount()
end

function modifier_rubick_spellsteal_spell_amp:OnRefresh( table )
	self.stolen_spell_amp = self:GetStackCount()
end

function modifier_rubick_spellsteal_spell_amp:DeclareFunctions()
	local funcs = {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}

	return funcs
end

function modifier_rubick_spellsteal_spell_amp:GetModifierSpellAmplify_Percentage()
	return self.stolen_spell_amp
end

-------------------------------------------
--	modifier_rubick_spellsteal_movespeed
-------------------------------------------
modifier_rubick_spellsteal_movespeed = class({})

function modifier_rubick_spellsteal_movespeed:IsDebuff()   return false end
function modifier_rubick_spellsteal_movespeed:IsPurgable() return true end

function modifier_rubick_spellsteal_movespeed:DeclareFunctions()
	local funcs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}

	return funcs
end

function modifier_rubick_spellsteal_movespeed:GetModifierMoveSpeedBonus_Percentage()
	return 100
end