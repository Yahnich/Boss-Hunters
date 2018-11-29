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

		self.damage = self:GetTalentSpecialValueFor("damage") * 0.1
		self.radius = self:GetTalentSpecialValueFor("radius")

		local particleRadius = 50

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_seer/dark_seer_ion_shell.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControl(nfx, 1, Vector(particleRadius, particleRadius, particleRadius))
		self:AttachEffect(nfx)

		self:StartIntervalThink(0.1)
	end
end

function modifier_ds_shell:OnRefresh(table)
	if IsServer() then
		self.damage = self:GetTalentSpecialValueFor("damage") * 0.1
		self.radius = self:GetTalentSpecialValueFor("radius")
	end
end

function modifier_ds_shell:OnRemoved()
	if IsServer() then
		StopSoundOn("Hero_Dark_Seer.Ion_Shield_lp", self:GetParent())
		EmitSoundOn("Hero_Dark_Seer.Ion_Shield_end", self:GetParent())
	end
end

function modifier_ds_shell:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local enemies = caster:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), self.radius)
	for _,enemy in pairs(enemies) do
		if enemy ~= parent then
			local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_seer/dark_seer_ion_shell_damage.vpcf", PATTACH_POINT, caster)
						ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
						ParticleManager:SetParticleControlEnt(nfx, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
						ParticleManager:SetParticleControlEnt(nfx, 2, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
						ParticleManager:ReleaseParticleIndex(nfx)

			ability:DealDamage(caster, enemy, self.damage)
		end
	end
end

function modifier_ds_shell:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH}
end

function modifier_ds_shell:OnDeath(params)
	if IsServer() then
		local caster = self:GetCaster()

		if caster:HasTalent("special_bonus_unique_ds_shell_2") then
			local parent = self:GetParent()
			local ability = self:GetAbility()
			local unit = params.unit

			local duration = self:GetTalentSpecialValueFor("duration")

			if unit == parent then
				local units = caster:FindAllUnitsInRadius(caster:GetAbsOrigin(), 350, {order = FIND_CLOSEST})
				for _,target in pairs(units) do
					if not target:HasModifier("modifier_ds_shell") then
						target:AddNewModifier(caster, ability, "modifier_ds_shell", {Duration = duration})
						break
					end
				end
			end
		end
	end
end

function modifier_ds_shell:IsDebuff()
	return false
end
