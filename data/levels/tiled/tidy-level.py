#!/usr/bin/python

import sys,json
from tiles import *

# load a json file, throw away the data we don't use and convert to our format
HEIGHT = 0
WIDTH = 0

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
	# we start by making the array and then running with it
	sorted_list = parray.keys()
	for i in parray.keys():
		sorted_list[int(i)] = parray[i]
	return(sorted_list)

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
	global WIDTH, HEIGHT

	data = grabData(json_data)
	WIDTH = data['width']
	HEIGHT = data['height']
	array = makeArray(data['tilesets'])
	data = reduceObjects(data)
	physics = getObjectsNew(data, array)
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
	for x in range(WIDTH):
		for y in range(HEIGHT):
			index = level['grid'][x + (y * WIDTH)]
			if(index != 0):
				# TODO: Fix this magic number
				if index >= 10:
					# tall objects have the wrong y position
					objects.append([[pos[0] + x, pos[1] + y -1] for pos in array[index]])
				else:
					# add our xpos and ypos to all points in the array
					objects.append([[pos[0] + x, pos[1] + y] for pos in array[index]])
	return(objects)

def getObjectsNew(level, array):
	# we have the indexed array and the real objects, let us now sort through them
	objects = []
	for y, row in enumerate(level):
		for x, index in enumerate(row):
			if(index != []):			
				objects.append([[pos[0] + x, pos[1] + y] for pos in index])
	return(objects)

def reduceObjects(level):
	level = objectsInArray(level)
	# start from the bottom and join all squares
	level.reverse()
	for x in range(WIDTH):
		ypos = 0
		squares = 0
		# count the stack of squares
		while((ypos < HEIGHT) and (len(level[ypos][x]) == 4)):
			squares += 1
			ypos += 1
		# now we know the number of squares, delete all the ones not used
		# that would be xpos = x, ypos for indexes 1 -> (squares - 1)
		for ypos in range(1, squares):
			level[ypos][x] = []
	# put it back the right way and return it
	level.reverse()
	return(level)

def objectsInArray(level):
	points = makeArray(level['tilesets'])
	array = []
	out_of_place = []
	for y in range(HEIGHT):
		row = []
		for x in range(WIDTH):
			index = level['grid'][x + (y * WIDTH)]
			if(index != 0 and index != None):
				# add our xpos and ypos to all points in the array
				if index >= 10:
					# these items are large triangles that need to be moved
					# we will recall these amd insert later
					row.append([])
					out_of_place.append({'x':x, 'y':y - 1, 'p':points[index]})
				else:
					row.append(points[index])
			else:
				# [] represents 0 - an object with no points
				row.append([])
		array.append(row)
	# now we have the array, add back those out of place
	for i in out_of_place:
		array[i['y']][i['x']] = i['p']
	return(array)
				

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

