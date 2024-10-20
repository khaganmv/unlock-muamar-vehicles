STREET_CRED_LEVEL_REQUIREMENT = 50

-- Herrera Outlaw "Weiler"
HERRERA_OUTLAW_WEILER_OFFER_ID = "Vehicle.herrera_outlaw_courier_outro_failed_offer"
HERRERA_OUTLAW_WEILER_OFFER_OWNERSHIP_FACT = "herrera_outlaw_courier_outro_owned"
HERRERA_OUTLAW_WEILER_VEHICLE_ID = "Vehicle.v_sport1_herrera_outlaw_heist_player"

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
            or TDBID.ToStringDEBUG(id) == HERRERA_OUTLAW_WEILER_OFFER_ID 
        ) then
            Game.GetQuestsSystem():SetFact(vehicleOfferRecord:AvailabilityFact(), 1)
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

    ObserveAfter("gameuiVehicleShopGameController", "OnVehicleShopPurchaseEventEvent", function (self, evt)
        local id = evt.offerRecord:GetRecordID()

        if TDBID.ToStringDEBUG(id) == HERRERA_OUTLAW_WEILER_OFFER_ID then
            Game.GetVehicleSystem():EnablePlayerVehicle(HERRERA_OUTLAW_WEILER_VEHICLE_ID, true)
        end
    end)

    -- Ensures backwards compatibility with v1.0.1
    ObserveAfter("PlayerPuppet", "OnGameAttached", function (self) 
        if Game.GetQuestsSystem():GetFact(HERRERA_OUTLAW_WEILER_OFFER_OWNERSHIP_FACT) == 1 then
            Game.GetVehicleSystem():EnablePlayerVehicle(HERRERA_OUTLAW_WEILER_VEHICLE_ID, true)
        end
    end)
end)
