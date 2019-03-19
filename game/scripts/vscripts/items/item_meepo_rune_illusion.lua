item_meepo_rune_illusion = class({})

function item_meepo_rune_illusion:OnSpellStart()
	local caster = self:GetCaster()

	if caster:IsAlive() then
		EmitSoundOn("Rune.Illusion", caster)
		
		local duration = self:GetSpecialValueFor("duration")
		local max_images = self:GetSpecialValueFor("max_images")
		local incoming = self:GetSpecialValueFor("incoming")
		local outgoing = self:GetSpecialValueFor("outgoing")

		for i=1,max_images do
			local callback = (function(image)
				if image ~= nil then
				end
			end)

			local image = caster:ConjureImage( caster:GetAbsOrigin(), duration, outgoing, incoming, nil, self, true, caster, callback)
		end
	
		self:Destroy()
	end
end