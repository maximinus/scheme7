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
	print sorted(parray.iteritems())

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
	array = makeArray(data['tilesets'])
	physics = getObjects(data)
	exportLevel(physics)
	
def grabData(data):
	'Just grab the data we need'
	converted = {}
	# one layer, and we just want to grab the grid
	converted['grid'] = data['layers'][0]['data']
	# now grab the data from the tileset offsets
	width = data['tilewidth']
	height = data['tileheight']
	converted['width'] = data['width']
	converted['height'] = data['height']
	tilesets = []
	for i in data['tilesets']:
		tilesets.append({'width':i['tilewidth']//width, 'height':i['tileheight']//height, 'firstgid':i['firstgid']})
	converted['tilesets'] = tilesets
	return(converted)

def getObjects(level):
	pass

def exportLevel(data):
	print(data)

if __name__ == '__main__':
	# make sure we have an input file
	if(len(sys.argv) > 2):
		showError('Too many arguments')
	elif(len(sys.argv) == 1):
		showError('No json file given')
	dict_data = loadData(sys.argv[1])
	new_dict = convertLevel(dict_data)


