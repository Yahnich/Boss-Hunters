warlock_chaos_bolt = class({})
LinkLuaModifier("modifier_warlock_chaos_bolt", "heroes/hero_warlock/warlock_chaos_bolt", LUA_MODIFIER_MOTION_NONE)

function warlock_chaos_bolt:IsStealable()
	return true
end

function warlock_chaos_bolt:IsHiddenWhenStolen()
	return false
end

function warlock_chaos_bolt:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	local speed = 1000
	local attachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1

	EmitSoundOn("Hero_Abaddon.DeathCoil.Cast", caster)
	self:FireTrackingProjectile("particles/units/heroes/hero_warlock/warlock_chaos_bolt.vpcf", target, speed, {}, attachment, true, true, 250)
end

function warlock_chaos_bolt:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()
	if hTarget and not hTarget:TriggerSpellAbsorb( self ) then
		local damage = self:GetSpecialValueFor("damage")
		EmitSoundOn("Hero_Batrider.Flamebreak.Impact", hTarget)
		if self:RollPRNG( self:GetSpecialValueFor("chance") ) then
			damage = damage * self:GetSpecialValueFor("crit_mult")/100

			--Corruption Check
			if hTarget:HasModifier("modifier_warlock_corruption_curse") then
				local curse = hTarget:FindModifierByName("modifier_warlock_corruption_curse")
				curse:SetDuration( curse:GetDuration(), true )
				curse:ForceRefresh()
			end

			--Talent 1 Check
			if caster:HasTalent("special_bonus_unique_warlock_chaos_bolt_1") then
				local enemies = caster:FindEnemyUnitsInRadius(vLocation, caster:FindTalentValue("special_bonus_unique_warlock_chaos_bolt_1", "radius"))
				for _,enemy in pairs(enemies) do
					self:DealDamage(caster, enemy, damage*caster:FindTalentValue("special_bonus_unique_warlock_chaos_bolt_1", "damage")/100, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
				end
			end

			--Talent 2 Check
			hTarget:AddNewModifier(caster, self, "modifier_warlock_chaos_bolt", {Duration = self:GetSpecialValueFor("debuff_duration")})

			local newDamage = self:DealDamage(caster, hTarget, damage, {}, 0)
			
			hTarget:ShowPopup( {
						PostSymbol = 4,
						Color = Vector( 125, 125, 255 ),
						Duration = 0.7,
						Number = newDamage,
						pfx = "spell"} )

		else
			self:DealDamage(caster, hTarget, damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
		end
	end
end

modifier_warlock_chaos_bolt = class({})
function modifier_warlock_chaos_bolt:OnCreated(table)
	self.damage_amp = self:GetSpecialValueFor("damage_amp")
	self.damage = self:GetSpecialValueFor("damage_over_time")
	self.slow = self:GetCaster():FindTalentValue("special_bonus_unique_warlock_chaos_bolt_2")
	if IsServer() then
		self:StartIntervalThink( self:GetDuration() / self:GetSpecialValueFor("debuff_duration") * 1)
	end
end

function modifier_warlock_chaos_bolt:OnRefresh(table)
	self.damage_amp = self:GetSpecialValueFor("damage_amp")
	self.damage = self:GetSpecialValueFor("damage_over_time")
	self.slow = self:GetCaster():FindTalentValue("special_bonus_unique_warlock_chaos_bolt_2")
end

function modifier_warlock_chaos_bolt:OnIntervalThink()
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
	self:StartIntervalThink( self:GetDuration() / self:GetSpecialValueFor("debuff_duration") * 1 )
end

function modifier_warlock_chaos_bolt:DeclareFunctions()
	return { MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end

function modifier_warlock_chaos_bolt:GetModifierIncomingDamage_Percentage()
	return self.damage_amp
end

function modifier_warlock_chaos_bolt:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_warlock_chaos_bolt:GetEffectName()
	return "particles/econ/items/wraith_king/wraith_king_ti6_bracer/wraith_king_ti6_hellfireblast_debuff.vpcf"
end

function modifier_warlock_chaos_bolt:IsDebuff()
	return true
end