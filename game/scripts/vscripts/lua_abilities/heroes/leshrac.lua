leshrac_inner_torment = class({})

LinkLuaModifier( "modifier_leshrac_inner_torment", "lua_abilities/heroes/leshrac.lua" ,LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function leshrac_inner_torment:GetIntrinsicModifierName()
    return "modifier_leshrac_inner_torment"
end

function leshrac_inner_torment:OnToggle()
	return
end

function leshrac_inner_torment:OnHeroLevelUp()
    self:GetCaster():FindModifierByName("modifier_leshrac_inner_torment"):IncrementStackCount()
end

modifier_leshrac_inner_torment = class({})

if IsServer() then
	function modifier_leshrac_inner_torment:OnCreated()
		self.piercing = self:GetAbility():GetTalentSpecialValueFor("pure_damage_per_level")
		self:SetStackCount(self:GetCaster():GetLevel())
	end
end

function modifier_leshrac_inner_torment:IsHidden()
	return false
end

function modifier_leshrac_inner_torment:RemoveOnDeath()
	return false
end

function InnerTorment(filterTable)
	local victim_index = filterTable["entindex_victim_const"]
    local attacker_index = filterTable["entindex_attacker_const"]

    if not victim_index or not attacker_index then
        return filterTable
    end
	local damage = filterTable["damage"] --Post reduction
	local inflictor = filterTable["entindex_inflictor_const"]
	local ability = EntIndexToHScript( inflictor )
	if ability:GetName() == "leshrac_inner_torment" then return filterTable end

    local victim = EntIndexToHScript( victim_index )
    local attacker = EntIndexToHScript( attacker_index )
	local torment = attacker:FindAbilityByName("leshrac_inner_torment")
	if torment:GetToggleState() then 
		return filterTable
	end
    local damagetype = filterTable["damagetype_const"]
	local modifier = attacker:FindModifierByName("modifier_leshrac_inner_torment")
	local pierce = math.min(100, (modifier.piercing * modifier:GetStackCount())) / 100
	if (victim:GetMagicalArmorValue() <= 0 and damagetype == 2) or (victim:GetPhysicalArmorReduction() <= 0 and damagetype == 1) then return filterTable end
	filterTable["damage"] = filterTable["damage"] * (1- pierce) -- replace damage by different damage
	
	if damagetype == 1 then -- true physical damage before reductions
		damage = damage / (1 - victim:GetPhysicalArmorReduction() / 100 )
	elseif damagetype == 2 and victim:GetMagicalArmorValue() < 1 then -- true magic damage before reductions
		damage = damage /  (1 - victim:GetMagicalArmorValue())
	end
	ApplyDamage({victim = victim, attacker = attacker, damage = damage * pierce, damage_type = DAMAGE_TYPE_PURE, ability = torment})
	return filterTable
end