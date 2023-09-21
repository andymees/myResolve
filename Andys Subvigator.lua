local ui = fu.UIManager
local disp = bmd.UIDispatcher(ui)

local lastTrack = 1
local subTrack = 1
local matchType = {MatchContains = true }

-- Setup 'Subvigator' window
subvigator = disp:AddWindow({ID = 'MyWin', WindowTitle = "Andy's Subvigator", Geometry = {100, 100, 380, 700}, Spacing = 0, ui.VGroup{ui.VGap(2), ui.HGroup{Weight = 0, ui.HGap(10), ui.Label{ID = 'Label', Text = 'Filter', Weight = 0.05}, ui.LineEdit{ID = 'SearchText', PlaceholderText = 'Search Text Filter', Weight = 0.9}, ui:ComboBox{ID = 'SearchType', Weight = 0.05}, }, ui.VGap(2), ui.Tree{ID = 'Tree', SortingEnabled = true, Events = {ItemClicked = true, }, }, ui.VGap(2), ui.HGroup{Weight = 0, ui:ComboBox{ID = 'SearchTrack', Weight = 0.3, Events ={Activated = true,}}, ui.HGap(10), ui.Button{ID = 'refreshBtn', Text = 'Refresh'},ui.HGap(10)}, }, })
itm = subvigator:GetItems()

projectManager = resolve:GetProjectManager()
project = projectManager:GetCurrentProject()
timeline = project:GetCurrentTimeline()
framerate = timeline:GetSetting('timelineFrameRate')
trackItems = timeline:GetItemListInTrack('subtitle', subTrack)
subsCount = #trackItems
zeroPad = '%0'..string.len(subsCount)..'d'

-- Add combo box options for track choice
trackCount = timeline:GetTrackCount('subtitle')
for track = 0, trackCount-1 do itm.SearchTrack:AddItem('ST '..track+1) end

-- Add combo box items for search choice
itm.SearchType:AddItem('Contains')
itm.SearchType:AddItem('Exact')
itm.SearchType:AddItem('Starts With')
itm.SearchType:AddItem('Ends With')

-- Add table header
hdr = itm.Tree:NewItem()
hdr.Text[0] = '#'
hdr.Text[1] = 'Subtitle'
itm.Tree:SetHeaderItem(hdr)

-- Setup column widths
itm.Tree.ColumnCount = 2
itm.Tree.ColumnWidth[0] = 58
itm.Tree.ColumnWidth[1] = 290

-- Define function to add rows
function populateTable(hide)
    for row = 1, subsCount do
        itRow = itm.Tree:NewItem()
        itRow.Text[0] = string.format(zeroPad, row)
        itRow.Text[1] = trackItems[row]:GetName()
        itRow.Text[2] = tostring(trackItems[row]:GetStart())
        itm.Tree:AddTopLevelItem(itRow)
        if (hide and not(itm.SearchText.Text == '')) then itRow:SetHidden(true) end
    end
end

-- Add rows (all visible)
populateTable(0)

-- Apply default sort
itm.Tree:SortItems(0,'AscendingOrder')

-- Move timeline playhead
function subvigator.On.Tree.ItemClicked(ev)
    frameval = ev.item.Text[2]
    print('frameval '..frameval)
    secs = frameval/framerate
    print('frame val in secs '..secs)
    hours   = math.floor(secs / 3600) % 24
    print('hours '..hours)
    minutes = math.floor(secs / 60) % 60
    print('minutes '..minutes)
    seconds = secs % 60
    print('seconds '..seconds)
    frames = frameval % framerate
    print('frames '..frames)
    timecode = string.format('%02d', hours)..':'..string.format('%02d', minutes)..':'..string.format('%02d', seconds)..':'..string.format('%02d', frames)
    print('timecode '..timecode)
    timeline:SetCurrentTimecode(timecode)
end

-- Filter for search text
function subvigator.On.SearchText.TextChanged(ev)
    mySearchText = itm.SearchText.Text
    hits = itm.Tree:FindItems(mySearchText, matchType, 1)
    if (mySearchText == '') then for row = 0, subsCount-1 do itm.Tree:TopLevelItem(row):SetHidden(false) end
    else
        for row = 0, subsCount-1 do itm.Tree:TopLevelItem(row):SetHidden(true) end
        for showRow = 0, #hits-1 do row = hits[showRow+1].Text[0]; itm.Tree:TopLevelItem(row-1):SetHidden(false) end
    end
end

-- Change search type
function subvigator.On.SearchType.CurrentIndexChanged(ev)
    if itm.SearchType.CurrentIndex == 0 then matchType = {MatchContains = true }
    elseif itm.SearchType.CurrentIndex == 1 then matchType = {MatchExactly = true }
    elseif itm.SearchType.CurrentIndex == 2 then matchType = {MatchStartsWith = true }
    elseif itm.SearchType.CurrentIndex == 3 then matchType = {MatchEndsWith = true } end
    subvigator.On.SearchText.TextChanged()
end

-- Change search track
function subvigator.On.SearchTrack.Activated(ev)
    subTrack = itm.SearchTrack.CurrentIndex +1
    if (not(subTrack == lastTrack)) then lastTrack = subTrack; subvigator.On.refreshBtn.Clicked() end
end

-- Refresh table
function subvigator.On.refreshBtn.Clicked(ev)
    project = projectManager:GetCurrentProject()
    timeline = project:GetCurrentTimeline()
    framerate = timeline:GetSetting('timelineFrameRate')
    trackCount = timeline:GetTrackCount('subtitle')
    trackItems = timeline:GetItemListInTrack('subtitle', subTrack)
    subsCount = #trackItems
    zeroPad = '%0'..string.len(subsCount)..'d'
    
    itm.SearchTrack:Clear()
    for track = 0, trackCount-1 do itm.SearchTrack:AddItem('ST '..track+1) end

    -- Remove all rows and repopulate table
	itm.Tree:Clear()
    populateTable(1)
    
    -- Apply default sort
    itm.Tree:SortItems(0,'AscendingOrder')
    itm.SearchTrack.CurrentIndex = lastTrack-1

    -- Filter for search text
    mySearchText = itm.SearchText.Text
    hits = itm.Tree:FindItems(mySearchText, matchType, 1)
    if (not(itm.SearchText.Text == '')) then
        for showRow = 0, #hits-1 do row = hits[showRow+1].Text[0]; itm.Tree:TopLevelItem(row-1):SetHidden(false) end
    end
end

-- The window was closed
function subvigator.On.MyWin.Close(ev) disp:ExitLoop() end

subvigator:Show()
disp:RunLoop()
subvigator:Hide()
