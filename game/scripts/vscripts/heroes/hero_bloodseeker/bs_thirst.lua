bs_thirst = class({})
LinkLuaModifier("modifier_bs_thirst", "heroes/hero_bloodseeker/bs_thirst", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bs_thirst_damage", "heroes/hero_bloodseeker/bs_thirst", LUA_MODIFIER_MOTION_NONE)

function bs_thirst:IsStealable()
	return false
end

function bs_thirst:IsHiddenWhenStolen()
	return false
end

function bs_thirst:GetIntrinsicModifierName()
	return "modifier_bs_thirst"
end

modifier_bs_thirst = class({})
function modifier_bs_thirst:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
	return funcs
end

function modifier_bs_thirst:OnAttackStart(params)
	if IsServer() then
		if params.attacker == self:GetCaster() then
			local caster = params.attacker
		    local target = params.target
		    local ability = self:GetAbility()
			local modifier = "modifier_bs_thirst_damage"
		    local missing_health = target:GetHealthDeficit() ---GetMaxHealth() - target:GetHealth()
		    local damage = math.floor(ability:GetTalentSpecialValueFor("percent") * missing_health * 0.01) + 1
			caster:AddNewModifier(caster, ability, modifier, {duration = 1})
			caster:SetModifierStackCount( modifier, ability, damage )
		    if caster.show_popup ~= true then
		                    caster.show_popup = true
		                    caster:ShowPopup( {
		                    PreSymbol = 1,
		                    PostSymbol = 4,
		                    Color = Vector( 255, 50, 10 ),
		                    Duration = 1.5,
		                    Number = damage,
		                    pfx = "damage",
		                    Player = true
		                } )
	            Timers:CreateTimer(2.0,function()
	                caster.show_popup = false
	            end)
		    end
		end
	end
end

function modifier_bs_thirst:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetCaster() then
			self:GetCaster():RemoveModifierByName("modifier_bs_thirst_damage")
		end
	end
end

function modifier_bs_thirst:IsHidden()
	return true
end

modifier_bs_thirst_damage = class({})
function modifier_bs_thirst_damage:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE_POST_CRIT
	}
	return funcs
end

function modifier_bs_thirst_damage:GetModifierPreAttack_BonusDamage()
	return 1 * self:GetStackCount()
end

function modifier_bs_thirst_damage:GetModifierPreAttack_BonusDamagePostCrit()
	return 1 * self:GetStackCount()
end

function modifier_bs_thirst_damage:IsHidden()
	return true
end