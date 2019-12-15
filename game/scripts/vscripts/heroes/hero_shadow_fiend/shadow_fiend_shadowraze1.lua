shadow_fiend_shadowraze1 = class({})
LinkLuaModifier( "modifier_shadow_fiend_shadowraze","heroes/hero_shadow_fiend/shadow_fiend_shadowraze1.lua",LUA_MODIFIER_MOTION_NONE )

function shadow_fiend_shadowraze1:GetCastRange(vLocation, hTarget)
	return self:GetTalentSpecialValueFor("range")
end

function shadow_fiend_shadowraze1:OnUpgrade()
	local raze2 = self:GetCaster():FindAbilityByName("shadow_fiend_shadowraze2")
	local raze3 = self:GetCaster():FindAbilityByName("shadow_fiend_shadowraze3")
	
	-- Check to not enter a level up loop
	if raze2 and raze2:GetLevel() ~= self:GetLevel() then
		raze2:SetLevel(self:GetLevel())
	end
	if raze3 and raze3:GetLevel() ~= self:GetLevel() then
		raze3:SetLevel(self:GetLevel())
	end
end

function shadow_fiend_shadowraze1:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
    if self:GetCaster():HasTalent("special_bonus_unique_shadow_fiend_shadowraze_2") then cooldown = cooldown + self:GetCaster():FindTalentValue("special_bonus_unique_shadow_fiend_shadowraze_2", "cdr") end
    return cooldown
end

function shadow_fiend_shadowraze1:OnSpellStart()
	EmitSoundOn("Hero_Nevermore.Shadowraze", self:GetCaster())
	self:singleRaze()
end

function shadow_fiend_shadowraze1:singleRaze()
	local caster = self:GetCaster()

	local startPos = caster:GetAbsOrigin()
	local direction = caster:GetForwardVector()
	local distance = self:GetTalentSpecialValueFor("range")

	local radius = self:GetTalentSpecialValueFor("radius")

	local position = startPos + direction * distance
	if caster:HasTalent("special_bonus_unique_shadow_fiend_shadowraze_1") then
		position = startPos
	end
	position = GetGroundPosition(position, caster)

	CutTreesInRadius(position, radius)
	AddFOWViewer(caster:GetTeam(), position, radius, 1, false)
		
	ParticleManager:FireParticle("particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf", PATTACH_POINT, caster, {[0]=position})

	local damage = self:GetTalentSpecialValueFor("damage")

	local modifier = caster:FindModifierByName("modifier_shadow_fiend_necro")
	if modifier and ( caster:FindAbilityByName("shadow_fiend_necro"):GetToggleState() and modifier:GetStackCount() >= self:GetTalentSpecialValueFor("soul_cost") or caster:HasScepter() ) then
		local newStackCount = modifier:GetStackCount() - TernaryOperator( 0, caster:HasScepter(), self:GetTalentSpecialValueFor("soul_cost") )
		caster:FindModifierByName("modifier_shadow_fiend_necro"):SetStackCount(newStackCount)
		if modifier:GetStackCount() < 1 then modifier:Destroy() end

		damage = damage + self:GetTalentSpecialValueFor("soul_cost") * caster:FindAbilityByName("shadow_fiend_necro"):GetTalentSpecialValueFor("damage")
	end

	local enemies = caster:FindEnemyUnitsInRadius(position, radius, {})
	for _,enemy in pairs(enemies) do
		if not enemy:TriggerSpellAbsorb( self ) then
			local enemyDamage = 0
			if enemy:HasModifier("modifier_shadow_fiend_shadowraze") then
				enemyDamage = self:GetTalentSpecialValueFor("combo_amp") * enemy:FindModifierByName("modifier_shadow_fiend_shadowraze"):GetStackCount()
			end

			enemy:AddNewModifier(caster, self, "modifier_shadow_fiend_shadowraze", {Duration = self:GetTalentSpecialValueFor("combo_time")}):AddIndependentStack(self:GetTalentSpecialValueFor("combo_time"))
			self:DealDamage(caster, enemy, damage/#enemies + enemyDamage, {}, 0)
		end
	end
end

modifier_shadow_fiend_shadowraze = class({})
function modifier_shadow_fiend_shadowraze:GetEffectName()
	return "particles/units/heroes/hero_nevermore/nevermore_shadowraze_debuff.vpcf"
end