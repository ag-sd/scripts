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

<####
    Processes the keys into a collection
####>
function split-and-process($metakeys) {
    $keys = @()
    forEach($metaKey in $metaKeys) {
        $metaKey = $metaKey.Trim()
        if($metaKey.Length -ge 4) {
            $keys += $metaKey
        }
    }

    $keys
}

<####
    Splits the file name by space to look for keywords
####>
function find-word-keys($sanitizedFileName) {
    $keys = $sanitizedFileName.split(' -_')
    split-and-process $keys
}

<####
    Splits the file name by - to look for keywords
####>
function find-path-keys($sanitizedFileName) {
    $keys = $sanitizedFileName -Split '-'
    split-and-process $keys
}

<####
    Splits the file name by brackets to look for keywords
####>
function find-meta-keys($sanitizedFileName) {
    $keys = @()
    $metaKeys = [Regex]::Matches($sanitizedFileName, '(?<=[\[\{\(])(.*?)(?=[\)\}\]])')
    forEach($metaKey in $metaKeys) {
        $metaKey = $metaKey.Value.Trim()
        $keys += $metaKey
    }
    $keys
}

<####
    Finds all the exif meta data in the file
####>
function find-exif-keys($file) {
    #Read all tags
    #-s2 or -s -s     - no extra spaces to column-align values
    $tags = &$EXIF_TOOL -s2 $file

    #Filter the tags we care about
    $tags = $tags -match $EXIF_TAGS_INCLUDE
    $tags = $tags -notmatch $EXIF_TAGS_EXCLUDE
    split-and-process $tags
}

<####
    Create keys for file
####>
function create-keys-for-file($file) {
    Write-Host 'Processing...', $file.FullName -ForegroundColor Cyan

    $set = New-Object System.Collections.Generic.HashSet[String]
    $extension = $file.Extension
    $name = $file.Name.Replace($extension, '')

    $tmp=''

    find-word-keys $name          | ForEach-Object{ $tmp = $set.Add($_) }
    find-meta-keys $name          | ForEach-Object{ $tmp = $set.Add($_) }
    find-path-keys $name          | ForEach-Object{ $tmp = $set.Add($_) }
    find-exif-keys $file.FullName | ForEach-Object{ $tmp = $set.Add($_) }

    $tmp = $set.Add('Name: '          + $file.Name)
    $tmp = $set.Add('Length: '        + $file.Length)
    $tmp = $set.Add('DirectoryName: ' + $file.DirectoryName)
    $tmp = $set.Add('FullName: '      + $file.FullName)
    $tmp = $set.Add('Extension: '     + $file.Extension)
    $tmp = $set.Add('CreationTime: '  + $file.CreationTime)
    $tmp = $set.Add('Attributes: '    + $file.Attributes)
    
    $set
}

<####
    Create keys for path
####>
function create-keys-for-path($path) {
    #Find all files in the path
    $files = Get-ChildItem -Path $path -Recurse -File
    foreach($file in $files) {
        $keys = create-keys-for-file $file
        ConvertTo-Json $keys
    }
}


#$f = Get-Item 'D:\powershell\metaX\test\file.flac'
#create-keys-for-file $f

create-keys-for-path 'H:\test' 
