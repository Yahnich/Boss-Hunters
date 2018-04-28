relic_unique_sacrificial_dagger = class({})

function relic_unique_sacrificial_dagger:OnCreated()
	self:SetStackCount(1)
end

function relic_unique_sacrificial_dagger:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH}
end

function relic_unique_sacrificial_dagger:OnDeath(params)
	if params.unit == self:GetParent() and self:GetStackCount() > 0 then
		self:DecrementStackCount()
		for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
			if not unit:IsAlive() then
				local origin = unit:GetOrigin()
				unit:RespawnHero(false, false)
				unit:SetOrigin(origin)
			end
			if unit:IsAlive() then
				unit:SetHealth( unit:GetMaxHealth() )
				unit:SetMana( unit:GetMaxMana() )
			end
		end
	end
end

function relic_unique_sacrificial_dagger:IsHidden()
	return self:GetStackCount() == 0
end

function relic_unique_sacrificial_dagger:IsPurgable()
	return false
end

function relic_unique_sacrificial_dagger:RemoveOnDeath()
	return false
end

function relic_unique_sacrificial_dagger:IsPermanent()
	return true
end

function relic_unique_sacrificial_dagger:AllowIllusionDuplicate()
	return true
end