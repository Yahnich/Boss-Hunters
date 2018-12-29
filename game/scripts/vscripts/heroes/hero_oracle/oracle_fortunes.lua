oracle_fortunes = class({})
LinkLuaModifier("modifier_oracle_fortunes_channel", "heroes/hero_oracle/oracle_fortunes", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_oracle_fortunes_status_resist", "heroes/hero_oracle/oracle_fortunes", LUA_MODIFIER_MOTION_NONE)

function oracle_fortunes:IsStealable()
    return true
end

function oracle_fortunes:IsHiddenWhenStolen()
    return false
end

function oracle_fortunes:GetChannelTime()
    return self:GetTalentSpecialValueFor("max_duration")
end

function oracle_fortunes:GetAOERadius()
    return self:GetTalentSpecialValueFor("radius")
end

function oracle_fortunes:OnChannelFinish(bInterrupted)
	local caster = self:GetCaster()

	StopSoundOn("Hero_Oracle.FortunesEnd.Channel", caster)
	EmitSoundOn("Hero_Oracle.FortunesEnd.Attack", caster)
end

function oracle_fortunes:OnSpellStart()
	local caster = self:GetCaster()
	
	EmitSoundOn("Hero_Oracle.FortunesEnd.Channel", caster)

	caster:AddNewModifier(caster, self, "modifier_oracle_fortunes_channel", {Duration = self:GetTalentSpecialValueFor("max_duration")})
end

function oracle_fortunes:OnProjectileHit_ExtraData(hTarget, vLocation, table)
    local caster = self:GetCaster()
    local damage = table.damage
    local rootDuration = table.root

    local radius = self:GetTalentSpecialValueFor("radius")

    EmitSoundOnLocationWithCaster(vLocation, "Hero_Oracle.FortunesEnd.Target", caster)

    if hTarget then
    	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_oracle/oracle_fortune_aoe.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControl(nfx, 0, vLocation)
					ParticleManager:SetParticleControl(nfx, 2, Vector(radius, radius, radius))
					ParticleManager:SetParticleControl(nfx, 3, vLocation)
					ParticleManager:ReleaseParticleIndex(nfx)

    	local units = caster:FindAllUnitsInRadius(vLocation, radius)
    	for _,unit in pairs(units) do
    		if unit:GetTeam() == caster:GetTeam() then
    			unit:Purge(false, true, false, true, false)

    			if caster:HasTalent("special_bonus_unique_oracle_fortunes_1") then
    				unit:HealEvent(damage, self, caster, false)
    			end
    		else
    			local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_oracle/oracle_fortune_dmg.vpcf", PATTACH_POINT, caster)
							ParticleManager:SetParticleControlEnt(nfx, 0, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), true)
							ParticleManager:SetParticleControlEnt(nfx, 1, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), true)
							ParticleManager:SetParticleControl(nfx, 3, vLocation + Vector(0, 0, 100))
							ParticleManager:ReleaseParticleIndex(nfx)

    			unit:Purge(true, false, false, false, false)

    			if caster:HasTalent("special_bonus_unique_oracle_fortunes_2") then
    				unit:AddNewModifier(caster, self, "modifier_oracle_fortunes_status_resist", {Duration = rootDuration})
    			end

    			unit:Root(self, caster, rootDuration)
    			self:DealDamage(caster, unit, damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
    		end
    	end
    end
end

modifier_oracle_fortunes_channel = class({})
function modifier_oracle_fortunes_channel:OnCreated(table)
	if IsServer() then
		local parent = self:GetParent()

		self.target = self:GetAbility():GetCursorTarget()

		self.damageIncrement = ( self:GetTalentSpecialValueFor("damage") / self:GetDuration() ) * 0.1
		self.damage = 0
		
		self.root = self:GetTalentSpecialValueFor("min_duration")
		self.rootIncrement = ( ( self:GetTalentSpecialValueFor("max_duration") - self.root ) / self:GetDuration() ) * 0.1

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_oracle/oracle_fortune_channel.vpcf", PATTACH_POINT_FOLLOW, parent)
					ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_attack1", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 1, parent, PATTACH_POINT_FOLLOW, "attach_attack1", parent:GetAbsOrigin(), true)

		self:AttachEffect(nfx)

		self:StartIntervalThink(0.1)
	end
end

function modifier_oracle_fortunes_channel:OnRefresh(table)
	if IsServer() then
		self.target = self:GetAbility():GetCursorTarget()

		self.damageIncrement = ( self:GetTalentSpecialValueFor("damage") / self:GetDuration() ) * 0.1
		self.damage = 0
		
		self.root = self:GetTalentSpecialValueFor("min_duration")
		self.rootIncrement = ( ( self:GetTalentSpecialValueFor("max_duration") - self.root ) / self:GetDuration() ) * 0.1
		

		self:StartIntervalThink(0.1)
	end
end

function modifier_oracle_fortunes_channel:OnIntervalThink()
	if IsServer() then
		local parent = self:GetParent()

		if parent:IsChanneling() then
			self.damage = self.damage + self.damageIncrement
			self.root = self.root + self.rootIncrement
		else
			self:Destroy()
		end
	end
end

function modifier_oracle_fortunes_channel:OnRemoved()
	if IsServer() then
		local parent = self:GetParent()
		local ability = self:GetAbility()

		local extraData = {damage = self.damage, root = self.root}
		ability:FireTrackingProjectile("particles/units/heroes/hero_oracle/oracle_fortune_prj.vpcf", self.target, 1000, {extraData = extraData}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, false, true, 250)
	end
end

function modifier_oracle_fortunes_channel:IsDebuff()
	return false
end

modifier_oracle_fortunes_status_resist = class({})
function modifier_oracle_fortunes_status_resist:OnCreated(table)
	self.statusResist = self:GetCaster():FindTalentValue("special_bonus_unique_oracle_fortunes_2")
end

function modifier_oracle_fortunes_status_resist:OnRefresh(table)
	self.statusResist = self:GetCaster():FindTalentValue("special_bonus_unique_oracle_fortunes_2")
end

function modifier_oracle_fortunes_status_resist:DeclareFunctions()
	local funcs = {MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING}
	return funcs
end

function modifier_oracle_fortunes_status_resist:GetModifierStatusResistanceStacking()
	return self.statusResist
end

function modifier_oracle_fortunes_status_resist:IsDebuff()
	return true
end