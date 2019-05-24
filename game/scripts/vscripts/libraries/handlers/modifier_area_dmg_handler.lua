modifier_area_dmg_handler = class({})
AREA_DAMAGE_RADIUS = 325

function modifier_area_dmg_handler:OnCreated()
	self:SetStackCount(0)
	self.lastProc = 0
end

function modifier_area_dmg_handler:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end


function modifier_area_dmg_handler:OnTakeDamage(params)
	local countsAsAttack = ( params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK ) or HasBit( params.damage_flags, DOTA_DAMAGE_FLAG_PROPERTY_FIRE )
	if params.attacker ~= self:GetParent() or params.unit:IsSameTeam(params.attacker) or self:GetStackCount() == 0 or params.damage <= 0 then return end
	local spellValid = false
	local spellValidTargeting = false
	local spellHasTarget = false
	if params.inflictor then
		spellValidTargeting = ( HasBit( params.inflictor:GetBehavior(), DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) and not HasBit( params.inflictor:GetBehavior(), DOTA_ABILITY_BEHAVIOR_AOE) ) 
		spellHasTarget = ( params.unit == params.inflictor:GetCursorTarget() or not params.inflictor:GetCursorTarget() )
		spellValid = ( spellValidTargeting and spellHasTarget ) or ( params.inflictor.HasAreaDamage and params.inflictor:HasAreaDamage() )
	end
	if countsAsAttack or ( spellValid and self.lastProc + 0.1 <= GameRules:GetGameTime() ) then
		local areaDamage = params.original_damage * self:GetStackCount() / 100
		if not countsAsAttack or params.attacker:IsRangedAttacker() then
			areaDamage = areaDamage / 2
		end
		for _, enemy in ipairs( params.attacker:FindEnemyUnitsInRadius( params.unit:GetAbsOrigin(), AREA_DAMAGE_RADIUS ) ) do
			if enemy ~= params.unit then
				ApplyDamage({victim = enemy, attacker = params.attacker, damage_type = params.damage_type, damage = areaDamage, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL})
			end
		end
		self.lastProc = GameRules:GetGameTime()
	end
end

function modifier_area_dmg_handler:IsHidden()
	return true
end

function modifier_area_dmg_handler:IsPurgable()
	return false
end

function modifier_area_dmg_handler:RemoveOnDeath()
	return false
end

function modifier_area_dmg_handler:IsPermanent()
	return true
end

function modifier_area_dmg_handler:AllowIllusionDuplicate()
	return true
end

function modifier_area_dmg_handler:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end