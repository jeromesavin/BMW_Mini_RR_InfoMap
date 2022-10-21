#!/bin/bash
# Created by jerome.savin_@_gmail.com
# This script parses Map infomations and help to create new entry in Lookup.xml used for FSC generators
# 20221020 - Initial version


# Example
# ./MapInfo.sh -v -d "./Europe EVO 2022-1"
 


# Set variables
INFO_MAP_FILENAME="Info_Map.imp"
VERBOSE=""
GENERATEXML=""
MAP_FOLDER=""
ZIP_FILE=""
ARCHIVE_FILE="" 
DEFAULT=""

# Functions declaration

function parseInfoMapFile()  {
    if [ "${VERBOSE}" == "1" ] ; then echo -e "Parsing file...\c"; fi
    export MAP_NAME=`hexdump -C $INFOMAP_FILE | awk -F"|" '{ print $2 }' | tr -d "\n" | cut -c 21-200`
    export MAP_SWID_FscShort=`hexdump -C $INFOMAP_FILE | sed -e 's/\(.*\)/\U\1/'  | head -1    | awk -F" " '{ print $10$11$12$13}'`
    export MAP_REGION=`hexdump -C $INFOMAP_FILE | sed -e 's/\(.*\)/\U\1/'  | head -1    | awk -F" " '{ print "0x" $11 }'`
    export MAP_YEAR=`hexdump -C $INFOMAP_FILE | sed -e 's/\(.*\)/\U\1/' | head -1    | awk -F" " '{ print "0x" $13 }'`
    if [ "${VERBOSE}" == "1" ] ; then echo -e " [OK]"; fi
}

function showMapInfos() {
    echo -e " "
    tput bold; echo -e "===================== Map Informations ========================="; tput sgr0
    echo -e "MapName : \"${MAP_NAME}\""
    echo -e "SWID_FscShort: \"${MAP_SWID_FscShort}\""
    echo -e "MapRegion : \"${MAP_REGION}\""
    echo -e "MapYear : \"${MAP_YEAR}\""
    tput bold; echo -e "================================================================"; tput sgr0
    echo -e " "
}

function showLookupXMLEntry() {

    LONG_MAP_NAME="${MAP_NAME} (SWID_FscShort=${MAP_SWID_FscShort}, MapRegion=${MAP_REGION}, MapYear=${MAP_YEAR})"
    tput bold; echo -e "===================== XML Generation ==========================="; tput sgr0
    tput bold; echo -e "Add this entry at the end of the maps list of your Lookup.xml file :"; tput sgr0
    echo -e "
<-- From the line below -->

    <SgbmId id=\"NAVD_000024A8_255_007_034\" SWID_FscShort=\"${MAP_SWID_FscShort}\" name=\"${MAP_NAME} (SWID_FscShort=${MAP_SWID_FscShort}, MapRegion=${MAP_REGION}, MapYear=${MAP_YEAR})\" supplier=\"NTQ\" sop=\"01.05.2021\" version=\"10_09\" MapOrderNumberBMW=\"\" MapOrderNumberMINI=\"\" MapOrderNumberRR=\"\" successorMapOrderNumberBMW=\"\" successorMapOrderNumberMINI=\"\" successorMapOrderNumberRR=\"\" NextNo=\"01826\">
        <EcuVariant CompatibilityIdentifier=\"NBTevo-HB\" Format=\"CIC\" />
        <SwUpdate SwUpdateEntry=\"\"/>
    </SgbmId>

<-- To the upper line --> "
    echo -e " "
    tput bold;
     echo -e "You will find a new map called ${LONG_MAP_NAME} in other tools ;-)";
    echo -e "As is you will have all informations in one place."
    tput sgr0
    tput bold; echo -e "================================================================"; tput sgr0
}


# NoteBook
#➜  Mini Nav Maps 2022 ARGUMENT_TYPE=`file 'NBTEvo SA609 NBTEVO Europe 2021-3.tar' | awk -F':' '{ print $2}' | sed 's/ //g'` ; echo $ARGUMENT_TYPE 
# POSIXtararchive
# ➜  Mini Nav Maps 2022 ARGUMENT_TYPE=`file 'Road_Map_Europe_EVO_2022-2-BU.zip' | awk -F':' '{ print $2}' | sed 's/ //g'`; echo $ARGUMENT_TYPE  
# Ziparchivedata,atleastv2.0toextract,compressionmethod=store
# ➜  Mini Nav Maps 2022 ARGUMENT_TYPE=`file 'Europe EVO 2022-1.7z' | awk -F':' '{ print $2}' | sed 's/ //g'` ; echo $ARGUMENT_TYPE              
# 7-ziparchivedata,version0.4
# ➜  Mini Nav Maps 2022

