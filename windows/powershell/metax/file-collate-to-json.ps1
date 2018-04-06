
$EXIF_TOOL = '.\exiftool.exe'
[regex]
$EXIF_TAGS_INCLUDE = '(^Date|MIMEType|SampleRate|Vendor|Title|Artist|Album|Genre|Albumartist|Composer|MPEGAudioVersion
                       |AudioLayer|AudioBitrate|Encoder|Band|Year|JFIFVersion|ImageWidth|ImageHeight|EncodingProcess
                       |BitsPerSample|ColorComponents|YCbCrSubSampling|ImageSize|Megapixels|Make|Model|Orientation
                       |Software|Flash|RatingPercent|Rating|Aperture|GPS|ShutterSpeed|HyperfocalDistance|LightValue|Lens|BitDepth
                       |ColorType|CompressorID|SourceImageWidth|SourceImageHeight|PixelAspectRatio|VideoFrameRate|AudioFormat
                       |AudioChannels|AudioSampleRate|AvgBitrate|BMPVersion|AudioCodecID|IsVBR)'

$EXIF_TAGS_EXCLUDE = '(Zune|PictureMIMEType|DateTimeOriginal|Exif|SourceImage|YCbCrSub|LensSerialNumber|ColorComponents
                       |BitsPerSample|JFIFVersion|PixelAspectRatio|LensManualDistortionAmount|LensProfileSetup
                       |LensProfileEnable|FlashCompensation)'



function get-sanitized-name($file) {
    $extension = $file.Extension
    $name = $file.Name.Replace($extension, '')
    return $name
}

function add-to-dict($dict, $key) {
    $key = $key -replace '()', ''
    $key = $key.Trim()

    if($key -eq '') {
        return $dict
    }

    if($dict.ContainsKey($key)) {
        #Update Count
        $count = $dict[$key] + 1
        $dict[$key] = $count

    } else {
        #Insert New
        $dict[$key] = 1

    }

    return $dict
}

<####
    Splits the file name by space to look for keywords
####>
function find-word-keys($files, $dict) {
    ForEach($file in $files) {
        $name = get-sanitized-name $file
        $metaKeys = $name.split(' -')
        forEach($metaKey in $metaKeys) {
            $metaKey = $metaKey.Trim()
            $dict = add-to-dict $dict $metaKey
        }
    }

    return $dict
}

<####
    Splits the file name by - to look for keywords
####>
function find-path-keys($files, $dict) {
    ForEach($file in $files) {
        $name = get-sanitized-name $file
        $metaKeys = $name -Split '-'
        forEach($metaKey in $metaKeys) {
            $metaKey = $metaKey.Trim()
            $dict = add-to-dict $dict $metaKey
        }
    }

    return $dict
}

<####
    Splits the file name by brackets to look for keywords
####>
function find-meta-keys($files, $dict) {
    ForEach($file in $files) {
        $name = get-sanitized-name $file
        $metaKeys = [Regex]::Matches($name, '(?<=[\[\{\(])(.*?)(?=[\)\}\]])')
        forEach($metaKey in $metaKeys) {
            $metaKey = $metaKey.Value.Trim()
            $dict = add-to-dict $dict $metaKey
        }
    }

    return $dict
}

function find-exif-keys($files, $dict) {

    ForEach($file in $files) {
        Write-Host $file.FullName -ForegroundColor Cyan

        #Read all tags
        #-s2 or -s -s     - no extra spaces to column-align values
        $tags = &$EXIF_TOOL -s2 $file.FullName

        #Filter the tags we care about
        $tags = $tags -match $EXIF_TAGS_INCLUDE
        $tags = $tags -notmatch $EXIF_TAGS_EXCLUDE

        forEach($tag in $tags) {
            $tag = $tag.Trim()
            $dict = add-to-dict $dict $tag
        }
    }

    return $dict
}

function flatten-dictionary($dict) {
    $keysToDelete = @()
    ForEach($key in $dict.Keys.GetEnumerator()) {
        $key = [Regex]::Escape($key)
        $match = '\b'+$key+'\b'
        #Find similar keys
        $otherKeys = $dict.Keys -match $match
        #Remove current key from the list
        $otherKeys = $otherKeys | Where-Object {$_ -ne $key}
        if($otherKeys.Length -gt 0) {
            Write-Host $key, ' Is part of ', $otherKeys -ForegroundColor Green
            $keysToDelete += $key
        }
    }

    ForEach($key in $keysToDelete) {
        $dict.remove($key)
    }

    return $dict
}


function find-all-keys($path) {

    $dict = @{}
    $files = Get-ChildItem -Path $path -Recurse -File

    $dict = find-word-keys $files $dict
    
    $dict = find-path-keys $files $dict

    $dict = find-meta-keys $files $dict

    #$dict = find-exif-keys $files $dict

    flatten-dictionary $dict
    
    $dict = $dict.getenumerator() | 
            sort-object -property value -Descending |
            Where-Object {$_.value -ge 2 -and $_.Key.ToString().Length -ge 4}
    
    $dict
}





<#

    1 Find all files in path
    2 Find key
    3 Group by key
    4 Find all files that are not in a key
    5 half the filename as key repeat 3, 4
    6 half the half the filename as key repeat 3, 4
    7 repeat until key is length 1

#>

find-all-keys "H:\Downloads\Test"
