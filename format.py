#!/usr/bin/env python3
# 

from dataclasses import dataclass
from operator import attrgetter
import datetime
import os
import pathlib
import sys

@dataclass
class Sample:
    ext: str
    timestamp: datetime.datetime
    content: bytes

output_sub_dirs = ['position', 'position_new', 'image_map', 'pointcloud', 'internal_state']
input_sub_dirs = ['position', 'position_new', 'image', 'map', 'internal_state']

def compute_to_migrate(input_directory):
    to_migrate = {d: [] for d in input_sub_dirs}
    for d in input_sub_dirs:
        path = pathlib.Path(input_directory, d)
        assert path.exists()
        for file in path.glob("*"):
            with open(file, 'rb') as f:
                content = f.read()
            if len(content) == 0:
                continue

            timestamp, extention = str(os.path.basename(file)).split('.')
            
            sample = Sample(ext=extention, timestamp=datetime.datetime.fromisoformat(timestamp), content=content)
            to_migrate[d].append(sample)
        to_migrate[d] = sorted(to_migrate[d], key=attrgetter('timestamp'))
    return to_migrate

def dedupe(to_migrate):
    content_to_map = {map.content: map for map in to_migrate['map']}
    to_migrate['map'] = [map for _, map in content_to_map.items()]

    new_to_migrate = {d: [] for d in input_sub_dirs}
    for position in to_migrate['position']:
        position_new = find(to_migrate['position_new'], position)            
        image = find(to_migrate['image'], position)            
        map = find(to_migrate['map'], position)            
        internal_state = find(to_migrate['internal_state'], position)            
        if position_new and image and map and internal_state:
            new_to_migrate['position_new'].append(position_new)
            new_to_migrate['position'].append(position)
            new_to_migrate['image'].append(image)
            new_to_migrate['map'].append(map)
            new_to_migrate['internal_state'].append(internal_state)

    return new_to_migrate

def save(output_directory, to_migrate):
    for i, position in enumerate(to_migrate['position']):
        position_new = find(to_migrate['position_new'], position)
        image = find(to_migrate['image'], position)            
        map = find(to_migrate['map'], position)            
        internal_state = find(to_migrate['internal_state'], position)            
        if position_new and image and map and internal_state:
            write(output_directory, 'position_new', f"position_{i}.{position_new.ext}", position_new.content)
            write(output_directory, 'position', f"position_{i}.{position.ext}", position.content)
            write(output_directory, 'image_map', f"image_map_{i}.{image.ext}", image.content)
            write(output_directory, 'pointcloud', f"pointcloud_{i}.{map.ext}", map.content)
            write(output_directory, 'internal_state', f"internal_state_{i}.{internal_state.ext}", internal_state.content)

def main():
    if len(sys.argv) != 3:
        print("usage ./format.py input_sample_directory output_sample_directory")
        return
    input_directory = sys.argv[1]
    output_directory = sys.argv[2]
    to_migrate = dedupe(compute_to_migrate(input_directory))


    for d in output_sub_dirs:
        os.makedirs(pathlib.Path(output_directory, d), exist_ok=True)

    save(output_directory, to_migrate)

            
        
def find(l, sample):
    for s in l:
        if s.timestamp == sample.timestamp:
            return s
def write(output_directory, sub_directory, filename, content):
    with open(pathlib.Path(output_directory, sub_directory, filename), "wb") as f:
        f.write(content)
    
if __name__ == '__main__':
    main()

