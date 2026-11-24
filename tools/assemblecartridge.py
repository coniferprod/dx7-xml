# voice map
voice_map = {
    1: 'learning',
}

data_path = '../data'

filenames = []
for number in range(1, 32+1):
    if number in voice_map:
        filename = f'{data_path}/{voice_map[number]}.xml'
    else:
        filename = f'{data_path}/initvoice.xml'
    filenames.append(filename)
    print(f'{number}: {filename}')

print(filenames)
