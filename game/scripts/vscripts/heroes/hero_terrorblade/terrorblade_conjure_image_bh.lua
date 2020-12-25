terrorblade_conjure_image_bh = class({})

function terrorblade_conjure_image_bh:GetCooldown(iLvl)
	return self.BaseClass.GetCooldown( self, iLvl ) + self:GetCaster():FindTalentValue("special_bonus_unique_terrorblade_conjure_image_1")
end

function terrorblade_conjure_image_bh:GetIntrinsicModifierName()
	return "modifier_terrorblade_conjureimage_death"
end

function terrorblade_conjure_image_bh:OnSpellStart()
	self:CreateImage()
end

function terrorblade_conjure_image_bh:CreateImage( position, duration, outgoing, incoming, amount )
	local caster = self:GetCaster()

	local vPos = position or caster:GetAbsOrigin() + RandomVector(150)
	local fDur = duration or self:GetTalentSpecialValueFor("illusion_duration")
	local fOut = outgoing or self:GetTalentSpecialValueFor("illusion_outgoing_damage")
	local fInc = incoming or self:GetTalentSpecialValueFor("illusion_incoming_damage")

	-- local callback = ( function(illusion)
		-- illusion:StartGesture( ACT_DOTA_SPAWN )
		-- if caster:HasTalent("special_bonus_unique_terrorblade_conjure_image_2") then
			-- local heal = caster:GetMaxHealth() * caster:FindTalentValue("special_bonus_unique_terrorblade_conjure_image_2") / 100
			-- Timers:CreateTimer(function()
				-- if not illusion:IsNull() and illusion:IsAlive() then
					-- return 0.33
				-- else
					-- caster:HealEvent( heal, self, caster )
				-- end
			-- end)
		-- end
	-- end )
	local illusions = caster:ConjureImage( {outgoing_damage = fOut - 100, incoming_damage = fInc - 100, position = vPos, illusion_modifier = "modifier_terrorblade_conjureimage", scramble = false}, fDur, caster, amount )
	for _, illusion in ipairs( illusions ) do
		illusion.isConjureImageIllusion = true
	end
	return illusions
end

modifier_terrorblade_conjureimage_death = class({})
LinkLuaModifier( "modifier_terrorblade_conjureimage_death", "heroes/hero_terrorblade/terrorblade_conjure_image_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_terrorblade_conjureimage_death:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH}
end

function modifier_terrorblade_conjureimage_death:OnDeath( params )
	if params.unit.isConjureImageIllusion and self:GetCaster():IsRealHero() then
		local caster = self:GetCaster()
		if caster:HasTalent("special_bonus_unique_terrorblade_conjure_image_2") then
			local heal = caster:GetMaxHealth() * caster:FindTalentValue("special_bonus_unique_terrorblade_conjure_image_2") / 100
			caster:HealEvent( heal, self:GetAbility(), caster )
		end
	end
end