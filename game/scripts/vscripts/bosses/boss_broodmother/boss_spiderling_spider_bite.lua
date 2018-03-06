boss_spiderling_spider_bite = class({})

function boss_spiderling_spider_bite:GetIntrinsicModifierName()
	return "modifier_boss_spiderling_spider_bite_passive"
end

modifier_boss_spiderling_spider_bite_passive = class({})
LinkLuaModifier("modifier_boss_spiderling_spider_bite_passive", "bosses/boss_broodmother/boss_spiderling_spider_bite", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_spiderling_spider_bite_passive:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_boss_spiderling_spider_bite_passive:OnAttackLanded(params)
	if params.attacker == self:GetParent() then
		params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_boss_spiderling_spider_bite_debuff", {duration = self:GetSpecialValueFor("duration")})
	end
end

modifier_boss_spiderling_spider_bite_debuff = class({})
LinkLuaModifier("modifier_boss_spiderling_spider_bite_debuff", "bosses/boss_broodmother/boss_spiderling_spider_bite", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_spiderling_spider_bite_debuff:OnCreated()
	self.slow = self:GetSpecialValueFor("slow")
	self.damage = self:GetSpecialValueFor("damage")
	self:SetStackCount(1)
	if IsServer() then
		self:StartIntervalThink(0.5)
	end
end

function modifier_boss_spiderling_spider_bite_debuff:OnRefresh()	
	self.slow = self:GetSpecialValueFor("slow")
	self.damage = self:GetSpecialValueFor("damage")
	self:IncrementStackCount()
end

function modifier_boss_spiderling_spider_bite_debuff:OnIntervalThink()
	self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), self.damage * 0.5 * self:GetStackCount() )
end

function modifier_boss_spiderling_spider_bite_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_boss_spiderling_spider_bite_debuff:GetModifierMoveSpeedBonus_Percentage(oarams)
	return self.slow * self:GetStackCount()
end