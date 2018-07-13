boss_troll_warlord_mystic_axes = class({})
LinkLuaModifier( "modifier_boss_troll_warlord_mystic_axes", "bosses/boss_troll_warlord/boss_troll_warlord_mystic_axes.lua", LUA_MODIFIER_MOTION_NONE )

function boss_troll_warlord_mystic_axes:OnSpellStart()
	local caster = self:GetCaster()
	local maxAxe = self:GetSpecialValueFor("axe_number")
	local currentAxe = 0

	Timers:CreateTimer(FrameTime(), function()
		if currentAxe < maxAxe then
			local axe = CreateUnitByName("npc_dota_boss_troll_warlord_mystic_axe", caster:GetAbsOrigin() + ActualRandomVector(500, 250), true, caster, caster, caster:GetTeam())
			EmitSoundOn("Hero_TrollWarlord.WhirlingAxes.Melee", axe)
			axe:AddNewModifier(caster, self, "modifier_boss_troll_warlord_mystic_axes", {duration = self:GetSpecialValueFor("duration")})
			currentAxe = currentAxe + 1
			return 0.1
		else
			return nil
		end
	end)
end

modifier_boss_troll_warlord_mystic_axes = class({})
function modifier_boss_troll_warlord_mystic_axes:OnCreated(table)
	self.damage = self:GetSpecialValueFor("damage") * 0.1
	if IsServer() then
		local parent = self:GetParent()
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_troll_warlord/troll_warlord_whirling_axe_melee.vpcf", PATTACH_POINT_FOLLOW, parent)
					ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin()+Vector(0,0,150), true)
					ParticleManager:SetParticleControlEnt(nfx, 1, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin()+Vector(0,0,150), true)
					ParticleManager:SetParticleControlEnt(nfx, 3, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin()+Vector(0,0,150), true)
					ParticleManager:SetParticleControl(nfx, 4, Vector(500, 0, 0))
		self:AddEffect(nfx)
		self:StartIntervalThink(1)
	end
end

function modifier_boss_troll_warlord_mystic_axes:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	if not self.init then
		self.init = true
		self:StartIntervalThink(0.1)
	end
	local enemies = caster:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), self:GetSpecialValueFor("axe_radius"))
	for _,enemy in pairs(enemies) do
		self:GetAbility():DealDamage(parent, enemy, self.damage, {damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_BLOCK}, 0)
	end
	if not caster:IsAlive() then
		parent:Destroy()
		self:Destroy()
	end
end

function modifier_boss_troll_warlord_mystic_axes:OnRemoved()
	if IsServer() then
		self:GetParent():ForceKill(false)
		UTIL_Remove( self:GetParent() )
	end
end

function modifier_boss_troll_warlord_mystic_axes:CheckState()
	local state = { [MODIFIER_STATE_INVULNERABLE] = true,
					[MODIFIER_STATE_UNSELECTABLE] = true,
					[MODIFIER_STATE_UNTARGETABLE] = true,
					[MODIFIER_STATE_ATTACK_IMMUNE] = true,
					[MODIFIER_STATE_MAGIC_IMMUNE] = true,
					[MODIFIER_STATE_NO_HEALTH_BAR] = true,
					[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
					[MODIFIER_STATE_NO_TEAM_SELECT] = true,}
	return state
end