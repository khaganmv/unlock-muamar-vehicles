STREET_CRED_LEVEL_REQUIREMENT = 50

local function getStreetCredLevel()
    return PlayerDevelopmentSystem
        .GetData(Game.GetPlayer())
        :GetProficiencyLevel(gamedataProficiencyType.StreetCred)
end

local function unlockMuamarVehicles()
    local vehicleOfferRecords = TweakDB:GetRecords("gamedataVehicleOffer_Record")

    for _, vehicleOfferRecord in pairs(vehicleOfferRecords) do
        local id = vehicleOfferRecord:GetRecordID()
        local unlockType = TweakDB:GetFlat(id .. ".unlockType")

        if (
            TDBID.ToStringDEBUG(unlockType) == "Vehicle.CourierMissions"
            or TDBID.ToStringDEBUG(id) == "Vehicle.herrera_outlaw_courier_outro_failed_offer"
        ) then
            local availabilityFact = vehicleOfferRecord:AvailabilityFact()
            Game.GetQuestsSystem():SetFact(availabilityFact, 1)
        end
    end
end

registerForEvent("onInit", function()
    ObserveAfter("PlayerDevelopmentSystem", "OnRestored", function (_)
        if getStreetCredLevel() >= STREET_CRED_LEVEL_REQUIREMENT then
            unlockMuamarVehicles()
        end
    end)

    ObserveAfter("LevelUpNotificationQueue", "OnCharacterLevelUpdated", function (_)
        if getStreetCredLevel() >= STREET_CRED_LEVEL_REQUIREMENT then
            unlockMuamarVehicles()
        end
    end)
end)
