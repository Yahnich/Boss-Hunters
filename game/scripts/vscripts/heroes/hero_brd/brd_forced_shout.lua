brd_forced_shout = class({})
LinkLuaModifier( "modifier_forced_shout", "heroes/hero_brd/brd_forced_shout.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
function brd_forced_shout:OnSpellStart()
	local caster = self:GetCaster()

	EmitSoundOn("Hero_Axe.Berserkers_Call", self:GetCaster())

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_axe/axe_beserkers_call_owner.vpcf", PATTACH_POINT_FOLLOW, caster)
	ParticleManager:SetParticleControl(nfx, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControlEnt(nfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_mouth", caster:GetAbsOrigin(), true)

	local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self:GetSpecialValueFor("radius"), {})
	for _,enemy in pairs(enemies) do
		enemy:Taunt(self,caster,self:GetSpecialValueFor("duration"))
	end

	caster:AddNewModifier(caster,self,"modifier_forced_shout",{Duration = self:GetTalentSpecialValueFor("duration")})
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_forced_shout = class({})
function modifier_forced_shout:OnCreated(table)
	self.armor = self:GetCaster():GetPhysicalArmorValue() + self:GetCaster():GetPhysicalArmorValue() * self:GetTalentSpecialValueFor("armor_bonus")/100
end

function modifier_forced_shout:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
	return funcs
end

function modifier_forced_shout:GetModifierPhysicalArmorBonus()
	return self.armor
end