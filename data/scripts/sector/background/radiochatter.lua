if onClient() then

    function RadioChatter.initialize()
        local x, y = Sector():getCoordinates()
        local dist = length(vec2(x, y))
        self.dist = dist

        self.GeneralStationChatter =
        {
            -- jibber jabber
            "Dock ${LN2} is clear."%_t,
            "Dock ${LN2} is not clear."%_t,
            "${R}: Docking permission granted."%_t,
            "${R}: Docking permission denied."%_t,
            "Approach vector ${N2}/${N} confirmed."%_t,
            "All incoming vessels: we welcome you in our sector and we hope for you that your intentions are peaceful."%_t,
            "Freighter ${N2}: this is ${R}. Please identify yourself."%_t,
            "Please repeat the last statement."%_t,
            "${R}, what is your estimated time of arrival?"%_t,
            "${R}, you're free to dock. Choose whichever dock you please."%_t,
            "${R}, please send us position and approach angle."%_t,
            "Negative, we are still waiting for the delivery."%_t,
            "This is the automated response system. Denied requests can be reviewed at any time by our algorithm."%_t,
            "${R}, please come in."%_t,
            "No, that form is no longer up to date."%_t,
            "We ask all captains and pilots not to occupy docks any longer than necessary."%_t,
        }

        self.GeneralShipChatter =
        {
            -- jibber jabber
            "Requesting permission to dock."%_t,
            "Requesting flight vector."%_t,
            "We are now at vector ${N2}/${N}."%_t,
            "Asking for clearance."%_t,
            "${R} entering flight vector."%_t,
        }

        self.FreighterChatter =
        {
        }

        self.HostileShipChatter =
        {
            -- Move along
            "Leave our territory."%_t,
            "Please leave our territory."%_t,
            "You should leave our territory."%_t,
            "I think it would be better for you to move on."%_t,

            -- More formal move along
            "This is a friendly reminder: please leave our territory."%_t,
            "This is a friendly reminder: hostile parties are not welcome, and will find their stay less than rewarding."%_t,
            "You aren't welcome around these parts. We kindly ask you to vacate our territory."%_t,
            "According to our records, you're an enemy of our faction. Please leave our territory, otherwise we'll have to take actions against you."%_t,
            "Our leadership has ordered us to open fire if you don't leave our territory."%_t,

            -- Threatening
            "We've got orders to shoot down any hostiles if they try something and right now you're on that list. Better move on."%_t,
            "This is a friendly reminder: if you don't leave our territory, we will open fire."%_t,
            "This is an unfriendly reminder to leave. Now."%_t,
            "Warning: if you don't leave this territory, we will open fire."%_t,
        }

        if getLanguage() == "en" then
            -- these don't have translation markers on purpose
            table.insert(self.GeneralStationChatter, "Notice to all arriving ships: Dock ${L}-${N} is temporarily disabled for maintenance. Thank you for your patience.")
            table.insert(self.GeneralStationChatter, "Construction of section ${N2} is now complete.")
            table.insert(self.GeneralStationChatter, "Due to maintenance in corridor ${N2}, all personnel on their way to section ${LN3} should take elevator ${R} instead of ${LN3}.")

            -- these don't have translation markers on purpose
            table.insert(self.GeneralShipChatter, "Transponder signal verified. Continued existence permitted.")
            table.insert(self.GeneralShipChatter, "Entering rotation cycle ${N2}. All systems nominal.")

            -- these don't have translation markers on purpose
            table.insert(self.FreighterChatter, "I sure hope our cargo will fetch a good price.")
        end


        self.XsotanSwarmChatter = {
        {
            -- xsotanSwarmOngoing
            "There are too many!"%_t,
            "SOS! We're being overrun! Requesting immediate backup!"%_t,
            "When will it stop? Please make it stop!"%_t,
            "Bloody Xsotan. We'll show you how to stand fast!"%_t,
            "We won't lose! Stay strong!"%_t,
            "Why Boxelware, WHY!?"%_t,
            "I think this qualifies as the worst day of my life."%_t,
            "This sector will burn!"%_t,
            "Empty all magazines! Fire! Fire! Fire!"%_t,
        },
        {
            -- xsotanSwarmSuccess
            "Let's hope this swarm never comes back!"%_t,
            "We showed them damn Xsotan! Woohoo!"%_t,
            "Did those Xsotan really think they could win?!"%_t
        },
        {
            -- xsotanSwarmFail
            "Have we really lost? What now?"%_t,
            "We hoped to defeat the Xsotan plague once and for all. Guess it wasn't meant to be."%_t
        },
        {
            -- xsotanSwarmForeshadow
            "The Xsotan swarm was so damn strong. Let's hope this doesn't happen again!"%_t,
            "It's so good that we defeated the Xsotan swarm. Who knows what would have happened otherwise."%_t,
            "A lot of Xsotan appeared on our radars... are they regrouping?"%_t,
        }
        }

        local x, y = Sector():getCoordinates()
        local dist = length(vec2(x, y))

        --chatter only inside the barrier
        if dist < Balancing_GetBlockRingMax() then
            -- xsotan swarm
        end

        local generalChatter =
        {
            -- jibber jabber
            "Checking radio... Changing frequency to ${R}."%_t,
        }

        RadioChatter.addStationChatter(generalChatter)
        RadioChatter.addShipChatter(generalChatter)
    end

end