# To determine if we have to process archive file (tar/zip/7Z) or a directory containing an extract map archive


function processArchiveFile () {
    if [ "${ARCHIVE_FILE}" != "" ]
    then
        if [ -f "${ARCHIVE_FILE}" ]
        then
            if [ "${VERBOSE}" == "1" ] ; then echo -e "File archive exists"; fi
            PATH_TO_INFOMAP_FILE=`7z l "${ARCHIVE_FILE}" | grep "${INFO_MAP_FILENAME}" | grep -v "LIGHT" | awk '{print $NF}'`
            if [ "${VERBOSE}" == "1" ]
            then
                echo -e "Archive content ..."
                7z l "${ARCHIVE_FILE}"    
            fi
            if [ "${VERBOSE}" == "1" ] ; then echo -e "Looking for ${INFO_MAP_FILENAME} file into archive... [OK] - ${PATH_TO_INFOMAP_FILE}"; fi
            
            # Get filename extension
            filename=$(basename -- "${ARCHIVE_FILE}") ; extension="${filename##*.}" ; filename="${filename%.*}"
            if [ "${VERBOSE}" == "1" ] ; then echo -e "Archive extension is : $extension"; echo -e "OS says : `file ${ARCHIVE_FILE}`"; fi
            
            # Switch case
            if [ "${extension}" == "7z" ] || [ "${extension}" == "7Z" ]
            then
                # Case of 7zip archive. It will be long to parse the archive
                # Extract Info_Map.imp file from archive
                echo -e "Please note that only one file will be extracted from archive, so do not worry about spacedisk."
                echo -e " "
                tput bold; echo -e "Please wait a little bit ((i.e. 2 or 3 minutes) while we are looking for the file in a 7zip archive (mins.) ! "; tput sgr0
                7z -y e "${ARCHIVE_FILE}" -o"/tmp" ${PATH_TO_INFOMAP_FILE}
            else
                # Case of other extensions (.zip / .ZIP / .tar)
                7z -y e "${ARCHIVE_FILE}" -o"/tmp" ${PATH_TO_INFOMAP_FILE} > /dev/null
            fi

            # Verifying presence of Info_Map.imp file on disk
            if [ "${VERBOSE}" == "1" ] ; then echo -e "Verifying presence of Info_Map.imp file on disk"; fi
            if [ -f "/tmp/${INFO_MAP_FILENAME}" ]
            then
                if [ "${VERBOSE}" == "1" ] ; then echo -e "`ls -l /tmp/${INFO_MAP_FILENAME}`"; fi
                INFOMAP_FILE="/tmp/${INFO_MAP_FILENAME}"
            else
                echo -e "ERROR : ${INFO_MAP_FILENAME} file not extracted in /tmp"
                exit 2;
            fi
        else
            echo -e "ERROR : ${ARCHIVE_FILE} file dos not exists"
            exit 2
        fi
        echo "Function processArchiveFile called but variable ARCHIVE_FILE is missing"
        exit 99 # Internal error (i.e. BUG)
    fi    
}


function setWorkDir () {
    if [ -d "${MAP_FOLDER}" ]
    then
        cd "${MAP_FOLDER}";
        if [ "${VERBOSE}" == "1" ] ; then echo -e "Using Map folder: ${MAP_FOLDER} ... [OK]"; fi
    else
        echo -e "ERROR the given folder in argument doesn't exists"
        exit 2
    fi    
}

function processFolder() {
    if [ "${VERBOSE}" == "1" ] ; then echo -e "Processing in folder ${MAP_FOLDER} ..." ; fi
    
    # Looking where we are, map folder or not (it should contain a subfolder named "1" ?
    if [ -d ./1 ]
    then
        export MAP_DIR=`echo -e $PWD`
        if [ "${VERBOSE}" == "1" ] ; then echo -e "We are inside Map folder: ${MAP_FOLDER} ... [OK]"; fi
        
        # Looking for InfoMap.imp file in the subfolder ./1/INFOxxxxx not containing "LIGHT" string
        if [ "${VERBOSE}" == "1" ] ; then echo -e "Looking for InfoMap file (${INFO_MAP_FILENAME})\c" ; fi
        ls 1/INFO*/${INFO_MAP_FILENAME} | grep -v "LIGHT" >/dev/null && export INFOMAP_FILE=`ls 1/INFO*/Info_Map.imp | grep -v "LIGHT"`
        if [ $? -ne 0 ]
        then
            ERROR="Cannot find ${INFO_MAP_FILENAME} file in folder(s) 1/INFO*"
            echo -e "\n ${ERROR}\n"; exit 2
        fi
    else
        echo -e " "
        tput bold;
        echo -e "---------------------------------- [ERROR] -----------------------------------------------";
        echo -e "We are not in a map folder (or try to delete spaces/special caracters in folder name/path)"; 
        echo -e " "
        tput sgr0
        exit 2
    fi
}

