medusa_splitshot_ebf = class({})

if IsServer() then
	function medusa_splitshot_ebf:OnToggle()
		if self:GetToggleState() then
			self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_medusa_splitshot_toggle", {})
		else
			self:GetCaster():RemoveModifierByName("modifier_medusa_splitshot_toggle")
		end
	end
	
	function medusa_splitshot_ebf:OnProjectileHit(target, position)
		self.disableLoop = true
		self:GetCaster():PerformAttack(target, true, true, true, true, false)
	end
end

LinkLuaModifier( "modifier_medusa_splitshot_toggle", "lua_abilities/heroes/medusa.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_medusa_splitshot_toggle = class({})


function modifier_medusa_splitshot_toggle:OnCreated()
	self.damage = self:GetAbility():GetSpecialValueFor("damage_modifier")
	self.radius = self:GetAbility():GetSpecialValueFor("range")
	self.arrows = self:GetAbility():GetSpecialValueFor("arrow_count")
end

function modifier_medusa_splitshot_toggle:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ATTACK,
	MODIFIER_EVENT_ON_ATTACK_START,
	MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
  }
  return funcs
end

function modifier_medusa_splitshot_toggle:GetModifierDamageOutgoing_Percentage()
	return self.damage
end

function modifier_medusa_splitshot_toggle:OnAttackStart(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			self:GetAbility().disableLoop = false
		end
	end
end

function modifier_medusa_splitshot_toggle:OnAttack(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			if self:GetAbility().disableLoop then return end
			local units = FindUnitsInRadius(self:GetParent():GetTeam(), self:GetParent():GetAbsOrigin(), nil, self:GetParent():GetAttackRange(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
			local arrows = self.arrows
			for _,unit in pairs(units) do
				if unit ~= params.target then
					local projectile = {
						Target = unit,
						Source = self:GetParent(),
						Ability = self:GetAbility(),
						EffectName = self:GetParent():GetProjectileModel(),
						bDodgable = true,
						bProvidesVision = false,
						iMoveSpeed = self:GetParent():GetProjectileSpeed(),
						iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
					}
					arrows = arrows - 1
					ProjectileManager:CreateTrackingProjectile(projectile)
					if arrows < 1 then break end
				end
			end
		end
	end
end

function modifier_medusa_splitshot_toggle:IsHidden()
	return true
end