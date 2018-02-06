espirit_rock = class({})
LinkLuaModifier( "modifier_rock_punch", "heroes/hero_espirit/espirit_rock_punch.lua" ,LUA_MODIFIER_MOTION_NONE )

function espirit_rock:GetAOERadius()
	return self:GetTalentSpecialValueFor("radius")
end

function espirit_rock:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/espirit_spawn.vpcf", PATTACH_POINT, caster)
	ParticleManager:SetParticleControl(nfx, 0, point)
	ParticleManager:SetParticleControl(nfx, 1, point)
	ParticleManager:ReleaseParticleIndex(nfx)

    local enemies = caster:FindEnemyUnitsInRadius(point, self:GetTalentSpecialValueFor("radius"))
    for _,enemy in pairs(enemies) do
    	if not enemy:HasModifier("modifier_knockback") then
			enemy:ApplyKnockBack(enemy, 0.5, 0.5, 0, 300, caster, self)
			self:DealDamage(caster, enemy, self:GetTalentSpecialValueFor("damage"), {}, 0)
		end
    end

    local rock = caster:CreateSummon("npc_dota_earth_spirit_stone", point, self:GetTalentSpecialValueFor("rock_duration"))
	rock:SetForwardVector(caster:GetForwardVector())

	rock:AddNewModifier(caster, self, "modifier_rock_punch", {})    
end