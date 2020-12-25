sand_caustics = class({})

function sand_caustics:GetAbilityType()
    if self:GetCaster():HasScepter() then
        return DAMAGE_TYPE_PURE
    end

    return DAMAGE_TYPE_MAGICAL
end

function sand_caustics:GetIntrinsicModifierName()
    return "modifier_caustics"
end

modifier_caustics = class({})
LinkLuaModifier( "modifier_caustics", "heroes/hero_sand/sand_caustics.lua" ,LUA_MODIFIER_MOTION_NONE )
function modifier_caustics:DeclareFunctions()
    funcs = {MODIFIER_EVENT_ON_ATTACK}
    return funcs
end

function modifier_caustics:OnAttack(params)
    if IsServer() then
        if params.attacker == self:GetCaster() and params.target:IsAlive() and not params.target:IsMagicImmune() and not params.target:HasModifier("modifier_caustics_enemy") then
            params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_caustics_enemy", {Duration = self:GetTalentSpecialValueFor("duration"), ignoreStatusAmp = true})
        end
    end
end

function modifier_caustics:IsHidden()
    return true
end

modifier_caustics_enemy = class({})
LinkLuaModifier( "modifier_caustics_enemy", "heroes/hero_sand/sand_caustics.lua" ,LUA_MODIFIER_MOTION_NONE )
function modifier_caustics_enemy:OnCreated(table)
	self.radius = self:GetTalentSpecialValueFor("damage_radius")
	self.base_damage = self:GetTalentSpecialValueFor("base_damage")
	self.death_bonus_dmg = self:GetTalentSpecialValueFor("death_bonus_dmg") / 100
	
	self.as = self:GetTalentSpecialValueFor("attack_slow")
	self.ms = self:GetTalentSpecialValueFor("move_slow")
	
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_sand_caustics_2")
	self.talent2Val = self:GetCaster():FindTalentValue("special_bonus_unique_sand_caustics_2") / 100
	
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_sand_caustics_1")
	self.talent1MS = self:GetCaster():FindTalentValue("special_bonus_unique_sand_caustics_1")
end

function modifier_caustics_enemy:OnDestroy()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	if IsClient() then return end
	local unitExploded = false
	local  talentHeal = 0
	if not parent:IsAlive() then
		local enemies = caster:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), self.radius )
		local totalDamage = self.base_damage * (1 + caster:GetSpellAmplification( false ) ) + parent:GetMaxHealth() * self.death_bonus_dmg
		talentHeal = self.base_damage + parent:GetMaxHealth() * self.death_bonus_dmg
		for _,enemy in ipairs(enemies) do
			ability:DealDamage(caster, enemy, totalDamage, {damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION})
		end
		unitExploded = true
	elseif self:GetRemainingTime() <= 0 or parent.forcedCausticRemoval then
		ability:DealDamage(caster, parent, self.base_damage)
		talentHeal = self.base_damage
		unitExploded = true
	end
	if unitExploded then
		SendOverheadEventMessage(caster:GetPlayerOwner(), OVERHEAD_ALERT_BONUS_POISON_DAMAGE, parent, talentHeal, caster:GetPlayerOwner())
		EmitSoundOn("Ability.SandKing_CausticFinale", parent)
		ParticleManager:FireParticle("particles/units/heroes/hero_sandking/sandking_caustic_finale_explode.vpcf", PATTACH_POINT, parent)
		if self.talent2 then
			for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( parent:GetAbsOrigin(), self.radius ) ) do
				ally:HealEvent( talentHeal * self.talent2Val, ability, caster )
			end
		end
	end
end

function modifier_caustics_enemy:GetEffectName()
    return "particles/units/heroes/hero_sandking/sandking_caustic_finale_debuff.vpcf"
end

function modifier_caustics_enemy:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end

function modifier_caustics_enemy:GetModifierAttackSpeedBonus_Constant()
	return self.as
end

function modifier_caustics_enemy:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end