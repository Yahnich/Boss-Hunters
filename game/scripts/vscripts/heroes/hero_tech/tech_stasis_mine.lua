tech_stasis_mine = class({})
LinkLuaModifier( "modifier_stasis_mine", "heroes/hero_tech/tech_stasis_mine.lua", LUA_MODIFIER_MOTION_NONE )


function tech_stasis_mine:IsStealable()
	return true
end

function tech_stasis_mine:IsHiddenWhenStolen()
	return false
end

function tech_stasis_mine:PiercesDisableResistance()
    return true
end

function tech_stasis_mine:OnSpellStart()
	local caster = self:GetCaster()

	EmitSoundOn("Hero_Techies.StasisTrap.Plant", caster)
	local mine = CreateUnitByName("npc_dota_techies_stasis_trap", self:GetCursorPosition(), true, caster, caster, caster:GetTeam())
	if caster:HasTalent("special_bonus_unique_tech_stasis_mine_1") then
		mine:AddNewModifier(caster, self, "modifier_stasis_emp", {})
		mine:AddNewModifier(caster, self, "modifier_kill", {duration = self:GetTalentSpecialValueFor("active_delay") + self:GetTalentSpecialValueFor("stun_duration")+0.2})
	else
		mine:AddNewModifier(caster, self, "modifier_stasis_mine", {})
		mine:AddNewModifier(caster, self, "modifier_kill", {duration = 120})
	end
end

modifier_stasis_emp = ({})
LinkLuaModifier( "modifier_stasis_emp", "heroes/hero_tech/tech_stasis_mine.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_stasis_emp:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		self.damage = caster:FindTalentValue("special_bonus_unique_tech_stasis_mine_1")
		self.duration = caster:FindTalentValue("special_bonus_unique_tech_stasis_mine_1", "duration")
		self.tick = caster:FindTalentValue("special_bonus_unique_tech_stasis_mine_1", "tick")
		self.radius = self:GetTalentSpecialValueFor("stun_radius")
		self.delay = self:GetTalentSpecialValueFor("active_delay")
		Timers:CreateTimer(self.delay, function()
			self:StartIntervalThink(self.tick)
		end)
	end	
end

function modifier_stasis_emp:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	local enemies = self:GetCaster():FindEnemyUnitsInRadius(parent:GetAbsOrigin(), self.radius)
	for _,enemy in ipairs(enemies) do
		if not enemy:TriggerSpellAbsorb( ability ) then
			enemy:Paralyze(ability, caster, self.duration )
			ability:DealDamage( caster, enemy, self.damage, {damage_type = DAMAGE_TYPE_MAGICAL} )
		end
	end
	StopSoundOn("Hero_Techies.StasisTrap.Plant", self:GetCaster())
	EmitSoundOn("Hero_Techies.StasisTrap.Stun", parent)
	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_stasis_trap_explode.vpcf", PATTACH_POINT, self:GetCaster())
	ParticleManager:SetParticleControl(nfx, 0, parent:GetAbsOrigin())
	ParticleManager:SetParticleControl(nfx, 1, Vector(self.radius, self.radius, self.radius))
	ParticleManager:SetParticleControl(nfx, 3, parent:GetAbsOrigin())
	Timers:CreateTimer(0.5, function()
		ParticleManager:ClearParticle(nfx, false)
	end)
end


function modifier_stasis_emp:CheckState()
	local state = { [MODIFIER_STATE_UNSELECTABLE] = true,
					[MODIFIER_STATE_INVISIBLE] = true,
					[MODIFIER_STATE_INVULNERABLE] = true,
					[MODIFIER_STATE_UNTARGETABLE] = true,
					[MODIFIER_STATE_ROOTED] = true,
					[MODIFIER_STATE_NO_HEALTH_BAR] = true,
					[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
	return state
end

modifier_stasis_mine = ({})
LinkLuaModifier( "modifier_stasis_mine", "heroes/hero_tech/tech_stasis_mine.lua", LUA_MODIFIER_MOTION_NONE )
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
	if #enemies > 0 then
		Timers:CreateTimer( 0.3, function()
			for _,enemy in pairs(self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), radius, {flag = self:GetAbility():GetAbilityTargetFlags()})) do
				if not enemy:TriggerSpellAbsorb( self:GetAbility() ) then
					StopSoundOn("Hero_Techies.StasisTrap.Plant", self:GetCaster())
					EmitSoundOn("Hero_Techies.StasisTrap.Stun", self:GetParent())

					enemy:Paralyze(self:GetAbility(),self:GetCaster(), self:GetTalentSpecialValueFor("stun_duration") )
					
					-- if self:GetCaster():HasTalent("special_bonus_unique_tech_stasis_mine_1") then
						-- enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_stasis_mine_mr", {Duration = self:GetTalentSpecialValueFor("stun_duration")})
					-- end
				end
				triggered = true
			end
			local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_stasis_trap_explode.vpcf", PATTACH_POINT, self:GetCaster())
				ParticleManager:SetParticleControl(nfx, 0, self:GetParent():GetAbsOrigin())
				ParticleManager:SetParticleControl(nfx, 1, Vector(radius, radius, radius))
				ParticleManager:SetParticleControl(nfx, 3, self:GetParent():GetAbsOrigin())
				Timers:CreateTimer(1, function()
					ParticleManager:DestroyParticle(nfx, false)
				end)
			self:GetParent():ForceKill(false)
			self:Destroy()
		end)
		self:StartIntervalThink(-1)
	end
end


function modifier_stasis_mine:CheckState()
	local state = { [MODIFIER_STATE_UNSELECTABLE] = true,
					[MODIFIER_STATE_INVISIBLE] = true,
					[MODIFIER_STATE_INVULNERABLE] = true,
					[MODIFIER_STATE_UNTARGETABLE] = true,
					[MODIFIER_STATE_ROOTED] = true,
					[MODIFIER_STATE_NO_HEALTH_BAR] = true,
					[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
	return state
end