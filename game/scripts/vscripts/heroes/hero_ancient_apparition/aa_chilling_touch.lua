aa_chilling_touch = class({})
LinkLuaModifier("modifier_aa_chilling_touch", "heroes/hero_ancient_apparition/aa_chilling_touch", LUA_MODIFIER_MOTION_NONE)

function aa_chilling_touch:OnSpellStart()
	local caster = self:GetCaster()
	local radius = 5000
	ParticleManager:FireParticle("particles/units/heroes/hero_ancient_apparition/ancient_apparition_chilling_touch.vpcf", PATTACH_POINT, caster, {[0]=caster:GetAbsOrigin(),[1]=Vector(radius,radius,radius)})
	EmitSoundOn("Hero_Ancient_Apparition.ChillingTouchCast", caster)

	local friends = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE)
	for _,friend in pairs(friends) do
		if friend:IsHero() then
			friend:AddNewModifier(caster, self, "modifier_aa_chilling_touch", {Duration = self:GetTalentSpecialValueFor("duration")})
		end
	end
end

modifier_aa_chilling_touch = class({})
function modifier_aa_chilling_touch:OnCreated(table)
	if IsServer() then 
		self.damage = self:GetTalentSpecialValueFor("bonus_damage")
		self.chill = self:GetTalentSpecialValueFor("move_speed_pct")
	end

	if self:GetParent() == self:GetCaster() and self:GetCaster():HasTalent("special_bonus_unique_aa_chilling_touch_2") then
		self.as = self:GetCaster():FindTalentValue("special_bonus_unique_aa_chilling_touch_2")
	else
		self.as = 0
	end 
end

function modifier_aa_chilling_touch:OnRefresh(table)
	if IsServer() then 
		self.damage = self:GetTalentSpecialValueFor("bonus_damage")
		self.chill = self:GetTalentSpecialValueFor("move_speed_pct")
	end

	if self:GetParent() == self:GetCaster() and self:GetCaster():HasTalent("special_bonus_unique_aa_chilling_touch_2") then
		self.as = self:GetCaster():FindTalentValue("special_bonus_unique_aa_chilling_touch_2")
	else
		self.as = 0
	end 
end

function modifier_aa_chilling_touch:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        
    }
    return funcs
end

function modifier_aa_chilling_touch:OnAttackLanded(params)
    if IsServer() and params.attacker == self:GetParent() and params.target and params.target:GetTeam() ~= self:GetCaster():GetTeam() then
    	local damage = self:GetTalentSpecialValueFor("bonus_damage")
		if params.target:IsFrozenGeneric() then
			damage = damage * params.attacker:FindTalentValue("special_bonus_unique_aa_chilling_touch_1")
		end
		self:GetAbility():DealDamage(self:GetCaster(), params.target, damage, {damage_type=DAMAGE_TYPE_MAGICAL, damage_flags=DOTA_DAMAGE_FLAG_PROPERTY_FIRE}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
		local chill = math.max( self.chill - self:GetChillAmount(), 1 + ( GameRules.BasePlayers - HeroList:GetActiveHeroCount() ) )
    	params.target:AddChill(self:GetAbility(), self:GetCaster(), self:GetTalentSpecialValueFor("move_speed_duration"), chill )
    end
end

function modifier_aa_chilling_touch:GetModifierAttackSpeedBonus()
    return self.as
end

function modifier_aa_chilling_touch:GetEffectName()
	return "particles/units/heroes/hero_ancient_apparition/ancient_apparition_chilling_touch_buff.vpcf"
end