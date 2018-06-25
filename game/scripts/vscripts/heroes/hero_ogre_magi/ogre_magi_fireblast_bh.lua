ogre_magi_fireblast_bh = class({})

function ogre_magi_fireblast_bh:IsStealable()
	return true
end

function ogre_magi_fireblast_bh:IsHiddenWhenStolen()
	return false
end

function ogre_magi_fireblast_bh:GetCooldown(nLevel)
    local cooldown = self.BaseClass.GetCooldown( self, nLevel )
    if self.newCoolDown then
    	cooldown = cooldown - self.newCoolDown
    end
    return cooldown
end

function ogre_magi_fireblast_bh:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ogre_magi/ogre_magi_fireblast_cast.vpcf", PATTACH_POINT_FOLLOW, caster)
				ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack3", caster:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(nfx)
				
	return true
end

function ogre_magi_fireblast_bh:OnSpellStart()
	EmitSoundOn("Hero_OgreMagi.Fireblast.Cast", self:GetCaster())

	self:Fireblast()
end

function ogre_magi_fireblast_bh:Fireblast()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	EmitSoundOn("Hero_OgreMagi.Fireblast.Target", target)
	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ogre_magi/ogre_magi_fireblast.vpcf", PATTACH_POINT_FOLLOW, caster)
				ParticleManager:SetParticleControlEnt(nfx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
				ParticleManager:SetParticleControl(nfx, 1, target:GetAbsOrigin())
				ParticleManager:ReleaseParticleIndex(nfx)

	self:Stun(target, self:GetTalentSpecialValueFor("duration"), false)
	self:DealDamage(caster, target, self:GetTalentSpecialValueFor("damage"), {}, 0)
end