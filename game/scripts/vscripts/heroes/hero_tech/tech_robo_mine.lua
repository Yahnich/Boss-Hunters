tech_robo_mine = class({})
LinkLuaModifier( "modifier_robo_mine", "heroes/hero_tech/tech_robo_mine.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_movespeed_cap", "libraries/modifiers/modifier_movespeed_cap.lua", LUA_MODIFIER_MOTION_NONE )

function tech_robo_mine:IsStealable()
	return true
end

function tech_robo_mine:IsHiddenWhenStolen()
	return false
end

function tech_robo_mine:GetAOERadius()
	return TernaryOperator( self:GetSpecialValueFor("scepter_radius"), self:GetCaster():HasScepter(), self:GetSpecialValueFor("radius") )
end

function tech_robo_mine:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	local radius = TernaryOperator( self:GetSpecialValueFor("scepter_radius"), self:GetCaster():HasScepter(), self:GetSpecialValueFor("radius") )
	local duration = self:GetSpecialValueFor("duration")
	local scepter = caster:HasScepter()
	for _, mine in ipairs( caster:FindFriendlyUnitsInRadius( position, radius, {flag = DOTA_UNIT_TARGET_FLAG_INVULNERABLE} ) ) do
		if mine:GetUnitName() == "npc_dota_techies_stasis_trap"
		or mine:GetUnitName() == "npc_dota_techies_land_mine" then
			EmitSoundOn("Hero_Techies.RemoteMine.Plant", mine)
			mine:AddNewModifier( caster, self, "modifier_robo_mine", {duration = duration} )
			if not scepter then
				break
			end
		end
	end
	
end

modifier_robo_mine = ({})
function modifier_robo_mine:OnCreated(table)
	if IsServer() then
		self:GetParent():SetMoveCapability( DOTA_UNIT_CAP_MOVE_GROUND )
		self:GetParent():SetControllableByPlayer( self:GetCaster():GetPlayerID(),  true )
	end
end

function modifier_robo_mine:OnDestroy()
	if IsServer() then
		self:GetParent():SetMoveCapability( DOTA_UNIT_CAP_MOVE_NONE )
		self:GetParent():SetControllableByPlayer( self:GetCaster():GetPlayerID(),  false )
	end
end

function modifier_robo_mine:CheckState()
	local state = {[MODIFIER_STATE_UNSLOWABLE] = true,
				   [MODIFIER_STATE_UNSELECTABLE] = false,
				   [MODIFIER_STATE_UNTARGETABLE] = false,
				   [MODIFIER_STATE_ROOTED] = false}
	if self:GetCaster():HasScepter() then
		state[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true
	end
	return state
end

function modifier_robo_mine:GetPriority()
	return MODIFIER_PRIORITY_HIGH 
end

function modifier_robo_mine:IsHidden()
	return false
end

function modifier_robo_mine:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
	}
	return funcs
end

function modifier_robo_mine:GetModifierMoveSpeedBonus_Constant()
	return self:GetSpecialValueFor("movespeed")	
end