ds_shell = class({})
LinkLuaModifier( "modifier_ds_shell", "heroes/hero_dark_seer/ds_shell.lua" ,LUA_MODIFIER_MOTION_NONE )

function ds_shell:IsStealable()
    return true
end

function ds_shell:IsHiddenWhenStolen()
    return false
end

function ds_shell:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	local duration = self:GetTalentSpecialValueFor("duration")

	EmitSoundOn("Hero_Dark_Seer.Ion_Shield_Start", target)
	target:RemoveModifierByName("modifier_ds_shell")
	target:AddNewModifier(caster, self, "modifier_ds_shell", {Duration = duration})

	if caster:HasTalent("special_bonus_unique_ds_shell_1") then
		local units = caster:FindAllUnitsInRadius(caster:GetAbsOrigin(), self:GetTrueCastRange())
		for _,unit in pairs(units) do
			if not unit:HasModifier("modifier_ds_shell") then
				unit:AddNewModifier(caster, self, "modifier_ds_shell", {Duration = duration})
				break
			end
		end
	end
end

modifier_ds_shell = class({})
function modifier_ds_shell:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()

		EmitSoundOn("Hero_Dark_Seer.Ion_Shield_lp", parent)

		self:OnRefresh()

		local particleRadius = 50

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_seer/dark_seer_ion_shell.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControl(nfx, 1, Vector(particleRadius, particleRadius, particleRadius))
		self:AttachEffect(nfx)

		self:StartIntervalThink(0.25)
	end
end

function modifier_ds_shell:OnRefresh(table)
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		self.damage = self:GetTalentSpecialValueFor("damage") * 0.25
		self.radius = self:GetTalentSpecialValueFor("radius")
		self.talent2 = caster:HasTalent("special_bonus_unique_ds_shell_2")
		self.talent3 = caster:HasTalent("special_bonus_unique_ds_shell_3")
		self.talent3Heal = caster:FindTalentValue("special_bonus_unique_ds_shell_3") / 100
		self.damageDealt = 0
	end
end

function modifier_ds_shell:OnRemoved()
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		StopSoundOn("Hero_Dark_Seer.Ion_Shield_lp", parent)
		EmitSoundOn("Hero_Dark_Seer.Ion_Shield_end", parent)
		
		if self.talent3 and self.damageDealt > 0 then
			local allies = caster:FindFriendlyUnitsInRadius( parent:GetAbsOrigin(), self.radius )
			local heal = (self.damageDealt * self.talent3Heal) / #allies
			for _, ally in ipairs( allies ) do
				ally:HealEvent( heal, ability, caster )
			end
		end
	end
end

function modifier_ds_shell:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local enemies = caster:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), self.radius)
	for _,enemy in pairs(enemies) do
		if enemy ~= parent or self.talent2 then
			local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_seer/dark_seer_ion_shell_damage.vpcf", PATTACH_POINT, caster)
						ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
						ParticleManager:SetParticleControlEnt(nfx, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
						ParticleManager:SetParticleControlEnt(nfx, 2, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
						ParticleManager:ReleaseParticleIndex(nfx)

			self.damageDealt = self.damageDealt + ability:DealDamage(caster, enemy, self.damage)
		end
	end
end

-- function modifier_ds_shell:DeclareFunctions()
	-- return {MODIFIER_EVENT_ON_DEATH}
-- end

-- function modifier_ds_shell:OnDeath(params)
	-- if IsServer() then
		-- local caster = self:GetCaster()

		-- if caster:HasTalent("special_bonus_unique_ds_shell_2") then
			-- local parent = self:GetParent()
			-- local ability = self:GetAbility()
			-- local unit = params.unit

			-- local duration = self:GetTalentSpecialValueFor("duration")

			-- if unit == parent then
				-- local units = caster:FindAllUnitsInRadius(caster:GetAbsOrigin(), 350, {order = FIND_CLOSEST})
				-- for _,target in pairs(units) do
					-- if not target:HasModifier("modifier_ds_shell") then
						-- target:AddNewModifier(caster, ability, "modifier_ds_shell", {Duration = duration})
						-- break
					-- end
				-- end
			-- end
		-- end
	-- end
-- end

function modifier_ds_shell:IsDebuff()
	return false
end
