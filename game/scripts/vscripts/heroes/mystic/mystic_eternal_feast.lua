mystic_eternal_feast = class({})

function mystic_eternal_feast:GetAOERadius()
	return self:GetSpecialValueFor("initial_radius")
end

function mystic_eternal_feast:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	
	local radius = self:GetSpecialValueFor("initial_radius")
	local damage = self:GetSpecialValueFor("initial_damage")
	
	local enemies = caster:FindEnemyUnitsInRadius(point, radius)
	for _, enemy in ipairs(enemies) do
		enemy:AddNewModifier(caster, self, "modifier_mystic_eternal_feast_debuff", {duration = self:GetSpecialValueFor("debuff_duration")})
		self:DealDamage(caster, enemy, damage)
	end
	EmitSoundOn("Hero_Invoker.ForgeSpirit", caster)
end

modifier_mystic_eternal_feast_debuff = class({})
LinkLuaModifier("modifier_mystic_eternal_feast_debuff", "heroes/mystic/mystic_eternal_feast.lua", 0)

function modifier_mystic_eternal_feast_debuff:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH}
end

function modifier_mystic_eternal_feast_debuff:OnDeath(params)
	if params.unit == self:GetParent() and IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local position =  GetGroundPosition(self:GetParent():GetAbsOrigin(), self:GetParent()) + Vector(0,0,128)
		local orbRadius = self:GetSpecialValueFor("damage_radius")
		local orbDamage = self:GetSpecialValueFor("healdamage")
		local orb = ParticleManager:CreateParticle("particles/heroes/mystic/mystic_eternal_feast_orb.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(orb, 0, position)
		ParticleManager:SetParticleControl(orb, 15, Vector(255,0,0))
		
		Timers:CreateTimer(FrameTime(), function()
			if caster:HasTalent("mystic_eternal_feast_talent_1") then
				local allies = caster:FindFriendlyUnitsInRadius(position, FIND_UNITS_EVERYWHERE, {order = FIND_CLOSEST})
				for _, ally in pairs(allies) do 
					position = GetGroundPosition(position + CalculateDirection(ally, position) * caster:FindTalentValue("mystic_eternal_feast_talent_1") * FrameTime(), nil) + Vector(0,0,128)
					ParticleManager:SetParticleControl(orb, 0, position)
					break
				end
			end
			local alliesCheck = caster:FindFriendlyUnitsInRadius(position, orbRadius - 125, {order = FIND_CLOSEST})
			local allies = caster:FindFriendlyUnitsInRadius(position, orbRadius, {order = FIND_CLOSEST})
			if #alliesCheck == 0 then 
				return FrameTime() 
			else 
				for _, ally in pairs(allies) do
					ally:HealEvent(orbDamage, ability, caster)
				end
				ParticleManager:DestroyParticle(orb, false)
				ParticleManager:ReleaseParticleIndex(orb)
				local enemies = caster:FindEnemyUnitsInRadius(position, orbRadius, {})
				for _, enemy in pairs(enemies) do
					enemy:AddNewModifier(caster, ability, "modifier_mystic_eternal_feast_debuff", {duration = ability:GetSpecialValueFor("debuff_duration")})
					ability:DealDamage(caster, enemy, orbDamage)
				end
			end
		end)
	end
end

function modifier_mystic_eternal_feast_debuff:GetEffectName()
	return "particles/heroes/mystic/mystic_eternal_feast_debuff.vpcf"
end