pango_swift_dash = class({})
LinkLuaModifier( "modifier_pango_swift_dash", "heroes/hero_pango/pango_swift_dash.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_pango_swift_dash_enemy", "heroes/hero_pango/pango_swift_dash.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_pango_swift_dash_attack", "heroes/hero_pango/pango_swift_dash.lua" ,LUA_MODIFIER_MOTION_NONE )

function pango_swift_dash:IsStealable()
    return true
end

function pango_swift_dash:IsHiddenWhenStolen()
    return false
end

function pango_swift_dash:OnSpellStart()
	EmitSoundOn("Hero_Pangolier.Swashbuckle.Cast", self:GetCaster())
	EmitSoundOn("Hero_Pangolier.Swashbuckle.Layer", self:GetCaster())
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_pango_swift_dash", {})

    self:GetCaster().hitUnits = {}
end

modifier_pango_swift_dash = class({})
function modifier_pango_swift_dash:OnCreated(table)
	if IsServer() then
		local parent = self:GetParent()
		self.dir = CalculateDirection(self:GetAbility():GetCursorPosition(), self:GetParent():GetAbsOrigin())
		self.distance = CalculateDistance(self:GetAbility():GetCursorPosition(), parent:GetAbsOrigin())

		self:StartIntervalThink(FrameTime())
		self:StartMotionController()
	end
end

function modifier_pango_swift_dash:OnIntervalThink()
	local enemies = self:GetParent():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self:GetParent():GetAttackRange())
	for _,enemy in pairs(enemies) do
		if not self:GetCaster().hitUnits[ enemy:entindex() ] and not enemy:IsAttackImmune() then
			self:GetParent():PerformAttack(enemy, true, true, true, false, false, false, true)
			self:GetCaster().hitUnits[ enemy:entindex() ] = enemy
			break
		end
	end
end

function modifier_pango_swift_dash:DoControlledMotion()
	local parent = self:GetParent()
	if self.distance > 0 then
		local speed = self:GetSpecialValueFor("speed") * 0.03
		self.distance = self.distance - speed
		parent:SetAbsOrigin(GetGroundPosition(parent:GetAbsOrigin(), parent) + self.dir*speed)
	else
		FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
		self:StopMotionController(true)
	end
end

function modifier_pango_swift_dash:CheckState()
	local state = { [MODIFIER_STATE_STUNNED] = true}
	return state
end

function modifier_pango_swift_dash:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION
    }
    return funcs
end

function modifier_pango_swift_dash:GetOverrideAnimation()
	return ACT_DOTA_CAST_ABILITY_1
end

function modifier_pango_swift_dash:OnRemoved()
	if IsServer() then
		self:GetCaster().hitUnits = {}
		self:GetParent():RemoveGesture(ACT_DOTA_CAST_ABILITY_1)
	end
end

function modifier_pango_swift_dash:GetEffectName()
	return "particles/units/heroes/hero_pangolier/pangolier_swashbuckler_dash.vpcf"
end

function modifier_pango_swift_dash:IsHidden()
	return true
end