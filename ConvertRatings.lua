-- Define a table to list all the different spec mastery coefficents
masterytab = {}

-- Populate the table with mastery coefficents
masterytab.DEATHKNIGHT250 = 1.5
masterytab.DEATHKNIGHT251 = 1.5
masterytab.DEATHKNIGHT252 = 2.25
masterytab.DEMONHUNTER577 = 1
masterytab.DEMONHUNTER581 = 0.75
masterytab.DRUID102 = 2
masterytab.DRUID103 = 2
masterytab.DRUID104 = 0.5
masterytab.DRUID105 = 0.6
masterytab.HUNTER253 = 2.25
masterytab.HUNTER254 = 0.625
masterytab.HUNTER255 = 0.5
masterytab.MAGE62 = 1.2
masterytab.MAGE63 = 0.75
masterytab.MAGE64 = 2.25
masterytab.MONK268 = 1
masterytab.MONK269 = 10
masterytab.MONK270 = 1.25
masterytab.PALADIN65 = 1.5
masterytab.PALADIN66 = 1
masterytab.PALADIN70 = 1.5
masterytab.PRIEST256 = 1.5
masterytab.PRIEST257 = 1.25
masterytab.PRIEST258 = 2.5
masterytab.ROGUE259 = 4
masterytab.ROGUE260 = 2.2
masterytab.ROGUE261 = 2.76
masterytab.SHAMAN262 = 2.25
masterytab.SHAMAN263 = 2
masterytab.SHAMAN264 = 3
masterytab.WARLOCK265 = 3.125
masterytab.WARLOCK266 = 1.8
masterytab.WARLOCK267 = 3
masterytab.WARRIOR71 = 2
masterytab.WARRIOR72 = 1.4
masterytab.WARRIOR73 = 1.5

--These are the amounts of each rating for 1 percent for each rating
--The mastery amount is the base rating amount before the coefficent is applied
critamt = 350
hasteamt = 325
versinamt = 400
versoutamt = 800
masteryamt = 350

--Create Function to round the decimals

math.round = function(number, precision)
  precision = precision or 0

  local decimal = string.find(tostring(number), ".", nil, true);
  
  if ( decimal ) then  
    local power = 10 ^ precision;
    
    if ( number >= 0 ) then 
      number = math.floor(number * power + 0.5) / power;
    else 
      number = math.ceil(number * power - 0.5) / power;    
    end
    
    -- convert number to string for formatting
    number = tostring(number);      
    
    -- set cutoff
    local cutoff = number:sub(decimal + 1 + precision);
      
    -- delete everything after the cutoff
    number = number:gsub(cutoff, "");
  else
    -- number is an integer
    if ( precision > 0 ) then
      number = tostring(number);
      
      number = number .. ".";
      
      for i = 1,precision
      do
        number = number .. "0";
      end
    end
  end    
  return number;
end




--CHANGES:Lanrutcon:Create a start-up function - This is needed because some WoW API is only available after some events.
--Gnor: I moved this up in the addon, because i need this data stored to run before the calculations
local AddOn = CreateFrame("FRAME", "ConvertRatings");
AddOn:SetScript("OnEvent", function(self, event, ...)
    
    if(event == "PLAYER_ENTERING_WORLD") then
        --Getting Player Information
    
        --Get Current Player Spec
        local specn = GetSpecialization()

        --This call pulls the specific info from the spec number that the player currently is using, item 1 from the call is the unique spec number
        local specid = select(1,GetSpecializationInfo(specn))

        --turn the integer that is returned from the last call to a string so that it can be properly concatenated with the class name
        tostring(specid)

        --Get Current Player Class
        local classn = select(2,UnitClass("player"))

        --Concatenate class and specid for mastery coefficent lookup
        local masterycs = classn .. specid

        --Pull the coeff from the mastery table using the class name and spec id
        masterycf = masterytab[masterycs]
    end

end);

AddOn:RegisterEvent("PLAYER_ENTERING_WORLD");


--CHANGES:Lanrutcon:New function for GameTooltip's "OnTooltipSetItem"
local function getItemIdFromTooltip(self)
    local name, itemLink = self:GetItem();
    
    --Gets stats from item using itemLink - it's a table
    stats = GetItemStats(itemLink);
    
    --CHANGES:Lanrutcon:This is a protection-condition. Items like "Recipes" don't have items, so 'stats' table will be nil and there's no need to go further
    if(stats == nil) then
        return;
    end

    --Gnor: pull individual stats from stats table since the way that it was being accomplished wouldn't allow for calculations to be done
    local rawmastery = stats["ITEM_MOD_MASTERY_RATING_SHORT"]
    local rawcrit = stats["ITEM_MOD_CRIT_RATING_SHORT"]
    local rawhaste = stats["ITEM_MOD_HASTE_RATING_SHORT"]
    local rawvers = stats["ITEM_MOD_VERSATILITY"]

    --CHANGES:Lanrutcon:Localing the variables here - we'll use them after...
    local pcrit, phaste, pversin, pversout, pmastery, prcrit, prhaste, prversin, prversout, prmastery;
    
    --convert raw stats into percentages so long as they are not nil
    --This seems to work, as I am not getting any error output
    if rawcrit ~= nil then
        pcrit = rawcrit / critamt
    end

    if rawhaste ~= nil then
        phaste = rawhaste / hasteamt
    end

    if rawvers ~= nil then
        pversin = rawvers / versinamt
        pversout = rawvers / versoutamt
    end

    if rawmastery ~= nil then
        pmastery = (rawmastery / masteryamt) * masterycf
    end

    --Round The outputs
    prcrit = math.round(pcrit, 2)
    prhaste = math.round(phaste, 2)
    prversin = math.round(pversin, 2)
    prversout = math.round(pversout, 2)
    prmastery = math.round(pmastery, 2)


    --Convert percentages to strings
    tostring(prcrit)
    tostring(prhaste)
    tostring(prversin)
    tostring(prversout)
    tostring(prmastery)

    --Send the converted stats to the tooltip if they are not nil
    --This does not work atm
    --temp see if they output to chat ... nope must be missing something

    if pcrit ~= nil then
        GameTooltip:AddLine(prcrit .. "% Crit")
    end

    if phaste ~= nil then
        GameTooltip:AddLine(prhaste .. "% Haste")
    end

    if pmastery ~= nil then
        GameTooltip:AddLine(prmastery .. "% Mastery")
    end

    if pversin ~= nil then
        GameTooltip:AddLine(prversin .. "%/" .. prversout .. "% Versatility")
    end
end
GameTooltip:HookScript("OnTooltipSetItem", getItemIdFromTooltip);
