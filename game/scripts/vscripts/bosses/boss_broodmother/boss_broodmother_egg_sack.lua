boss_broodmother_egg_sack = class({})

function boss_broodmother_egg_sack:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_status_immunity", {duration = self:GetCastPoint() - 0.01})
	return true
end

function boss_broodmother_egg_sack:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local eggs = self:GetSpecialValueFor("eggs")
	local hits = self:GetSpecialValueFor("egg_hits")
	for i = 1, eggs do
		local egg = CreateUnitByName("npc_dota_creature_broodmother_egg", position + ActualRandomVector(650), true, self, nil, self:GetCaster():GetTeam())
		egg:AddNewModifier(caster, self, "modifier_boss_broodmother_egg_sack_handler", {})
	end
	
	EmitSoundOn("Hero_Broodmother.SpawnSpiderlingsCast", caster)
end

modifier_boss_broodmother_egg_sack_handler = class({})
LinkLuaModifier("modifier_boss_broodmother_egg_sack_handler", "bosses/boss_broodmother/boss_broodmother_egg_sack", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_boss_broodmother_egg_sack_handler:OnCreated()
		self.threat = self:GetSpecialValueFor("destroy_threat")
		self:StartIntervalThink(0.15)
	end
	
	function modifier_boss_broodmother_egg_sack_handler:OnIntervalThink()
		local parent = self:GetParent()
		local steppedOn = parent:FindEnemyUnitsInRadius( parent:GetAbsOrigin(), 80, {flag = DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES})
		for _, enemy in ipairs(steppedOn) do
			EmitSoundOn("Hero_Broodmother.SpawnSpiderlings", enemy)
			enemy:ModifyThreat(self.threat)
			parent:ForceKill(false)
			UTIL_Remove(parent)
			break
		end
	end
end

function modifier_boss_broodmother_egg_sack_handler:CheckState()
	return {[MODIFIER_STATE_MAGIC_IMMUNE] = true,
			[MODIFIER_STATE_ATTACK_IMMUNE] = true,
			[MODIFIER_STATE_UNSELECTABLE] = true,
			[MODIFIER_STATE_NO_HEALTH_BAR] = true,}
end