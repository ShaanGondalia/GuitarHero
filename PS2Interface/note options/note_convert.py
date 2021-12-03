import sys

# python script takes in hex input and converts to notes
# A   B   C   D   E   F
# 10  11  12  13  14  15

# convert string hex to int decimal
def hex_to_int(n):
    return int(n, 16)

print(sys.argv[1])
input_txt = sys.argv[1]
list_of_int = map(hex_to_int, list(input_txt))
print(list_of_int)

indices = [0, 0, 0, 0]
for i in range(len(list_of_int)):
    binary_list = list(format(list_of_int[i], "04b"))
    # print(binary_list)
    for j in range(len(binary_list)):
        if(binary_list[j] == '1'):
            out = "NOTE_POS" + str(j + 1) + "[" + str(indices[j]) + "] = " + str(i * -100) + ";"
            indices[j] = indices[j] + 1
            print(out)
