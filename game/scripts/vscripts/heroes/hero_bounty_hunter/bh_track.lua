bh_track = class({})
LinkLuaModifier( "modifier_bh_track", "heroes/hero_bounty_hunter/bh_track.lua" ,LUA_MODIFIER_MOTION_NONE )

function bh_track:IsStealable()
	return true
end

function bh_track:IsHiddenWhenStolen()
	return false
end

function bh_track:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local maxUnits = caster:FindTalentValue("special_bonus_unique_bh_track_2")
	local currentUnits = 0

	EmitSoundOn("Hero_BountyHunter.Target", caster)

	self:Track(target)

	if caster:HasTalent("special_bonus_unique_bh_track_2") then
		local enemies = caster:FindEnemyUnitsInRadius(target:GetAbsOrigin(), 500)
		for _,enemy in pairs(enemies) do
			if enemy ~= target and currentUnits <= maxUnits then
				self:Track(enemy)
				currentUnits = currentUnits + 1
			end
		end
	end
end

function bh_track:Track(target)
	local caster = self:GetCaster()

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_cast.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT, "attach_attack2", caster:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(nfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(nfx)

	target:AddNewModifier(caster, self, "modifier_bh_track", {Duration = self:GetTalentSpecialValueFor("duration")})
end

modifier_bh_track = class({})
function modifier_bh_track:OnCreated(table)
    if IsServer() then
    	local caster = self:GetCaster()
    	local parent = self:GetParent()

    	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_trail.vpcf", PATTACH_POINT_FOLLOW, caster)
    				ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
    				ParticleManager:SetParticleControlEnt(nfx, 1, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
    	self:AttachEffect(nfx)

    	local nfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_shield.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)
					ParticleManager:SetParticleControlEnt(nfx2, 0, parent, PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
		self:AttachEffect(nfx2)

		self:StartIntervalThink(0.1)
    end
end

function modifier_bh_track:OnIntervalThink()
	AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), 150, 0.1, false)
end

function modifier_bh_track:DeclareFunctions()
    local funcs = {MODIFIER_EVENT_ON_DEATH}
    return funcs
end

---Houth says to reduce gold from nonbosses, IsRoundBoss()
function modifier_bh_track:OnDeath(params)
	if IsServer() then
		local caster = self:GetCaster()
		if params.unit == self:GetParent() and params.unit:HasModifier("modifier_bh_track") then
			local allies = caster:FindFriendlyUnitsInRadius(self:GetParent():GetAbsOrigin(), FIND_UNITS_EVERYWHERE)
			for _,ally in pairs(allies) do
				if ally:IsHero() and ally ~= self:GetCaster() then
					local gold = self:GetTalentSpecialValueFor("bonus_gold")
					if not params.unit:IsRoundBoss() then
						gold = gold * self:GetSpecialValueFor("trash_gold_reduc")/100
					end
					ally:AddGold(gold)
				end
			end

			local gold = self:GetTalentSpecialValueFor("bonus_gold_self")
			if not params.unit:IsRoundBoss() then
				gold = gold * ( 100 - self:GetSpecialValueFor("trash_gold_reduc"))/100
			end
			caster:AddGold(self:GetTalentSpecialValueFor("bonus_gold_self"))
		end
	end
end