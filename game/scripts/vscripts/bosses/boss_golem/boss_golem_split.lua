boss_golem_split = class({})

function boss_golem_split:GetIntrinsicModifierName()
	return "modifier_boss_golem_split"
end

modifier_boss_golem_split = class({})
LinkLuaModifier( "modifier_boss_golem_split", "bosses/boss_golem/boss_golem_split", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_golem_split:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH}
end

function modifier_boss_golem_split:OnDeath(params)
	if params.unit == self:GetParent() and self:GetParent():GetModelScale() >= self:GetSpecialValueFor("minimum_scale") then
		local divider = self:GetSpecialValueFor("golem_hp") / 100
		local hp = self:GetParent():GetMaxHealth() * divider
		local scale = self:GetParent():GetModelScale() * 0.85
		for i = 1, self:GetSpecialValueFor("split_count") do
			golem = CreateUnitByName("npc_dota_boss12_golem", self:GetParent():GetAbsOrigin() + RandomVector(250), false, nil, nil, self:GetParent():GetTeamNumber())
			
			golem:SetModelScale( scale )
			golem:SetBaseMoveSpeed( golem:GetBaseMoveSpeed() / scale)
			Timers:CreateTimer(0.1, function()
				golem:SetBaseMaxHealth( hp )
				golem:SetMaxHealth( hp )
				golem:SetHealth( hp )
			end)
		end
	end
end