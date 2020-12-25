sand_tremors = class({})

function sand_tremors:IsStealable()
	return true
end

function sand_tremors:IsHiddenWhenStolen()
	return false
end

function sand_tremors:GetCastPoint()
	if self:GetCaster():HasTalent("special_bonus_unique_sand_tremors_1") then
		return self:GetCaster():FindTalentValue("special_bonus_unique_sand_tremors_1", "cast_point")
	else
		return self:GetTalentSpecialValueFor("cast_point")
	end
end

function sand_tremors:OnAbilityPhaseStart()
	EmitSoundOn("Ability.SandKing_Epicenter.spell", self:GetCaster())
	return true
end

function sand_tremors:OnAbilityPhaseInterrupted()
	StopSoundOn("Ability.SandKing_Epicenter.spell", self:GetCaster())
end

function sand_tremors:OnSpellStart()
    local caster = self:GetCaster()

    caster:AddNewModifier(caster, self, "modifier_tremors", {Duration = self:GetTalentSpecialValueFor("duration") + 0.1, ignoreStatusAmp = true})
	caster:RemoveGesture( ACT_DOTA_CAST_ABILITY_4 )
end

modifier_tremors = class({})
LinkLuaModifier("modifier_tremors", "heroes/hero_sand/sand_tremors.lua", 0)

function modifier_tremors:OnCreated()
	self.damage = self:GetTalentSpecialValueFor("damage")
	self.radius = self:GetTalentSpecialValueFor("starting_radius")
	self.radius_growth = self:GetTalentSpecialValueFor("radius_growth")
	self.duration = self:GetTalentSpecialValueFor("slow_duration")
	self.rate = self:GetTalentSpecialValueFor("duration") / self:GetTalentSpecialValueFor("tremors")
	
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_sand_tremors_2")
	self.talent2Val = self:GetCaster():FindTalentValue("special_bonus_unique_sand_tremors_2", "distance")
	
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_sand_tremors_1")
	self.talent1MS = self:GetCaster():FindTalentValue("special_bonus_unique_sand_tremors_1")
	
	if IsServer() then
		EmitSoundOn("Ability.SandKing_Epicenter", self:GetParent())
		self:StartIntervalThink( self.rate )
	end
end

function modifier_tremors:OnIntervalThink()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local parent = self:GetParent()
	
	ParticleManager:FireParticle("particles/units/heroes/hero_sandking/sandking_epicenter.vpcf", PATTACH_POINT, caster, {[0] = caster:GetAbsOrigin(), [1] = Vector(self.radius,self.radius,self.radius)})
	
	StopSoundOn("Ability.SandKing_Epicenter", parent)
	EmitSoundOn("Ability.SandKing_Epicenter", parent)
	local enemies = caster:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), self.radius, {})
	for _,enemy in pairs(enemies) do
		if not enemy:TriggerSpellAbsorb( ability ) then
			ability:DealDamage(caster, enemy, self.damage )
			enemy:AddNewModifier(caster, ability, "modifier_tremors_enemy", {Duration = self.duration})

			if self.talent2 then
				enemy:ApplyKnockBack(caster:GetAbsOrigin(), 0.25, 0.25, 0, self.talent2Val , caster, ability)
			end
		end
	end
	
	self.radius = self.radius + self.radius_growth
end

function modifier_tremors:OnDestroy()
	if IsServer() then
		StopSoundOn("Ability.SandKing_Epicenter", self:GetParent())
	end
end

function modifier_tremors:CheckState()
	if self.talent1 then
		return {[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true}
	end
end

function modifier_tremors:DeclareFunctions()
	return { MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT }
end

function modifier_tremors:GetModifierMoveSpeedBonus_Constant()
	return self.talent1MS
end

function modifier_tremors:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE 
end

modifier_tremors_enemy = class({})
LinkLuaModifier("modifier_tremors_enemy", "heroes/hero_sand/sand_tremors.lua", 0)
function modifier_tremors_enemy:OnCreated()
	self.as = self:GetTalentSpecialValueFor("slow_as")
	self.ms = self:GetTalentSpecialValueFor("slow_move")
end

function modifier_tremors_enemy:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
            MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
            }
end

function modifier_tremors_enemy:GetModifierMoveSpeedBonus_Percentage()
    return self.ms
end

function modifier_tremors_enemy:GetModifierAttackSpeedBonus_Constant()
    return self.as
end

function modifier_tremors_enemy:IsDebuff()
    return true
end