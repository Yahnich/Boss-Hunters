item_galactic_hammer = class({})
LinkLuaModifier( "modifier_item_galactic_hammer_passive", "items/item_galactic_hammer.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_galactic_hammer_burn", "items/item_galactic_hammer.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_galactic_hammer_channel", "items/item_galactic_hammer.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_galactic_hammer:GetIntrinsicModifierName()
	return "modifier_item_galactic_hammer_passive"
end

function item_galactic_hammer:GetChannelTime()
	return self:GetSpecialValueFor("channel")
end

function item_galactic_hammer:GetChannelAnimation()
	return ACT_DOTA_GENERIC_CHANNEL_1
end

function item_galactic_hammer:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	EmitSoundOn("DOTA_Item.MeteorHammer.Channel", caster)

	self.casterFX = ParticleManager:CreateParticle("particles/items4_fx/meteor_hammer_cast.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControl(self.casterFX, 0, caster:GetAbsOrigin())
	self.pointFX = ParticleManager:CreateParticle("particles/items4_fx/meteor_hammer_aoe.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControl(self.pointFX, 0, point)
					ParticleManager:SetParticleControl(self.pointFX, 1, Vector(self:GetSpecialValueFor("radius"), 1, 1))

	caster:AddNewModifier(caster, self, "modifier_item_galactic_hammer_channel", {Duration = self:GetSpecialValueFor("channel")})
end

function item_galactic_hammer:OnChannelFinish(bInterrupted)
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	StopSoundOn("DOTA_Item.MeteorHammer.Channel", caster)

	ParticleManager:ClearParticle(self.casterFX)
	ParticleManager:ClearParticle(self.pointFX)

	caster:RemoveModifierByName("modifier_item_galactic_hammer_channel")

	if not bInterrupted then
		local radius = self:GetSpecialValueFor("radius")
		local x = math.random(-radius,radius)
		local y = math.random(-radius,radius)
		local height = 500
		local heightPoint = Vector(x, y, height)

		EmitSoundOn("DOTA_Item.MeteorHammer.Cast", caster)
		ParticleManager:FireParticle("particles/items4_fx/meteor_hammer_spell.vpcf", PATTACH_POINT, caster, {[0]=point+heightPoint, [1]=point, [2]=Vector(0.5,0,0), [3]=point})

		Timers:CreateTimer(0.5, function()
			EmitSoundOnLocationWithCaster(point, "DOTA_Item.MeteorHammer.Impact", caster)
			local enemies = caster:FindEnemyUnitsInRadius(point, radius)
			for _,enemy in pairs(enemies) do
				self:Stun(enemy, self:GetSpecialValueFor("stun_duration"), false)
				self:DealDamage(caster, enemy, self:GetSpecialValueFor("damage"), {damage_type=DAMAGE_TYPE_MAGICAL}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
				enemy:AddNewModifier(caster, self, "modifier_item_galactic_hammer_burn", {Duration = self:GetSpecialValueFor("duration")})
			end
		end)
	end
end

modifier_item_galactic_hammer_channel = class({})
function modifier_item_galactic_hammer_channel:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
end

function modifier_item_galactic_hammer_channel:GetOverrideAnimation()
	return ACT_DOTA_GENERIC_CHANNEL_1
end

function modifier_item_galactic_hammer_channel:IsHidden()
	return true
end

modifier_item_galactic_hammer_passive = class({})
function modifier_item_galactic_hammer_passive:OnCreated(table)
	self.hp_regen = self:GetSpecialValueFor("hp_regen")
	self.manaregen = self:GetSpecialValueFor("m_regen")
	self.int = self:GetSpecialValueFor("bonus_int")
	self.str = self:GetSpecialValueFor("bonus_str")
end

function modifier_item_galactic_hammer_passive:OnRefresh(table)
	self.hp_regen = self:GetSpecialValueFor("hp_regen")
	self.manaregen = self:GetSpecialValueFor("m_regen")
	self.int = self:GetSpecialValueFor("bonus_int")
	self.str = self:GetSpecialValueFor("bonus_str")
end

function modifier_item_galactic_hammer_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end

function modifier_item_galactic_hammer_passive:GetModifierConstantHealthRegen()
	return self.hp_regen
end

function modifier_item_galactic_hammer_passive:GetModifierConstantManaRegen()
	return self.manaregen
end

function modifier_item_galactic_hammer_passive:GetModifierBonusStats_Strength()
	return self.int
end

function modifier_item_galactic_hammer_passive:GetModifierBonusStats_Intellect()
	return self.str
end

function modifier_item_galactic_hammer_passive:IsHidden()
	return true
end

function modifier_item_galactic_hammer_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

modifier_item_galactic_hammer_burn = class({})
function modifier_item_galactic_hammer_burn:OnCreated(table)
	if IsServer() then
		self.damage = self:GetSpecialValueFor("damage_per_sec")
		self:StartIntervalThink(1)
	end
end

function modifier_item_galactic_hammer_burn:OnRefresh(table)
	if IsServer() then
		self.damage = self:GetSpecialValueFor("damage_per_sec")
	end
end

function modifier_item_galactic_hammer_burn:OnIntervalThink()
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.damage, {damage_type=DAMAGE_TYPE_MAGICAL}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
end

function modifier_item_galactic_hammer_burn:GetEffectName()
	return "particles/items4_fx/meteor_hammer_spell_debuff.vpcf"
end