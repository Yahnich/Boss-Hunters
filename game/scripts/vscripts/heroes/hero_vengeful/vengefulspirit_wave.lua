vengefulspirit_wave = class({})
LinkLuaModifier( "modifier_vengefulspirit_wave", "heroes/hero_vengeful/vengefulspirit_wave.lua",LUA_MODIFIER_MOTION_NONE )

function vengefulspirit_wave:IsStealable()
	return true
end

function vengefulspirit_wave:IsHiddenWhenStolen()
	return false
end

function vengefulspirit_wave:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	local direction = CalculateDirection(point, caster:GetAbsOrigin())
	local speed = self:GetTalentSpecialValueFor("speed")
	local distance = self:GetTrueCastRange()
	local velocity = direction * speed

	EmitSoundOn("Hero_VengefulSpirit.WaveOfTerror", caster)

	self:FireLinearProjectile("particles/units/heroes/hero_vengeful/vengeful_wave_of_terror_orig.vpcf", velocity, distance, self:GetTalentSpecialValueFor("width"), {}, false, true, self:GetTalentSpecialValueFor("width"))
end

function vengefulspirit_wave:OnProjectileHit(hTarget, vLocation)
	if hTarget ~= nil then
		hTarget:AddNewModifier(self:GetCaster(), self, "modifier_vengefulspirit_wave", {Duration = self:GetTalentSpecialValueFor("duration")}):AddIndependentStack(self:GetTalentSpecialValueFor("duration"))
		hTarget:Daze(self, self:GetCaster(), self:GetTalentSpecialValueFor("daze_duration"))
		self:DealDamage(self:GetCaster(), hTarget, self:GetTalentSpecialValueFor("damage"), {}, 0)
	end
end

modifier_vengefulspirit_wave = class({})
function modifier_vengefulspirit_wave:OnCreated(table)
    if IsServer() then
    	self.nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_vengeful/vengeful_wave_of_terror_recipient.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    	ParticleManager:SetParticleControlEnt(self.nfx, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
    end
end

function modifier_vengefulspirit_wave:OnRefresh(table)
    if IsServer() then
    	self.nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_vengeful/vengeful_wave_of_terror_recipient.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    	ParticleManager:SetParticleControlEnt(self.nfx, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
    end
end

function modifier_vengefulspirit_wave:OnRemoved()
    if IsServer() then
    	ParticleManager:ClearParticle(self.nfx)
    end
end

function modifier_vengefulspirit_wave:DeclareFunctions()
    local funcs = {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
    return funcs
end

function modifier_vengefulspirit_wave:GetModifierPhysicalArmorBonus()
    return self:GetTalentSpecialValueFor("armor_reduction") * self:GetStackCount()
end