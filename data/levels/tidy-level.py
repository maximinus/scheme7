#!/usr/bin/python

import sys,json

# load a json file, throw away the data we don't use and convert to our format

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

def convertLevel(data):
	'Just grab the data we need'
	converted = {}
	# one layer, and we just want to grab the grid
	converted['grid'] = data['layers'][0]['data']
	# now grab the data from the tileset offsets
	width = data['width']
	height = data['height']
	converted['width'] = data['width']
	converted['height'] = data['height']
	tilesets = []
	for i in data['tilesets']:
		tilesets.append({'width':i['tilewidth']//width, 'height':i['tileheight']//height, 'firstgid':i['firstgid']})
	converted['tilesets'] = tilesets
	return(converted)

def saveLevel(data):
	print(data)

if __name__ == '__main__':
	# make sure we have an input file
	if(len(sys.argv) > 2):
		showError('Too many arguments')
	elif(len(sys.argv) == 1):
		showError('No json file given')
	dict_data = loadData(sys.argv[1])
	new_dict = convertLevel(dict_data)
	saveLevel(new_dict)

