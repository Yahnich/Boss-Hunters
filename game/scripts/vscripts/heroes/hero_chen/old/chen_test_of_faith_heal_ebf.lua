chen_test_of_faith_heal_ebf = class({})
LinkLuaModifier( "modifier_chen_test_of_faith_heal_ebf", "heroes/hero_chen/chen_test_of_faith_heal_ebf.lua" ,LUA_MODIFIER_MOTION_NONE )

function chen_test_of_faith_heal_ebf:IsStealable()
	return true
end

function chen_test_of_faith_heal_ebf:IsHiddenWhenStolen()
	return false
end

function chen_test_of_faith_heal_ebf:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	if target == nil then
		local friends = caster:FindFriendlyUnitsInRadius(self:GetCursorPosition(), FIND_UNITS_EVERYWHERE, {order = FIND_CLOSEST})
		for _,friend in pairs(friends) do
			target = friend
			break
		end
	end

	EmitSoundOn("Hero_Chen.TeleportIn", caster)
	EmitSoundOn("Hero_Chen.TeleportOut", target)

	local min = self:GetTalentSpecialValueFor("min_heal")
	local max = self:GetTalentSpecialValueFor("max_heal")
	local heal = target:GetMaxHealth() * math.random(min,max)/100

	if caster:HasTalent("special_bonus_unique_chen_test_of_faith_heal_ebf_2") then
		target:AddNewModifier(caster, self, "modifier_chen_test_of_faith_heal_ebf", {Duration = caster:FindTalentValue("special_bonus_unique_chen_test_of_faith_heal_ebf_2", "duration")})
	end

	ParticleManager:FireParticle("particles/units/heroes/hero_chen/chen_test_of_faith.vpcf", PATTACH_POINT, target, {})

	target:HealEvent(heal, self, caster)
	target:Purge(false, true, false, true, true)
end

modifier_chen_test_of_faith_heal_ebf = class({})
function modifier_chen_test_of_faith_heal_ebf:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_EVASION_CONSTANT
    }
    return funcs
end

function modifier_chen_test_of_faith_heal_ebf:GetModifierEvasion_Constant()
    return self:GetCaster():FindTalentValue("special_bonus_unique_chen_test_of_faith_heal_ebf_2")
end