juggernaut_hidden_blade = class({})

function juggernaut_hidden_blade:IsStealable()
    return false
end

function juggernaut_hidden_blade:IsHiddenWhenStolen()
    return false
end

function juggernaut_hidden_blade:OnInventoryContentsChanged()
    if self:GetCaster():HasScepter() then
        self:SetLevel(1)
        self:SetHidden(false)
        self:SetActivated(true)
    else
        self:SetLevel(0)
        self:SetHidden(true)
        self:SetActivated(false)
    end
end

function juggernaut_hidden_blade:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local omnislash = caster:FindAbilityByName("juggernaut_dance_of_blades")
	
	local duration = self:GetSpecialValueFor("duration")
	
	caster:AddNewModifier(caster, omnislash, "modifier_juggernaut_dance_of_blades", {duration = duration + 0.1})
	omnislash:Bounce(target)
	if caster:HasTalent("special_bonus_unique_juggernaut_dance_of_blades_1") then
		local radius = omnislash:GetSpecialValueFor("radius") + caster:GetAttackRange()
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), radius) ) do
			if enemy ~= target then
				omnislash:Bounce(enemy)
				break
			end
		end
	end
end