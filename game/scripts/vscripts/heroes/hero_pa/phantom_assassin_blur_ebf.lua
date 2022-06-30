phantom_assassin_blur_ebf = class({})

function phantom_assassin_blur_ebf:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_NO_TARGET
end

function phantom_assassin_blur_ebf:GetCastPoint( )
	if self:GetCaster():HasScepter() then
		return 0
	else
		return self.BaseClass.GetCastPoint( self )
	end
end

function phantom_assassin_blur_ebf:GetCooldown( iLvl )
	return self.BaseClass.GetCooldown( self, iLvl )
end

function phantom_assassin_blur_ebf:GetIntrinsicModifierName()
    return "modifier_phantom_assassin_blur_ebf"
end

function phantom_assassin_blur_ebf:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier( caster, self, "modifier_phantom_assassin_blur_fade", {duration = self:GetTalentSpecialValueFor("duration")})
	caster:EmitSound("Hero_PhantomAssassin.Blur")
end

LinkLuaModifier( "modifier_phantom_assassin_blur_ebf", "heroes/hero_pa/phantom_assassin_blur_ebf", LUA_MODIFIER_MOTION_NONE )
modifier_phantom_assassin_blur_ebf = class({})

function modifier_phantom_assassin_blur_ebf:OnCreated()
    self:OnRefresh()
end

function modifier_phantom_assassin_blur_ebf:OnRefresh()
    self.evasion = self:GetTalentSpecialValueFor("bonus_evasion")
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_pa_blur_1")
	
	if self.talent1 and IsServer() then
		self.t1Radius = self:GetCaster():FindTalentValue("special_bonus_unique_pa_blur_1")
		self:OnIntervalThink()
		self:StartIntervalThink(0.33)
	end
end

function modifier_phantom_assassin_blur_ebf:OnIntervalThink()
	local caster = self:GetCaster()
	if not self.talent1 then
		self:StartIntervalThink(-1)
		return
	end
	if caster:HasModifier("modifier_phantom_assassin_blur_fade") then return end
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), self.t1Radius ) ) do
		return
	end
	if not caster:HasModifier("modifier_phantom_assassin_blur_fade_lesser") then 
		caster:AddNewModifier( caster, self:GetAbility(), "modifier_phantom_assassin_blur_fade_lesser", {} )
	end
end

function modifier_phantom_assassin_blur_ebf:DeclareFunctions()
    funcs = {
               MODIFIER_PROPERTY_EVASION_CONSTANT,
			   MODIFIER_EVENT_ON_DEATH
            }
    return funcs
end

function modifier_phantom_assassin_blur_ebf:GetModifierEvasion_Constant(params)
    return self.evasion
end

function modifier_phantom_assassin_blur_ebf:OnDeath(params)
	if self:GetParent():HasScepter() and params.attacker == self:GetParent() and not params.unit:IsMinion() then
		params.attacker:RefreshAllCooldowns()
	end
end

function modifier_phantom_assassin_blur_ebf:IsHidden()
	return true
end

modifier_phantom_assassin_blur_fade = class({})
LinkLuaModifier( "modifier_phantom_assassin_blur_fade", "heroes/hero_pa/phantom_assassin_blur_ebf", LUA_MODIFIER_MOTION_NONE )
function modifier_phantom_assassin_blur_fade:OnCreated()
	self:OnRefresh()
end

function modifier_phantom_assassin_blur_fade:OnRefresh()
	self.break_delay = self:GetTalentSpecialValueFor("break_delay")
end

function modifier_phantom_assassin_blur_fade:DeclareFunctions()
	return { MODIFIER_EVENT_ON_TAKEDAMAGE }
end

function modifier_phantom_assassin_blur_fade:CheckState()
	return {[MODIFIER_STATE_INVISIBLE] = true,
			[MODIFIER_STATE_UNTARGETABLE] = true,
			[MODIFIER_STATE_INVULNERABLE] = self:GetCaster():HasScepter()}
end

function modifier_phantom_assassin_blur_fade:OnTakeDamage(params)
	if params.attacker == self:GetParent() and not params.unit:IsMinion() and ( GameRules:GetGameTime() - self:GetLastAppliedTime( ) ) > self.break_delay then
		self:Destroy()
	end
end


function modifier_phantom_assassin_blur_fade:GetStatusEffectName()
	return "particles/status_fx/status_effect_phantom_assassin_active_blur.vpcf"
end

function modifier_phantom_assassin_blur_fade:StatusEffectPriority()
	return 10
end

function modifier_phantom_assassin_blur_fade:GetEffectName()
	return "particles/units/heroes/hero_phantom_assassin/phantom_assassin_active_blur.vpcf"
end


modifier_phantom_assassin_blur_fade_lesser = class(modifier_phantom_assassin_blur_fade)
LinkLuaModifier( "modifier_phantom_assassin_blur_fade_lesser", "heroes/hero_pa/phantom_assassin_blur_ebf", LUA_MODIFIER_MOTION_NONE )

function modifier_phantom_assassin_blur_fade_lesser:OnCreated()
	self.radius = self:GetCaster():FindTalentValue("special_bonus_unique_pa_blur_1")
	self.break_delay = self:GetCaster():FindTalentValue("special_bonus_unique_pa_blur_1", "delay")
	self.creationTime = self:GetLastAppliedTime( ) 
	
	if IsServer() then self:StartIntervalThink(0.25) end
end

function modifier_phantom_assassin_blur_fade_lesser:OnIntervalThink()
	local caster = self:GetCaster()
	if (GameRules:GetGameTime() - self.creationTime) <= self.break_delay then return end
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), self.radius ) ) do
		if not enemy:IsMinion() then
			self:Destroy()
			return
		end
	end
end