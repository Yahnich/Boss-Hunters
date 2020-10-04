slardar_blood_in_the_water = class({})

function slardar_blood_in_the_water:GetIntrinsicModifierName()
	return "modifier_slardar_blood_in_the_water_handler"
end

modifier_slardar_blood_in_the_water_handler = class({})
LinkLuaModifier( "modifier_slardar_blood_in_the_water_handler", "heroes/hero_slardar/slardar_blood_in_the_water", LUA_MODIFIER_MOTION_NONE )

function modifier_slardar_blood_in_the_water_handler:OnCreated()
	self.modifierList = {}
	self.linger_duration = self:GetTalentSpecialValueFor("linger_duration")
end

function modifier_slardar_blood_in_the_water_handler:OnRefresh()
	self.linger_duration = self:GetTalentSpecialValueFor("linger_duration")
end

function modifier_slardar_blood_in_the_water_handler:OnIntervalThink()
	local caster = self:GetCaster()
	local blood = caster:FindModifierByName("modifier_slardar_blood_in_the_water")
	local foundModifier = false
	for enemy, modifiers in pairs(self.modifierList) do
		if enemy:IsNull() then
			self.modifierList[enemy] = nil
		elseif not foundModifier then
			for i = #modifiers, 1, -1 do
				if enemy:HasModifier( modifiers[i] ) then
					foundModifier = true
					break
				else
					modifiers[i] = nil
				end
			end
		end
	end
	if blood then
		if not foundModifier then
			blood:SetDuration( self.linger_duration, true )
			self:StartIntervalThink(-1)
		elseif blood:GetDuration() ~= -1 then
			blood:SetDuration( -1, true )
		end
	elseif foundModifier then
		local hello = caster:AddNewModifier( caster, self:GetAbility(), "modifier_slardar_blood_in_the_water", {} )
	end
end

function modifier_slardar_blood_in_the_water_handler:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_slardar_blood_in_the_water_handler:OnAttackLanded(params)
	if params.attacker == self:GetParent() then
		params.attacker:AddNewModifier( params.attacker, self:GetAbility(), "modifier_slardar_blood_in_the_water", {duration = self.linger_duration} )
	end
end

function modifier_slardar_blood_in_the_water_handler:OnUnitModifierAdded(params)
	if params.caster == self:GetCaster() and not params.unit:IsSameTeam( params.caster ) and params.ability and params.caster:HasAbility( params.ability:GetAbilityName() ) then
		self.modifierList[params.unit] = {} or self.modifierList[params.unit]
		table.insert( self.modifierList[params.unit], params.modifier_name )
		self:StartIntervalThink(0.25)
	end
end

function modifier_slardar_blood_in_the_water_handler:IsHidden()
	return true
end

modifier_slardar_blood_in_the_water = class({})
LinkLuaModifier( "modifier_slardar_blood_in_the_water", "heroes/hero_slardar/slardar_blood_in_the_water", LUA_MODIFIER_MOTION_NONE )

function modifier_slardar_blood_in_the_water:OnCreated()
	self:OnRefresh()
	if IsServer() then 
		self:GetParent():EmitSound("Hero_Slardar.Sprint")
	end
end

function modifier_slardar_blood_in_the_water:OnRefresh()
	self.movespeed = self:GetTalentSpecialValueFor("bonus_speed")
	self.attackspeed = self:GetTalentSpecialValueFor("bonus_attack_speed")
	self.red = self:GetCaster():FindTalentValue("special_bonus_unique_slardar_blood_in_the_water_1")
	self.as = self:GetCaster():FindTalentValue("special_bonus_unique_slardar_blood_in_the_water_2")
	self.dmg = self:GetCaster():FindTalentValue("special_bonus_unique_slardar_blood_in_the_water_2", "value2")
	self:GetParent():HookInModifier( "GetMoveSpeedLimitBonus", self )
	self:GetParent():HookInModifier( "GetModifierAttackSpeedLimitBonus", self )
end

function modifier_slardar_blood_in_the_water:OnDestroy()
	self:GetParent():HookOutModifier( "GetMoveSpeedLimitBonus", self )
	self:GetParent():HookOutModifier( "GetModifierAttackSpeedLimitBonus", self )
end

function modifier_slardar_blood_in_the_water:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
    }
    return funcs
end

function modifier_slardar_blood_in_the_water:GetModifierMoveSpeedBonus_Percentage()
	local ms = self.movespeed
	if self:GetCaster():InWater() then ms = ms * 2 end
    return ms
end

function modifier_slardar_blood_in_the_water:GetModifierAttackSpeedBonus_Constant()
	local as = self.attackspeed
	if self:GetCaster():InWater() then as = as * 2 end
    return as
end

function modifier_slardar_blood_in_the_water:GetMoveSpeedLimitBonus()
	if self:GetCaster():InWater() then return 99999 end
end

function modifier_slardar_blood_in_the_water:GetModifierAttackSpeedLimitBonus()
	if self:GetCaster():InWater() then return 99999 end
end

function modifier_slardar_blood_in_the_water:GetModifierIncomingDamage_Percentage()
	if self.red <= 0 then return end
	local red = self.red
	if self:GetCaster():InWater() then red = red * 2 end
    return red
end


function modifier_slardar_blood_in_the_water:GetModifierBaseDamageOutgoing_Percentage()
	if self.dmg <= 0 then return end
	local dmg = self.dmg
	if self:GetCaster():InWater() then dmg = dmg * 2 end
    return dmg
end

function modifier_slardar_blood_in_the_water:GetActivityTranslationModifiers()
	return "sprint"
end

function modifier_slardar_blood_in_the_water:GetEffectName()
	return "particles/units/heroes/hero_slardar/slardar_sprint.vpcf"
end