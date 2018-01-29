furion_tree_ant = class({})
function furion_tree_ant:GetAOERadius()
	return self:GetTalentSpecialValueFor("radius")
end

function furion_tree_ant:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    local treants = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE, {})
    for _,treant in pairs(treants) do
    	if treant:GetUnitName() == "npc_dota_furion_treant" then
    		treant:ForceKill(false)
    	end
    end

    local radius = self:GetTalentSpecialValueFor("radius")

    local trees = GridNav:GetAllTreesAroundPoint(point, radius, true)
    if #trees > 1 then
    	GridNav:DestroyTreesAroundPoint(point, radius, true)

	    for i=1,self:GetTalentSpecialValueFor("max_treants") do
	    	local randoVect = Vector(RandomInt(-radius,radius), RandomInt(-radius,radius), 0)
			local pointRando = point + randoVect

	    	local tree = caster:CreateSummon("npc_dota_furion_treant", pointRando, self:GetTalentSpecialValueFor("treant_duration"))
	    	tree:SetMaxHealth(self:GetTalentSpecialValueFor("treant_health"))
	    	tree:SetHealth(self:GetTalentSpecialValueFor("treant_health"))
	    	tree:SetBaseMaxHealth(self:GetTalentSpecialValueFor("treant_health"))
	    	local ad = caster:GetAttackDamage() * self:GetTalentSpecialValueFor("treant_damage")/100
	    	tree:SetBaseDamageMax(ad)
	    	tree:SetBaseDamageMin(ad)
	    	tree:AddAbility("furion_entangle"):SetLevel(1)
	    end
	else
		self:RefundManaCost()
		self:EndCooldown()
	end
end