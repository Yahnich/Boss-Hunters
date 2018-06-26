boss_broodmother_fates_web = class({})

function boss_broodmother_fates_web:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	
	local dummy = CreateUnitByName("npc_dummy_unit", target, false, nil, nil, caster:GetTeam())
	dummy:AddNewModifier(caster, self, "modifier_boss_broodmother_fates_web_web", {})
	dummy:SetBaseMaxHealth( self:GetSpecialValueFor("hits_to_kill") )
	dummy:SetMaxHealth( self:GetSpecialValueFor("hits_to_kill") )
	dummy:SetHealth( self:GetSpecialValueFor("hits_to_kill") )
end


modifier_boss_broodmother_fates_web_web = class({})
LinkLuaModifier("modifier_boss_broodmother_fates_web_web", "bosses/boss_broodmother/boss_broodmother_fates_web", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_broodmother_fates_web_web:OnCreated()
	self.radius = self:GetSpecialValueFor("radius")
	if IsServer() then
		local wFX = ParticleManager:CreateParticle("particles/units/heroes/hero_broodmother/broodmother_web.vpcf", PATTACH_ABSORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(wFX, 1, Vector(self.radius, self.radius, self.radius))
		ParticleManager:SetParticleControl(wFX, 2, Vector(self.radius, self.radius, self.radius))
		ParticleManager:SetParticleControl(wFX, 3, Vector(self.radius, self.radius, self.radius))
		ParticleManager:SetParticleControl(wFX, 4, Vector(self.radius, self.radius, self.radius))
		ParticleManager:SetParticleControl(wFX, 5, Vector(self.radius, self.radius, self.radius))
		ParticleManager:SetParticleControl(wFX, 10, Vector(self.radius, self.radius, self.radius))
		ParticleManager:SetParticleControl(wFX, 11, Vector(self.radius, self.radius, self.radius))
		ParticleManager:SetParticleControl(wFX, 12, Vector(self.radius, self.radius, self.radius))
		ParticleManager:SetParticleControl(wFX, 13, Vector(self.radius, self.radius, self.radius))
		ParticleManager:SetParticleControl(wFX, 14, Vector(self.radius, self.radius, self.radius))
		ParticleManager:SetParticleControl(wFX, 15, Vector(self.radius, self.radius, self.radius))
		ParticleManager:SetParticleControl(wFX, 16, Vector(self.radius, self.radius, self.radius))
		ParticleManager:SetParticleControl(wFX, 17, Vector(self.radius, self.radius, self.radius))
		self:AddEffect(wFX)
	end
end


function modifier_boss_broodmother_fates_web_web:IsHidden()
	return true
end

function modifier_boss_broodmother_fates_web_web:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_boss_broodmother_fates_web_web:CheckState()
	return {[MODIFIER_STATE_MAGIC_IMMUNE] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION ] = true,
			[MODIFIER_STATE_FLYING ] = true,}
end

function modifier_boss_broodmother_fates_web_web:GetModifierIncomingDamage_Percentage( params )
	local parent = self:GetParent()
	if params.inflictor then return -999 end
	if parent:GetHealth() > 1 then
		parent:SetHealth( math.max(1, parent:GetHealth() - 1) )
		return -999
	elseif parent:IsAlive() then
		self:ForceKill(false)
	end
end

--------------------------------------------------------------------------------

function modifier_boss_broodmother_fates_web_web:IsAura()
	return true
end

--------------------------------------------------------------------------------

function modifier_boss_broodmother_fates_web_web:GetModifierAura()
	return "modifier_boss_broodmother_fates_web_handler"
end

--------------------------------------------------------------------------------

function modifier_boss_broodmother_fates_web_web:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_BOTH
end

--------------------------------------------------------------------------------

function modifier_boss_broodmother_fates_web_web:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

--------------------------------------------------------------------------------

function modifier_boss_broodmother_fates_web_web:GetAuraRadius()
	return self.radius
end

--------------------------------------------------------------------------------
function modifier_boss_broodmother_fates_web_web:IsPurgable()
    return false
end



modifier_boss_broodmother_fates_web_handler = class({})
LinkLuaModifier("modifier_boss_broodmother_fates_web_handler", "bosses/boss_broodmother/boss_broodmother_fates_web", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_broodmother_fates_web_handler:OnCreated()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	
	self.sameTeam = caster:IsSameTeam(parent)
	if self.sameTeam then
		self.ms = self:GetSpecialValueFor("bonus_ms")
	else
		self.ms = self:GetSpecialValueFor("slow")
	end
end

function modifier_boss_broodmother_fates_web_handler:OnRefresh()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	
	self.sameTeam = caster:IsSameTeam(parent)
	if self.sameTeam then
		self.ms = self:GetSpecialValueFor("bonus_ms")
	else
		self.ms = self:GetSpecialValueFor("slow")
	end
end

function modifier_boss_broodmother_fates_web_handler:CheckState()
	if self.sameTeam then
		return {[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,}
	end
end

function modifier_boss_broodmother_fates_web_handler:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_boss_broodmother_fates_web_handler:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end