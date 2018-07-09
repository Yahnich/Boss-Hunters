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
	if hTarget then
		local damage = self:GetTalentSpecialValueFor("damage")
		EmitSoundOn("Hero_Batrider.Flamebreak.Impact", hTarget)
		if self:RollPRNG( self:GetTalentSpecialValueFor("chance") ) then
			damage = damage * self:GetTalentSpecialValueFor("crit_mult")/100

			--Corruption Check
			if hTarget:HasModifier("modifier_warlock_corruption_curse") then
				hTarget:FindModifierByName("modifier_warlock_corruption_curse"):ForceRefresh()
			end

			--Talent 1 Check
			if caster:HasTalent("special_bonus_unique_warlock_chaos_bolt_1") then
				local enemies = caster:FindEnemyUnitsInRadius(vLocation, caster:FindTalentValue("special_bonus_unique_warlock_chaos_bolt_1", "radius"))
				for _,enemy in pairs(enemies) do
					self:DealDamage(caster, enemy, damage*caster:FindTalentValue("special_bonus_unique_warlock_chaos_bolt_1", "damage")/100, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
				end
			end

			--Talent 2 Check
			if caster:HasTalent("special_bonus_unique_warlock_chaos_bolt_2") then
				hTarget:AddNewModifier(caster, self, "modifier_warlock_chaos_bolt", {Duration = caster:FindTalentValue("special_bonus_unique_warlock_chaos_bolt_2")})
			end

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
	if IsServer() then
		self.duration = self:GetDuration()
		self:StartIntervalThink(1)
	end
end

function modifier_warlock_chaos_bolt:OnIntervalThink()
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self:GetTalentSpecialValueFor("damage")/self.duration, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
end

function modifier_warlock_chaos_bolt:GetEffectName()
	return "particles/econ/items/wraith_king/wraith_king_ti6_bracer/wraith_king_ti6_hellfireblast_debuff.vpcf"
end

function modifier_warlock_chaos_bolt:IsDebuff()
	return true
end