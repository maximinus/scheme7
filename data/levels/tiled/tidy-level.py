#!/usr/bin/python

import sys,json
from tiles import *

# load a json file, throw away the data we don't use and convert to our format

def makeArray(tilesets):
	"""Return an array that matches the index values found the level file"""
	# zero should be ignored as a null file
	parray = {'0':None}
	# now go through the tilesets
	for i in tilesets:
		index = 0
		matched_set = getTilesetMatch(i['width'], i['height'])
		for j in matched_set:
			parray[str(index + i['firstgid'])] = j
			index += 1
	# we should have a set of numbers 0->something, put in an array and return
	return(	[x[1] for x in sorted(parray.iteritems())])

def showError(error_text):
	print 'Error: ' + error_text
	print 'Usage: ./tidy_level filename.json'
	sys.exit()

def loadData(filename):
	"""Load the json file and dump into a dictionary"""
	if(not filename.split('.')[-1] in ['jsn', 'json']):
		showError('File is not a json file')
	level = json.loads(open(filename).read())
	return(level)

def convertLevel(json_data):
	data = grabData(json_data)
	physics = getObjects(data)
	exportLevel(physics)
	
def grabData(data):
	# Just grab the data we need"""
	converted = {}
	# one layer, and we just want to grab the grid
	converted['grid'] = data['layers'][0]['data']
	# now grab the data from the tileset offsets
	# tiles must be squares
	size = data['tilewidth']
	converted['width'] = data['width']
	converted['height'] = data['height']
	tilesets = []
	for i in data['tilesets']:
		tilesets.append({'width':i['tilewidth']//size, 'height':i['tileheight']//size, 'firstgid':i['firstgid']})
	converted['tilesets'] = tilesets
	return(converted)

def getObjects(level):
	array = makeArray(level['tilesets'])
	# we have the indexed array and the real objects, let us now sort through them
	objects = []
	width = level['width']
	for x in range(width):
		for y in range(level['height']):
			index = level['grid'][x + (y * width)]
			if(index != 0):
				# add our xpos and ypos to all points in the array
				objects.append([[pos[0] + x, pos[1] + y] for pos in array[index]])
	return(objects)

def exportLevel(data):
	# we have an array of objects that contain the x/y cords of their points
	# output that to the fike 'leveltest.json'
	foo = open('leveltest.js', 'w')
	foo.write('test_level = ')
	with foo as outfile:
		json.dump(data, outfile, indent=4)

if __name__ == '__main__':
	# make sure we have an input file
	if(len(sys.argv) > 2):
		showError('Too many arguments')
	elif(len(sys.argv) == 1):
		showError('No json file given')
	dict_data = loadData(sys.argv[1])
	new_dict = convertLevel(dict_data)
	print 'Level converted to json at leveltest.js'

