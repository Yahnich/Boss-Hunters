druid_bear_return = class({})

function druid_bear_return:IsStealable()
    return false
end

function druid_bear_return:IsHiddenWhenStolen()
    return false
end

function druid_bear_return:OnSpellStart()
	local caster = self:GetCaster()
	local owner = caster:GetOwner()

	EmitSoundOn("LoneDruid_SpiritBear.ReturnStart", caster)
	EmitSoundOn("LoneDruid_SpiritBear.Return", caster)

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_bear_blink_end.vpcf", PATTACH_POINT, owner)
				ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(nfx)

	FindClearSpaceForUnit(caster, owner:GetAbsOrigin(), true)
end
