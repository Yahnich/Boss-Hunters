shadow_fiend_shadowraze2 = class({})
LinkLuaModifier( "modifier_shadow_fiend_shadowraze","heroes/hero_shadow_fiend/shadow_fiend_shadowraze1.lua",LUA_MODIFIER_MOTION_NONE )

function shadow_fiend_shadowraze2:GetCastRange(vLocation, hTarget)
	return self:GetTalentSpecialValueFor("range")
end

function shadow_fiend_shadowraze2:OnUpgrade()
	local raze1 = self:GetCaster():FindAbilityByName("shadow_fiend_shadowraze1")
	local raze3 = self:GetCaster():FindAbilityByName("shadow_fiend_shadowraze3")
	
	-- Check to not enter a level up loop
	if raze1 and raze1:GetLevel() ~= self:GetLevel() then
		raze1:SetLevel(self:GetLevel())
	end
	if raze3 and raze3:GetLevel() ~= self:GetLevel() then
		raze3:SetLevel(self:GetLevel())
	end
end

function shadow_fiend_shadowraze2:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
    if self:GetCaster():HasTalent("special_bonus_unique_shadow_fiend_shadowraze_2") then cooldown = cooldown + self:GetCaster():FindTalentValue("special_bonus_unique_shadow_fiend_shadowraze_2", "cdr") end
    return cooldown
end

function shadow_fiend_shadowraze2:OnSpellStart()
	EmitSoundOn("Hero_Nevermore.Shadowraze", self:GetCaster())
	if self:GetCaster():HasTalent("special_bonus_unique_shadow_fiend_shadowraze_1") then
		self:CircleRaze()
	else
		self:singleRaze()
	end
end

function shadow_fiend_shadowraze2:singleRaze()
	local caster = self:GetCaster()

	local startPos = caster:GetAbsOrigin()
	local direction = caster:GetForwardVector()
	local distance = self:GetTalentSpecialValueFor("range")

	local radius = self:GetTalentSpecialValueFor("radius")

	local position = startPos + direction * distance
	position = GetGroundPosition(position, caster)

	CutTreesInRadius(position, radius)
	AddFOWViewer(caster:GetTeam(), position, radius, 1, false)
		
	ParticleManager:FireParticle("particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf", PATTACH_POINT, caster, {[0]=position})

	local damage = self:GetTalentSpecialValueFor("damage")

	local modifier = caster:FindModifierByName("modifier_shadow_fiend_necro")
	if modifier and caster:FindAbilityByName("shadow_fiend_necro"):GetToggleState() and modifier:GetStackCount() >= self:GetTalentSpecialValueFor("soul_cost") then
		local newStackCount = modifier:GetStackCount() - self:GetTalentSpecialValueFor("soul_cost")
		caster:FindModifierByName("modifier_shadow_fiend_necro"):SetStackCount(newStackCount)
		if modifier:GetStackCount() < 1 then caster:RemoveModifierByName(modifier) end

		damage = damage + self:GetTalentSpecialValueFor("soul_cost") * caster:FindAbilityByName("shadow_fiend_necro"):GetTalentSpecialValueFor("damage")
	end

	local enemies = caster:FindEnemyUnitsInRadius(position, radius, {})
	for _,enemy in pairs(enemies) do
		local enemyDamage = 0
		if enemy:HasModifier("modifier_shadow_fiend_shadowraze") then
			enemyDamage = self:GetTalentSpecialValueFor("combo_amp") * enemy:FindModifierByName("modifier_shadow_fiend_shadowraze"):GetStackCount()
		end

		enemy:AddNewModifier(caster, self, "modifier_shadow_fiend_shadowraze", {Duration = self:GetTalentSpecialValueFor("combo_time")}):AddIndependentStack(self:GetTalentSpecialValueFor("combo_time"))
		self:DealDamage(caster, enemy, damage/#enemies + enemyDamage, {}, 0)
	end
end

function shadow_fiend_shadowraze2:CircleRaze()
	local caster = self:GetCaster()

	local startPos = caster:GetAbsOrigin()
	local direction = caster:GetForwardVector()
	local distance = self:GetTalentSpecialValueFor("range")

	local radius = self:GetTalentSpecialValueFor("radius")

	local angle = 30

	local maxRaze = 360/angle
	local curRaze = 0

	local damage = self:GetTalentSpecialValueFor("damage")

	for i=curRaze,maxRaze do
		direction = RotateVector2D(direction, ToRadians( angle ) )
		local position = startPos + direction * distance
		position = GetGroundPosition(position, caster)

		CutTreesInRadius(position, radius)
		AddFOWViewer(caster:GetTeam(), position, radius, 1, false)
		
		ParticleManager:FireParticle("particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf", PATTACH_POINT, caster, {[0]=position})
	end

	local modifier = caster:FindModifierByName("modifier_shadow_fiend_necro")
	if modifier and caster:FindAbilityByName("shadow_fiend_necro"):GetToggleState() and modifier:GetStackCount() >= self:GetTalentSpecialValueFor("soul_cost") then
		local newStackCount = modifier:GetStackCount() - self:GetTalentSpecialValueFor("soul_cost")
		caster:FindModifierByName("modifier_shadow_fiend_necro"):SetStackCount(newStackCount)
		if modifier:GetStackCount() < 1 then modifier:Destroy() end

		damage = damage + self:GetTalentSpecialValueFor("soul_cost") * caster:FindAbilityByName("shadow_fiend_necro"):GetTalentSpecialValueFor("damage")
	end

	local enemies = caster:FindEnemyUnitsInRing(startPos, radius*2, radius/2, {})
	for _,enemy in pairs(enemies) do
		local enemyDamage = 0
		if enemy:HasModifier("modifier_shadow_fiend_shadowraze") then
			enemyDamage = self:GetTalentSpecialValueFor("combo_amp") * enemy:FindModifierByName("modifier_shadow_fiend_shadowraze"):GetStackCount()
		end

		enemy:AddNewModifier(caster, self, "modifier_shadow_fiend_shadowraze", {Duration = self:GetTalentSpecialValueFor("combo_time")}):AddIndependentStack(self:GetTalentSpecialValueFor("combo_time"))
		self:DealDamage(caster, enemy, damage/#enemies + enemyDamage, {}, 0)
	end
end