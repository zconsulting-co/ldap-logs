# logs.ps1

Get logs with ID 2889

.\logs.ps1 (nameFile) (begin) (end)

nameFile: outputfile name without .csv extension

.\logs.ps1 (nameFile): logs are obtained from the previous day at 6 AM

.\logs.ps1 (nameFile) all: get all logs

eg:

.\logs.ps1 ad01

.\logs.ps1 ad01 all

## note1

- must be executed on the DC that previously enabled the capture of events 2889

- The file must always be named, for now it only works in the two ways seen above

- don't use output as the output name, the script creates a temporary file with that name and there may be problems

# log-excel.ps1

convert the cvs that was obtained with the previous script to an excel file

.\log-excel.ps1 (inputFile) (outputFile)

inputFile: it is a csv file, the extension should not be placed only the name

outputFile: it is an excel file, the file extension should not be placed

## note2
- must be run on a computer that has excel

- if the Remove-Item -Path $ result_csv line is uncommented in the code, the csv that was given as input will be deleted

# extract-ip-usr.ps1

get client IP from firs csv

.\extract-ip-usr.ps1 -path "\path\to\file" -inputFile "inputfile-without-extension" "outputfile-without-extension"