
function Encyclopedia.fillTree()

    --include("chapters/basics")
    --include("chapters/exploring")
    --include("chapters/building")
    --include("chapters/craftmanagement")
    --include("chapters/fleetmanagement")
    --include("chapters/diplomacy")
    --include("chapters/combat")
    include("chapters/coopmultiplayer")

    local searchText = string.trim(self.searchTextBox.text)

    if searchText == "" then
        Encyclopedia.fillTreeCompletely()
    else
        Encyclopedia.fillTreeFiltered(searchText)
    end

end
