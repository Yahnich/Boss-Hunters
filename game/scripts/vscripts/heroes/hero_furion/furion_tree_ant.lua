furion_tree_ant = class({})
function furion_tree_ant:GetAOERadius()
	return self:GetTalentSpecialValueFor("radius")
end

function furion_tree_ant:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    local treants = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE, {})

    local radius = self:GetTalentSpecialValueFor("radius")

    local trees = GridNav:GetAllTreesAroundPoint(point, radius, true)
    if #trees > 1 then
    	GridNav:DestroyTreesAroundPoint(point, radius, true)
		local treants = math.min(#trees, self:GetTalentSpecialValueFor("max_treants"))
	    for i=1, treants do
	    	local randoVect = Vector(RandomInt(-radius,radius), RandomInt(-radius,radius), 0)
			local pointRando = point + randoVect

	    	self:SpawnTreant(pointRando)
	    end
	else
		self:RefundManaCost()
		self:EndCooldown()
	end
end

function furion_tree_ant:SpawnTreant(position)
	local caster = self:GetCaster()
	local tree = caster:CreateSummon("npc_dota_furion_treant", position, self:GetTalentSpecialValueFor("treant_duration"))
	FindClearSpaceForUnit(tree, position, true)
	local maxHP = self:GetTalentSpecialValueFor("treant_health") + caster:GetMaxHealth() * self:GetTalentSpecialValueFor("treant_health_pct") / 100
	tree:SetBaseMaxHealth(maxHP)
	tree:SetMaxHealth(self:GetTalentSpecialValueFor("treant_health"))
	tree:SetHealth(self:GetTalentSpecialValueFor("treant_health"))
	local ad = caster:GetAverageTrueAttackDamage(caster) * self:GetTalentSpecialValueFor("treant_damage")/100
	tree:SetBaseDamageMax(ad)
	tree:SetBaseDamageMin(ad)
	tree:SetPhysicalArmorBaseValue(caster:GetPhysicalArmorValue())
	tree:AddAbility("furion_entangle"):SetLevel(1)
	tree:MoveToPositionAggressive(position)
end