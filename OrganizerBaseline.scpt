on run 
    set targetFolder to (/Users/bir_65/Downloads)
    my organiizeBaseline(targetFolder)
end run  

on organizeBaseline(targetFolderAlias)
    tell application "Finder"
        set targetFolder to targetFolderAlias as alias

        --subfolders
        my ensureFolderExists(targetFolder,"Audio")
        my ensureFolderExists(targetFolder,"Video")
        my ensureFolderExists(targetFolder,"Images")
        my ensureFolderExists(targetFolder,"Documents")
        my ensureFolderExists(targetFolder,"Archives")
        my ensureFolderExists(targetFolder,"Others")

        set movedCount to 0
        set allItems to every file of targetFolder
        repeat with oneFile in allItems
            set fileName to name of oneFile
            if fileName ends with ".mp3" or fileName ends with ".wav" or fileName ends with ".aac" or fileName ends with ".m4a" or fileName ends with ".flac" or fileName ends with ".alac" or fileName ends with ".ogg" or fileName ends with ".wma" or fileName ends with ".aiff" or fileName ends with ".aif" or fileName ends with ".caf" or fileName ends with ".ac3" or fileName ends with ".dts" then            
                move oneFile to folder "Audio" of targetFolder with replacing
                set moved
        
        
        
        
        
        
        end repeat
    end tell