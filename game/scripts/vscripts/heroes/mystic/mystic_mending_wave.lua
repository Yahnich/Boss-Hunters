mystic_mending_wave = class({})

function mystic_mending_wave:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	local bounces = self:GetTalentSpecialValueFor("bounces")
	local radius = self:GetTalentSpecialValueFor("search_radius")
	local targetTeam = DOTA_UNIT_TARGET_TEAM_FRIENDLY
	if caster:HasTalent("mystic_mending_wave_talent_1") then
		targetTeam = targetTeam + DOTA_UNIT_TARGET_TEAM_ENEMY
	end
	
	Timers:CreateTimers(0.3, function(à
		local potTargets = self:FindEnemyUnitsInRadius(target:GetAbsOrigin(), radius, {order = FIND_CLOSEST, team = targetTeam})
		for _, newTarget in pairs(potTargets) do
			target = newTarget
		end
	end
end