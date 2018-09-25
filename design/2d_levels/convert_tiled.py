import sys
import json
import pygame

# example of loading data from an svg file
# TODO: Handle ploygons
#       Save as filled in image
#       Get correct height and width
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


def die(message='Unknown'):
    """Helper function to print error and quit"""
    print('  Error: {0}'.format(message))
    sys.exit(False)


def loadPathsFromJson(filename):
    json_text = open(filename).read()
    json_data = json.loads(json_text)
    for i in json_data['layers']:
        if i['name'] == 'Polygons':
            return i['objects']


def convertAllPaths(path_data):
    return [Path(x['polyline'], x['x'], x['y']) for x in path_data]


def drawPaths(paths):
    pygame.init()
    screen = pygame.display.set_mode((800, 800))
    # now draw to the screen
    screen.fill((0, 0, 0))
    for i in paths:
        # start at point 1, continue
        start = i.points[0]
        for j in i.points[1:]:
            pygame.draw.line(screen, (255, 255, 255), start.as_tuple, j.as_tuple)
            start = j
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
    paths = loadPathsFromJson(sys.argv[1])
    paths = convertAllPaths(paths)
    drawPaths(paths)
    print('  * Done')
