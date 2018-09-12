terrorblade_conjure_image_bh = class({})

function terrorblade_conjure_image_bh:GetCooldown(iLvl)
	return self.BaseClass.GetCooldown( self, iLvl ) + self:GetCaster():FindTalentValue("special_bonus_unique_terrorblade_conjure_image_1")
end

function terrorblade_conjure_image_bh:OnSpellStart()
	self:CreateImage()
end

function terrorblade_conjure_image_bh:CreateImage( position, duration, outgoing, incoming )
	local caster = self:GetCaster()

	local vPos = position or caster:GetAbsOrigin() + RandomVector(150)
	local fDur = duration or self:GetTalentSpecialValueFor("illusion_duration")
	local fOut = outgoing or self:GetTalentSpecialValueFor("illusion_outgoing_damage")
	local fInc = incoming or self:GetTalentSpecialValueFor("illusion_incoming_damage")

	local illusion = caster:ConjureImage( vPos, fDur, fOut - 100, fInc - 100, "modifier_terrorblade_conjureimage", self, true, caster )
	illusion:StartGesture( ACT_DOTA_SPAWN )
	if caster:HasTalent("special_bonus_unique_terrorblade_conjure_image_2") then
		local heal = caster:GetMaxHealth() * caster:FindTalentValue("special_bonus_unique_terrorblade_conjure_image_2") / 100
		Timers:CreateTimer(function()
			if not illusion:IsNull() and illusion:IsAlive() then
				return 0.33
			else
				caster:HealEvent( heal, self, caster )
			end
		end)
	end
	return illusion
end