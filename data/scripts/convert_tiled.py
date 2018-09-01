#!/usr/bin/env python

import os
import sys
import json

# convert a tiled map into a better format
# since we touch up the images ourselves, we need to simply extract the physics objects for now

# here's the names and the data

TILE_DATA = ['bl_small.png',
             'tr_long.png',
             'tr_small.png',
             'tr_tall.png',
             'bl_tall.png',
             'br_long.png',
             'br_small.png',
             'br_tall.png',
             'solid.png',
             'tl_long.png',
             'tl_small.png',
             'tl_tall.png']


def displayError(message):
    print(message)
    sys.exit(False)


def loadJson(filename):
    try:
        json_text = open(filename, 'r').read()
        json_data = json.loads(json_text)
        return json_data
    except Exception as e:
        displayError('  Error: Could not load: {0}'.format(e))


def getData(filename):
    # load as json
    json_text = open(filename, 'r').read()
    json_data = json.loads(json_text)
    # ensure all the data is there
    data_vars = ['width', 'height', 'layers']
    for i in data_vars:
        if i not in json_data:
            displayError('  Error: Missing data section {0}'.format(i))
    # does layers have one called 'rock'
    try:
        names = [x['name'] for x in json_data['layers']]
        if 'rock' not in names:
            displayError('  Error: No rock layer')
    except Exception as e:
        displayError('  Error: Cannot read json data: {0}'.format(e))
    # data seems ok this end
    return json_data


def convertMap(filename):
    data = getData(filename)
    width = data['width']
    height = data['height']
    # so we need to find the right layer. It is called 'rock'
    for layer in data['layers']:
        if layer['name'] == 'rock':
            rock_layer = layer['data']
            break
    # iterate over this
    index = 0
    for x in range(width):
        for y in range(height):
            if rock_layer[index] != 0:
                print('Got {0} at [{1},{2}]'.format(rock_layer[index], x, y))
            index += 1


if __name__ == '__main__':
    # must have 1 argument
    if len(sys.argv) < 2:
        displayError('  Error: No file name supplied')
    filename = sys.argv[1]
    if not os.path.exists(filename):
        displayError('  Error: No such file {0}'.format(filename))
    # is a json file?
    if not filename.endswith('json'):
        displayError('  Error: {0} is not a json file'.format(filename))
    # now we can convert the map
    convertMap(filename)
