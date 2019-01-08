RhythmConfigHelper = RhythmConfigHelper = {}

local _table_insert = table.insert
local _table_sort = table.sort

function RhythmConfigHelper.GetMusicRhythm(musicId)
    local rhythmList = {}
    for k, v in pairs(RhythmConfig.Rhythm) do
        if v.musicId == musicId then
            _table_insert(rhythmList, v)
        end
    end
    _table_sort(rhythmList, function(a, b)
        return a.time < b.time
    end)
    return rhythmList
end