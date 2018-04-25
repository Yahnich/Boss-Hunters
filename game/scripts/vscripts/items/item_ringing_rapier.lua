item_ringing_rapier = class({})

LinkLuaModifier( "modifier_item_ringing_rapier", "items/item_ringing_rapier.lua" ,LUA_MODIFIER_MOTION_NONE )
function item_ringing_rapier:GetIntrinsicModifierName()
	return "modifier_item_ringing_rapier"
end

function item_ringing_rapier:ShouldUseResources()
	return true
end

modifier_item_ringing_rapier = class({})

function modifier_item_ringing_rapier:OnCreated()
	self.delay = self:GetSpecialValueFor("attack_delay")
	self.paralyze = self:GetAbility():GetSpecialValueFor("paralyze_duration")
end

function modifier_item_ringing_rapier:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_item_ringing_rapier:OnAttackLanded(params)
	if IsServer() then
		if not self:GetParent():IsRangedAttacker() and params.attacker == self:GetParent() and self:GetAbility():IsCooldownReady() then
			local parent = self:GetParent()
			parent:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 6)
			self:GetAbility():SetCooldown()
			Timers:CreateTimer(self.delay, function() 
				parent:PerformGenericAttack(params.target, true, 0, false, true)
				if parent:IsRealHero() then params.target:Paralyze(self:GetAbility(), parent, self.paralyze) end
			end)
		end
	end
end

function modifier_item_ringing_rapier:IsHidden()
	return true
end
