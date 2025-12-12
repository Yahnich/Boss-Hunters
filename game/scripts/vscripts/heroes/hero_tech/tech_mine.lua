tech_mine = class({})
LinkLuaModifier( "modifier_mine", "heroes/hero_tech/tech_mine.lua", LUA_MODIFIER_MOTION_NONE )

function tech_mine:IsStealable()
	return true
end

function tech_mine:IsHiddenWhenStolen()
	return false
end

function tech_mine:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local duration = self:GetSpecialValueFor("lifetime")
	
	EmitSoundOn("Hero_Techies.LandMine.Plant", caster)
	self:PlantLandMine( position, duration )

	if caster:HasTalent("special_bonus_unique_tech_mine_2") then
		self:PlantLandMine( caster:GetAbsOrigin() + ActualRandomVector( self:GetTrueCastRange(), 25 ), duration )
	end
end

function tech_mine:PlantLandMine( position, duration )
	local caster = self:GetCaster()
	local lifetime = duration or self:GetSpecialValueFor("lifetime")
	local mine = CreateUnitByName("npc_dota_techies_land_mine", position, true, caster, caster, caster:GetTeam())
	mine:AddNewModifier(caster, self, "modifier_mine", {})
	mine:AddNewModifier(caster, self, "modifier_kill", {duration = lifetime})
	return mine
end

modifier_mine = ({})
function modifier_mine:OnCreated(table)
	if IsServer() then
		Timers:CreateTimer(self:GetSpecialValueFor("active_delay"), function()
			self:StartIntervalThink(FrameTime())
		end)
	end
end

function modifier_mine:OnIntervalThink()
	local radius = self:GetSpecialValueFor("radius")
	local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), radius, {flag = self:GetAbility():GetAbilityTargetFlags()})
	if enemies[1] then
		self:StartIntervalThink(-1)
		Timers:CreateTimer( 0.25, function()
			self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), radius, {flag = self:GetAbility():GetAbilityTargetFlags()})
			enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), radius, {flag = self:GetAbility():GetAbilityTargetFlags()})
			if enemies[1] then
				for _,enemy in pairs(enemies) do
					StopSoundOn("Hero_Techies.LandMine.Plant", self:GetCaster())
					
					local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_land_mine_explode.vpcf", PATTACH_POINT, self:GetCaster())
					ParticleManager:SetParticleControl(nfx, 0, self:GetParent():GetAbsOrigin())
					ParticleManager:SetParticleControl(nfx, 1, self:GetParent():GetAbsOrigin())
					ParticleManager:SetParticleControl(nfx, 2, Vector(radius, radius, radius))
					ParticleManager:ReleaseParticleIndex(nfx)
					if not enemy:TriggerSpellAbsorb( self:GetAbility() ) then
						self:GetAbility():DealDamage(self:GetCaster(), enemy, self:GetSpecialValueFor("damage"), {}, 0)
						EmitSoundOn("Hero_Techies.LandMine.Detonate", self:GetParent())
					end
				end
				self:GetParent():ForceKill(false)
				self:Destroy()
			else
				self:StartIntervalThink(FrameTime())
			end
		end)
	end
	
end


function modifier_mine:CheckState()
	local state = { [MODIFIER_STATE_UNSELECTABLE] = true,
					[MODIFIER_STATE_INVISIBLE] = true,
					[MODIFIER_STATE_INVULNERABLE] = true,
					[MODIFIER_STATE_UNTARGETABLE] = true,
					-- [MODIFIER_STATE_ROOTED] = true,
					[MODIFIER_STATE_NO_HEALTH_BAR] = true,
					[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
	return state
end

function modifier_mine:IsHidden()
	return true
end