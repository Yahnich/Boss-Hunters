mystic_mist_barrier = class({})

function mystic_mist_barrier:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	EmitSoundOn("Hero_Abaddon.AphoticShield.Cast", target)
	target:AddNewModifier(caster, self, "modifier_mystic_mist_barrier", {duration = self:GetSpecialValueFor("duration")})
end

modifier_mystic_mist_barrier = class({})
LinkLuaModifier("modifier_mystic_mist_barrier", "heroes/mystic/mystic_mist_barrier.lua", 0)

if IsServer() then
	function modifier_mystic_mist_barrier:OnCreated()
		self.barrier = self:GetSpecialValueFor("barrier_amt")
		if self:GetCaster():HasTalent("mystic_mist_barrier_talent_1") then
			self.barrier = self.barrier + self:GetParent():GetMaxHealth() * self:GetSpecialValueFor("talent_barrier") / 100
		end
		self.maxBarrier = self.barrier
		self.barrierRegen = self:GetSpecialValueFor("barrier_regen") / 100
		
		self.particle = ParticleManager:CreateParticle("particles/heroes/mystic/mystic_mist_barrier.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(self.particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(self.particle, 1, Vector(self:GetParent():GetHullRadius() + 100,self:GetParent():GetHullRadius() + 100,self:GetParent():GetHullRadius() + 100))
		self:AddParticle(self.particle, false, false, 0, false, false)
		
		self:StartIntervalThink(0.3)
	end
	
	function modifier_mystic_mist_barrier:OnRefresh()
		self.barrier = self:GetSpecialValueFor("barrier_amt")
		if self:GetCaster():HasTalent("mystic_mist_barrier_talent_1") then
			self.barrier = self.barrier + self:GetParent():GetMaxHealth() * self:GetSpecialValueFor("talent_barrier") / 100
		end
		self.maxBarrier = self.barrier
		self.barrierRegen = self:GetSpecialValueFor("barrier_regen") / 100
	end
	
	function modifier_mystic_mist_barrier:OnIntervalThink()
		self.barrier = math.min( self.maxBarrier, self.barrier + self.maxBarrier * self.barrierRegen * 0.3 )
		if self:ModifierBarrier_Bonus() <= 0 then self:Destroy() end
	end

	function modifier_mystic_mist_barrier:DeclareFunctions()
		local funcs = {
			MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		}
		return funcs
	end

	function modifier_mystic_mist_barrier:ModifierBarrier_Bonus()
		return (self.barrier or 0)
	end
	

	function modifier_mystic_mist_barrier:GetModifierIncomingDamage_Percentage(params)
		if params.damage < self:ModifierBarrier_Bonus() then
			self.barrier = math.max((self:ModifierBarrier_Bonus() or 0) - params.damage, 0)
			return -100
		elseif self:ModifierBarrier_Bonus() > 0 then
			local dmgRed = (params.damage / self:ModifierBarrier_Bonus()) * (-1)
			self.barrier = 0
			return dmgRed
		end
	end
end