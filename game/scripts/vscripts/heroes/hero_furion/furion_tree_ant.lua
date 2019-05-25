furion_tree_ant = class({})

function furion_tree_ant:IsStealable()
	return false
end

function furion_tree_ant:IsHiddenWhenStolen()
	return false
end

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

function furion_tree_ant:SpawnTreant(position, bWasMinion)
	local caster = self:GetCaster()
	local tree = caster:CreateSummon("npc_dota_furion_treant_1", position, self:GetTalentSpecialValueFor("treant_duration"))
	FindClearSpaceForUnit(tree, position, true)
	local maxHP = self:GetTalentSpecialValueFor("treant_health") + caster:GetMaxHealth() * self:GetTalentSpecialValueFor("treant_health_pct") / 100
	if not bWasMinion then
		maxHP = maxHP * 4
	end
	tree:SetBaseMaxHealth(maxHP)
	tree:SetMaxHealth(self:GetTalentSpecialValueFor("treant_health"))
	tree:SetHealth(self:GetTalentSpecialValueFor("treant_health"))
	local ad = caster:GetAverageTrueAttackDamage(caster) * self:GetTalentSpecialValueFor("treant_damage")/100
	if bWasMinion then
		ad = ad * 4
	end
	tree:SetBaseDamageMax(ad)
	tree:SetBaseDamageMin(ad)
	tree:SetPhysicalArmorBaseValue(caster:GetPhysicalArmorValue(false))
	tree:AddAbility("furion_entangle"):SetLevel(1)
	tree:MoveToPositionAggressive(position)
	if caster:HasTalent("special_bonus_unique_furion_tree_ant_1") then
		tree:AddNewModifier( caster, self, "modifier_furion_tree_ant_talent", {})
	end
end

modifier_furion_tree_ant_talent = class({})
LinkLuaModifier("modifier_furion_tree_ant_talent", "heroes/hero_furion/furion_tree_ant", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_furion_tree_ant_talent:OnCreated()
		self.hp = self:GetParent():GetHealth()
		self:StartIntervalThink(0)
	end

	function modifier_furion_tree_ant_talent:OnIntervalThink()
		self.hp = self:GetParent():GetHealth()
	end

	function modifier_furion_tree_ant_talent:OnDestroy()
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		ParticleManager:FireParticle("particles/units/heroes/hero_sandking/sandking_caustic_finale_explode.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( self:GetParent():GetAbsOrigin(), caster:FindTalentValue("special_bonus_unique_furion_tree_ant_1") ) ) do
			ability:DealDamage( caster, enemy, self.hp, {damage_type = DAMAGE_TYPE_PHYSICAL, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION })
		end
	end
end

function modifier_furion_tree_ant_talent:IsHidden()
	return true
end

function modifier_furion_tree_ant_talent:IsPurgable()
	return false
end