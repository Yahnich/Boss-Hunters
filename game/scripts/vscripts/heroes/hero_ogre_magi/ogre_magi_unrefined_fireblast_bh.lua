ogre_magi_unrefined_fireblast_bh = class({})

function ogre_magi_unrefined_fireblast_bh:IsStealable()
	return true
end

function ogre_magi_unrefined_fireblast_bh:IsHiddenWhenStolen()
	return false
end

function ogre_magi_unrefined_fireblast_bh:OnInventoryContentsChanged()
	if self:GetCaster():HasScepter() then
		self:SetHidden(false)
		self:SetActivated(true)
	else
		self:SetHidden(true)
		self:SetActivated(false)
	end
end

function ogre_magi_unrefined_fireblast_bh:GetBehavior()
	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE
	end

	return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_HIDDEN + DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE
end

function ogre_magi_unrefined_fireblast_bh:GetManaCost()
    local manaCost = self:GetCaster():GetMana()*self:GetTalentSpecialValueFor("mana_cost")/100
    return manaCost
end

function ogre_magi_unrefined_fireblast_bh:GetCooldown(nLevel)
    local cooldown = self.BaseClass.GetCooldown( self, nLevel )
    if self.newCoolDown then
    	cooldown = cooldown - self.newCoolDown
    end
    return cooldown
end

function ogre_magi_unrefined_fireblast_bh:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ogre_magi/ogre_magi_fireblast_cast.vpcf", PATTACH_POINT_FOLLOW, caster)
				ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack3", caster:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(nfx)
				
	return true
end

function ogre_magi_unrefined_fireblast_bh:OnSpellStart()
	EmitSoundOn("Hero_OgreMagi.Fireblast.Cast", self:GetCaster())
	self:Fireblast()
end

function ogre_magi_unrefined_fireblast_bh:Fireblast()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerSpellAbsorb(self) then return end
	EmitSoundOn("Hero_OgreMagi.Fireblast.Target", target)
	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ogre_magi/ogre_magi_fireblast.vpcf", PATTACH_POINT_FOLLOW, caster)
				ParticleManager:SetParticleControlEnt(nfx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
				ParticleManager:SetParticleControl(nfx, 1, target:GetAbsOrigin())
				ParticleManager:ReleaseParticleIndex(nfx)

	self:Stun(target, self:GetTalentSpecialValueFor("duration"), false)
	self:DealDamage(caster, target, self:GetTalentSpecialValueFor("damage"), {}, 0)
end