razor_unstable_current_bh = class({})

function razor_unstable_current_bh:GetCooldown( iLvl )
	local cd = self.BaseClass.GetCooldown( self, iLvl )
	if self:GetCaster():HasTalent("special_bonus_unique_razor_unstable_current_bh_2") then
		cd = cd + self:GetCaster():FindTalentValue("special_bonus_unique_razor_unstable_current_bh_2")
	end
	return cd
end

function razor_unstable_current_bh:OnSpellStart()
	local caster = self:GetCaster()
	caster:Dispel( caster, true )
end

function razor_unstable_current_bh:GetIntrinsicModifierName()
	return "modifier_razor_unstable_current_bh"
end

modifier_razor_unstable_current_bh = class({})
LinkLuaModifier("modifier_razor_unstable_current_bh", "heroes/hero_razor/razor_unstable_current_bh", LUA_MODIFIER_MOTION_NONE)
function modifier_razor_unstable_current_bh:OnCreated()
	self.damage = self:GetSpecialValueFor("damage")
	self.duration = self:GetSpecialValueFor("slow_duration")
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_razor_unstable_current_bh_1")
	self.talent1CD = self:GetCaster():FindTalentValue("special_bonus_unique_razor_unstable_current_bh_1")
end

function modifier_razor_unstable_current_bh:OnRefresh()
	self.damage = self:GetSpecialValueFor("damage")
	self.duration = self:GetSpecialValueFor("slow_duration")
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_razor_unstable_current_bh_1")
	self.talent1CD = self:GetCaster():FindTalentValue("special_bonus_unique_razor_unstable_current_bh_1")
end

function modifier_razor_unstable_current_bh:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ABSORB_SPELL
	}
	return funcs
end

function modifier_razor_unstable_current_bh:GetAbsorbSpell(params)
	if self:GetAbility():IsCooldownReady() then
		local caster = params.ability:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		ability:DealDamage( parent, caster, self.damage )
		caster:Dispel( parent, false )
		caster:Paralyze(ability, parent, self.duration)
		ParticleManager:FireRopeParticle("particles/units/heroes/hero_razor/razor_unstable_current.vpcf", PATTACH_POINT_FOLLOW, parent, caster )
		if self.talent1 then
			for i = 0, parent:GetAbilityCount() - 1 do
				local ability = parent:GetAbilityByIndex( i )
				if ability then
					ability:ModifyCooldown( self.talent1CD )
				end
			end
		end
		ability:CastSpell()
		return 1
	end
end

function modifier_razor_unstable_current_bh:IsPurgeException()
	return false
end

function modifier_razor_unstable_current_bh:IsPurgable()
	return false
end

function modifier_razor_unstable_current_bh:IsHidden()
	return true
end