on run 
    set targetFolder to (path to downloads folder) as alias
    set resultRecord to my organizeBatchNoCache(targetFolder)

    display dialog "Baseline run complete." & return & ¬
        "Moved: "& (movedCount of resultRecord) & return & ¬
        "Runtime: " & (elapsedSeconds of resultRecord) & " seconds" buttons {"OK"} default button "OK"
end run

on organizeBaseline(targetFolderAlias)
    set startTime to (current date)
    set movedCount to 0

    tell application "Finder"
        set targetFolder to targetFolderAlias as alias

        --subfolders
        my ensureFolderExists(targetFolder,"Music")
        my ensureFolderExists(targetFolder,"Videos")
        my ensureFolderExists(targetFolder,"Images")
        my ensureFolderExists(targetFolder,"Documents")
        my ensureFolderExists(targetFolder,"Archives")
        
        set allItems to every file of targetFolder
        repeat with oneFile in allItems
            set fileName to (name of oneFile) as text
            set destinationFolderName to my destinationForFile(fileName)
            
            if destinationFolderName is not "" then
                move oneFile to folder destinationFolderName of targetFolder with replacing
                set movedCount to movedCount + 1
                my appendLog("Moved: "& fileName & " -> " & destinationFolderName)
            end if
        end repeat
    end tell
    set elapsedSeconds to ((current date)-startTime)
    my appendLog("BASELINE finished | moved="& movedCount & " | runtime="& elapsedSeconds & "s")
    return {movedCount:movedCount,elapsedSeconds:elapsedSeconds}
end organizeBaseline

on destinationForFile(fileName)
    ignoring case
        if fileName ends with ".jpg" or fileName ends with ".jpeg" or fileName ends with ".png" or fileName ends with ".gif" then
            return "Images"
        else if fileName ends with ".pdf" or fileName ends with ".doc" or fileName ends with ".txt" or fileName ends with ".docx" then
            return "Documents"
        else if fileName ends with ".zip" or fileName ends with ".dmg" or fileName ends with ".pkg" then
            return "Archives"
        else if fileName ends with ".mp4" or fileName ends with ".mov" or fileName ends with ".avi" then
            return "Videos"
        else if fileName ends with ".mp3" or fileName ends with ".wav" or fileName ends with ".aac" then
            return "Music"
        end if
    end ignoring
    return ""
end destinationForFile
on ensureFolderExists(parentFolder, folderName)
    tell application "Finder"
        if not(exists folder folderName of parentFolder) then
            make new folder at parentFolder with properties {name:folderName}
            my appendLog("Created folder:" & folderName)
        end if
    end tell
end ensureFolderExists


on appendLog(logMessage)
    set timestamp to do shell script "date '+%Y-%m-%d %H:%M:%S'"
    set logPath to (POSIX path of (path to desktop folder)) & "OrganizerLog.txt"
    do shell script "printf %s\\\\n " & quoted form of ("[" & timestamp & "] " & logMessage) & " >> " & quoted form of logPath

end appendLog



on organizeBatchNoCache(targetFolderAlias)
    set startTime to (current date)
    set movedCount to 0

    tell application "Finder"
        set targetFolder to targetFolderAlias as alias
                
        my ensureFolderExists(targetFolder,"Music")
        my ensureFolderExists(targetFolder,"Videos")
        my ensureFolderExists(targetFolder,"Images")
        my ensureFolderExists(targetFolder,"Documents")
        my ensureFolderExists(targetFolder,"Archives")

        set movedCount to movedCount + my moveBatch(targetFolder,{"jpg","jpeg","png","gif"},"Images")
        set movedCount to movedCount + my moveBatch(targetFolder,{"pdf","doc","docx","txt"},"Documents")
        set movedCount to movedCount + my moveBatch(targetFolder,{"zip","dmg","pkg"},"Archives")
        set movedCount to movedCount + my moveBatch(targetFolder,{"mp4","mov","avi"},"Videos")
        set movedCount to movedCount + my moveBatch(targetFolder,{"mp3","aac","wav"},"Music")

    end tell
    
    set elapsedSeconds to ((current date) - startTime)
    my appendLog("BATCH finished | moved=" & movedCount & " | runtime=" & elapsedSeconds & "s")
    return {movedCount:movedCount, elapsedSeconds:elapsedSeconds}
end organizeBatchNoCache

on moveBatch(targetFolder, extList, destinationFolderName)
    tell application "Finder"
        set matchedFiles to {}
        repeat with oneExt in extList
            set matchedFiles to matchedFiles & (every file of targetFolder whose name extension is (contents of oneExt))
        end repeat
        set fileCount to count of matchedFiles
        if fileCount > 0 then
            move matchedFiles to folder destinationFolderName of targetFolder with replacing
            my appendLog("Batch moved " & fileCount & " files -> " & destinationFolderName)
        end if
        return fileCount
    end tell
end moveBatch

    

