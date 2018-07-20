undying_flesh_golem_bh = class({})

function undying_flesh_golem_bh:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_undying_flesh_golem_bh", {duration = self:GetTalentSpecialValueFor("duration")})
end

modifier_undying_flesh_golem_bh = class({})
LinkLuaModifier("modifier_undying_flesh_golem_bh", "heroes/hero_undying/undying_flesh_golem_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_undying_flesh_golem_bh:Oncreated()
	self.radius = self:GetTalentSpecialValueFor("radius")
	self.bHeal = self:GetTalentSpecialValueFor("death_heal") / 100
	self.mHeal = self:GetTalentSpecialValueFor("death_heal_creep") / 100
end

function modifier_undying_flesh_golem_bh:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH}
end

function modifier_undying_flesh_golem_bh:OnDeath(params)
	if not params.unit:IsSameTeam( self:GetParent() )
	and CalculateDistance( params.unit, self:GetParent() ) <= self.radius then
		local heal = self.mHeal
		local = self:GetCaster()
		if params.unit:IsRoundBoss then
			heal = self.bHeal
		end
		caster:HealEvent( caster:GetMaxHealth() * heal, self:GetAbility(), caster )
		ParticleManager:FireRopeParticle("particles/units/heroes/hero_undying/undying_soul_rip_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster, params.unit)
	end
end


function modifier_undying_flesh_golem_bh:IsAura()
	return true
end

function modifier_undying_flesh_golem_bh:GetModifierAura()
	return "modifier_alchemist_acid_spray_ebf_debuff"
end

function modifier_undying_flesh_golem_bh:GetAuraRadius()
	return self.radius
end

function modifier_undying_flesh_golem_bh:GetAuraDuration()
	return 0.5
end

function modifier_undying_flesh_golem_bh:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_undying_flesh_golem_bh:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_undying_flesh_golem_bh:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end