with open(r"C:\Users\panna\OneDrive\Desktop\Study\comms pro\Drdo\message_input_newone.dat", 'r') as f:
    res = ''
    for line in f:
        line = line.strip()
        i = len(line)-2
        while i >= 0:
            res += line[i:i+2]
            i -= 2

    print(res)

with open(r"C:\Users\panna\OneDrive\Desktop\Study\comms pro\Drdo\inputMatlab.dat" , 'w') as g:
    g.write(res)