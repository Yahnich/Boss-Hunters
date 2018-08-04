boss27_protect_me = class({})

function boss27_protect_me:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	EmitSoundOn("Hero_Ursa.Overpower", caster)
	for id, bear in pairs( caster.bigBearsTable ) do
		if not bear:IsNull() and bear:IsAlive() then
			ParticleManager:FireTargetWarningParticle(bear)
		end
	end
	for id, bear in pairs( caster.smallBearsTable ) do
		if not bear:IsNull() and bear:IsAlive() then
			ParticleManager:FireTargetWarningParticle(bear)
		end
	end
	return true
end

function boss27_protect_me:OnSpellStart()
	local caster = self:GetCaster()
	
	local duration = self:GetSpecialValueFor("duration")
	caster:AddNewModifier(caster, self, "modifier_boss27_protect_me_buff", {duration = duration})
	
	caster:FindAbilityByName("boss27_destroy"):UseResources(false, false, true)
	caster:FindAbilityByName("boss27_kill_them"):UseResources(false, false, true)
end

modifier_boss27_protect_me_buff = class({})
LinkLuaModifier("modifier_boss27_protect_me_buff", "bosses/boss27/boss27_protect_me.lua", 0)

function modifier_boss27_protect_me_buff:OnCreated()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	self.red = self:GetSpecialValueFor("damage_reduction")
	if IsServer() then 
		self:StartIntervalThink(0.5)
		
		for id, bear in pairs( caster.bigBearsTable ) do
			if not bear:IsNull() and bear:IsAlive() then
				local linkFX = ParticleManager:CreateParticle("particles/bosses/boss27/boss27_protect_me_link.vpcf", PATTACH_POINT_FOLLOW, parent)
				ParticleManager:SetParticleControlEnt(linkFX, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(linkFX, 1, bear, PATTACH_POINT_FOLLOW, "attach_hitloc", bear:GetAbsOrigin(), true)
				self:AddEffect(linkFX)
				Timers:CreateTimer(0.25, function()
					if bear and not bear:IsNull() and not bear:IsAlive() then
						ParticleManager:ClearParticle(linkFX)
					end
					return 0.25
				end)
			end
		end
		for id, bear in pairs( caster.smallBearsTable ) do
			if not bear:IsNull() and bear:IsAlive() then
				local linkFX = ParticleManager:CreateParticle("particles/bosses/boss27/boss27_protect_me_link.vpcf", PATTACH_POINT_FOLLOW, parent)
				ParticleManager:SetParticleControlEnt(linkFX, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(linkFX, 1, bear, PATTACH_POINT_FOLLOW, "attach_hitloc", bear:GetAbsOrigin(), true)
				self:AddEffect(linkFX)
				Timers:CreateTimer(0.25, function()
					if not bear:IsAlive() then
						ParticleManager:ClearParticle(linkFX)
					end
					return 0.25
				end)
			end
		end
	end
end

function modifier_boss27_protect_me_buff:OnIntervalThink()
	if self:GetCaster():GetTotalBearCount() == 0 then 
		self:Destroy()
	end
end

function modifier_boss27_protect_me_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_boss27_protect_me_buff:GetModifierIncomingDamage_Percentage()
	return self.red
end

function modifier_boss27_protect_me_buff:GetEffectName()
	return "particles/econ/events/ti6/teleport_start_ti6_lvl3_shield.vpcf"
end

function modifier_boss27_protect_me_buff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end