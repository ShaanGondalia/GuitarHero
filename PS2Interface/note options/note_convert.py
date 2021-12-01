import sys

# convert string hex to int decimal
def hex_to_int(n):
    return int(n, 16)

print(sys.argv[1])
input_txt = sys.argv[1]
list_of_int = map(hex_to_int, list(input_txt))
print(list_of_int)

for i in range(len(list_of_int)):
    binary_list = list(format(list_of_int[i], "04b"))
    # print(binary_list)
    for j in range(len(binary_list)):
        if(binary_list[j] == '1'):
            out = "NOTE_POS" + str(j + 1) + "[" + str(i) + "] = " + str(i * -100) + ";"
            print(out)
        if(binary_list[j] == '0'):
            out = "NOTE_POS" + str(j + 1) + "[" + str(i) + "] = 500;"
            print(out)
