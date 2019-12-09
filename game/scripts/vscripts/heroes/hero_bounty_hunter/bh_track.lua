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
	
	-- deprecated multishot talent
	-- if caster:HasTalent("special_bonus_unique_bh_track_2") then
		-- local enemies = caster:FindEnemyUnitsInRadius(target:GetAbsOrigin(), 500)
		-- for _,enemy in pairs(enemies) do
			-- if enemy ~= target and currentUnits <= maxUnits then
				-- self:Track(enemy)
				-- currentUnits = currentUnits + 1
			-- end
		-- end
	-- end
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
	local caster = self:GetCaster()
   	local parent = self:GetParent()
	self.crit = self:GetTalentSpecialValueFor("critical_strike")
	self.gold = self:GetTalentSpecialValueFor("bonus_gold")
	self.bhGold = self:GetTalentSpecialValueFor("self_gold")
	self.trashGold = self:GetTalentSpecialValueFor("trash_gold_reduc")/100
	self.bossGold = self:GetTalentSpecialValueFor("boss_gold_inc")/100
	self.talent = caster:HasTalent("special_bonus_unique_bh_track_2")
    if IsServer() then
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
    local funcs = { MODIFIER_EVENT_ON_DEATH,
				    MODIFIER_PROPERTY_PREATTACK_TARGET_CRITICALSTRIKE,
					MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
    return funcs
end

function modifier_bh_track:GetModifierPreAttack_Target_CriticalStrike( params )
	local crit = self.crit
	if self.talent and params.target:IsMinion() then
		crit = crit * 2
	end
	return crit
end

function modifier_bh_track:GetModifierIncomingDamage_Percentage( params )
	if params.attacker == self:GetCaster() and params.inflictor then
		local crit = self.crit - 100
		if self.talent and params.target:IsMinion() then
			crit = crit * 2
		end
		SendOverheadEventMessage(params.target:GetPlayerOwner(), OVERHEAD_ALERT_CRITICAL, params.target, params.original_damage * crit/100, params.target:GetPlayerOwner())
		return crit
	end
end

function modifier_bh_track:OnDeath(params)
	if IsServer() then
		local caster = self:GetCaster()
		if params.unit == self:GetParent() then
			local gold = self.gold
			local bhGold = self.gold + self.bhGold
			if params.unit:IsMinion() then
				gold = gold * self.trashGold
				bhGold = bhGold * self.trashGold
			elseif params.unit:IsBoss() then
				gold = gold * self.bossGold
				bhGold = bhGold * self.bossGold
			end
			local allies = caster:FindFriendlyUnitsInRadius(self:GetParent():GetAbsOrigin(), FIND_UNITS_EVERYWHERE)
			for _,ally in pairs(allies) do
				if ally:IsRealHero() then
					if ally == caster then
						ally:AddGold( math.floor( bhGold ) )
					else
						ally:AddGold(gold)
					end
				end
			end
		end
	end
end