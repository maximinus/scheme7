import sys
import json
import pygame

# example of loading data from an svg file
# TODO: Handle polygons
#       Save as filled in image
#       Export as correct objects for Phaser


class Point:
    def __init__(self, x, y):
        self.x = x
        self.y = y

    def __eq__(self, other):
        if self.x == other.x and self.y == other.y:
            return True
        return False

    @property
    def as_tuple(self):
        return (self.x, self.y)


class Path:
    def __init__(self, points, x, y):
        # convert
        self.points = []
        for i in points:
            xpos = i['x'] + x
            ypos = i['y'] + y
            self.points.append(Point(xpos, ypos))

    def extend(self, map_data):
        self.points.append(Point(map_data.width, map_data.height))
        self.points.append(Point(0, map_data.height))

    @property
    def width(self):
        return max([x.x for x in self.points])

    @property
    def height(self):
        return max([x.x for x in self.points])

    @property
    def closed(self):
        if len(self.point) == 0:
            return False
        # loop of 1 elements is always closed
        return self.points[0] == self.points[-1]

    def __repr__(self):
        point_string = ['[{0},{1}]'.format(x.x, x.y) for x in self.points]
        return '->'.join(point_string)


class GameMap:
    def __init__(self, data, filename, poly):
        try:
            self.width = data['width'] * data['tilewidth']
            self.height = data['height'] * data['tileheight']
            self.name = filename.split('.')[0]
            self.poly = poly
            self.poly.extend(self)
        except Exception as e:
            die(e)

    @property
    def map_size(self):
        # return map size as a tuple
        return (self.width, self.height)


def die(message='Unknown'):
    """Helper function to print error and quit"""
    print('  Error: {0}'.format(message))
    sys.exit(False)


def loadJson(filename):
    json_text = open(filename).read()
    json_data = json.loads(json_text)
    return json_data


def getPaths(json_data):
    try:
        for i in json_data['layers']:
            if i['name'] == 'Polygons':
                return i['objects']
    except Exception as e:
        die(e)


def convertPolyline(path_data):
    # ignore if there is no polyline for now
    for i in path_data:
        if 'polyline' in i:
            return Path(i['polyline'], i['x'], i['y'])


def drawPaths(game_map):
    pygame.init()
    screen = pygame.display.set_mode(game_map.map_size)
    # now draw to the screen
    screen.fill((0, 0, 0))
    # start at point 1, continue
    start = game_map.poly.points[0]
    for i in game_map.poly.points[1:]:
        pygame.draw.line(screen, (255, 255, 255), start.as_tuple, i.as_tuple)
        start = i
    pygame.draw.line(screen, (255, 255, 255),
                     game_map.poly.points[-1].as_tuple,
                     game_map.poly.points[0].as_tuple)
    pygame.display.flip()
    while True:
        for event in pygame.event.get():
            # listening for the the X button at the top
            if event.type == pygame.QUIT:
                return
    pygame.quit()


if __name__ == '__main__':
    if len(sys.argv) != 2:
        die('Needs 1 param - the name of the file')
    data = loadJson(sys.argv[1])
    paths = getPaths(data)
    poly = convertPolyline(paths)
    map_data = GameMap(data, sys.argv[1], poly)
    drawPaths(map_data)
