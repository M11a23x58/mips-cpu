import sys
import os
def main():
	if (len(sys.argv) < 3):
		print("Use python translate.py [filename] [before/after]!!")
		sys.exit()
	else:
		filename = sys.argv[1]
		memtype = sys.argv[2]
		if(memtype == "before"):
			ReadFile(filename)
			IM("./tmp1.txt")
			DM("./tmp2.txt", "./tb/resourse/data/DM.dat")
		elif(memtype == "after"):
			ReadFile(filename)
			DM("./tmp2.txt", "./tb/resourse/data/golden.dat")
		else:
			print("Wrong")
		print("Done! ")
		os.remove("./tmp1.txt")
		os.remove("./tmp2.txt")
def IM(filename):
	fr = open(filename, "r")
	fw = open("./tb/resourse/data/IM.dat", "w+")

	frls = fr.readlines()
	for line in frls:
		if "[00" in line.split(" ")[0]:
			pc   = line.split(" ")[0]
			inst = line.split(" ")[1]
			fw.write("@"+str(pc[-4:-1])+"\n")
			for i in range(0,7,2):
				fw.write(inst[i:i+2]+" ")
			fw.write("\n")

	fr.close()
	fw.close()

	print("IM.dat generated")

def DM(filename, outputfile):
	fr = open(filename, "r")
	fw = open(outputfile, "w+")	

	frls = fr.readlines()

	cnt = 0
	for line in frls:
		if "[100" in line:
			tmp = line.split("    ")
			if(len(tmp)>2):
				addr = tmp[0]
				data = tmp[1].split("  ")
				fw.write("@"+addr[-4:-1]+"\n")
				cnt = cnt + 1
				for i in range(0,4):
					for j in range(0,7,2):
						fw.write(data[i][j:j+2]+" ")
					fw.write("\n")

	

	for i in range(16*cnt, 1024, 4):
		string = "{:03x}".format(i)
		fw.write("@" +  string + "\n")
		fw.write("00 00 00 00\n")
	fw.close()
	fr.close()
	
	print(outputfile + " generated")


def ReadFile(filename):
	fr = open(filename, "r")
	text = open("tmp1.txt", "w+")
	data = open("tmp2.txt", "w+")

	frls = fr.readlines()
	flag = 0
	for line in frls:
		if "User Text Segment" in line:
			flag = 1
		if "Kernel Text Segment" in line:
			flag = 2
		if "User data segment" in line:
			flag = 3
		if "User Stack" in line:
			flag = 4
		if(flag == 1):
			text.writelines(line)
		if(flag == 3):
			data.writelines(line)
	fr.close()
	text.close()
	data.close()

if __name__ == '__main__':
	main()
