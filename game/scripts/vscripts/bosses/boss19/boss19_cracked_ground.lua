boss19_cracked_ground = class({})

function boss19_cracked_ground:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_status_immunity", {duration = self:GetChannelTime() - 0.01})
	ParticleManager:FireWarningParticle(caster:GetAbsOrigin(), 600)
	self.chargeFX = ParticleManager:CreateParticle("particles/bosses/boss19/boss19_cracked_ground_charge.vpcf", PATTACH_POINT_FOLLOW, caster)
	ParticleManager:SetParticleControl(self.chargeFX, 0, caster:GetAbsOrigin())
	return true
end

function boss19_cracked_ground:OnChannelFinish(bInterrupted)
	if not bInterrupted then
		table.insert(self.useTable, true)
		local caster = self:GetCaster()
		caster:AddNewModifier(caster, self, "modifier_boss19_cracked_ground_thinker", {duration = self:GetSpecialValueFor("duration")})
	end
	AddFOWViewer(DOTA_TEAM_GOODGUYS, self:GetCaster():GetAbsOrigin(), 800, self:GetSpecialValueFor("duration"), false)
	ParticleManager:DestroyParticle(self.chargeFX, false)
	ParticleManager:ReleaseParticleIndex(self.chargeFX)
end


modifier_boss19_cracked_ground_thinker = class({})
LinkLuaModifier("modifier_boss19_cracked_ground_thinker", "bosses/boss19/boss19_cracked_ground.lua", 0)

if IsServer() then
	function modifier_boss19_cracked_ground_thinker:OnCreated()
		self.ticker = self:GetSpecialValueFor("spike_ticker")
		self:StartIntervalThink( self.ticker )
		self.spikeDir = self:GetParent():GetForwardVector()
		self.spikeCount = self:GetSpecialValueFor("spike_count")
		self.spikeAngle = ToRadians(360/self.spikeCount)
		self.spikeDirSpeed = ToRadians(360 / (self:GetDuration()/self.ticker))
		self.chasm = caster:FindAbilityByName("boss19_chasm")
	end
	
	function modifier_boss19_cracked_ground_thinker:OnIntervalThink()
		local spikeAngle = self.spikeDir
		local caster = self:GetCaster()
		local counter = 1
		for i = 1, self.spikeCount do
			counter = counter + 1
			caster:SetCursorPosition(caster:GetAbsOrigin() + spikeAngle * 200)
			self.chasm:OnSpellStart()
			spikeAngle = RotateVector2D(spikeAngle, self.spikeAngle)
		end
		self.spikeDir = RotateVector2D(self.spikeDir, self.spikeDirSpeed)
	end
end

function modifier_boss19_cracked_ground_thinker:CheckState()
	return {[MODIFIER_STATE_ROOTED] = true,
			[MODIFIER_STATE_DISARMED] = true,
			[MODIFIER_STATE_SILENCED] = true,}
end

function modifier_boss19_cracked_ground_thinker:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_boss19_cracked_ground_thinker:GetModifierIncomingDamage_Percentage()
	return self:GetSpecialValueFor("damage_reduction")
end