hoodwink_scurry_bh = class({})

function hoodwink_scurry_bh:CastFilterResult( )
	if self:GetCaster():HasModifier("modifier_hoodwink_scurry_bh_active") then
		return UF_FAIL_CUSTOM
	else
		return UF_SUCCESS
	end
end

function hoodwink_scurry_bh:GetCustomCastError( )
	return "#dota_hud_error_hoodwink_already_scurrying"
end

function hoodwink_scurry_bh:GetManaCost( iLvl )
	if self:GetCaster():HasTalent("special_bonus_unique_hoodwink_scurry_2") then
		return 0
	else
		return self.BaseClass.GetManaCost( self, iLvl )
	end
end

function hoodwink_scurry_bh:OnSpellStart()
	local caster = self:GetCaster()
	
	local duration = self:GetTalentSpecialValueFor("duration")
	caster:AddNewModifier( caster, self, "modifier_hoodwink_scurry_bh_active", {duration = duration} )
	if caster:HasTalent("special_bonus_unique_hoodwink_scurry_2") then
		local illusions = caster:ConjureImage( {outgoing_damage = -100, incoming_damage = 9999}, duration, caster, 1 )
		illusions[1]:AddNewModifier( caster, self, "modifier_hoodwink_scurry_bh_active", {duration = duration} )
	end
end

modifier_hoodwink_scurry_bh_active = class({})
LinkLuaModifier("modifier_hoodwink_scurry_bh_active", "heroes/hero_hoodwink/hoodwink_scurry_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_hoodwink_scurry_bh_active:OnCreated()
	self.movespeed = self:GetTalentSpecialValueFor("movement_speed_pct")
	self.evasion = self:GetTalentSpecialValueFor("evasion")
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_hoodwink_scurry_1")
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_hoodwink_scurry_2") and not self:GetParent():IsIllusion()
	if self.talent1 and IsServer() then
		self.talent1Delay = self:GetCaster():FindTalentValue("special_bonus_unique_hoodwink_scurry_1", "delay")
		self:StartIntervalThink( self.talent1Delay )
	end
end

function modifier_hoodwink_scurry_bh_active:OnIntervalThink()
	if GridNav:IsNearbyTree( self:GetCaster():GetAbsOrigin(), 128, true ) then return end
	local caster = self:GetCaster()
	local position = caster:GetAbsOrigin()
	local dummy = caster:CreateDummy( position,20 )
	dummy:AddNewModifier( caster, self:GetAbility(), "hoodwink_acorn_shot_bh_dummy", {} )
	AddFOWViewer( caster:GetTeam(), position, 200, 20, false )
	CreateTempTree(position, 20)
end

function modifier_hoodwink_scurry_bh_active:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_EVASION_CONSTANT, MODIFIER_PROPERTY_INVISIBILITY_LEVEL, MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS, MODIFIER_EVENT_ON_DEATH }
end

function modifier_hoodwink_scurry_bh_active:CheckState()
	local state = { [MODIFIER_STATE_ALLOW_PATHING_THROUGH_TREES] = true }
	if self.talent2 then 
		state[MODIFIER_STATE_INVISIBLE] = true
	end
	return state
end

function modifier_hoodwink_scurry_bh_active:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed
end

function modifier_hoodwink_scurry_bh_active:GetModifierEvasion_Constant()
	return self.evasion
end

function modifier_hoodwink_scurry_bh_active:GetModifierInvisibilityLevel()
	if self.talent2 then return 1 end
end

function modifier_hoodwink_scurry_bh_active:GetActivityTranslationModifiers()
	return "scurry"
end

function modifier_hoodwink_scurry_bh_active:OnDeath(params)
	if params.unit == self:GetParent() then
		local bushwack = self:GetParent():FindAbilityByName("hoodwink_bushwhack_bh")
		if bushwack and bushwack:GetLevel() >= 1 then
			local radius = bushwack:GetTalentSpecialValueFor("trap_radius")
			local checkDist = radius * 2
			local treePos
			local nearestTrees = GridNav:GetAllTreesAroundPoint( params.attacker:GetAbsOrigin(), checkDist*2, true )
			for _, tree in ipairs( nearestTrees ) do
				local treeDist = CalculateDistance( tree, params.attacker:GetAbsOrigin() )
				if treeDist < checkDist then
					treePos = tree:GetAbsOrigin()
					checkDist = treeDist
				end
			end
			if treePos then
				ParticleManager:FireWarningParticle( ( treePos + params.attacker:GetAbsOrigin() ) / 2, 125 )
				self:GetParent():SetCursorPosition( ( treePos + params.attacker:GetAbsOrigin() ) / 2 )
				bushwack:OnSpellStart( )
			end
		end
	end
end