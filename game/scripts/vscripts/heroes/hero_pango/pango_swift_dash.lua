pango_swift_dash = class({})
LinkLuaModifier( "modifier_pango_swift_dash", "heroes/hero_pango/pango_swift_dash.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_pango_swift_dash_as", "heroes/hero_pango/pango_swift_dash.lua" ,LUA_MODIFIER_MOTION_NONE )

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

    ProjectileManager:ProjectileDodge(self:GetCaster())
end

modifier_pango_swift_dash = class({})
function modifier_pango_swift_dash:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		self.dir = CalculateDirection(self:GetAbility():GetCursorPosition(), self:GetParent():GetAbsOrigin())
		self.distance = CalculateDistance(self:GetAbility():GetCursorPosition(), parent:GetAbsOrigin())

		self.hitUnits = {}

		if caster:HasTalent("special_bonus_unique_pango_swift_dash_1") then
			self:StartIntervalThink(0.06)
		end
		
		self:StartMotionController()
	end
end

function modifier_pango_swift_dash:OnIntervalThink()
	local enemies = self:GetParent():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self:GetParent():GetAttackRange())
	for _,enemy in pairs(enemies) do
		if not self.hitUnits[ enemy:entindex() ] and not enemy:IsAttackImmune() then
			self:GetParent():PerformGenericAttack(enemy, true, 0, false, false)
			self.hitUnits[ enemy:entindex() ] = true
			break
		end
	end
end

function modifier_pango_swift_dash:DoControlledMotion()
	local parent = self:GetParent()
	if self.distance > 0 then
		local speed = self:GetTalentSpecialValueFor("speed") * 0.03
		self.distance = self.distance - speed
		parent:SetAbsOrigin(GetGroundPosition(parent:GetAbsOrigin(), parent) + self.dir*speed)
	else
		FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
		self:Destroy()
		return nil
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
		self.hitUnits = {}

		if self:GetCaster():HasTalent("special_bonus_unique_pango_swift_dash_2") then
			self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_pango_swift_dash_as", {Duration = 2})
		end

		self:GetParent():RemoveGesture(ACT_DOTA_CAST_ABILITY_1)
		self:StopMotionController(false)
	end
end

function modifier_pango_swift_dash:GetEffectName()
	return "particles/units/heroes/hero_pangolier/pangolier_swashbuckler_dash.vpcf"
end

function modifier_pango_swift_dash:IsHidden()
	return true
end

modifier_pango_swift_dash_as = class({})
function modifier_pango_swift_dash_as:OnCreated(table)
	self.bonus_as = self:GetCaster():FindTalentValue("special_bonus_unique_pango_swift_dash_2")
end

function modifier_pango_swift_dash_as:OnRefresh(table)
	self.bonus_as = self:GetCaster():FindTalentValue("special_bonus_unique_pango_swift_dash_2")
end

function modifier_pango_swift_dash_as:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }
    return funcs
end

function modifier_pango_swift_dash_as:GetModifierAttackSpeedBonus_Constant()
	return self.bonus_as
end

function modifier_pango_swift_dash_as:IsDebuff()
	return false
end