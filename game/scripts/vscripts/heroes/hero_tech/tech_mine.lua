tech_mine = class({})
LinkLuaModifier( "modifier_mine", "heroes/hero_tech/tech_mine.lua", LUA_MODIFIER_MOTION_NONE )

function tech_mine:OnSpellStart()
	local caster = self:GetCaster()

	EmitSoundOn("Hero_Techies.LandMine.Plant", caster)
	local mine = CreateUnitByName("npc_dota_techies_land_mine", caster:GetAbsOrigin(), true, caster, caster, caster:GetTeam())
	mine:AddNewModifier(caster, self, "modifier_mine", {})

	if caster:HasTalent("special_bonus_unique_tech_mine_1") then
		local mine2 = CreateUnitByName("npc_dota_techies_land_mine", caster:GetAbsOrigin(), true, caster, caster, caster:GetTeam())
		mine2:AddNewModifier(caster, self, "modifier_mine", {})
	end
end

modifier_mine = ({})
function modifier_mine:OnCreated(table)
	if IsServer() then
		Timers:CreateTimer(self:GetTalentSpecialValueFor("active_delay"), function()
			self:StartIntervalThink(FrameTime())
		end)
	end
end

function modifier_mine:OnIntervalThink()
	local radius = self:GetTalentSpecialValueFor("radius")

	local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), radius, {flag = self:GetAbility():GetAbilityTargetFlags()})
	for _,enemy in pairs(enemies) do
		StopSoundOn("Hero_Techies.LandMine.Plant", self:GetCaster())
		EmitSoundOn("Hero_Techies.LandMine.Detonate", self:GetParent())

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_land_mine_explode.vpcf", PATTACH_POINT, self:GetCaster())
		ParticleManager:SetParticleControl(nfx, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(nfx, 1, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(nfx, 2, Vector(radius, radius, radius))
		ParticleManager:ReleaseParticleIndex(nfx)

		self:GetAbility():DealDamage(self:GetCaster(), enemy, self:GetTalentSpecialValueFor("damage"), {}, 0)
		self:GetParent():ForceKill(false)
		self:Destroy()
	end
end


function modifier_mine:CheckState()
	local state = { [MODIFIER_STATE_UNSELECTABLE] = true,
					[MODIFIER_STATE_INVISIBLE] = true,
					[MODIFIER_STATE_INVULNERABLE] = true,
					[MODIFIER_STATE_UNTARGETABLE] = true,
					[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
					[MODIFIER_STATE_NO_HEALTH_BAR] = true,
					[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
	return state
end