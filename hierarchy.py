import csv 

iden = []
clade = []

te = []

#TE name and cladereference
with open('reference.csv') as csvfile:
    readCSV = csv.reader(csvfile, delimiter=',')
    for row in readCSV:
        iden.append(row[0])
        clade.append(row[1:3])
        
#TE annotation file        
with open('annotation.csv') as csvfile:
    readCSV = csv.reader(csvfile, delimiter=',')
    for row in readCSV:
        te.append(row)
        
f = open('te.hier.txt', 'w+')
f.write('id\tfamily\torder\n')
for i in range(0, len(te)-1):
    for j in range(0, len(iden)-1):
        if str(te[i]).find(str(iden[j])) > -1:
            f.write(''.join(te[i]) + '\t' + '\t'.join(clade[j]) + '\n')

f.close() 
