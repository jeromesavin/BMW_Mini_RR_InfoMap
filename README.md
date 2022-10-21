# Goal of the script

Bored about collecting informations about downloaded maps, I wrote a little script (MacOS/Linux/*nix) to analyse archive and get necessary informations about the map.
Output example

    ===================== Map Informations =========================
    MapName : "Road Map EUROPE EVO 2022-2"
    SWID_FscShort: "00f10066"
    MapRegion : "0xf1"
    MapYear : "0x66"
    ================================================================

You can even generate the XML entry to add at your "Lokkup.xml" file, in order to use FSC generator tools.

Exemple (for the same map) :

    ===================== XML Generation ===========================
    Add this entry at the end of the maps list of your Lookup.xml file :

    <-- From the line below -->

        <SgbmId id="NAVD_000024A8_255_007_034" SWID_FscShort="00f10066" name="Road Map EUROPE EVO 2022-2 (SWID_FscShort=00f10066, MapRegion=0xf1, MapYear=0x66)" supplier="NTQ" sop="01.05.2021" version="10_09" MapOrderNumberBMW="" MapOrderNumberMINI="" MapOrderNumberRR="" successorMapOrderNumberBMW="" successorMapOrderNumberMINI="" successorMapOrderNumberRR="" NextNo="01826">
            <EcuVariant CompatibilityIdentifier="NBTevo-HB" Format="CIC" />
            <SwUpdate SwUpdateEntry=""/>
        </SgbmId>

    <-- To the upper line --> 
     
    You will find a new map called Road Map EUROPE EVO 2022-2 (SWID_FscShort=00f10066, MapRegion=0xf1, MapYear=0x66) in other tools ;-)
    As is you will have all informations in one place.
    ================================================================

# Note(s)

The map name in the XML will be in this case extended with FSCShort, MapRegion and MapYear, in order to find it easily in your tools :

    "Road Map EUROPE EVO 2022-2 (SWID_FscShort=00f10066, MapRegion=0xf1, MapYear=0x66)"

# Usage

    InfoMap.sh [OPTIONS]
    Extract hex informations from downloaded BMW / Mini / RR Maps
    v.0.1
     
    Default is the current directory (the one containing "1" subfolder)
      [-d | --directory <dir_path>]       Path to unzipped map folder. If you want to batch/iterate on different folders
      [-z | --zipfile <file path> ]       Path to zip archive file of the map
      [-7z | --7ZFile <file path>]        Path to 7zip archive map file (It could be long to parse this type of archive)
      [-rar | --RARFile <file path>]      Path to RAR archive map file
      [-v | --verbose]                    With more output is case of debugging.
      [-xml | --generateXML]              Generate XML entry to add to Lookup.xml according to this map informations
      [-u | --usage]                      Display this message
      [-h | --help]                       Display this message

Submit bugs to https://github.com/jeromesavin/BMW_Mini_RR_InfoMap/

So main arguments are :

    - -d|--directory : to process a folder containing an extracted archive map

    - -z|--ZipFile|-7z|--7ZFile|-rar|--RARFile : Script supports archive of type RAR/ZIP/7z (well, all formats supported by 7z binary)

    - -xml|--generateXML : Ability to generate the XML entry for your Lokkup.xml file

    - -v|--verbose : For debugging. In case of difficulties, please provide this kind output !

# Little RoadMap

    - Better error management
    - Self-update mechanism
    - etc.

Tell me if something is missing or not working as expected.
