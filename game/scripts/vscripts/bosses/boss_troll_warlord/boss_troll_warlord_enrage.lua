boss_troll_warlord_enrage = class({})
LinkLuaModifier( "modifier_boss_troll_warlord_enrage_handle", "bosses/boss_troll_warlord/boss_troll_warlord_enrage.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_boss_troll_warlord_enrage", "bosses/boss_troll_warlord/boss_troll_warlord_enrage.lua", LUA_MODIFIER_MOTION_NONE )

function boss_troll_warlord_enrage:GetIntrinsicModifierName()
	return "modifier_boss_troll_warlord_enrage_handle"
end

modifier_boss_troll_warlord_enrage_handle = class({})
function modifier_boss_troll_warlord_enrage_handle:OnCreated(table)
	if IsServer() then 
		
		AddAnimationTranslate(self:GetParent(), "melee")
		AddAnimationTranslate(self:GetParent(), "run")
		self:StartIntervalThink(0.1)
	end
end

function modifier_boss_troll_warlord_enrage_handle:OnIntervalThink()
	if self:GetParent():GetHealthPercent() < 50 then
		if not self:GetParent():HasModifier("modifier_boss_troll_warlord_enrage") then
			EmitSoundOn("Hero_OgreMagi.Bloodlust.Target", handle_2)
			self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_boss_troll_warlord_enrage", {duration = 10})
			self:StartIntervalThink(15)
			--self:Destroy()
		end
	end
end

function modifier_boss_troll_warlord_enrage_handle:IsPurgeException()
	return false
end

function modifier_boss_troll_warlord_enrage_handle:IsPurgable()
	return false
end

function modifier_boss_troll_warlord_enrage_handle:IsHidden()
	return true
end

modifier_boss_troll_warlord_enrage = class({})
function modifier_boss_troll_warlord_enrage:OnCreated(table)
	if IsServer() then AddAnimationTranslate(self:GetParent(), "melee")	end
end

function modifier_boss_troll_warlord_enrage:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_MODEL_SCALE
    }
    return funcs
end

function modifier_boss_troll_warlord_enrage:GetModifierAttackSpeedBonus_Constant()
	if self:GetParent():PassivesDisabled() then return end
    return self:GetSpecialValueFor("bonus_as")
end

function modifier_boss_troll_warlord_enrage:GetModifierMoveSpeedBonus_Percentage()
	if self:GetParent():PassivesDisabled() then return end
    return self:GetSpecialValueFor("bonus_ms")
end

function modifier_boss_troll_warlord_enrage:GetBaseAttackTime_Bonus()
	if self:GetParent():PassivesDisabled() then return end
    return self:GetSpecialValueFor("bonus_at")
end

function modifier_boss_troll_warlord_enrage:GetModifierModelScale()
    return 25
end

function modifier_boss_troll_warlord_enrage:GetEffectName()
	return "particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_buff.vpcf"
end

function modifier_boss_troll_warlord_enrage:IsHidden()
	return true
end

function modifier_boss_troll_warlord_enrage:IsPurgeException()
	return false
end

function modifier_boss_troll_warlord_enrage:IsPurgable()
	return false
end