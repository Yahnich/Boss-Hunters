tech_robo_mine = class({})
LinkLuaModifier( "modifier_robo_mine", "heroes/hero_tech/tech_robo_mine.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_movespeed_cap", "libraries/modifiers/modifier_movespeed_cap.lua", LUA_MODIFIER_MOTION_NONE )

function tech_robo_mine:IsStealable()
	return true
end

function tech_robo_mine:IsHiddenWhenStolen()
	return false
end

function tech_robo_mine:OnSpellStart()
	local caster = self:GetCaster()

	EmitSoundOn("Hero_Techies.RemoteMine.Plant", caster)
	local mine = CreateUnitByName("npc_dota_techies_remote_mine", caster:GetAbsOrigin(), true, caster, caster, caster:GetTeam())
	mine:SetControllableByPlayer(caster:GetPlayerID(), true)
	mine:SetOwner(caster)
	mine:AddNewModifier(caster, self, "modifier_robo_mine", {})
	mine:AddNewModifier(caster, self, "modifier_movespeed_cap", {})
	mine:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
end

modifier_robo_mine = ({})
function modifier_robo_mine:OnCreated(table)
	if IsServer() then
		Timers:CreateTimer(self:GetTalentSpecialValueFor("active_delay"), function()
			self:StartIntervalThink(FrameTime())
		end)
	end
end

function modifier_robo_mine:OnIntervalThink()
	local radius = self:GetTalentSpecialValueFor("radius")

	local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), radius, {flag = self:GetAbility():GetAbilityTargetFlags()})
	for _,enemy in pairs(enemies) do
		StopSoundOn("Hero_Techies.RemoteMine.Plant", self:GetCaster())
		EmitSoundOn("Hero_Techies.RemoteMine.Detonate", self:GetParent())

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_remote_mines_detonate.vpcf", PATTACH_POINT, self:GetCaster())
		ParticleManager:SetParticleControl(nfx, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(nfx, 1, Vector(radius, radius, radius))
		ParticleManager:ReleaseParticleIndex(nfx)

		self:GetAbility():DealDamage(self:GetCaster(), enemy, self:GetTalentSpecialValueFor("damage"), {}, 0)
		self:GetParent():ForceKill(false)
		self:Destroy()
		break
	end
end

function modifier_robo_mine:CheckState()
	local state = {	[MODIFIER_STATE_INVULNERABLE] = true,
					[MODIFIER_STATE_NO_HEALTH_BAR] = true,
					[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
	return state
end

function modifier_robo_mine:IsHidden()
	return true
end

function modifier_robo_mine:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
	}
	return funcs
end

function modifier_robo_mine:GetModifierMoveSpeedBonus_Constant()
	return self:GetTalentSpecialValueFor("move_speed")	
end