boss_leshrac_inevitable_end = class({})

function boss_leshrac_inevitable_end:GetIntrinsicModifierName()
	return "modifier_boss_leshrac_inevitable_end"
end

modifier_boss_leshrac_inevitable_end = class({})
LinkLuaModifier( "modifier_boss_leshrac_inevitable_end", "bosses/boss_leshrac/boss_leshrac_inevitable_end", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_leshrac_inevitable_end:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH}
end

function modifier_boss_leshrac_inevitable_end:OnDeath(params)
	if params.attacker == self:GetParent() then
		params.attacker:RefreshAllCooldowns( false, false )
		ParticleManager:FireRopeParticle("particles/items_fx/year_beast_refresher.vpcf", PATTACH_POINT_FOLLOW, params.attacker, params.unit )
		ParticleManager:FireParticle("particles/items2_fx/refresher.vpcf", PATTACH_POINT_FOLLOW, params.attacker )
		EmitSoundOn( "Hero_Leshrac.PartyOn", params.attacker )
	end
end

function modifier_boss_leshrac_inevitable_end:IsHidden()
	return true
end