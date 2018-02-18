tech_stasis_mine = class({})
LinkLuaModifier( "modifier_stasis_mine", "heroes/hero_tech/tech_stasis_mine.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_stasis_mine_mr", "heroes/hero_tech/tech_stasis_mine.lua", LUA_MODIFIER_MOTION_NONE )

function tech_stasis_mine:PiercesDisableResistance()
    return true
end

function tech_stasis_mine:OnSpellStart()
	local caster = self:GetCaster()

	EmitSoundOn("Hero_Techies.StasisTrap.Plant", caster)
	local mine = CreateUnitByName("npc_dota_techies_stasis_trap", caster:GetAbsOrigin(), true, caster, caster, caster:GetTeam())
	mine:AddNewModifier(caster, self, "modifier_stasis_mine", {})
end

modifier_stasis_mine = ({})
function modifier_stasis_mine:OnCreated(table)
	if IsServer() then
		Timers:CreateTimer(self:GetTalentSpecialValueFor("active_delay"), function()
			self:StartIntervalThink(FrameTime())
		end)
	end
end

function modifier_stasis_mine:OnIntervalThink()
	local radius = self:GetTalentSpecialValueFor("stun_radius")

	local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), radius, {flag = self:GetAbility():GetAbilityTargetFlags()})
	for _,enemy in pairs(enemies) do
		StopSoundOn("Hero_Techies.StasisTrap.Plant", self:GetCaster())
		EmitSoundOn("Hero_Techies.StasisTrap.Stun", self:GetParent())

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_stasis_trap_explode.vpcf", PATTACH_POINT, self:GetCaster())
		ParticleManager:SetParticleControl(nfx, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(nfx, 1, Vector(radius, radius, radius))
		ParticleManager:SetParticleControl(nfx, 3, self:GetParent():GetAbsOrigin())
		Timers:CreateTimer(1, function()
			ParticleManager:DestroyParticle(nfx, false)
		end)

		self:GetAbility():Stun(enemy, self:GetTalentSpecialValueFor("stun_duration"), false)

		if self:GetCaster():HasTalent("special_bonus_unique_tech_stasis_mine_1") then
			enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_stasis_mine_mr", {Duration = self:GetTalentSpecialValueFor("stun_duration")})
		end

		self:GetParent():ForceKill(false)
		self:Destroy()
	end
end


function modifier_stasis_mine:CheckState()
	local state = { [MODIFIER_STATE_UNSELECTABLE] = true,
					[MODIFIER_STATE_INVISIBLE] = true,
					[MODIFIER_STATE_INVULNERABLE] = true,
					[MODIFIER_STATE_UNTARGETABLE] = true,
					[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
					[MODIFIER_STATE_NO_HEALTH_BAR] = true,
					[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
	return state
end

modifier_stasis_mine_mr = ({})
function modifier_stasis_mine_mr:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
	}
	return funcs
end

function modifier_stasis_mine_mr:GetModifierMagicalResistanceBonus()
	return self:GetTalentSpecialValueFor("magic_resist")	
end

function modifier_stasis_mine_mr:IsDebuff()
	return true	
end