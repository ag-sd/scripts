import os

import feedparser

__IMAGE_PATH__ = "imageset2/"

__IMAGE_DICT__ = {
    "clearsky": "33.png",  # night
    "drizzle": "12.png",
    "fog": "11.png",
    "greycloud": "38.png",
    "hailshower": "26.png",
    "hazy": "11.png",
    "heavyrain": "18.png",
    "heavysnow": "22.png",
    "lightcloud": "36.png",
    "lightrain": "12.png",
    "lightsnow": "19.png",
    "mist": "11.png",
    "partlycloudy": "35.png",  # night
    "sandstorm": "1.png",
    "sleet": "26.png",
    "sunnyinterval": "3.png",
    "sunny": "1.png",
    "thickcloud": "6.png",
    "thunderstorm": "15.png",
    "thunderyshower": "16.png",
    "whitecloud": "7.png",
    "unknown": "CLM.png"
}


def lookup_image(key):

    image_key = key.split(":")[1].strip().replace(" ", "").lower()
    for item in __IMAGE_DICT__:
        if image_key.startswith(item):
            return os.path.join(__IMAGE_PATH__, __IMAGE_DICT__[item])
        # else:
        #     print(f"MATCH ERR {image_key} -> {item}")
    return os.path.join(__IMAGE_PATH__, __IMAGE_DICT__["unknown"])



def extract_data(entry, prefix, current=False):
    _title = entry.title.split(",")[0]
    data = {
                prefix + "TIT": _title,
                prefix + "IMG": lookup_image(_title)
           }
    kvps = entry.description.split(",")
    for kvp in kvps:
        tokens = kvp.split(":")
        key = tokens[0].strip()
        value = ":".join(tokens[1:]).strip()
        if key == "Minimum Temperature":
            data[prefix + "MIN"] = value
        if key == "Maximum Temperature":
            data[prefix + "MAX"] = value
        elif key == "Humidity":
            data[prefix + "HUM"] = value
        elif key == "Wind Direction":
            data[prefix + "WDR"] = value
        elif key == "Wind Speed":
            data[prefix + "WSP"] = value
        elif key == "Visibility":
            data[prefix + "VIS"] = value
        elif key == "Pressure":
            data[prefix + "PRE"] = value
        elif key == "Sunset":
            data[prefix + "SST"] = value
        elif key == "Sunrise":
            data[prefix + "SRE"] = value
    return data


def print_future(_dict, index):
    y_offset = (index * 55) + 165
    print("${hr 1}")
    print("${offset 60}${font Open Sans:bold:size=8.5}" + _dict['TIT'] + "${image " + _dict['IMG'] + " -p 10,"
          + str(y_offset) + "-s 36x36}")
    print(
        "${offset 60}${font Open Sans:size=8.5}↑" + _dict['MIN'].split(" ")[0] + " ↓" + _dict['MAX'].split(" ")[
            0] + "${alignr}Humidity " + _dict['HUM'])
    print("${offset 60}${font Open Sans:size=8.5}Sun(rise/set)${alignr}" + _dict['SRE'] + " / " + _dict['SST'])


# Prints out the weather in a way conky understands

__AREA_CODE__ = 5128581
bbc_feed = feedparser.parse(f"https://weather-broker-cdn.api.bbci.co.uk/en/forecast/rss/3day/{__AREA_CODE__}")
title = bbc_feed.feed.title.replace("BBC Weather - Forecast for  ", "")
today = extract_data(bbc_feed.entries[0], "", current=True)
tomorrow = extract_data(bbc_feed.entries[1], "")
day_after = extract_data(bbc_feed.entries[2], "")

print("${font Open Sans:Bold:size=10}${color0}" + bbc_feed.feed.title.replace("BBC Weather - Forecast for", "").strip() +" ${color EC0100}${hr 2}$color")
print("${font Roboto:size=60}${alignr}" + today['MIN'].split(" ")[0] + "${image " + today['IMG'] + " -p 25,25 -s 80x80}")
print("${voffset -80}${font Open Sans:size=8.5}Wind${offset 20}" + today['WSP'] + " " + today['WDR'] + "${alignr}${offset -20}Humidity 84%")
print("${font Open Sans:size=8.5}Sunset${offset 9}" + today['SST'] + "${alignr}Pressure 1022mb")
print_future(tomorrow, 0)
print_future(day_after, 1)
