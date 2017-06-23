skeleton_skirmisher_magic_conversion = class({})

function skeleton_skirmisher_magic_conversion:GetIntrinsicModifierName()
	return "modifier_skeleton_skirmisher_magic_conversion"
end


LinkLuaModifier( "modifier_skeleton_skirmisher_magic_conversion", "summons/skeleton_skirmisher/skeleton_skirmisher_magic_conversion.lua", 0)
modifier_skeleton_skirmisher_magic_conversion = class({})

function modifier_skeleton_skirmisher_magic_conversion:OnCreated()
	self.damage_on_attack = self:GetAbility():GetSpecialValueFor("damage_on_attack")
end

function modifier_skeleton_skirmisher_magic_conversion:CheckState()
	local state = { [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
					[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}
	return state
end

function modifier_skeleton_skirmisher_magic_conversion:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

function modifier_skeleton_skirmisher_magic_conversion:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			ApplyDamage({victim = params.target, attacker = self:GetParent():GetOwnerEntity(), damage = self.damage_on_attack, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
			if not self:GetParent():GetOwnerEntity():HasTalent("puppeteer_skeletal_rush_talent_1") then
				self:GetParent():ForceKill(true)
			end
		end
	end
end
