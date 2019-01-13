wisp_worm_hole = class({})
LinkLuaModifier("modifier_wisp_worm_hole", "heroes/hero_wisp/wisp_worm_hole", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_wisp_worm_hole_end", "heroes/hero_wisp/wisp_worm_hole", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_wisp_worm_hole_sickness", "heroes/hero_wisp/wisp_worm_hole", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_wisp_worm_hole_speed", "heroes/hero_wisp/wisp_worm_hole", LUA_MODIFIER_MOTION_NONE)

function wisp_worm_hole:IsStealable()
    return true
end

function wisp_worm_hole:IsHiddenWhenStolen()
    return false
end

function wisp_worm_hole:GetChannelTime()
    return self:GetTalentSpecialValueFor("channel_time")
end

function wisp_worm_hole:GetChannelAnimation()
    return ACT_DOTA_GENERIC_CHANNEL_1
end

function wisp_worm_hole:GetChannelAnimation()
    return ACT_DOTA_GENERIC_CHANNEL_1
end

function wisp_worm_hole:OnSpellStart()
	local caster = self:GetCaster()

	self.nfx =  ParticleManager:CreateParticle("particles/units/heroes/hero_wisp/wisp_relocate_channel.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControlEnt(self.nfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
end

function wisp_worm_hole:OnChannelFinish(bInterrupted)
	ParticleManager:ClearParticle(self.nfx)
	if not bInterrupted then
		local caster = self:GetCaster()
		local point = self:GetCursorPosition()

		local duration = self:GetTalentSpecialValueFor("duration")

		if self.startPortal and self.endPortal then
			self.startPortal:Destroy()
			self.endPortal:Destroy()
			self.startPortal = false
			self.endPortal = false
		end

		self.startPortal = CreateModifierThinker(caster, self, "modifier_wisp_worm_hole", {Duration = duration}, caster:GetAbsOrigin(), caster:GetTeam(), false)
		self.endPortal = CreateModifierThinker(caster, self, "modifier_wisp_worm_hole_end", {Duration = duration}, point, caster:GetTeam(), false)
	
		EmitSoundOn("Hero_Wisp.Relocate", self.startPortal)
		EmitSoundOn("Hero_Wisp.Relocate", self.endPortal)

	end
	--return true
end

modifier_wisp_worm_hole = class({})

function modifier_wisp_worm_hole:OnCreated(table)
	if IsServer() then
		local nfx = ParticleManager:CreateParticle("particles/econ/items/wisp/wisp_relocate_marker_ti7.vpcf", PATTACH_POINT, self:GetCaster())
					ParticleManager:SetParticleControl(nfx, 0, self:GetParent():GetAbsOrigin())
		self:AttachEffect(nfx)

		self.radius = self:GetTalentSpecialValueFor("radius")

		self.talentRadius = self:GetCaster():FindTalentValue("special_bonus_unique_wisp_worm_hole_1")

		AddFOWViewer(self:GetCaster():GetTeam(), self:GetParent():GetAbsOrigin(), self.radius, self:GetDuration(), true)

		self:StartIntervalThink(0.1)
	end
end

function modifier_wisp_worm_hole:OnIntervalThink()
	local caster = self:GetCaster()
	local point = self:GetParent():GetAbsOrigin()
	if self:GetAbility().endPortal then
		local oppoPoint = self:GetAbility().endPortal:GetAbsOrigin()

		local sickDuration = self:GetTalentSpecialValueFor("sickness_duration")

		local allies = caster:FindFriendlyUnitsInRadius(point, self.radius)
		for _,ally in pairs(allies) do
			if not ally:HasModifier("modifier_wisp_worm_hole_sickness") then

				EmitSoundOn("Hero_Wisp.TeleportIn", self:GetParent())

				local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_wisp/wisp_relocate_teleport.vpcf", PATTACH_POINT, caster)
							ParticleManager:SetParticleControl(nfx, 0, oppoPoint + Vector(0,0,200))
							ParticleManager:SetParticleControl(nfx, 1, oppoPoint)
							ParticleManager:ReleaseParticleIndex(nfx)

				if caster:HasTalent("special_bonus_unique_wisp_worm_hole_1") then
					local enemies = caster:FindEnemyUnitsInRadius(point, self.talentRadius)
					for _,enemy in pairs(enemies) do
						enemy:ApplyKnockBack(point, 0.5, 0.5, self.talentRadius, 100, caster, self:GetAbility(), false)
					end
				end

				if caster:HasTalent("special_bonus_unique_wisp_worm_hole_2") then
					ally:AddNewModifier(caster, self:GetAbility(), "modifier_wisp_worm_hole_speed", {Duration = caster:FindTalentValue("special_bonus_unique_wisp_worm_hole_2", "duration")})
				end

				ally:AddNewModifier(caster, self:GetAbility(), "modifier_wisp_worm_hole_sickness", {Duration = sickDuration})
				FindClearSpaceForUnit(ally, oppoPoint, true)
			end
		end
	end
end

function modifier_wisp_worm_hole:OnRemoved()
	if IsServer() then
		self:GetAbility().startPortal = false
	end
end

modifier_wisp_worm_hole_end = class({})

function modifier_wisp_worm_hole_end:OnCreated(table)
	if IsServer() then
<<<<<<< HEAD
		local nfx = ParticleManager:CreateParticle("particles/econ/items/wisp/wisp_relocate_marker_ti7_endpoint.vpcf", PATTACH_POINT, self:GetCaster())
=======
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_wisp/wisp_worm_hole_end.vpcf", PATTACH_POINT, self:GetCaster())
>>>>>>> 4359de20b3a163f67394a2f7c5338c27f7fa8374
					ParticleManager:SetParticleControl(nfx, 0, self:GetParent():GetAbsOrigin())
		self:AttachEffect(nfx)

		self.radius = self:GetTalentSpecialValueFor("radius")

		self.talentRadius = self:GetCaster():FindTalentValue("special_bonus_unique_wisp_worm_hole_1")

		AddFOWViewer(self:GetCaster():GetTeam(), self:GetParent():GetAbsOrigin(), self.radius, self:GetDuration(), true)

		self:StartIntervalThink(0.1)
	end
end

function modifier_wisp_worm_hole_end:OnIntervalThink()
	local caster = self:GetCaster()
	local point = self:GetParent():GetAbsOrigin()
	if self:GetAbility().startPortal then
		local oppoPoint = self:GetAbility().startPortal:GetAbsOrigin()

		local sickDuration = self:GetTalentSpecialValueFor("sickness_duration")

		local allies = caster:FindFriendlyUnitsInRadius(point, self.radius)
		for _,ally in pairs(allies) do
			if not ally:HasModifier("modifier_wisp_worm_hole_sickness") then

				EmitSoundOn("Hero_Wisp.TeleportIn", self:GetParent())

				local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_wisp/wisp_relocate_teleport.vpcf", PATTACH_POINT, caster)
							ParticleManager:SetParticleControl(nfx, 0, oppoPoint + Vector(0,0,200))
							ParticleManager:SetParticleControl(nfx, 1, oppoPoint)
							ParticleManager:ReleaseParticleIndex(nfx)

				ally:AddNewModifier(caster, self:GetAbility(), "modifier_wisp_worm_hole_sickness", {Duration = sickDuration})
				
				if caster:HasTalent("special_bonus_unique_wisp_worm_hole_1") then
					local enemies = caster:FindEnemyUnitsInRadius(point, self.talentRadius)
					for _,enemy in pairs(enemies) do
						enemy:ApplyKnockBack(point, 0.5, 0.5, self.talentRadius, 100, caster, self:GetAbility(), false)
					end
				end

				if caster:HasTalent("special_bonus_unique_wisp_worm_hole_2") then
					ally:AddNewModifier(caster, self:GetAbility(), "modifier_wisp_worm_hole_speed", {Duration = caster:FindTalentValue("special_bonus_unique_wisp_worm_hole_2", "duration")})
				end

				GridNav:DestroyTreesAroundPoint(oppoPoint, self.radius, false)
				FindClearSpaceForUnit(ally, oppoPoint, true)
			end
		end
	end
end

function modifier_wisp_worm_hole_end:OnRemoved()
	if IsServer() then
		self:GetAbility().endPortal = false
	end
end

modifier_wisp_worm_hole_sickness = class({})

function modifier_wisp_worm_hole_sickness:OnCreated(table)
	if IsServer() then
		self:SetDuration(self:GetDuration(), true)
	end
end

function modifier_wisp_worm_hole_sickness:IsDebuff()
	return true
end

modifier_wisp_worm_hole_speed = class({})

function modifier_wisp_worm_hole_speed:OnCreated(table)
	self.bonus_ms = self:GetCaster():FindTalentValue("special_bonus_unique_wisp_worm_hole_2", "bonus_ms")
end

function modifier_wisp_worm_hole_speed:OnRefresh(table)
	self.bonus_ms = self:GetCaster():FindTalentValue("special_bonus_unique_wisp_worm_hole_2", "bonus_ms")
end

function modifier_wisp_worm_hole_speed:DeclareFunctions()
	local funcs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
	return funcs
end

function modifier_wisp_worm_hole_speed:GetModifierMoveSpeedBonus_Percentage()
	return self.bonus_ms
end

function modifier_wisp_worm_hole_speed:IsDebuff()
	return false
end

function modifier_wisp_worm_hole_speed:IsPurgable()
	return true
end