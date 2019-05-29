ta_trap_spring = class({})
LinkLuaModifier( "modifier_ta_trap_spring", "heroes/hero_ta/ta_trap.lua" ,LUA_MODIFIER_MOTION_NONE )

function ta_trap_spring:IsStealable()
	return false
end

function ta_trap_spring:IsHiddenWhenStolen()
	return false
end

function ta_trap_spring:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local trapAbility = caster:FindAbilityByName("ta_trap")
	local trap
	local closest = 100000
	if trapAbility.traps and #trapAbility.traps > 0 then
		for _,tableTrap in pairs(trapAbility.traps) do
			local distance = (point - tableTrap:GetAbsOrigin()):Length2D()
		
			-- Notes the closest distance and closest trap
			if distance < closest then
				closest = distance
				trap = tableTrap
			end
		end
	end
	if trap then
		ParticleManager:FireParticle("particles/units/heroes/hero_templar_assassin/templar_assassin_trap_explode.vpcf", PATTACH_WORLDORIGIN, trap, {[0]=trap:GetAbsOrigin(),
																																					[1]=trap:GetAbsOrigin(),
																																					[2]=trap:GetAbsOrigin()})
		EmitSoundOn("Hero_TemplarAssassin.Trap.Trigger", caster)
		EmitSoundOn("Hero_TemplarAssassin.Trap.Explode", trap)
		local trap_radius = self:GetTalentSpecialValueFor("trap_radius") + TernaryOperator( self:GetTalentSpecialValueFor("scepter_bonus_radius"), caster:HasScepter(), 0 )
		local trap_duration = self:GetTalentSpecialValueFor("trap_duration")
		local enemies = caster:FindEnemyUnitsInRadius(trap:GetAbsOrigin(), trap_radius, {})
		for _, enemy in pairs(enemies) do
			local slow = enemy:AddNewModifier(caster, trapAbility, "modifier_ta_trap_spring", {duration = trap_duration})
			slow:SetStackCount(trap.currSlow)
			trapAbility:DealDamage(caster, enemy, trap.currDamage, {}, 0)
		end
		trap:ForceKill(false)
		for index,tableTrap in pairs(trapAbility.traps) do
			if trap == tableTrap then
				table.remove(trapAbility.traps,index)
			end
		end
	end
end