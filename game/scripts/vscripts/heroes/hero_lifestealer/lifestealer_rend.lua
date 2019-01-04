lifestealer_rend = class({})
LinkLuaModifier("modifier_lifestealer_rend_autocast", "heroes/hero_lifestealer/lifestealer_rend", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lifestealer_rend_debuff", "heroes/hero_lifestealer/lifestealer_rend", LUA_MODIFIER_MOTION_NONE)

function lifestealer_rend:IsStealable()
    return false
end

function lifestealer_rend:IsHiddenWhenStolen()
    return false
end

function lifestealer_rend:GetCastPoint()
	return 0
end

function lifestealer_rend:GetManaCost( iLvl )
	if self:GetCaster():HasTalent("special_bonus_unique_lifestealer_rend_1") then
		return self:GetCaster():FindTalentValue("special_bonus_unique_lifestealer_rend_1") 
	else
		return self.BaseClass.GetManaCost( self, iLvl )
	end
end

function lifestealer_rend:GetIntrinsicModifierName()
    return "modifier_lifestealer_rend_autocast"
end

function lifestealer_rend:OnSpellStart()
	local target = self:GetCursorTarget()
	self.forceCast = true
	self:RefundManaCost()
	self:GetCaster():SetAttacking( target )
	self:GetCaster():MoveToTargetToAttack( target )
end

function lifestealer_rend:GetCastRange(location, target)
    return self:GetCaster():GetAttackRange()
end

modifier_lifestealer_rend_autocast = class({})

function modifier_lifestealer_rend_autocast:IsHidden()
    return true
end

if IsServer() then
	function modifier_lifestealer_rend_autocast:OnCreated()
		self.duration = self:GetTalentSpecialValueFor("duration")
	end
	
	function modifier_lifestealer_rend_autocast:OnRefresh()
		self.duration = self:GetTalentSpecialValueFor("duration")
	end
	
    function modifier_lifestealer_rend_autocast:DeclareFunctions()
        return {MODIFIER_EVENT_ON_ATTACK_LANDED}
    end
    
    function modifier_lifestealer_rend_autocast:OnAttackLanded(params)
        if params.attacker == self:GetParent() and params.target and ( self:GetAbility():GetAutoCastState() or self:GetAbility().forceCast ) then
            if not params.target:IsMagicImmune() then
				params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_lifestealer_rend_debuff", {Duration = self.duration}):AddIndependentStack()
				self:GetAbility():SpendMana()
				self:GetAbility().forceCast = false
            end
        end
    end
end

modifier_lifestealer_rend_debuff = class({})

if IsServer() then
    function modifier_lifestealer_rend_debuff:OnCreated()
        self:StartIntervalThink(1)
    end
    
    function modifier_lifestealer_rend_debuff:OnIntervalThink()
        self:GetCaster():Lifesteal(self:GetAbility(), self:GetTalentSpecialValueFor("heal"), self:GetTalentSpecialValueFor("damage") * self:GetStackCount(), self:GetParent(), self:GetAbility():GetAbilityDamageType(), DOTA_LIFESTEAL_SOURCE_ABILITY, true)
    end
end

function modifier_lifestealer_rend_debuff:GetEffectName()
    return "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture.vpcf"
end

function modifier_lifestealer_rend_debuff:IsDebuff()
    return true
end