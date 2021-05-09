import gzip
import sys


if len(sys.argv) != 3:
    print(f"#usage: python {sys.argv[0]} [fq] [result]")
    sys.exit()

fq=sys.argv[1]
result=sys.argv[2]

s = set()

cnt = 0

write_handle = open(result, 'w')

with gzip.open(fq, 'rt') as handle:
    for line in handle:
        line = line.strip()
        if cnt % 4 == 0: # header
            if line not in s:
                s.add(line)
                write_flag = True
            else:
                write_flag = False
        if write_flag:
            write_handle.write(line+"\n")
        cnt += 1

write_handle.close()