############# Program starts from here #############

# Arguments parsing

POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
    case $1 in
    -u|--usage|-h|--help)
        echo "Usage: InfoMap.sh [OPTIONS]"
        echo "Extract hex informations from downloaded BMW / Mini / RR Maps"
        echo "v.0.1"
        echo " "
        echo "Default is the current directory (the one containing \"1\" subfolder)"
        echo "  [-xml | --generateXML]                      Generate XML entry to add to Lookup.xml according to this map informations"
        echo "  [-d | --directory <dir path>]               Path to unzipped map folder. If you want to batch/iterate on different folders"
        echo "  [-z | --zipfile <file path> ]               Path to zip archive map file"
        echo "  [-7z | --7ZFile <file path>]                Path to 7zip archive map file"
        echo "  [-rar| --RARFile <file path>]               Path to RAR archive map file"
        echo "  [-v | --verbose]                            With more output is case of debugging. Otherwise output is minimalist for batch running with multiple map folders/archives)"
        echo "  [-u | --usage]                              Display this message"
        echo "  [-h | --help]                               Display this message"
        echo " "
        echo "Submit bugs to https://github.com/jeromesavin/BMW_Mini_RR_InfoMap.sh/"
        exit 0
        ;;
    -d|--directory)
        MAP_FOLDER="$2"
        shift # past argument
        shift # past value
        ;;
    -v|--verbose)
        VERBOSE="1"
        shift # past value
        ;;
    -z|--ZipFile|-7z|--7ZFile|-rar|--RARFile)
        ARCHIVE_FILE="$2"
        shift # past argument
        shift # past value
        ;;
    -xml|--generateXML)
        GENERATEXML="1"
        shift # past value
        ;;
    
    --default)
        # Note that is UNUSED
        DEFAULT=YES
        shift # past argument
        ;;
    -*|--*)
        echo "Unknown option $1"
        exit 1
        ;;
    *)
        POSITIONAL_ARGS+=("$1") # save positional arg
        shift # past argument
        ;;
    esac
done
set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

# End of argument management 

# Usefull for argument debugging
if [ "${VERBOSE}" == "1" ] ; then
    echo -e " "
    tput bold; echo -e "-----------------------------------------"; tput sgr0
    tput bold; echo -e "Arguments parsed :"; tput sgr0
    echo -e "   VERBOSE       = ${VERBOSE}"
    echo -e "   MAP_FOLDER    = ${MAP_FOLDER}"
    echo -e "   ARCHIVE_FILE  = ${ARCHIVE_FILE}"
    echo -e "   GENERATEXML   = ${GENERATEXML}"
    echo -e "   DEFAULT       = ${DEFAULT}--UNUSED--"
    tput bold;  echo -e "-----------------------------------------"; tput sgr0
fi


# Sets the working directory
if [ "${MAP_FOLDER}" != "" ]
then
    if [ "${VERBOSE}" == "1" ] ; then echo -e "Switching to directory ${MAP_FOLDER}"; fi
    setWorkDir ${MAP_FOLDER};
    # Process the folder in order to fin the Info_Map.imp file
    processFolder ${MAP_FOLDER}
else
    if [ "${ARCHIVE_FILE}" != "" ]
    then
        if [ "${VERBOSE}" == "1" ] ; then echo -e "Looking into archive file ${ARCHIVE_FILE}"; fi
        # Process the archive in order to find Info_Map.imp file 
        processArchiveFile
    else
        if [ "${VERBOSE}" == "1" ] ; then echo -e "Switching local directory as map folder (ie. as you pass -d `pwd`)"; fi
        # Set forking directory to self-directory
        MAP_FOLDER="."
        # Process the folder in order to fin the Info_Map.imp file
        processFolder ${MAP_FOLDER}
    fi
fi


# InfoMap.imp file found
if [ "${VERBOSE}" == "1" ] ; then echo -e " ${INFOMAP_FILE} - [OK]"; fi
# Parsing InfoMap file
parseInfoMapFile $INFOMAP_FILE

# Display map informations
if [ "${SHOWMAP_INFOS}" == "1" ] ; then showMapInfos; fi
showMapInfos

# generate XML entry to add in Lookup.xml ?
if [ "${GENERATEXML}" == "1" ] ; then showLookupXMLEntry; fi
    
