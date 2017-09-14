justicar_blessed_aegis = class({})

function justicar_blessed_aegis:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	local cast = ParticleManager:CreateParticle("particles/econ/items/omniknight/hammer_ti6_immortal/omniknight_purification_immortal_cast.vpcf", PATTACH_POINT_FOLLOW, caster)
	ParticleManager:SetParticleControl(cast, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(cast, 1, target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(cast)
	
	local launch = ParticleManager:CreateParticle("particles/heroes/justicar/justicar_blessed_aegis_launch.vpcf", PATTACH_POINT_FOLLOW, target)
	ParticleManager:SetParticleControl(launch, 2, Vector(target:GetModelRadius() * 1.5,0,0))
	ParticleManager:ReleaseParticleIndex(launch)
	
	EmitSoundOn("Hero_Omniknight.Repel", target)
	
	local barrier = self:GetTalentSpecialValueFor("barrier") + caster:GetInnerSun()
	caster:ResetInnerSun()
	if caster:HasTalent("justicar_blessed_aegis_talent_1") then
		barrier = barrier + caster:FindTalentValue("justicar_blessed_aegis_talent_1") / 100 * caster:GetHealth()
	end
	print(barrier)
	target:AddNewModifier(caster, self, "modifier_justicar_blessed_aegis_barrier", {barrier = barrier})
end

modifier_justicar_blessed_aegis_barrier = class({})
LinkLuaModifier("modifier_justicar_blessed_aegis_barrier", "heroes/justicar/justicar_blessed_aegis.lua", 0)

if IsServer() then
	function modifier_justicar_blessed_aegis_barrier:OnCreated(kv)
		self.barrier = kv.barrier or 0
		print(kv.barrier)
		self.particle = ParticleManager:CreateParticle("particles/heroes/justicar/justicar_blessed_aegis.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControlEnt(self.particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_origin", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(self.particle, 2, Vector(self:GetParent():GetModelRadius() * 1.1,0,0))
		self:AddParticle(self.particle, false, false, 0, false, false)
		if IsServer() then self:StartIntervalThink(0.3) end
	end

	function modifier_justicar_blessed_aegis_barrier:OnRefresh(kv)
		self.barrier = (self.barrier or 0) + kv.barrier
		self.ModifierBarrier_Bonus = function() return self.barrier end
	end

	function modifier_justicar_blessed_aegis_barrier:OnIntervalThink()
		self.barrier = math.max( 0, self.barrier - math.max( 1, self.barrier * self:ModifierBarrier_DegradeRate() ) )
		if self:ModifierBarrier_Bonus() <= 0 then self:Destroy() end
	end

	function modifier_justicar_blessed_aegis_barrier:DeclareFunctions()
		local funcs = {
			MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		}
		return funcs
	end

	function modifier_justicar_blessed_aegis_barrier:ModifierBarrier_Bonus()
		return (self.barrier or 0)
	end
	
	function modifier_justicar_blessed_aegis_barrier:ModifierBarrier_DegradeRate()
		return 0.01
	end

	function modifier_justicar_blessed_aegis_barrier:GetModifierIncomingDamage_Percentage(params)
		if params.damage < self:ModifierBarrier_Bonus() then
			self.barrier = (self:ModifierBarrier_Bonus() or 0) - params.damage
			self.ModifierBarrier_Bonus = function() return self.barrier end
			return -100
		elseif self:ModifierBarrier_Bonus() > 0 then
			local dmgRed = (params.damage / self:ModifierBarrier_Bonus()) * (-1)
			self.barrier = 0
			return dmgRed
		else
			self:Destroy()
		end
	end
end